#!/bin/bash
# Unit Test: Medieval theme in messages

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "Medieval themed messages"

medieval_terms=("quill" "candlelight" "scribe" "parchment" "scroll" "thy" "thee")
found_count=0

for term in "${medieval_terms[@]}"; do
    if grep -ri "$term" "$PROJECT_ROOT/source/scripts/" 2>/dev/null | head -1 >/dev/null; then
        found_count=$((found_count + 1))
        echo "  ✓ Found medieval term: $term"
    fi
done

assert_greater_than "$found_count" 2 "Should have at least 3 medieval terms"

pass_test "Medieval theme preserved (found $found_count/7 terms)"
