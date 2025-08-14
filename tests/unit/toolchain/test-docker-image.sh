#!/bin/bash
# Unit Test: Docker image exists for unified build

source "$(dirname "$0")/../../test-framework.sh"

init_test "Docker image exists"

# Check if unified Docker image exists
if docker images | grep -q "quillkernel-unified"; then
    pass_test "Unified Docker image 'quillkernel-unified' exists"
else
    fail_test "Unified Docker image 'quillkernel-unified' not found"
fi