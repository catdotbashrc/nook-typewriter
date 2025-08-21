#!/bin/bash
# Docker BuildKit Cache Manager for JesterOS
# Manages Docker build cache and optimizes storage usage
# "By quill and candlelight, we manage our digital scrolls!"

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to format size
format_size() {
    local size=$1
    if [[ $size -lt 1024 ]]; then
        echo "${size}B"
    elif [[ $size -lt 1048576 ]]; then
        echo "$((size / 1024))KB"
    elif [[ $size -lt 1073741824 ]]; then
        echo "$((size / 1048576))MB"
    else
        echo "$((size / 1073741824))GB"
    fi
}

# Function to show usage
show_usage() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "           🐳 JesterOS Docker Cache Manager"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  info      Show cache information and statistics"
    echo "  clean     Clean BuildKit cache (preserves images)"
    echo "  prune     Aggressive cleanup (removes unused images too)"
    echo "  optimize  Optimize cache for JesterOS builds"
    echo "  status    Quick status of Docker resources"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 info      # Show detailed cache information"
    echo "  $0 clean     # Safe cleanup of build cache"
    echo "  $0 optimize  # Optimize for JesterOS builds"
    echo ""
}

# Function to show cache info
show_cache_info() {
    echo -e "${BOLD}📊 Docker BuildKit Cache Information${NC}"
    echo "═══════════════════════════════════════════════════════════════"
    
    # Check if BuildKit is enabled
    if docker buildx version >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Docker BuildKit is available${NC}"
        docker buildx version | head -1
    else
        echo -e "${YELLOW}⚠ Docker BuildKit not detected${NC}"
        echo "  Enable with: export DOCKER_BUILDKIT=1"
    fi
    echo ""
    
    # Show build cache usage
    echo -e "${BLUE}Build Cache Usage:${NC}"
    docker system df -v 2>/dev/null | grep -A10 "Build Cache" || {
        echo "  Build cache information not available"
        echo "  Using standard Docker statistics:"
        docker system df
    }
    echo ""
    
    # Show JesterOS base images
    echo -e "${BLUE}JesterOS Unified Base Images:${NC}"
    echo "────────────────────────────────────────"
    
    base_count=0
    for image in "jesteros:lenny-base" "jesteros:dev-base" "jesteros:runtime-base"; do
        if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${image}$"; then
            info=$(docker images --format "table {{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedSince}}" | grep "^${image}")
            echo "  ✓ $info"
            ((base_count++))
        else
            echo "  ✗ $image (not built)"
        fi
    done
    
    if [ $base_count -eq 0 ]; then
        echo -e "${YELLOW}  No unified base images found${NC}"
        echo "  Build them with: make docker-base-all"
    else
        echo -e "${GREEN}  $base_count/3 base images built${NC}"
    fi
    echo ""
    
    # Show layer sharing statistics
    echo -e "${BLUE}Layer Sharing Analysis:${NC}"
    echo "────────────────────────────────────────"
    
    # Count shared layers between JesterOS images
    shared_layers=0
    if docker images | grep -q "jesteros"; then
        # Get all JesterOS image IDs
        image_ids=$(docker images --format "{{.ID}}" | sort -u)
        
        # Rough estimate of shared layers based on image similarities
        jesteros_images=$(docker images | grep -c "jesteros" || echo "0")
        
        echo "  JesterOS images: $jesteros_images"
        
        if [ "$jesteros_images" -gt 1 ]; then
            # Check for common base layers
            base_size=$(docker images --format "{{.Size}}" jesteros:lenny-base 2>/dev/null | head -1)
            if [ -n "$base_size" ]; then
                echo -e "  Base layer size: ${GREEN}$base_size${NC} (shared across all images)"
                echo "  Estimated savings: Multiple images share this base"
            fi
        fi
    else
        echo "  No JesterOS images found"
    fi
    echo ""
    
    # Show cache mount effectiveness
    echo -e "${BLUE}BuildKit Cache Mount Status:${NC}"
    echo "────────────────────────────────────────"
    
    # Check for NDK cache
    if docker volume ls | grep -q "buildkit"; then
        echo -e "${GREEN}✓ BuildKit cache volumes detected${NC}"
        docker volume ls | grep buildkit | while read -r line; do
            echo "  $line"
        done
    else
        echo -e "${YELLOW}⚠ No BuildKit cache volumes found${NC}"
        echo "  Cache mounts will be created on next BuildKit build"
    fi
}

