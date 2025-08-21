#!/bin/bash
# Fix import paths after architecture migration
# Updates all script references to match new 5-layer structure

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔧 Fixing Import Paths for Architecture Migration"
echo "================================================"
echo ""

# Function to print colored messages
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_fix() { echo -e "${GREEN}[FIX]${NC} $1"; }

# Check if we're in the right directory
if [ ! -d "runtime" ]; then
    log_error "Must run from project root (no runtime/ directory found)"
    exit 1
fi

# Dry run mode
DRY_RUN=${1:-false}
if [ "$DRY_RUN" = "--dry-run" ]; then
    log_warn "DRY RUN MODE - No changes will be made"
    echo ""
fi

# Track changes
CHANGES_MADE=0

# Function to fix a path in a file
fix_path() {
    local file="$1"
    local old_pattern="$2"
    local new_path="$3"
    
    if grep -q "$old_pattern" "$file" 2>/dev/null; then
        if [ "$DRY_RUN" = "--dry-run" ]; then
            echo "  Would update: $file"
            echo "    Old: $old_pattern"
            echo "    New: $new_path"
        else
            sed -i "s|$old_pattern|$new_path|g" "$file"
            log_fix "Updated: $file"
        fi
        ((CHANGES_MADE++))
    fi
}

# Function to calculate relative path between two directories
get_relative_path() {
    local from="$1"
    local to="$2"
    
    # Simple relative path calculation
    # This is basic - enhance if needed for complex cases
    python3 -c "
import os.path
from_path = '$from'
to_path = '$to'
rel_path = os.path.relpath(to_path, os.path.dirname(from_path))
print(rel_path)
" 2>/dev/null || echo "$to"
}

log_info "Scanning for paths that need updating..."
echo ""

# ============================================
# Fix Layer 2 (Application) imports
# ============================================
log_info "Fixing Application Layer (Layer 2) imports..."

# Fix jesteros service manager
if [ -f "src/services/services/jester/manager.sh" ]; then
    fix_path "src/services/services/jester/manager.sh" \
        "../lib/service-functions.sh" \
        "../../services/system/service-functions.sh"
fi

# Fix any other Layer 2 scripts that source common libraries
for script in runtime/services/jester/*.sh; do
    if [ -f "$script" ]; then
        # Fix common.sh references
        fix_path "$script" \
            "../lib/common.sh" \
            "../../services/system/common.sh"
        
        fix_path "$script" \
            "scripts/lib/common.sh" \
            "services/system/common.sh"
    fi
done

# ============================================
# Fix Layer 1 (UI) imports
# ============================================
log_info "Fixing UI Layer (Layer 1) imports..."

for script in runtime/services/menu/*.sh; do
    if [ -f "$script" ]; then
        # Fix common library references
        fix_path "$script" \
            "../../scripts/lib/common.sh" \
            "../../services/system/common.sh"
        
        fix_path "$script" \
            "../lib/common.sh" \
            "../../services/system/common.sh"
    fi
done

# ============================================
# Fix Init scripts
# ============================================
log_info "Fixing Init script imports..."

for script in runtime/init/*.sh; do
    if [ -f "$script" ]; then
        # Fix paths to system libraries
        fix_path "$script" \
            "../lib/common.sh" \
            "../services/system/common.sh"
        
        # Fix paths to services
        fix_path "$script" \
            "../scripts/services/" \
            "../services/jester/"
    fi
done

# ============================================
# Fix absolute paths
# ============================================
log_info "Fixing absolute paths..."

# Common absolute paths that might need updating
ABSOLUTE_PATHS=(
    "/usr/local/bin/jesteros-"
    "/etc/jesteros/"
    "/var/jesteros/"
)

for pattern in "${ABSOLUTE_PATHS[@]}"; do
    for script in runtime/**/*.sh; do
        if [ -f "$script" ] && grep -q "$pattern" "$script" 2>/dev/null; then
            log_warn "Found absolute path in $script: $pattern"
            log_warn "  Manual review recommended for absolute paths"
        fi
    done
