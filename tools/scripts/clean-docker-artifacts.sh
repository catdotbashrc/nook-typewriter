#!/bin/bash
# Clean Docker artifacts from firmware directory
# Safe cleanup that preserves functionality while removing Docker contamination

set -euo pipefail
trap 'echo "Error at line $LINENO" >&2' ERR

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🧹 Cleaning Docker artifacts from platform/nook-touch/"
echo "============================================"

# Counter for changes
CHANGES=0

# 1. Remove .dockerenv files if they exist
echo -e "${YELLOW}Checking for .dockerenv files...${NC}"
if find platform/nook-touch/ -name ".dockerenv" -type f 2>/dev/null | grep -q .; then
    find platform/nook-touch/ -name ".dockerenv" -type f -delete
    echo -e "${GREEN}✓ Removed .dockerenv files${NC}"
    CHANGES=$((CHANGES + 1))
else
    echo "  No .dockerenv files found"
fi

# 2. Remove .dockerignore files
echo -e "${YELLOW}Checking for .dockerignore files...${NC}"
if find platform/nook-touch/ -name ".dockerignore" -type f 2>/dev/null | grep -q .; then
    find platform/nook-touch/ -name ".dockerignore" -type f -delete
    echo -e "${GREEN}✓ Removed .dockerignore files${NC}"
    CHANGES=$((CHANGES + 1))
else
    echo "  No .dockerignore files found"
fi

# 3. Clean Docker references from scripts (safe mode - just comments)
echo -e "${YELLOW}Cleaning Docker references from scripts...${NC}"

# Fix the jesteros-service-init.sh file
INIT_SCRIPT="platform/nook-touch/rootfs/usr/local/bin/jesteros-service-init.sh"
if [[ -f "$INIT_SCRIPT" ]]; then
    # Replace Docker-specific comment with generic one
    if grep -q "for Docker environments" "$INIT_SCRIPT" 2>/dev/null; then
        sed -i 's/# Set TERM if not set (for Docker environments)/# Set TERM if not set (for compatibility)/' "$INIT_SCRIPT"
        echo -e "${GREEN}✓ Cleaned Docker reference from jesteros-service-init.sh${NC}"
        CHANGES=$((CHANGES + 1))
    else
        echo "  No Docker references in init script"
    fi
fi

# 4. Check for any Dockerfile remnants
echo -e "${YELLOW}Checking for Dockerfile remnants...${NC}"
if find platform/nook-touch/ -name "Dockerfile*" -type f 2>/dev/null | grep -q .; then
    find platform/nook-touch/ -name "Dockerfile*" -type f -delete
    echo -e "${GREEN}✓ Removed Dockerfile remnants${NC}"
    CHANGES=$((CHANGES + 1))
else
    echo "  No Dockerfile remnants found"
fi

# 5. Remove Docker-specific environment variables from scripts
echo -e "${YELLOW}Checking for Docker-specific environment variables...${NC}"
DOCKER_ENV_COUNT=$(grep -r "DOCKER_" platform/nook-touch/ 2>/dev/null | wc -l || true)
if [[ $DOCKER_ENV_COUNT -gt 0 ]]; then
    echo -e "${YELLOW}  Found $DOCKER_ENV_COUNT Docker environment references${NC}"
    echo "  These should be manually reviewed for safety"
else
    echo "  No Docker environment variables found"
fi

# 6. Create a production marker file
echo -e "${YELLOW}Creating production marker...${NC}"
echo "# JesterOS Production Build" > platform/nook-touch/PRODUCTION_BUILD
echo "# Built without Docker contamination" >> platform/nook-touch/PRODUCTION_BUILD
echo "# Date: $(date)" >> platform/nook-touch/PRODUCTION_BUILD
echo -e "${GREEN}✓ Created production marker${NC}"
CHANGES=$((CHANGES + 1))

# Summary
echo ""
echo "============================================"
if [[ $CHANGES -gt 0 ]]; then
    echo -e "${GREEN}✅ Cleanup complete: $CHANGES changes made${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Rebuild firmware with: make firmware"
    echo "2. Verify clean build with: tar -tzf firmware.tar.gz | grep -i docker"
    echo "3. Test on actual Nook hardware"
else
    echo -e "${GREEN}✅ No Docker artifacts found - firmware is clean!${NC}"
fi
echo "============================================"