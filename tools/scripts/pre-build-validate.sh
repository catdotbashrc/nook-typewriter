#!/bin/bash
# Pre-build validation for JesterOS
set -euo pipefail

source "$(dirname "$0")/lib/validation.sh"

echo "Running pre-build validation..."

# Check Docker availability
if ! command -v docker >/dev/null 2>&1; then
    echo "Error: Docker not found"
    exit 1
fi

# Check BuildKit support
if ! docker buildx version >/dev/null 2>&1; then
    echo "Warning: Docker BuildKit not available, builds will be slower"
fi

# Validate project structure
required_dirs=(
    "build/docker"
    "build/scripts"
    "src/configs"
    "scripts"
)

for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "Error: Required directory $dir not found"
        exit 1
    fi
done

echo "✓ Pre-build validation passed"