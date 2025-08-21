#!/bin/bash
# Unified test runner for JesterOS build system
set -euo pipefail

TESTS_DIR="$(dirname "$0")"
FAILED_TESTS=()
PASSED_TESTS=()

echo "════════════════════════════════════════════════════════════════"
echo "                 JesterOS Test Suite Execution"
echo "════════════════════════════════════════════════════════════════"

# Run each test script
for test_script in "$TESTS_DIR"/*.sh; do
    if [ "$test_script" != "$0" ] && [ -x "$test_script" ]; then
        test_name=$(basename "$test_script")
        echo ""
        echo "Running: $test_name"
        echo "────────────────────────────────────────────────────────────────"
        
        if "$test_script"; then
            PASSED_TESTS+=("$test_name")
            echo "✓ $test_name PASSED"
        else
            FAILED_TESTS+=("$test_name")
            echo "✗ $test_name FAILED"
        fi
    fi
done

# Summary
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "                        Test Summary"
echo "════════════════════════════════════════════════════════════════"
echo "Passed: ${#PASSED_TESTS[@]}"
echo "Failed: ${#FAILED_TESTS[@]}"

if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
    echo ""
    echo "✅ All tests passed!"
    exit 0
else
    echo ""
    echo "❌ Some tests failed:"
    for test in "${FAILED_TESTS[@]}"; do
        echo "  - $test"
    done
    exit 1
fi