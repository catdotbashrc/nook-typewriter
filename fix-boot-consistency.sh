#!/bin/bash
# Fix Boot Script Consistency Issues
# Automatically resolves issues found in BOOT_CONSISTENCY_ANALYSIS.md
# Run with: ./fix-boot-consistency.sh

set -euo pipefail
trap 'echo "Error at line $LINENO" >&2' ERR

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "═══════════════════════════════════════════════════"
echo "   Boot Script Consistency Fixes"
echo "   Fixing issues found in analysis"
echo "═══════════════════════════════════════════════════"
echo ""

# Counter for fixes applied
FIX_COUNT=0

# Function to report progress
report() {
    echo -e "${GREEN}✓${NC} $1"
    ((FIX_COUNT++))
}

# Function to report warnings
warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to report errors
error() {
    echo -e "${RED}✗${NC} $1"
}

# 1. Create missing jester-mischief.sh
echo "→ Creating missing jester-mischief.sh..."
if [ ! -f source/scripts/boot/jester-mischief.sh ]; then
    cat > source/scripts/boot/jester-mischief.sh << 'EOF'
#!/bin/sh
# Jester Mischief Animations
# Boot-time animations and mischievous displays
# "The jester's bells jingle with glee!"

# Safety settings for reliable animation
set -eu
trap 'echo "Error in jester-mischief.sh at line $LINENO" >&2' ERR

# Boot logging
BOOT_LOG="${BOOT_LOG:-/var/log/jesteros-boot.log}"
log_animation() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [jester-mischief] $1" >> "$BOOT_LOG" 2>/dev/null || true
}

# Display function with E-Ink support
display_animation() {
    if command -v fbink >/dev/null 2>&1; then
        fbink -c 2>/dev/null
        fbink -y 10 "$1" 2>/dev/null || echo "$1"
    else
        echo "$1"
    fi
}

# Main animation sequence
main() {
    local mode="${1:-boot}"
    
    log_animation "Starting $mode animations"
    
    case "$mode" in
        boot)
            display_animation "The jester awakens with mischievous glee!"
            sleep 1
            display_animation "*jingle jingle* The bells do ring!"
            sleep 1
            ;;
        menu)
            display_animation "The jester juggles menu options..."
            ;;
        *)
            display_animation "The jester performs a merry jig!"
            ;;
    esac
    
    log_animation "Animation sequence complete"
}

# Run animation
main "$@"
EOF
    chmod +x source/scripts/boot/jester-mischief.sh
    report "Created jester-mischief.sh"
else
    warn "jester-mischief.sh already exists, skipping"
fi

# 2. Remove module loading from boot-jester.sh
echo "→ Removing kernel module loading from boot-jester.sh..."
if grep -q "load_jesteros_modules" source/scripts/boot/boot-jester.sh; then
    # Comment out the module loading function and its call
    sed -i 's/^load_jesteros_modules()/#load_jesteros_modules()/' source/scripts/boot/boot-jester.sh
    sed -i 's/^    load_jesteros_modules/#    load_jesteros_modules/' source/scripts/boot/boot-jester.sh
    report "Disabled module loading in boot-jester.sh"
else
    warn "Module loading already disabled in boot-jester.sh"
fi

# 3. Remove module loading from squireos-init.sh  
echo "→ Removing kernel module loading from squireos-init.sh..."
if grep -q "insmod.*\.ko" source/scripts/boot/squireos-init.sh; then
    # Comment out insmod lines
    sed -i 's/^\s*insmod/#    insmod/' source/scripts/boot/squireos-init.sh
    sed -i 's/^\s*if \[ -f.*\.ko.*\]/#&/' source/scripts/boot/squireos-init.sh
    report "Disabled module loading in squireos-init.sh"
else
    warn "Module loading already disabled in squireos-init.sh"
fi

# 4. Rename SquireOS files to JesterOS (with backup)
echo "→ Renaming SquireOS files to JesterOS..."
RENAMED=0

# Rename squireos-boot.sh
if [ -f source/scripts/boot/squireos-boot.sh ]; then
    if [ ! -f source/scripts/boot/jesteros-boot.sh ]; then
        mv source/scripts/boot/squireos-boot.sh source/scripts/boot/jesteros-boot.sh
        report "Renamed squireos-boot.sh → jesteros-boot.sh"
        RENAMED=1
    else
        warn "jesteros-boot.sh already exists, keeping both"
    fi
fi

# Rename squireos-init.sh
if [ -f source/scripts/boot/squireos-init.sh ]; then
    if [ ! -f source/scripts/boot/jesteros-init.sh ]; then
        mv source/scripts/boot/squireos-init.sh source/scripts/boot/jesteros-init.sh
        report "Renamed squireos-init.sh → jesteros-init.sh"
        RENAMED=1
    else
        warn "jesteros-init.sh already exists, keeping both"
    fi
fi

