#!/bin/bash
# Unit Test: NDK version is correct (4.9 for XDA-proven)

source "$(dirname "$0")/../../test-framework.sh"

init_test "NDK version verification"

# Build Docker image if needed
if ! docker images | grep -q "quillkernel-unified"; then
    echo "  Building Docker image for testing..."
    if ! docker build -t quillkernel-unified -f "$PROJECT_ROOT/build/docker/kernel-xda-proven.dockerfile" "$PROJECT_ROOT/build/docker/" >/dev/null 2>&1; then
        skip_test "Cannot build Docker image for testing"
    fi
fi

# Check NDK version
ndk_version=$(docker run --rm quillkernel-unified arm-linux-androideabi-gcc --version 2>/dev/null | head -1)

assert_contains "$ndk_version" "4.9" "NDK version should be 4.9 (XDA-proven)"

pass_test "NDK 4.9 toolchain verified"