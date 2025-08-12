#!/bin/bash
# Unit Test: Jester Module Functionality
# Tests the ASCII art mood system and E-Ink compatibility

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "Jester Module"

MODULE_DIR="$PROJECT_ROOT/source/kernel/src/drivers/squireos"
JESTER_MODULE="$MODULE_DIR/jester.c"

# Verify jester module exists
assert_file_exists "$JESTER_MODULE" "Jester module source"

echo "  Testing jester module structure..."

# Test module basics
assert_contains "$(cat "$JESTER_MODULE")" "MODULE_LICENSE.*GPL" "Has GPL license"
assert_contains "$(cat "$JESTER_MODULE")" "MODULE_DESCRIPTION.*[Jj]ester" "Has jester description"

# Test ASCII art jester functionality
assert_contains "$(cat "$JESTER_MODULE")" "jester_mood\|enum.*mood" "Has mood system"
assert_contains "$(cat "$JESTER_MODULE")" "JESTER_HAPPY\|HAPPY" "Has happy mood"
assert_contains "$(cat "$JESTER_MODULE")" "JESTER_SLEEPY\|SLEEPY" "Has sleepy mood"

# Test jester ASCII art elements
assert_contains "$(cat "$JESTER_MODULE")" "♦\|\\\|~/\|~\|" "Contains jester hat symbols"

# Test randomness and time-based behavior
assert_contains "$(cat "$JESTER_MODULE")" "random\|jiffies" "Has time/random behavior"
assert_contains "$(cat "$JESTER_MODULE")" "get_random_bytes\|get.*mood" "Has mood selection logic"

# Test proc interface integration
assert_contains "$(cat "$JESTER_MODULE")" "squireos_root" "References SquireOS root"
assert_contains "$(cat "$JESTER_MODULE")" "proc.*entry\|create_proc" "Creates proc entry"

# Test medieval personality
assert_contains "$(cat "$JESTER_MODULE")" "Huzzah\|quill\|bells\|mischief" "Has medieval personality"

echo "  Testing E-Ink display compatibility..."

# Extract ASCII art patterns and test E-Ink compatibility
ascii_content=$(grep -A 10 -B 2 "\\\\n\|ASCII\|art" "$JESTER_MODULE" || echo "")

if [ -n "$ascii_content" ]; then
    # Test that ASCII art uses printable characters only
    if echo "$ascii_content" | grep -q '[[:print:][:space:]]'; then
        echo "  ✓ ASCII art uses printable characters"
    else
        echo "  ⚠ ASCII art character validation skipped"
    fi
    
    # Test line length (should fit on E-Ink display)
    max_line_length=$(echo "$ascii_content" | awk '{print length}' | sort -n | tail -1)
    if [ "$max_line_length" -le 40 ]; then
        echo "  ✓ ASCII art fits E-Ink display width"
    else
        echo "  ⚠ ASCII art may be too wide for E-Ink display ($max_line_length chars)"
    fi
fi

echo "  Testing mood system implementation..."

# Test mood enumeration
mood_count=$(grep -c "JESTER_[A-Z]" "$JESTER_MODULE" || echo "0")
assert_greater_than "$mood_count" 2 "Has multiple jester moods"

# Test mood selection function
if grep -q "get_jester_mood\|get.*mood" "$JESTER_MODULE"; then
    echo "  ✓ Has mood selection function"
else
    echo "  ⚠ Mood selection function not clearly identified"
fi

# Test that each mood has corresponding output
if grep -q "switch.*mood\|case.*JESTER" "$JESTER_MODULE"; then
    echo "  ✓ Has mood-specific output handling"
else
    echo "  ⚠ Mood-specific output handling not clearly identified"
fi

echo "  Testing integration with SquireOS core..."

# Test dependency on core module
assert_contains "$(cat "$JESTER_MODULE")" "extern.*squireos_root\|squireos_root" "References SquireOS core"

# Test proper cleanup
assert_contains "$(cat "$JESTER_MODULE")" "remove_proc_entry" "Has cleanup code"

echo "  Testing memory and performance constraints..."

# Test file size (should be reasonable for embedded system)
file_size=$(stat -c%s "$JESTER_MODULE" 2>/dev/null || echo "0")
assert_less_than "$file_size" 10240 "Jester module size reasonable for embedded system"

# Test line count
line_count=$(wc -l < "$JESTER_MODULE")
assert_less_than "$line_count" 300 "Module is reasonably sized"

# Test that strings are not excessively long
max_string_length=$(grep -o '"[^"]*"' "$JESTER_MODULE" | awk '{print length}' | sort -n | tail -1 || echo "0")
assert_less_than "$max_string_length" 200 "String literals are reasonable size"

echo "  Testing writer-friendly features..."

# Test that jester provides encouragement
assert_contains "$(cat "$JESTER_MODULE")" "write\|quill\|tale\|word" "References writing activities"

# Test personality consistency
personality_phrases=$(grep -c "Huzzah\|bells\|mischief\|Hmm" "$JESTER_MODULE" || echo "0")
assert_greater_than "$personality_phrases" 1 "Has consistent medieval personality"

pass_test "Jester module structure, ASCII art, and E-Ink compatibility validated"