# Rename load-squireos-modules.sh
if [ -f source/scripts/boot/load-squireos-modules.sh ]; then
    if [ ! -f source/scripts/boot/load-jesteros-modules.sh ]; then
        mv source/scripts/boot/load-squireos-modules.sh source/scripts/boot/load-jesteros-modules.sh
        report "Renamed load-squireos-modules.sh → load-jesteros-modules.sh"
        RENAMED=1
    else
        warn "load-jesteros-modules.sh already exists, keeping both"
    fi
fi

# Rename squire-menu.sh
if [ -f source/scripts/menu/squire-menu.sh ]; then
    if [ ! -f source/scripts/menu/jester-menu.sh ]; then
        mv source/scripts/menu/squire-menu.sh source/scripts/menu/jester-menu.sh
        report "Renamed squire-menu.sh → jester-menu.sh"
        RENAMED=1
    else
        warn "jester-menu.sh already exists, keeping both"
    fi
fi

# 5. Update references if files were renamed
if [ $RENAMED -eq 1 ]; then
    echo "→ Updating script references..."
    
    # Update references in all boot scripts
    find source/scripts/boot -name "*.sh" -type f -exec sed -i \
        -e 's/squireos-boot\.sh/jesteros-boot.sh/g' \
        -e 's/squireos-init\.sh/jesteros-init.sh/g' \
        -e 's/load-squireos-modules\.sh/load-jesteros-modules.sh/g' \
        -e 's/squire-menu\.sh/jester-menu.sh/g' {} \;
    
    # Update references in menu scripts
    find source/scripts/menu -name "*.sh" -type f -exec sed -i \
        -e 's/squireos-boot\.sh/jesteros-boot.sh/g' \
        -e 's/squire-menu\.sh/jester-menu.sh/g' {} \;
    
    report "Updated all script references"
fi

# 6. Fix SquireOS → JesterOS in file contents
echo "→ Updating SquireOS references to JesterOS..."
CONTENT_FIXED=0

for file in source/scripts/boot/*.sh source/scripts/menu/*.sh; do
    if [ -f "$file" ] && grep -q "SquireOS" "$file"; then
        sed -i 's/SquireOS/JesterOS/g' "$file"
        CONTENT_FIXED=1
    fi
done

if [ $CONTENT_FIXED -eq 1 ]; then
    report "Updated SquireOS → JesterOS in file contents"
else
    warn "No SquireOS references found in file contents"
fi

# 7. Fix /proc/squireos references
echo "→ Fixing /proc/squireos references..."
PROC_FIXED=0

for file in source/scripts/boot/*.sh source/scripts/services/*.sh; do
    if [ -f "$file" ] && grep -q "/proc/squireos" "$file"; then
        sed -i 's|/proc/squireos|/var/jesteros|g' "$file"
        PROC_FIXED=1
    fi
done

if [ $PROC_FIXED -eq 1 ]; then
    report "Fixed /proc/squireos → /var/jesteros"
else
    warn "No /proc/squireos references found"
fi

# 8. Create validation script
echo "→ Creating validation script..."
cat > validate-boot-consistency.sh << 'EOF'
#!/bin/bash
# Validate boot script consistency after fixes

echo "Validating boot script consistency..."
ERRORS=0

# Check for missing scripts
echo -n "Checking for missing scripts... "
if [ ! -f source/scripts/boot/jester-mischief.sh ]; then
    echo "✗ jester-mischief.sh still missing"
    ((ERRORS++))
else
    echo "✓"
fi

# Check for module loading attempts
echo -n "Checking for kernel module loading... "
if grep -q "insmod.*jesteros_core" source/scripts/boot/*.sh 2>/dev/null; then
    echo "✗ Still trying to load non-existent modules"
    ((ERRORS++))
else
    echo "✓"
fi

# Check for SquireOS references
echo -n "Checking for SquireOS references... "
if grep -q "SquireOS" source/scripts/boot/*.sh 2>/dev/null; then
    echo "✗ SquireOS references still exist"
    ((ERRORS++))
else
    echo "✓"
fi

# Check for /proc/squireos references
echo -n "Checking for /proc/squireos references... "
if grep -q "/proc/squireos" source/scripts/boot/*.sh 2>/dev/null; then
    echo "✗ /proc/squireos references still exist"
    ((ERRORS++))
else
    echo "✓"
fi

if [ $ERRORS -eq 0 ]; then
    echo "✅ All consistency issues resolved!"
else
    echo "❌ $ERRORS issues remain"
fi

exit $ERRORS
EOF
chmod +x validate-boot-consistency.sh
report "Created validation script"

# Summary
echo ""
echo "═══════════════════════════════════════════════════"
echo "   Fix Summary"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Applied $FIX_COUNT fixes"
echo ""
echo "Next steps:"
echo "1. Run: ./validate-boot-consistency.sh"
echo "2. Test boot sequence: make test"
echo "3. Commit changes: git add -A && git commit -m 'fix: resolve boot script consistency issues'"
echo ""
echo "✅ Boot consistency fixes complete!"