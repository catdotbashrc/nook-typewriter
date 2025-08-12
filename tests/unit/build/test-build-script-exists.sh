#!/bin/bash
# Unit Test: Build script exists

source "$(dirname "$0")/../../test-framework.sh"

init_test "Build script existence"

build_script="$PROJECT_ROOT/build_kernel.sh"

assert_file_exists "$build_script" "Unified build script"

pass_test "Build script found at expected location"