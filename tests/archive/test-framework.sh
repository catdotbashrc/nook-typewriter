#!/bin/bash
# Test Framework for QuillKernel Unit Tests
# Provides common functions for all unit tests

set -euo pipefail

# Export for child scripts
export TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$(dirname "$TEST_ROOT")"

# Color codes for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export NC='\033[0m' # No Color

# Test state
export TEST_NAME=""
export TEST_PASSED=0
export TEST_FAILED=0

# Initialize test
init_test() {
    TEST_NAME="$1"
    echo -e "${BLUE}[TEST]${NC} $TEST_NAME"
}

# Pass test
pass_test() {
    local message="${1:-Test passed}"
    echo -e "${GREEN}[PASS]${NC} $TEST_NAME: $message"
    TEST_PASSED=1
    exit 0
}

# Fail test
fail_test() {
    local message="${1:-Test failed}"
    echo -e "${RED}[FAIL]${NC} $TEST_NAME: $message"
    TEST_FAILED=1
    exit 1
}

# Skip test
skip_test() {
    local reason="${1:-Dependency not met}"
    echo -e "${YELLOW}[SKIP]${NC} $TEST_NAME: $reason"
    exit 0
}

# Assertion functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"
    
    if [ "$expected" = "$actual" ]; then
        echo "  ✓ $message"
        return 0
    else
        echo "  ✗ $message"
        echo "    Expected: $expected"
        echo "    Actual: $actual"
        fail_test "$message"
    fi
}

assert_not_equals() {
    local unexpected="$1"
    local actual="$2"
    local message="${3:-Values should not be equal}"
    
    if [ "$unexpected" != "$actual" ]; then
        echo "  ✓ $message"
        return 0
    else
        echo "  ✗ $message"
        echo "    Both values: $actual"
        fail_test "$message"
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Should contain substring}"
    
    if echo "$haystack" | grep -q "$needle"; then
        echo "  ✓ $message"
        return 0
    else
        echo "  ✗ $message"
        echo "    Looking for: $needle"
        fail_test "$message"
    fi
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Should not contain substring}"
    
    if ! echo "$haystack" | grep -q "$needle"; then
        echo "  ✓ $message"
        return 0
    else
        echo "  ✗ $message"
        echo "    Found unexpected: $needle"
        fail_test "$message"
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist}"
    
    if [ -f "$file" ]; then
        echo "  ✓ $message: $file"
        return 0
    else
        echo "  ✗ $message"
        echo "    File not found: $file"
        fail_test "$message"
    fi
}

assert_file_not_exists() {
    local file="$1"
    local message="${2:-File should not exist}"
    
    if [ ! -f "$file" ]; then
        echo "  ✓ $message"
        return 0
    else
        echo "  ✗ $message"
        echo "    File exists: $file"
        fail_test "$message"
    fi
}

assert_directory_exists() {
    local dir="$1"
    local message="${2:-Directory should exist}"
    
    if [ -d "$dir" ]; then
        echo "  ✓ $message: $dir"
        return 0
    else
        echo "  ✗ $message"
        echo "    Directory not found: $dir"
        fail_test "$message"
    fi
}

assert_executable() {
    local file="$1"
    local message="${2:-File should be executable}"
    
    if [ -x "$file" ]; then
        echo "  ✓ $message: $file"
        return 0
    else
        echo "  ✗ $message"
        echo "    Not executable: $file"
        fail_test "$message"
    fi
}

assert_command_exists() {
    local cmd="$1"
    local message="${2:-Command should exist}"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  ✓ $message: $cmd"
        return 0
    else
        echo "  ✗ $message"
        echo "    Command not found: $cmd"
        fail_test "$message"
    fi
}

assert_greater_than() {
    local value="$1"
    local threshold="$2"
    local message="${3:-Value should be greater than threshold}"
    
    if [ "$value" -gt "$threshold" ]; then
        echo "  ✓ $message ($value > $threshold)"
        return 0
    else
        echo "  ✗ $message"
        echo "    Value: $value"
        echo "    Threshold: $threshold"
        fail_test "$message"
    fi
}

assert_less_than() {
    local value="$1"
    local threshold="$2"
    local message="${3:-Value should be less than threshold}"
    
    if [ "$value" -lt "$threshold" ]; then
        echo "  ✓ $message ($value < $threshold)"
        return 0
    else
        echo "  ✗ $message"
        echo "    Value: $value"
        echo "    Threshold: $threshold"
        fail_test "$message"
    fi
}

assert_docker_image_exists() {
    local image="$1"
    local message="${2:-Docker image should exist}"
    
    if docker images | grep -q "$image"; then
        echo "  ✓ $message: $image"
        return 0
    else
        echo "  ✗ $message"
        echo "    Docker image not found: $image"
        fail_test "$message"
    fi
}

# Cleanup function
cleanup() {
    # Override in individual tests if needed
    true
}

# Trap for cleanup
trap cleanup EXIT