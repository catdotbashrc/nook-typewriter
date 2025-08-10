#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Parse command line options
FORCE_REBUILD=false
SKIP_EXPORT=false
OUTPUT_FILE="nook-alpine-armv7.tar.gz"

while [[ $# -gt 0 ]]; do
  case $1 in
    --force)
      FORCE_REBUILD=true
      shift
      ;;
    --skip-export)
      SKIP_EXPORT=true
      shift
      ;;
    --output)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --force        Force rebuild even if image exists"
      echo "  --skip-export  Skip export step (just build image)"
      echo "  --output FILE  Output filename (default: nook-alpine-armv7.tar.gz)"
      echo "  --help         Show this help"
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Cleanup function
cleanup() {
  if [[ -n "${cid:-}" ]]; then
    log_info "Cleaning up container..."
    docker rm -f "$cid" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
  log_error "Docker is not running. Please start Docker and try again."
  exit 1
fi

# Check if image already exists
IMAGE_EXISTS=false
if docker image inspect nook-system:armv7 >/dev/null 2>&1; then
  IMAGE_EXISTS=true
  if [[ "$FORCE_REBUILD" == "false" ]]; then
    log_info "Image nook-system:armv7 already exists. Use --force to rebuild."
    log_info "Skipping build step..."
  else
    log_warning "Forcing rebuild of existing image..."
  fi
fi

# Ensure buildx builder exists
log_info "Setting up buildx builder..."
if ! docker buildx inspect nookbuilder >/dev/null 2>&1; then
  log_info "Creating new buildx builder 'nookbuilder'..."
  docker buildx create --name nookbuilder --use
else
  log_info "Using existing buildx builder 'nookbuilder'..."
  docker buildx use nookbuilder
fi

# Build ARMv7 image if needed
if [[ "$IMAGE_EXISTS" == "false" || "$FORCE_REBUILD" == "true" ]]; then
  log_info "Building ARMv7 image for Nook..."
  
  # Check if config directory exists
  if [[ ! -d "config" ]]; then
    log_error "Missing config/ directory. Please ensure config files are present."
    exit 1
  fi
  
  docker buildx build \
    --platform linux/arm/v7 \
    -t nook-system:armv7 \
    -f nookwriter.dockerfile \
    --load \
    --progress=plain \
    .
  
  log_success "Build completed successfully!"
else
  log_info "Using existing image nook-system:armv7"
fi

# Export rootfs tarball
if [[ "$SKIP_EXPORT" == "false" ]]; then
  log_info "Exporting rootfs to $OUTPUT_FILE..."
  
  # Remove existing output file if it exists
  if [[ -f "$OUTPUT_FILE" ]]; then
    log_warning "Removing existing $OUTPUT_FILE..."
    rm -f "$OUTPUT_FILE"
  fi
  
  # Create container and export
  cid="$(docker create --name nook-export nook-system:armv7)"
  log_info "Created temporary container: $cid"
  
  # Export with progress indicator
  docker export "$cid" | pv -N "Exporting" | gzip > "$OUTPUT_FILE" 2>/dev/null || \
  docker export "$cid" | gzip > "$OUTPUT_FILE"
  
  # Get file size for verification
  if [[ -f "$OUTPUT_FILE" ]]; then
    FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    log_success "Created $OUTPUT_FILE ($FILE_SIZE)"
    
    # Verify it's a valid gzip file
    if gzip -t "$OUTPUT_FILE" 2>/dev/null; then
      log_success "Rootfs archive verified successfully!"
    else
      log_error "Generated archive appears to be corrupted!"
      exit 1
    fi
  else
    log_error "Failed to create $OUTPUT_FILE"
    exit 1
  fi
else
  log_info "Skipping export step as requested"
fi

log_success "Build process completed!"
if [[ "$SKIP_EXPORT" == "false" ]]; then
  echo
  log_info "Next steps:"
  echo "  1. Write $OUTPUT_FILE to SD card using the nook-quick-start.md guide"
  echo "  2. Boot your rooted Nook with the custom kernel"
  echo "  3. Enjoy your Alpine Linux typewriter!"
fi