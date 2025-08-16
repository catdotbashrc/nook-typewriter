#!/bin/bash
# Consistency check - Prevent regressions like missing scripts
# This catches integration issues between scripts

set -euo pipefail

echo "🔍 CONSISTENCY CHECK - Are all the pieces connected?"
echo "===================================================="
echo ""

CONSISTENT=true
SCRIPT_DIR="../source/scripts"

# Check 1: All scripts referenced in boot files exist
echo -n "✓ Boot script references valid... "
MISSING_SCRIPTS=0
for boot_script in "$SCRIPT_DIR"/boot/*.sh; do
    if [ -f "$boot_script" ]; then
        # Look for sourced or called scripts
        while IFS= read -r referenced; do
            # Extract just the script filename from source/bash/sh commands
            ref_clean=$(echo "$referenced" | sed 's/.*source //; s/.*\. //; s/.*bash //; s/.*sh //' | sed 's/["${}]//g' | xargs)
            # Skip if it's not a .sh file or is empty
            if [ -z "$ref_clean" ] || [[ "$ref_clean" != *.sh ]]; then
                continue
            fi
            # Only process actual script references, not variable assignments
            if [[ "$ref_clean" == *"="* ]] || [[ "$ref_clean" == *" "* ]]; then
                continue
            fi
            # Check if it's a relative or absolute path
            if [[ "$ref_clean" == /* ]]; then
                # Absolute path
                if [ ! -f "$ref_clean" ] && [ ! -f "../$ref_clean" ]; then
                    ((MISSING_SCRIPTS++))
                    [ $MISSING_SCRIPTS -eq 1 ] && echo ""
                    echo "    Missing: $ref_clean (referenced in $(basename $boot_script))"
                    CONSISTENT=false
                fi
            else
                # Relative path - check various locations
                found=false
                for dir in "$SCRIPT_DIR/boot" "$SCRIPT_DIR/services" "$SCRIPT_DIR/menu" "$SCRIPT_DIR/lib"; do
                    if [ -f "$dir/$ref_clean" ]; then
                        found=true
                        break
                    fi
                done
                if [ "$found" = false ] && [ ! -f "$SCRIPT_DIR/$ref_clean" ]; then
                    ((MISSING_SCRIPTS++))
                    [ $MISSING_SCRIPTS -eq 1 ] && echo ""
                    echo "    Missing: $ref_clean (referenced in $(basename $boot_script))"
                    CONSISTENT=false
                fi
            fi
        done < <(grep -h '\.sh' "$boot_script" 2>/dev/null | grep -v '^#' | grep -E 'source |bash |\. ' || true)
    fi
done
if [ $MISSING_SCRIPTS -eq 0 ]; then
    echo "YES"
else
    echo "NO ($MISSING_SCRIPTS missing)"
fi

# Check 2: No kernel module loading attempts (we're userspace only!)
echo -n "✓ No kernel module references... "
MODULE_REFS=$(grep -r "insmod\|modprobe\|\.ko\|load_module" "$SCRIPT_DIR" 2>/dev/null | grep -v "^#" | wc -l || echo "0")
if [ "$MODULE_REFS" -eq 0 ]; then
    echo "YES"
else
    echo "NO ($MODULE_REFS references found)"
    echo "    JesterOS is userspace only - no kernel modules!"
    CONSISTENT=false
fi

# Check 3: Naming consistency (JesterOS, not SquireOS)
echo -n "✓ Consistent JesterOS naming... "
SQUIRE_REFS=$(grep -r "squireos\|squire\|SquireOS" "$SCRIPT_DIR" 2>/dev/null | grep -v "^#" | grep -iv "esquire" | wc -l || echo "0")
if [ "$SQUIRE_REFS" -eq 0 ]; then
    echo "YES"
else
    echo "WARNING ($SQUIRE_REFS SquireOS references remain)"
    echo "    Should be JesterOS throughout"
fi

# Check 4: Common functions available
echo -n "✓ Common library sourced... "
COMMON_SOURCES=$(find "$SCRIPT_DIR" -name "*.sh" -exec grep -l "common\.sh" {} \; 2>/dev/null | wc -l)
if [ "$COMMON_SOURCES" -gt 0 ]; then
    echo "YES ($COMMON_SOURCES scripts use it)"
else
    echo "WARNING - No scripts source common.sh"
fi

# Check 5: Service paths consistency
echo -n "✓ Service paths consistent... "
if grep -r "/proc/squireos" "$SCRIPT_DIR" 2>/dev/null | grep -v "^#" | grep -q .; then
    echo "NO - Found /proc/squireos (should be /var/jesteros)"
    CONSISTENT=false
elif grep -r "/proc/jesteros" "$SCRIPT_DIR" 2>/dev/null | grep -v "^#" | grep -q .; then
    echo "NO - Found /proc/jesteros (should be /var/jesteros)"
    CONSISTENT=false
else
    echo "YES (/var/jesteros)"
fi

# Check 6: Script permissions
echo -n "✓ Scripts are executable... "
NON_EXEC=$(find "$SCRIPT_DIR" -name "*.sh" -type f ! -perm -u+x | wc -l)
if [ "$NON_EXEC" -eq 0 ]; then
    echo "YES"
else
    echo "WARNING ($NON_EXEC scripts not executable)"
    echo "    Run: chmod +x $SCRIPT_DIR/**/*.sh"
fi

# Check 7: No orphaned function calls (simplified check)
echo -n "✓ Function calls valid... "
# Just check for a few common functions that should be defined
MISSING_COMMON=0
if [ -f "$SCRIPT_DIR/lib/common.sh" ]; then
    # Check if common functions are defined
    for func in "validate_menu_choice" "validate_path" "error_handler"; do
        if ! grep -q "^${func}()\|^function ${func}" "$SCRIPT_DIR/lib/common.sh" 2>/dev/null; then
            ((MISSING_COMMON++))
        fi
    done
fi
if [ $MISSING_COMMON -eq 0 ]; then
    echo "YES"
else
    echo "WARNING ($MISSING_COMMON common functions missing)"
fi

echo ""
if [ "$CONSISTENT" = true ]; then
    echo "✅ CONSISTENCY CHECK PASSED"
    echo "All scripts properly connected"
    exit 0
else
    echo "❌ CONSISTENCY ISSUES FOUND"
    echo "Fix script references before deployment"
    exit 1
fi