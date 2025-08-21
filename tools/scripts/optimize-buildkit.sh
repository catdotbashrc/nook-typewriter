#!/bin/bash
# BuildKit optimization helper for JesterOS

# Enable BuildKit globally
export DOCKER_BUILDKIT=1

# Configure BuildKit for optimal caching
cat > ~/.docker/buildkitd.toml << 'TOML'
[worker.oci]
  max-parallelism = 4

[registry."docker.io"]
  mirrors = ["mirror.gcr.io"]
TOML

echo "BuildKit optimized for JesterOS builds"
echo "Tips:"
echo "  - Use 'make docker-cache-info' to monitor cache"
echo "  - Use 'make docker-cache-clean' to clean cache"
echo "  - BuildKit cache persists between builds"