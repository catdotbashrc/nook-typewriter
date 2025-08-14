#!/bin/bash
# Unit Test: Dockerfile uses XDA-proven NDK version

source "$(dirname "$0")/../../test-framework.sh"

init_test "Dockerfile NDK version"

dockerfile="$PROJECT_ROOT/build/docker/kernel-xda-proven.dockerfile"

if [ ! -f "$dockerfile" ]; then
    skip_test "Dockerfile not found"
fi

# Check for NDK r12b (XDA-proven)
assert_contains "$(cat "$dockerfile")" "android-ndk-r12b" "Dockerfile should use NDK r12b"

pass_test "Dockerfile configured for XDA-proven NDK r12b"