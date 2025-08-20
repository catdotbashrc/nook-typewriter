#!/bin/bash
# Docker Image Monitor for JesterOS
# Helps you keep track of all Docker images built for the project

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "═══════════════════════════════════════════════════════════════"
echo "              🐳 JesterOS Docker Image Monitor"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Function to format size
format_size() {
    local size=$1
    if [[ $size =~ MB$ ]]; then
        echo -e "${GREEN}$size${NC}"
    elif [[ $size =~ GB$ ]]; then
        echo -e "${RED}$size${NC}"
    else
        echo "$size"
    fi
}

# List all JesterOS images
echo -e "${BLUE}📦 JesterOS Docker Images:${NC}"
echo "────────────────────────────────────────────────────────────────"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}" | \
    grep -E "jesteros|kernel-xda|quillkernel|nook|REPOSITORY" | \
    while IFS=$'\t' read -r repo tag id created size; do
        if [[ "$repo" == "REPOSITORY" ]]; then
            printf "%-40s %-10s %-12s %-15s %s\n" "$repo" "$tag" "$id" "$created" "$size"
        else
            size_formatted=$(format_size "$size")
            printf "%-40s %-10s %-12s %-15s %s\n" "$repo" "$tag" "$id" "$created" "$size_formatted"
        fi
    done

echo ""
echo "────────────────────────────────────────────────────────────────"

# Calculate total disk usage
echo -e "${BLUE}💾 Disk Usage Summary:${NC}"
total_size=$(docker images --format "{{.Repository}}:{{.Tag}}:{{.Size}}" | \
    grep -E "jesteros|kernel-xda|quillkernel|nook" | \
    awk -F: '{print $3}' | \
    sed 's/GB/*1024/g; s/MB//g' | \
    awk '{sum += $1} END {printf "%.1f", sum}')

echo "  Total space used by JesterOS images: ${total_size}MB"

# Count images
image_count=$(docker images | grep -cE "jesteros|kernel-xda|quillkernel|nook" || true)
echo "  Number of JesterOS images: $image_count"

echo ""
echo "────────────────────────────────────────────────────────────────"

# Show dangling images
dangling_count=$(docker images -f "dangling=true" -q | wc -l)
if [ "$dangling_count" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Dangling Images Found:${NC}"
    echo "  $dangling_count dangling image(s) taking up space"
    dangling_size=$(docker images -f "dangling=true" --format "{{.Size}}" | \
        sed 's/GB/*1024/g; s/MB//g' | \
        awk '{sum += $1} END {printf "%.1f", sum}')
    echo "  Space used: ${dangling_size}MB"
    echo "  To clean: docker image prune"
else
    echo -e "${GREEN}✓ No dangling images${NC}"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo -e "${BLUE}📊 Image Details:${NC}"
echo ""

# Show detailed info for key images
for image in "jesteros-prod-multistage" "jesteros-production" "kernel-xda-proven" "kernel-xda-optimized"; do
    if docker images | grep -q "^$image "; then
        echo "→ $image:"
        docker images --format "  ID: {{.ID}}\n  Created: {{.CreatedSince}}\n  Size: {{.Size}}" "$image" | head -3
        
        # Check if image has been used
        if docker ps -a --format "{{.Image}}" | grep -q "$image"; then
            echo -e "  ${GREEN}Status: Used in containers${NC}"
        else
            echo -e "  ${YELLOW}Status: Never run${NC}"
        fi
        echo ""
    fi
done

echo "═══════════════════════════════════════════════════════════════"
echo -e "${BLUE}🛠️  Useful Commands:${NC}"
echo ""
echo "  View image layers:     docker history <image-name>"
echo "  Inspect image:         docker inspect <image-name>"
echo "  Remove image:          docker rmi <image-name>"
echo "  Remove unused images:  docker image prune -a"
echo "  Export image:          docker save <image> | gzip > image.tar.gz"
echo "  Run container:         docker run --rm -it <image-name> /bin/bash"
echo ""
echo "  Check specific image:  docker images jesteros-prod-multistage"
echo "  View build cache:      docker system df"
echo "  Clear build cache:     docker builder prune"
echo ""
echo "═══════════════════════════════════════════════════════════════"