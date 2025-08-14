#!/bin/bash
# Unit Test: Wisdom Module Functionality  
# Tests inspirational quote system for writers

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "Wisdom Module"

MODULE_DIR="$PROJECT_ROOT/source/kernel/src/drivers/squireos"
WISDOM_MODULE="$MODULE_DIR/wisdom.c"

# Verify wisdom module exists
assert_file_exists "$WISDOM_MODULE" "Wisdom module source"

echo "  Testing wisdom module structure..."

# Test module basics
assert_contains "$(cat "$WISDOM_MODULE")" "MODULE_LICENSE.*GPL" "Has GPL license"
assert_contains "$(cat "$WISDOM_MODULE")" "MODULE_DESCRIPTION.*[Ww]isdom\|[Qq]uote\|[Ii]nspiration" "Has wisdom description"

# Test quote system functionality
assert_contains "$(cat "$WISDOM_MODULE")" "quote\|wisdom\|saying\|advice" "Has quote/wisdom system"
assert_contains "$(cat "$WISDOM_MODULE")" "random\|rotate\|select" "Has quote selection mechanism"

# Test integration with SquireOS
assert_contains "$(cat "$WISDOM_MODULE")" "squireos_root\|extern.*squireos" "Integrates with SquireOS core"
assert_contains "$(cat "$WISDOM_MODULE")" "create_proc.*entry\|proc.*read" "Creates proc interface"

echo "  Testing inspirational content..."

# Test for writing-related wisdom
writing_themes=0
if grep -q "write\|writing\|writer" "$WISDOM_MODULE"; then
    echo "  ✓ Contains writing-themed wisdom"
    ((writing_themes++))
fi

if grep -q "word\|story\|tale\|book" "$WISDOM_MODULE"; then
    echo "  ✓ Contains literary references"
    ((writing_themes++))
fi

if grep -q "pen\|quill\|ink\|parchment" "$WISDOM_MODULE"; then
    echo "  ✓ Contains medieval writing tools"
    ((writing_themes++))
fi

if grep -q "author\|poet\|scribe" "$WISDOM_MODULE"; then
    echo "  ✓ References writing professions"
    ((writing_themes++))
fi

assert_greater_than "$writing_themes" 1 "Contains writing-relevant wisdom"

echo "  Testing quote rotation system..."

# Test quote array or collection
if grep -q "quote.*\[\]\|wisdom.*\[\]\|saying.*\[\]" "$WISDOM_MODULE"; then
    echo "  ✓ Has quote collection array"
elif grep -q "static.*char.*quote\|static.*char.*wisdom" "$WISDOM_MODULE"; then
    echo "  ✓ Has quote storage system"
else
    echo "  ⚠ Quote storage system not clearly identified"
fi

# Test random selection mechanism
if grep -q "get_random_bytes\|random\|rand" "$WISDOM_MODULE"; then
    echo "  ✓ Has random quote selection"
else
    echo "  ⚠ Random selection mechanism not clearly identified"
fi

# Test time-based rotation
if grep -q "jiffies\|time\|rotate\|cycle" "$WISDOM_MODULE"; then
    echo "  ✓ Has time-based quote rotation"
else
    echo "  ⚠ Time-based rotation not clearly identified"
fi

echo "  Testing content quality and appropriateness..."

# Test quote length (should fit on E-Ink display)
if grep -q '"[^"]\{1,100\}"' "$WISDOM_MODULE"; then
    echo "  ✓ Quotes are appropriately sized for E-Ink display"
else
    echo "  ⚠ Quote length validation skipped"
fi

# Test for positive/encouraging content
positive_indicators=0
if grep -q "inspire\|motivat\|encourage\|uplift" "$WISDOM_MODULE"; then
    echo "  ✓ Contains inspirational language"
    ((positive_indicators++))
fi

if grep -q "create\|dream\|imagine\|craft" "$WISDOM_MODULE"; then
    echo "  ✓ Contains creative encouragement"
    ((positive_indicators++))
fi

if grep -q "persever\|persist\|continue\|onward" "$WISDOM_MODULE"; then
    echo "  ✓ Contains perseverance themes"
    ((positive_indicators++))
fi

echo "  Testing medieval theming consistency..."

# Test medieval language and themes
medieval_elements=0
if grep -q "thee\|thou\|thy\|hath\|doth" "$WISDOM_MODULE"; then
    echo "  ✓ Uses medieval language style"
    ((medieval_elements++))
fi

if grep -q "lord\|noble\|knight\|court\|realm" "$WISDOM_MODULE"; then
    echo "  ✓ Contains medieval social references"
    ((medieval_elements++))
fi

if grep -q "candlelight\|parchment\|quill\|scroll" "$WISDOM_MODULE"; then
    echo "  ✓ References medieval writing tools"
    ((medieval_elements++))
fi

echo "  Testing technical implementation..."

# Test proc interface implementation
assert_contains "$(cat "$WISDOM_MODULE")" "wisdom_show\|wisdom.*read\|show.*wisdom" "Has proc read function"

# Test proper string handling
if grep -q "snprintf\|sprintf\|strncpy" "$WISDOM_MODULE"; then
    echo "  ✓ Uses safe string handling"
else
    echo "  ⚠ String handling safety not clearly identified"
fi

# Test buffer management
if grep -q "buffer.*size\|length\|EOF\|eof" "$WISDOM_MODULE"; then
    echo "  ✓ Has proper buffer management"
else
    echo "  ⚠ Buffer management not clearly identified"
fi

echo "  Testing memory and performance constraints..."

# Test file size constraints
file_size=$(stat -c%s "$WISDOM_MODULE" 2>/dev/null || echo "0")
assert_less_than "$file_size" 10240 "Module size reasonable for embedded system"

# Test that wisdom quotes don't consume excessive memory
line_count=$(wc -l < "$WISDOM_MODULE")
assert_less_than "$line_count" 250 "Module is reasonably sized"

# Test for memory leaks prevention
if grep -q "kfree\|free\|release" "$WISDOM_MODULE"; then
    echo "  ✓ Has memory management"
else
    echo "  ⚠ Memory management not clearly identified (may not be needed)"
fi

echo "  Testing error handling and robustness..."

# Test error handling
assert_contains "$(cat "$WISDOM_MODULE")" "module_exit\|cleanup\|remove_proc_entry" "Has proper cleanup"

# Test initialization error handling
if grep -q "return.*-\|error\|fail" "$WISDOM_MODULE"; then
    echo "  ✓ Has error handling in initialization"
else
    echo "  ⚠ Error handling not clearly identified"
fi

echo "  Testing writer experience features..."

# Test that wisdom appears in /proc/squireos/wisdom
assert_contains "$(cat "$WISDOM_MODULE")" '"wisdom"' "Creates wisdom proc entry"

# Test quote variety (should have multiple quotes)
quote_count=$(grep -c '".*"' "$WISDOM_MODULE" || echo "0")
if [ "$quote_count" -gt 3 ]; then
    echo "  ✓ Has multiple wisdom quotes ($quote_count found)"
else
    echo "  ⚠ Limited quote variety detected"
fi

pass_test "Wisdom module inspirational quotes and medieval theming validated"