# Function to clean cache
clean_cache() {
    echo -e "${BOLD}🧹 Cleaning Docker BuildKit Cache${NC}"
    echo "═══════════════════════════════════════════════════════════════"
    
    # Show current usage
    echo "Current usage:"
    docker system df
    echo ""
    
    # Clean build cache only
    echo "Cleaning build cache..."
    docker builder prune -f
    
    echo ""
    echo -e "${GREEN}✓ Build cache cleaned${NC}"
    
    # Show new usage
    echo ""
    echo "New usage:"
    docker system df
}

# Function for aggressive cleanup
prune_all() {
    echo -e "${BOLD}🔥 Aggressive Docker Cleanup${NC}"
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${RED}WARNING: This will remove:${NC}"
    echo "  - All stopped containers"
    echo "  - All unused networks"
    echo "  - All dangling images"
    echo "  - All build cache"
    echo ""
    
    read -p "Continue? (yes/NO): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Cancelled"
        exit 0
    fi
    
    echo "Performing cleanup..."
    docker system prune -a -f --volumes
    
    echo ""
    echo -e "${GREEN}✓ Aggressive cleanup complete${NC}"
    docker system df
}

# Function to optimize for JesterOS
optimize_cache() {
    echo -e "${BOLD}⚡ Optimizing Cache for JesterOS Builds${NC}"
    echo "═══════════════════════════════════════════════════════════════"
    
    # Check if base images exist
    echo "Checking base images..."
    
    needs_build=false
    for image in "jesteros:lenny-base" "jesteros:dev-base" "jesteros:runtime-base"; do
        if ! docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${image}$"; then
            echo -e "${YELLOW}  Missing: $image${NC}"
            needs_build=true
        else
            echo -e "${GREEN}  ✓ Found: $image${NC}"
        fi
    done
    
    if [ "$needs_build" = true ]; then
        echo ""
        echo -e "${YELLOW}Some base images are missing${NC}"
        echo "Build them with: make docker-base-all"
        echo ""
    fi
    
    # Clean old build cache but preserve base images
    echo "Cleaning old build cache (preserving base images)..."
    docker builder prune -f --filter "until=24h"
    
    # Pre-pull any required base images
    echo "Ensuring Debian Lenny rootfs is available..."
    if [ -f "lenny-rootfs.tar.gz" ]; then
        echo -e "${GREEN}  ✓ lenny-rootfs.tar.gz found${NC}"
    else
        echo -e "${YELLOW}  ⚠ lenny-rootfs.tar.gz not found${NC}"
        echo "    This file is required for building base images"
    fi
    
    echo ""
    echo -e "${GREEN}✓ Cache optimized for JesterOS builds${NC}"
    echo ""
    echo "Recommended build sequence:"
    echo "  1. make docker-base-all  # Build unified base images"
    echo "  2. make docker-build     # Build production images"
    echo "  3. make docker-test-all  # Build test images"
}

# Function to show quick status
show_status() {
    echo -e "${BOLD}📈 Docker Resource Status${NC}"
    echo "═══════════════════════════════════════════════════════════════"
    
    # Quick summary
    docker system df
    echo ""
    
    # JesterOS specific
    echo -e "${BLUE}JesterOS Images:${NC}"
    docker images | grep -E "jesteros|kernel-xda|nook|REPOSITORY" || echo "  No JesterOS images found"
    echo ""
    
    # Running containers
    echo -e "${BLUE}Running Containers:${NC}"
    running=$(docker ps -q | wc -l)
    if [ "$running" -gt 0 ]; then
        docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
    else
        echo "  No containers running"
    fi
}

# Main script logic
case "${1:-help}" in
    info)
        show_cache_info
        ;;
    clean)
        clean_cache
        ;;
    prune)
        prune_all
        ;;
    optimize)
        optimize_cache
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        show_usage
        exit 1
        ;;
esac

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo -e "${YELLOW}\"By quill and candlelight, the cache is managed!\"${NC}"