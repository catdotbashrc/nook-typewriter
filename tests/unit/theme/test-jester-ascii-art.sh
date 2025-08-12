#!/bin/bash
# Unit Test: Jester ASCII art

source "$(dirname "$0")/../../test-framework.sh"

init_test "Jester ASCII art"

ascii_dir="$PROJECT_ROOT/source/configs/ascii"

assert_directory_exists "$ascii_dir" "ASCII art directory"

# Check for jester ASCII art files
jester_count=$(find "$ascii_dir" -name "jester*.txt" 2>/dev/null | wc -l)

assert_greater_than "$jester_count" 0 "Jester ASCII art files should exist"

# Verify ASCII art contains jester elements
jester_art=$(cat "$ascii_dir"/jester*.txt 2>/dev/null | head -20)

if echo "$jester_art" | grep -q "◡\|☺\|⌒\|∩"; then
    pass_test "Jester ASCII art contains appropriate characters"
else
    fail_test "Jester ASCII art missing characteristic elements"
fi