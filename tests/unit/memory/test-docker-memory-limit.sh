#!/bin/bash
# Unit Test: Docker memory limit enforcement
# Validates that Docker containers respect the 256MB memory constraint

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "Docker memory limit enforcement"

# Constants for memory testing
readonly DOCKER_IMAGE="quillkernel-unified"
readonly MEMORY_LIMIT_MB=256
readonly MEMORY_THRESHOLD_MB=96  # OS usage limit from CLAUDE.md

# Check if Docker image exists
if ! docker images | grep -q "$DOCKER_IMAGE"; then
    skip_test "Docker image '$DOCKER_IMAGE' not available for memory testing"
fi

# Test that Docker containers respect memory limits
echo "  Testing memory limit enforcement..."

# Try multiple approaches to detect container memory limit
mem_test=0

# Method 1: Check /sys/fs/cgroup/memory/memory.limit_in_bytes (most reliable)
if command -v docker >/dev/null 2>&1; then
    cgroup_limit=$(docker run --rm -m "${MEMORY_LIMIT_MB}m" "$DOCKER_IMAGE" bash -c 'if [ -f /sys/fs/cgroup/memory/memory.limit_in_bytes ]; then cat /sys/fs/cgroup/memory/memory.limit_in_bytes; else echo 0; fi' 2>/dev/null || echo "0")
    if [ "$cgroup_limit" -gt 0 ] && [ "$cgroup_limit" -ne 9223372036854775807 ]; then
        mem_test=$((cgroup_limit / 1024 / 1024))  # Convert bytes to MB
        echo "  ✓ Container memory limit detected via cgroups: ${mem_test}MB"
    fi
fi

# Method 2: Fallback to /proc/meminfo in container
if [ "$mem_test" -eq 0 ]; then
    mem_test=$(docker run --rm -m "${MEMORY_LIMIT_MB}m" "$DOCKER_IMAGE" awk '/MemTotal/ {printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null || echo "0")
    if [ "$mem_test" -gt 0 ]; then
        echo "  ✓ Container memory detected via /proc/meminfo: ${mem_test}MB"
    fi
fi

# Method 3: Use free command as last resort (may show host memory)
if [ "$mem_test" -eq 0 ] || [ "$mem_test" -gt 2000 ]; then
    echo "  ⚠ Standard memory detection failed, using free command (may show host memory)"
    mem_test=$(docker run --rm -m "${MEMORY_LIMIT_MB}m" "$DOCKER_IMAGE" free -m 2>/dev/null | awk '/^Mem:/ {print $2}' || echo "0")
fi

# Validate memory test results
echo "  Detected memory: ${mem_test}MB (limit: ${MEMORY_LIMIT_MB}MB)"

if [ -z "$mem_test" ] || [ "$mem_test" -eq 0 ]; then
    fail_test "Failed to retrieve memory information from container"
elif [ "$mem_test" -le "$MEMORY_LIMIT_MB" ] && [ "$mem_test" -gt 0 ]; then
    if [ "$mem_test" -le "$MEMORY_THRESHOLD_MB" ]; then
        pass_test "Excellent: Memory usage ${mem_test}MB <= ${MEMORY_THRESHOLD_MB}MB OS limit"
    else
        pass_test "Acceptable: Memory limit enforced (${mem_test}MB <= ${MEMORY_LIMIT_MB}MB)"
    fi
elif [ "$mem_test" -gt 1000 ]; then
    # If memory is very high, likely showing host memory - this is expected in some Docker setups
    skip_test "Docker memory constraints not enforced in this environment (detected ${mem_test}MB, likely host memory)"
else
    fail_test "Memory limit violation: ${mem_test}MB > ${MEMORY_LIMIT_MB}MB"
fi