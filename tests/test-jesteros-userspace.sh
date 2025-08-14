#!/bin/bash
# JesterOS Userspace Service Validation
# Tests the userspace implementation of JesterOS services

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Medieval-themed output
echo "*** JesterOS Userspace Validation ***"
echo "====================================="
echo ""
echo "Validating the Jester's userspace services..."
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

# 1. Check JesterOS userspace scripts exist
echo "-> Checking JesterOS service scripts..."
JESTEROS_SCRIPTS=(
    "source/scripts/boot/jesteros-userspace.sh:Main userspace service"
    "source/scripts/services/jesteros-tracker.sh:Writing tracker service"
    "source/scripts/boot/jester-splash.sh:Boot splash service"
    "source/scripts/boot/jester-dance.sh:Jester animation"
)

for entry in "${JESTEROS_SCRIPTS[@]}"; do
    IFS=':' read -r script_path description <<< "$entry"
    if [ -f "$PROJECT_ROOT/$script_path" ]; then
        test_pass "$description"
    else
        test_fail "$description missing: $script_path"
    fi
done
echo ""

# 2. Check JesterOS interface paths
echo "-> Validating interface paths..."
INTERFACE_PATHS=(
    "/var/jesteros:Main interface directory"
    "/var/jesteros/jester:Jester mood display"
    "/var/jesteros/typewriter:Writing statistics"
    "/var/jesteros/wisdom:Writing quotes"
)

# Since we're not on the actual device, check the scripts reference these paths
for entry in "${INTERFACE_PATHS[@]}"; do
    IFS=':' read -r path description <<< "$entry"
    if grep -r "$path" "$PROJECT_ROOT/source/scripts" >/dev/null 2>&1; then
        test_pass "$description path referenced"
    else
        test_warn "$description path not found in scripts"
    fi
done
echo ""

# 3. Check service script permissions and structure
echo "-> Checking service script structure..."
JESTEROS_SERVICE="$PROJECT_ROOT/source/scripts/boot/jesteros-userspace.sh"
if [ -f "$JESTEROS_SERVICE" ]; then
    # Check shebang
    if head -1 "$JESTEROS_SERVICE" | grep -q "^#!/bin/bash"; then
        test_pass "Proper shebang"
    else
        test_fail "Missing or incorrect shebang"
    fi
    
    # Check error handling
    if grep -q "set -.*e" "$JESTEROS_SERVICE"; then
        test_pass "Error handling enabled"
    else
        test_warn "Missing 'set -e' error handling"
    fi
    
    # Check for interface creation
    if grep -q "mkdir.*jesteros" "$JESTEROS_SERVICE"; then
        test_pass "Creates interface directory"
    else
        test_fail "Does not create interface directory"
    fi
else
    test_fail "Main service script not found"
fi
echo ""

# 4. Check ASCII art resources
echo "-> Checking Jester ASCII art resources..."
ASCII_DIR="$PROJECT_ROOT/source/configs/ascii"
if [ -d "$ASCII_DIR" ]; then
    JESTER_COUNT=$(find "$ASCII_DIR" -name "*jester*" 2>/dev/null | wc -l)
    if [ "$JESTER_COUNT" -gt 0 ]; then
        test_pass "Found $JESTER_COUNT jester ASCII art files"
    else
        test_warn "No jester ASCII art files found"
    fi
else
    test_warn "ASCII art directory not found"
fi
echo ""

# 5. Check wisdom quotes
echo "-> Checking wisdom quotes..."
WISDOM_FILE="$PROJECT_ROOT/source/configs/wisdom/quotes.txt"
if [ -f "$WISDOM_FILE" ]; then
    QUOTE_COUNT=$(wc -l < "$WISDOM_FILE")
    if [ "$QUOTE_COUNT" -gt 10 ]; then
        test_pass "Found $QUOTE_COUNT wisdom quotes"
    else
        test_warn "Only $QUOTE_COUNT quotes (need more)"
    fi
elif grep -r "wisdom_quotes\|QUOTES" "$PROJECT_ROOT/source/scripts" >/dev/null 2>&1; then
    test_pass "Wisdom quotes embedded in scripts"
else
    test_warn "No wisdom quotes found"
fi
echo ""

# 6. Check for dangerous operations
echo "-> Checking for dangerous operations..."
DANGEROUS_PATTERNS=(
    "rm -rf /:Recursive root deletion"
    "dd.*of=/dev/sd:Direct disk write"
    "mkfs\.:Filesystem formatting"
    "insmod:Kernel module loading"
    "rmmod:Kernel module removal"
)

DANGER_FOUND=false
for entry in "${DANGEROUS_PATTERNS[@]}"; do
    IFS=':' read -r pattern description <<< "$entry"
    if grep -r "$pattern" "$PROJECT_ROOT/source/scripts" >/dev/null 2>&1; then
        test_fail "Found dangerous operation: $description"
        DANGER_FOUND=true
    fi
done

if [ "$DANGER_FOUND" = false ]; then
    test_pass "No dangerous operations found"
fi
echo ""

# 7. Check memory efficiency
echo "-> Checking service memory efficiency..."
# Count total script size
TOTAL_SIZE=0
for script in "$PROJECT_ROOT"/source/scripts/**/*.sh; do
    if [ -f "$script" ]; then
        SIZE=$(wc -c < "$script")
        TOTAL_SIZE=$((TOTAL_SIZE + SIZE))
    fi
done
TOTAL_KB=$((TOTAL_SIZE / 1024))

if [ "$TOTAL_KB" -lt 100 ]; then
    test_pass "Total script size efficient: ${TOTAL_KB}KB"
elif [ "$TOTAL_KB" -lt 500 ]; then
    test_warn "Script size moderate: ${TOTAL_KB}KB"
else
    test_fail "Scripts too large: ${TOTAL_KB}KB"
fi
echo ""

# Final assessment
echo "*** JesterOS Userspace Assessment ***"
echo "====================================="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo "Warnings: $WARN_COUNT"
echo ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "✅ JesterOS userspace services validated!"
    echo ""
    echo "The Jester proclaims:"
    echo "  'Verily, my services run free in userspace!'"
    echo "  'No kernel dangers shall trouble this place!'"
    exit 0
else
    echo "❌ JesterOS validation failed!"
    echo ""
    echo "The Jester laments:"
    echo "  'Alas! My services are not yet prepared!'"
    echo "  'Fix these issues ere we proceed!'"
    exit 1
fi