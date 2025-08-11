#!/bin/bash
# Test Docker build configurations

set -e

echo "Testing Docker builds..."

# Test minimal build
echo "  Testing minimal build..."
docker build --build-arg BUILD_MODE=minimal -t nook-test-minimal -f ../nookwriter-optimized.dockerfile .. >/dev/null 2>&1

# Test writer build
echo "  Testing writer build..."
docker build --build-arg BUILD_MODE=writer -t nook-test-writer -f ../nookwriter-optimized.dockerfile .. >/dev/null 2>&1

# Verify images exist
docker images | grep -q nook-test-minimal || exit 1
docker images | grep -q nook-test-writer || exit 1

# Test that vim is installed
docker run --rm nook-test-minimal which vim >/dev/null || exit 1
docker run --rm nook-test-writer which vim >/dev/null || exit 1

# Clean up
docker rmi nook-test-minimal nook-test-writer >/dev/null 2>&1

echo "  Docker build tests passed"