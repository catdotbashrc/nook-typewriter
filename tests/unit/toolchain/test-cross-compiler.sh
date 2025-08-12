#!/bin/bash
# Unit Test: Cross-compiler is available in Docker image

source "$(dirname "$0")/../../test-framework.sh"

init_test "Cross-compiler availability"

# Check if Docker image exists
if ! docker images | grep -q "quillkernel-unified"; then
    skip_test "Docker image not available for testing"
fi

# Check cross-compiler exists
compiler_path=$(docker run --rm quillkernel-unified which arm-linux-androideabi-gcc 2>/dev/null)

if [ -n "$compiler_path" ]; then
    pass_test "Cross-compiler found at: $compiler_path"
else
    fail_test "Cross-compiler arm-linux-androideabi-gcc not found"
fi