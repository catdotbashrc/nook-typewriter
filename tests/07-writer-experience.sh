#!/bin/bash
# Writer experience test - Validate error quality and basic workflow
# Ensures the system is debuggable and writer-friendly

set -euo pipefail

echo "✍️  WRITER EXPERIENCE TEST - Is it writer-friendly?"
echo "=================================================="
echo ""

EXPERIENCE_OK=true
SCRIPT_DIR="../source/scripts"

# Check 1: Error handling in scripts
echo -n "✓ Scripts have error handling... "
SCRIPTS_WITH_TRAP=$(grep -l "trap\|set -e" "$SCRIPT_DIR"/{boot,menu,services}/*.sh 2>/dev/null | wc -l || echo "0")
TOTAL_SCRIPTS=$(find "$SCRIPT_DIR"/{boot,menu,services} -name "*.sh" 2>/dev/null | wc -l || echo "0")
if [ "$TOTAL_SCRIPTS" -gt 0 ]; then
    PERCENTAGE=$((SCRIPTS_WITH_TRAP * 100 / TOTAL_SCRIPTS))
    if [ $PERCENTAGE -gt 80 ]; then
        echo "EXCELLENT ($SCRIPTS_WITH_TRAP/$TOTAL_SCRIPTS have traps)"
    elif [ $PERCENTAGE -gt 50 ]; then
        echo "GOOD ($SCRIPTS_WITH_TRAP/$TOTAL_SCRIPTS have traps)"
    else
        echo "POOR ($SCRIPTS_WITH_TRAP/$TOTAL_SCRIPTS have traps)"
        echo "    Add 'set -euo pipefail' to scripts!"
    fi
else
    echo "No scripts to check"
fi

# Check 2: Human-readable error messages
echo -n "✓ Error messages are friendly... "
TECH_JARGON=$(grep -r "errno\|ENOENT\|EINVAL\|ioctl\|syscall\|segfault" "$SCRIPT_DIR" 2>/dev/null | grep -v "^#" | wc -l || echo "0")
if [ "$TECH_JARGON" -eq 0 ]; then
    echo "YES (no technical jargon)"
else
    echo "WARNING ($TECH_JARGON technical errors)"
    echo "    Replace with writer-friendly messages"
fi

# Check 3: Medieval theme consistency
echo -n "✓ Medieval theme present... "
THEME_WORDS=$(grep -r "jester\|scroll\|quill\|parchment\|scribe\|knight\|medieval" "$SCRIPT_DIR" 2>/dev/null | wc -l || echo "0")
if [ "$THEME_WORDS" -gt 20 ]; then
    echo "EXCELLENT ($THEME_WORDS themed references)"
elif [ "$THEME_WORDS" -gt 10 ]; then
    echo "GOOD ($THEME_WORDS themed references)"
else
    echo "NEEDS MORE ($THEME_WORDS themed references)"
    echo "    Add more medieval flair!"
fi

# Check 4: Silent failures check
echo -n "✓ No silent failures... "
SILENT_FAILS=$(grep -r "2>/dev/null" "$SCRIPT_DIR" 2>/dev/null | grep -v "command -v\|which\|type\|grep\|find" | wc -l || echo "0")
if [ "$SILENT_FAILS" -lt 5 ]; then
    echo "EXCELLENT (minimal suppression)"
elif [ "$SILENT_FAILS" -lt 15 ]; then
    echo "OK ($SILENT_FAILS suppressions)"
else
    echo "WARNING ($SILENT_FAILS error suppressions)"
    echo "    Silent failures make debugging hard!"
fi

# Check 5: Writing directories setup
echo -n "✓ Writing directories configured... "
if grep -r "notes\|drafts\|scrolls" "$SCRIPT_DIR" 2>/dev/null | grep -q "mkdir"; then
    echo "YES (auto-created)"
else
    echo "WARNING - Directories not auto-created"
    echo "    Writers need: /root/notes, /root/drafts, /root/scrolls"
fi

# Check 6: Menu user experience
echo -n "✓ Menu has clear options... "
if [ -f "$SCRIPT_DIR/menu/nook-menu.sh" ]; then
    MENU_OPTIONS=$(grep -c "echo.*[0-9])" "$SCRIPT_DIR/menu/nook-menu.sh" || echo "0")
    if [ "$MENU_OPTIONS" -gt 3 ] && [ "$MENU_OPTIONS" -lt 10 ]; then
        echo "YES ($MENU_OPTIONS options - good balance)"
    elif [ "$MENU_OPTIONS" -le 3 ]; then
        echo "TOO FEW ($MENU_OPTIONS options)"
    else
        echo "TOO MANY ($MENU_OPTIONS options - overwhelming)"
    fi
else
    echo "NO MENU FOUND"
    EXPERIENCE_OK=false
fi

# Check 7: Recovery instructions
echo -n "✓ Recovery help available... "
RECOVERY_MSGS=$(grep -r "recover\|restore\|fix\|help\|retry" "$SCRIPT_DIR" 2>/dev/null | grep -i "echo\|printf" | wc -l || echo "0")
if [ "$RECOVERY_MSGS" -gt 10 ]; then
    echo "YES ($RECOVERY_MSGS recovery messages)"
else
    echo "MINIMAL ($RECOVERY_MSGS recovery messages)"
    echo "    Add more helpful recovery instructions"
fi

# Check 8: Startup time awareness
echo -n "✓ Boot messages friendly... "
if grep -r "Loading\|Starting\|Initializing\|Ready\|Welcome" "$SCRIPT_DIR/boot" 2>/dev/null | grep -q .; then
    echo "YES (progress indicators)"
else
    echo "WARNING - No progress messages"
    echo "    E-Ink is slow, add reassuring messages"
fi

# Check 9: Clear success indicators
echo -n "✓ Success feedback exists... "
SUCCESS_MSGS=$(grep -r "✓\|Success\|Complete\|Ready\|Done" "$SCRIPT_DIR" 2>/dev/null | wc -l || echo "0")
if [ "$SUCCESS_MSGS" -gt 5 ]; then
    echo "YES ($SUCCESS_MSGS success indicators)"
else
    echo "MINIMAL ($SUCCESS_MSGS success indicators)"
fi

# Check 10: Vim configuration
echo -n "✓ Vim writer-optimized... "
if [ -f "../source/configs/vim/vimrc" ] || [ -f "../config/vim/vimrc" ]; then
    echo "YES (custom vimrc)"
else
    echo "WARNING - Using stock vim"
    echo "    Add writer-friendly vim config"
fi

echo ""
echo "Experience Summary:"
echo "  Error handling: Check scripts for traps"
echo "  Message quality: Writer-friendly, not technical"
echo "  Theme consistency: Medieval flair throughout"
echo "  Debuggability: No silent failures"
echo ""

if [ "$EXPERIENCE_OK" = true ]; then
    echo "✅ WRITER EXPERIENCE ACCEPTABLE"
    echo "System should be pleasant to use"
    exit 0
else
    echo "⚠️  EXPERIENCE NEEDS IMPROVEMENT"
    echo "Focus on writer-friendly improvements"
    exit 1
fi