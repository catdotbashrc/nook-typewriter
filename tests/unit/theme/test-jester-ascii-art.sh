#!/bin/bash
# Unit Test: Jester ASCII art
# Validates the presence and quality of medieval jester ASCII art assets

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "Jester ASCII art"

# ASCII art configuration
readonly ASCII_DIR="$PROJECT_ROOT/source/configs/ascii"
readonly JESTER_SUBDIR="$ASCII_DIR/jester"

# Expected jester characteristics (Unicode and ASCII patterns)
readonly -a JESTER_PATTERNS=(
    "◡"  # White circle (face)
    "☺"  # Smiling face
    "⌒"  # Arc
    "∩"  # Intersection
    "o"   # Simple eyes
    "<"   # Mouth elements
    ">"
    "|"
    "/"
    "\\"
)

# Test ASCII art directory structure
assert_directory_exists "$ASCII_DIR" "ASCII art directory"

if [ -d "$JESTER_SUBDIR" ]; then
    echo "  ✓ Found jester subdirectory"
    search_dir="$JESTER_SUBDIR"
else
    echo "  ⚠ Using main ASCII directory (jester subdir not found)"
    search_dir="$ASCII_DIR"
fi

# Check for jester ASCII art files
jester_files=$(find "$search_dir" -name "*jester*.txt" -o -name "*ascii*.txt" 2>/dev/null)
jester_count=$(echo "$jester_files" | grep -c . 2>/dev/null || echo "0")

if [ "$jester_count" -eq 0 ]; then
    fail_test "No jester ASCII art files found in $search_dir"
fi

echo "  Found $jester_count ASCII art files"

# Verify ASCII art quality and content
pattern_matches=0
total_content=""

while IFS= read -r file; do
    if [ -f "$file" ] && [ -s "$file" ]; then
        echo "  ✓ Reading: $(basename "$file")"
        content=$(head -20 "$file" 2>/dev/null || true)
        total_content="$total_content\n$content"
    fi
done <<< "$jester_files"

# Check for jester characteristic patterns
for pattern in "${JESTER_PATTERNS[@]}"; do
    if echo -e "$total_content" | grep -q "$pattern"; then
        ((pattern_matches++))
    fi
done

echo "  Found $pattern_matches/${#JESTER_PATTERNS[@]} characteristic jester patterns"

if [ "$pattern_matches" -ge 3 ]; then
    pass_test "Jester ASCII art contains appropriate elements ($pattern_matches patterns found)"
elif [ "$pattern_matches" -gt 0 ]; then
    pass_test "Basic ASCII art present ($pattern_matches patterns found, could be enhanced)"
else
    fail_test "Jester ASCII art missing characteristic elements"
fi