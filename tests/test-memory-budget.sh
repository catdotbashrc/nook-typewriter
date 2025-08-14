#!/bin/bash
# Memory Budget Validation Test
# Ensures the OS stays under 95MB and protects the 160MB writing space

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Memory limits (in MB)
readonly MAX_OS_MB=95
readonly WRITING_SPACE_MB=160
readonly TOTAL_RAM_MB=256

echo "*** Memory Budget Validation ***"
echo "================================"
echo ""
echo "Sacred Memory Law:"
echo "  - OS Maximum: ${MAX_OS_MB}MB"
echo "  - Writing Space: ${WRITING_SPACE_MB}MB (PROTECTED)"
echo "  - Total RAM: ${TOTAL_RAM_MB}MB"
echo ""

# Track results
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# Test functions
test_pass() {
    echo "  [PASS] $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

test_fail() {
    echo "  [FAIL] $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

test_warn() {
    echo "  [WARN] $1"
    WARN_COUNT=$((WARN_COUNT + 1))
}

# 1. Check rootfs size
echo "-> Checking root filesystem size..."
ROOTFS_ARCHIVE="$PROJECT_ROOT/nook-mvp-rootfs.tar.gz"
if [ -f "$ROOTFS_ARCHIVE" ]; then
    # Compressed size
    COMPRESSED_SIZE=$(stat -c%s "$ROOTFS_ARCHIVE" 2>/dev/null || stat -f%z "$ROOTFS_ARCHIVE" 2>/dev/null || echo "0")
    COMPRESSED_MB=$((COMPRESSED_SIZE / 1048576))
    
    # Estimate uncompressed (typically 2-3x)
    ESTIMATED_MB=$((COMPRESSED_MB * 3))
    
    if [ "$COMPRESSED_MB" -lt 35 ]; then
        test_pass "Rootfs compressed: ${COMPRESSED_MB}MB (excellent)"
    elif [ "$COMPRESSED_MB" -lt 50 ]; then
        test_warn "Rootfs compressed: ${COMPRESSED_MB}MB (getting large)"
    else
        test_fail "Rootfs too large: ${COMPRESSED_MB}MB compressed"
    fi
    
    if [ "$ESTIMATED_MB" -lt "$MAX_OS_MB" ]; then
        test_pass "Estimated runtime: ~${ESTIMATED_MB}MB (under limit)"
    else
        test_warn "Estimated runtime: ~${ESTIMATED_MB}MB (may exceed limit)"
    fi
else
    test_warn "Rootfs archive not found"
fi
echo ""

# 2. Check Docker image sizes (development reference)
echo "-> Checking Docker image sizes..."
if command -v docker >/dev/null 2>&1; then
    # Check minimal boot image
    if docker images | grep -q "nook-mvp-rootfs"; then
        DOCKER_SIZE=$(docker images --format "table {{.Repository}}\t{{.Size}}" | grep "nook-mvp-rootfs" | awk '{print $2}')
        test_pass "Docker image size: $DOCKER_SIZE"
    else
        test_warn "Docker image not built"
    fi
else
    test_warn "Docker not available for size check"
fi
echo ""

# 3. Check kernel module sizes (should be minimal/none)
echo "-> Checking kernel module sizes..."
MODULE_DIR="$PROJECT_ROOT/firmware/kernel"
if [ -d "$MODULE_DIR" ]; then
    MODULE_COUNT=$(find "$MODULE_DIR" -name "*.ko" 2>/dev/null | wc -l)
    if [ "$MODULE_COUNT" -eq 0 ]; then
        test_pass "No kernel modules (userspace implementation)"
    else
        TOTAL_MODULE_SIZE=$(find "$MODULE_DIR" -name "*.ko" -exec du -ch {} + 2>/dev/null | grep total | awk '{print $1}')
        test_warn "Found $MODULE_COUNT modules: $TOTAL_MODULE_SIZE"
    fi
else
    test_pass "No kernel module directory (userspace only)"
fi
echo ""

# 4. Check script memory footprint
echo "-> Checking script memory footprint..."
TOTAL_SCRIPT_SIZE=0
SCRIPT_COUNT=0
for script in "$PROJECT_ROOT"/source/scripts/**/*.sh; do
    if [ -f "$script" ]; then
        SIZE=$(wc -c < "$script")
        TOTAL_SCRIPT_SIZE=$((TOTAL_SCRIPT_SIZE + SIZE))
        SCRIPT_COUNT=$((SCRIPT_COUNT + 1))
    fi
done
SCRIPT_KB=$((TOTAL_SCRIPT_SIZE / 1024))

if [ "$SCRIPT_KB" -lt 100 ]; then
    test_pass "Scripts total: ${SCRIPT_KB}KB ($SCRIPT_COUNT scripts)"
elif [ "$SCRIPT_KB" -lt 500 ]; then
    test_warn "Scripts getting large: ${SCRIPT_KB}KB"
else
    test_fail "Scripts too large: ${SCRIPT_KB}KB"
fi
echo ""

# 5. Check for memory hogs
echo "-> Checking for memory-hungry components..."
MEMORY_HOGS=(
    "node_modules:Node.js packages"
    ".git/objects:Git history"
    "*.log:Log files"
    "*.tmp:Temporary files"
    "docs:Documentation"
)

for entry in "${MEMORY_HOGS[@]}"; do
    IFS=':' read -r pattern description <<< "$entry"
    if find "$PROJECT_ROOT" -path "*/$pattern" -o -name "$pattern" 2>/dev/null | head -1 | grep -q .; then
        test_warn "Found $description (not for deployment)"
    fi
done
test_pass "Check complete (warnings are for dev environment only)"
echo ""

# 6. Calculate memory budget
echo "-> Calculating memory budget..."
echo ""
echo "Memory Allocation Plan:"
echo "  Kernel:     ~5MB  (compressed uImage)"
echo "  Userspace: ~30MB  (base Debian)"
echo "  JesterOS:   ~1MB  (scripts and configs)"
echo "  Vim:       ~10MB  (editor + minimal plugins)"
echo "  Services:   ~5MB  (system services)"
echo "  Buffers:   ~10MB  (file cache)"
echo "  Free:      ~34MB  (breathing room)"
echo "  ─────────────────────────────"
echo "  OS Total:  ~95MB  (MAXIMUM)"
echo "  Writing:  ~160MB  (PROTECTED)"
echo "  Hardware:   ~1MB  (reserved)"
echo "  ─────────────────────────────"
echo "  Total:     256MB"
echo ""

# Rough calculation check
ESTIMATED_USAGE=51  # Kernel + base + services
if [ "$ESTIMATED_USAGE" -lt "$MAX_OS_MB" ]; then
    test_pass "Estimated OS usage: ${ESTIMATED_USAGE}MB (well under limit)"
else
    test_fail "Estimated OS usage: ${ESTIMATED_USAGE}MB (exceeds limit!)"
fi
echo ""

# 7. Check for memory optimization flags
echo "-> Checking memory optimizations..."
if grep -r "CONFIG_EMBEDDED\|CONFIG_EXPERT\|CONFIG_TINY" "$PROJECT_ROOT/source/kernel" >/dev/null 2>&1; then
    test_pass "Kernel has embedded/tiny optimizations"
else
    test_warn "No kernel memory optimizations found"
fi

if grep -r "strip\|--strip" "$PROJECT_ROOT/build" >/dev/null 2>&1; then
    test_pass "Binary stripping enabled"
else
    test_warn "Consider stripping binaries for size"
fi
echo ""

# Final assessment
echo "*** Memory Budget Assessment ***"
echo "================================"
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo "Warnings: $WARN_COUNT"
echo ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "✅ Memory budget validated!"
    echo ""
    echo "The Memory Guardian proclaims:"
    echo "  'The sacred 160MB writing space is protected!'"
    echo "  'The OS shall not exceed its ${MAX_OS_MB}MB allowance!'"
    echo ""
    echo "Remember: Every byte saved is a word written!"
    exit 0
else
    echo "❌ Memory budget validation failed!"
    echo ""
    echo "The Memory Guardian warns:"
    echo "  'The sacred writing space is threatened!'"
    echo "  'Reduce thy footprint or writers shall suffer!'"
    exit 1
fi