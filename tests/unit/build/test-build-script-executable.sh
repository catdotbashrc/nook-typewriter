#!/bin/bash
# Unit Test: Build script is executable

source "$(dirname "$0")/../../test-framework.sh"

init_test "Build script executable"

build_script="$PROJECT_ROOT/build_kernel.sh"

assert_executable "$build_script" "Build script should be executable"

pass_test "Build script has executable permissions"