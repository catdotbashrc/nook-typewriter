#!/bin/bash
# Unit Test: Docker memory limit enforcement

source "$(dirname "$0")/../../test-framework.sh"

init_test "Docker memory limit enforcement"

# Check if Docker image exists
if ! docker images | grep -q "quillkernel-unified"; then
    skip_test "Docker image not available for memory testing"
fi

# Test that Docker containers respect memory limits
mem_test=$(docker run --rm -m 256m quillkernel-unified free -m 2>/dev/null | grep Mem | awk '{print $2}')

if [ -n "$mem_test" ] && [ "$mem_test" -le 256 ]; then
    pass_test "Docker memory limit enforced: ${mem_test}MB"
else
    fail_test "Docker memory limit not enforced or test failed: ${mem_test}MB"
fi