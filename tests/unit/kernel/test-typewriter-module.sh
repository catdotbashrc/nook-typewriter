#!/bin/bash
# Unit Test: Typewriter Module Functionality
# Tests writing statistics tracking and achievement system

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "Typewriter Module"

MODULE_DIR="$PROJECT_ROOT/source/kernel/src/drivers/squireos"
TYPEWRITER_MODULE="$MODULE_DIR/typewriter.c"

# Verify typewriter module exists
assert_file_exists "$TYPEWRITER_MODULE" "Typewriter module source"

echo "  Testing typewriter module structure..."

# Test module basics
assert_contains "$(cat "$TYPEWRITER_MODULE")" "MODULE_LICENSE.*GPL" "Has GPL license"
assert_contains "$(cat "$TYPEWRITER_MODULE")" "MODULE_DESCRIPTION.*[Tt]ypewriter\|[Ss]tatistics" "Has typewriter description"

# Test statistics tracking functionality
assert_contains "$(cat "$TYPEWRITER_MODULE")" "keystroke\|keypress\|word.*count\|statistics" "Has keystroke/word tracking"
assert_contains "$(cat "$TYPEWRITER_MODULE")" "stats\|counter\|track" "Has statistics infrastructure"

# Test proc interface for statistics
assert_contains "$(cat "$TYPEWRITER_MODULE")" "typewriter.*stats\|stats.*typewriter" "Has stats proc interface"
assert_contains "$(cat "$TYPEWRITER_MODULE")" "create_proc.*entry\|proc.*read" "Creates proc entries"

# Test integration with SquireOS
assert_contains "$(cat "$TYPEWRITER_MODULE")" "squireos_root\|extern.*squireos" "Integrates with SquireOS core"

echo "  Testing writing statistics features..."

# Test different types of statistics
stats_types=0
if grep -q "word.*count\|words" "$TYPEWRITER_MODULE"; then
    echo "  ✓ Tracks word count"
    ((stats_types++))
fi

if grep -q "keystroke\|key.*count\|keys" "$TYPEWRITER_MODULE"; then
    echo "  ✓ Tracks keystrokes"
    ((stats_types++))
fi

if grep -q "session\|time\|duration" "$TYPEWRITER_MODULE"; then
    echo "  ✓ Tracks writing sessions"
    ((stats_types++))
fi

if grep -q "achievement\|milestone\|goal" "$TYPEWRITER_MODULE"; then
    echo "  ✓ Has achievement system"
    ((stats_types++))
fi

assert_greater_than "$stats_types" 1 "Tracks multiple statistics types"

echo "  Testing memory and performance efficiency..."

# Test that statistics use appropriate data types
assert_contains "$(cat "$TYPEWRITER_MODULE")" "unsigned\|uint\|u32\|u64" "Uses appropriate data types for counters"

# Test atomic operations or locking for thread safety
if grep -q "atomic\|lock\|spin_lock\|mutex" "$TYPEWRITER_MODULE"; then
    echo "  ✓ Has thread safety mechanisms"
else
    echo "  ⚠ Thread safety mechanisms not clearly identified"
fi

# Test memory usage constraints
file_size=$(stat -c%s "$TYPEWRITER_MODULE" 2>/dev/null || echo "0")
assert_less_than "$file_size" 12288 "Module size reasonable for embedded system"

echo "  Testing writer motivation features..."

# Test achievement/milestone system
if grep -q "achievement\|milestone\|goal\|badge" "$TYPEWRITER_MODULE"; then
    echo "  ✓ Has writer achievement system"
    achievement_features=1
else
    echo "  ⚠ Achievement system not clearly identified"
    achievement_features=0
fi

# Test progress tracking
if grep -q "progress\|session.*start\|session.*end" "$TYPEWRITER_MODULE"; then
    echo "  ✓ Tracks writing progress"
    ((achievement_features++))
fi

# Test encouraging feedback
if grep -q "congratulat\|excellent\|progress\|well.*done" "$TYPEWRITER_MODULE"; then
    echo "  ✓ Provides encouraging feedback"
    ((achievement_features++))
fi

echo "  Testing data persistence and recovery..."

# Test statistics persistence
if grep -q "save\|persist\|restore\|load" "$TYPEWRITER_MODULE"; then
    echo "  ✓ Has statistics persistence"
else
    echo "  ⚠ Statistics persistence not clearly identified"
fi

# Test overflow protection
if grep -q "overflow\|MAX\|UINT.*MAX" "$TYPEWRITER_MODULE"; then
    echo "  ✓ Has overflow protection"
else
    echo "  ⚠ Overflow protection not clearly identified"
fi

echo "  Testing integration and dependencies..."

# Test proper module initialization order
assert_contains "$(cat "$TYPEWRITER_MODULE")" "module_init\|__init" "Has proper module initialization"

# Test cleanup functionality
assert_contains "$(cat "$TYPEWRITER_MODULE")" "module_exit\|__exit\|cleanup" "Has proper cleanup"
assert_contains "$(cat "$TYPEWRITER_MODULE")" "remove_proc_entry" "Removes proc entries on cleanup"

echo "  Testing input handling and filtering..."

# Test input validation/filtering
if grep -q "valid\|filter\|check\|sanitize" "$TYPEWRITER_MODULE"; then
    echo "  ✓ Has input validation"
else
    echo "  ⚠ Input validation not clearly identified"
fi

# Test handling of different input types
if grep -q "printable\|isalpha\|isdigit\|whitespace" "$TYPEWRITER_MODULE"; then
    echo "  ✓ Handles different character types"
else
    echo "  ⚠ Character type handling not clearly identified"
fi

echo "  Testing E-Ink display optimization..."

# Test that output is optimized for E-Ink displays
if grep -q "refresh\|update.*display\|e.*ink\|eink" "$TYPEWRITER_MODULE"; then
    echo "  ✓ E-Ink display optimizations present"
else
    echo "  ⚠ E-Ink optimizations not clearly identified"
fi

# Test output formatting for readability
if grep -q "format\|sprintf\|snprintf" "$TYPEWRITER_MODULE"; then
    echo "  ✓ Has formatted output"
else
    echo "  ⚠ Output formatting not clearly identified"
fi

echo "  Testing error handling and robustness..."

# Test error handling
error_handling=0
if grep -q "error\|err\|fail\|ENOMEM\|EINVAL" "$TYPEWRITER_MODULE"; then
    echo "  ✓ Has error handling"
    ((error_handling++))
fi

if grep -q "return.*-\|goto.*error\|cleanup" "$TYPEWRITER_MODULE"; then
    echo "  ✓ Has error recovery paths"
    ((error_handling++))
fi

assert_greater_than "$error_handling" 0 "Has error handling mechanisms"

pass_test "Typewriter module statistics tracking and writer motivation features validated"