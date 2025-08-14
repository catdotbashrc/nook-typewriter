#!/bin/bash
# Unit Test: XDA-proven Dockerfile exists

source "$(dirname "$0")/../../test-framework.sh"

init_test "XDA-proven Dockerfile"

dockerfile="$PROJECT_ROOT/build/docker/kernel-xda-proven.dockerfile"

assert_file_exists "$dockerfile" "XDA-proven Dockerfile"

pass_test "Dockerfile found at expected location"