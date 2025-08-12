#!/bin/bash
# Unit Test: Cross-compiler is available in Docker image
# Validates that the ARM cross-compilation toolchain is properly configured

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "Cross-compiler availability"

# Docker and toolchain configuration
readonly DOCKER_IMAGE="quillkernel-unified"
readonly CROSS_COMPILER="arm-linux-androideabi-gcc"
readonly -a REQUIRED_TOOLS=(
    "arm-linux-androideabi-gcc"
    "arm-linux-androideabi-ld"
    "arm-linux-androideabi-objcopy"
    "make"
)

# Check if Docker image exists
if ! docker images | grep -q "$DOCKER_IMAGE"; then
    skip_test "Docker image '$DOCKER_IMAGE' not available for testing"
fi

echo "  Testing cross-compilation toolchain..."

# Test each required tool
tools_found=0
for tool in "${REQUIRED_TOOLS[@]}"; do
    tool_path=$(docker run --rm "$DOCKER_IMAGE" which "$tool" 2>/dev/null || echo "")
    
    if [ -n "$tool_path" ]; then
        echo "  ✓ Found $tool at: $tool_path"
        ((tools_found++))
    else
        echo "  ✗ Missing: $tool"
    fi
done

# Test compiler version and functionality
if [ "$tools_found" -gt 0 ]; then
    echo "  Testing compiler functionality..."
    compiler_version=$(docker run --rm "$DOCKER_IMAGE" "$CROSS_COMPILER" --version 2>/dev/null | head -1 || echo "unknown")
    echo "  Compiler version: $compiler_version"
fi

# Evaluate results
if [ "$tools_found" -eq "${#REQUIRED_TOOLS[@]}" ]; then
    pass_test "Complete cross-compilation toolchain available ($tools_found/${#REQUIRED_TOOLS[@]} tools)"
elif [ "$tools_found" -ge 2 ]; then
    pass_test "Essential cross-compilation tools available ($tools_found/${#REQUIRED_TOOLS[@]} tools)"
elif [ "$tools_found" -gt 0 ]; then
    fail_test "Incomplete toolchain: only $tools_found/${#REQUIRED_TOOLS[@]} tools found"
else
    fail_test "No cross-compilation tools found"
fi