done

# ============================================
# Fix Docker references
# ============================================
log_info "Checking Docker files for path updates..."

for dockerfile in build/docker/*.dockerfile; do
    if [ -f "$dockerfile" ]; then
        # Check for old runtime/scripts paths
        if grep -q "src/services/scripts" "$dockerfile" 2>/dev/null; then
            log_warn "Docker file needs updating: $dockerfile"
            
            if [ "$DRY_RUN" != "--dry-run" ]; then
                # Update COPY commands
                sed -i 's|runtime/scripts/|runtime/|g' "$dockerfile"
                log_fix "Updated Docker paths in: $dockerfile"
            fi
        fi
    fi
done

# ============================================
# Fix test scripts
# ============================================
log_info "Checking test scripts..."

for test in tests/*.sh; do
    if [ -f "$test" ]; then
        # Check for old structure references
        if grep -q "src/services/scripts" "$test" 2>/dev/null; then
            log_warn "Test needs updating: $test"
        fi
        if grep -q "source/scripts" "$test" 2>/dev/null; then
            fix_path "$test" \
                "../source/scripts" \
                "../runtime"
        fi
    fi
done

# ============================================
# Create path mapping documentation
# ============================================
if [ "$DRY_RUN" != "--dry-run" ] && [ $CHANGES_MADE -gt 0 ]; then
    cat > runtime/PATH_MIGRATION.md << 'EOF'
# Path Migration Reference

## Import Path Updates

### Old Structure → New Structure

| Old Path | New Path | Layer |
|----------|----------|-------|
| `scripts/lib/common.sh` | `3-system/common/common.sh` | System |
| `scripts/lib/service-functions.sh` | `3-system/common/service-functions.sh` | System |
| `scripts/menu/*` | `1-ui/menu/*` | UI |
| `scripts/services/jesteros-*` | `2-application/jesteros/*` | Application |
| `scripts/boot/*` | `init/*` | Init |

## Relative Path Examples

From Layer 2 (Application) to Layer 3 (System):
```bash
# Old
. "$SCRIPT_DIR/../lib/common.sh"

# New  
. "$SCRIPT_DIR/../../services/system/common.sh"
```

From Layer 1 (UI) to Layer 3 (System):
```bash
# Old
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# New
source ../../services/system/common.sh
```

## Quick Reference

- Always use relative paths when possible
- Layer numbers indicate dependency direction (lower can't call higher)
- Init scripts are special - they can call any layer
EOF
    log_info "Created PATH_MIGRATION.md reference"
fi

# ============================================
# Summary
# ============================================
echo ""
echo "====================================="
if [ "$DRY_RUN" = "--dry-run" ]; then
    log_warn "DRY RUN COMPLETE"
    echo "Found $CHANGES_MADE paths that need updating"
    echo "Run without --dry-run to apply fixes"
else
    if [ $CHANGES_MADE -gt 0 ]; then
        log_info "✅ Fixed $CHANGES_MADE import paths"
        echo ""
        echo "Next steps:"
        echo "1. Review PATH_MIGRATION.md for reference"
        echo "2. Test scripts to ensure imports work"
        echo "3. Check for any absolute paths that need manual review"
    else
        log_info "No import paths needed fixing!"
    fi
fi

# Show any remaining issues
echo ""
log_info "Checking for remaining issues..."

# Find any remaining old-style paths
REMAINING=$(grep -r "scripts/lib\|scripts/services\|scripts/menu" runtime/ 2>/dev/null | wc -l || echo "0")

if [ "$REMAINING" -gt "0" ]; then
    log_warn "Found $REMAINING remaining old-style paths that may need manual review:"
    grep -r "scripts/lib\|scripts/services\|scripts/menu" runtime/ 2>/dev/null | head -5 || true
else
    log_info "✅ All paths appear to be updated!"
fi