#!/bin/bash
# Build script to download and cache FBInk binary
# Eliminates dependency on external Docker images

set -e

# Configuration
FBINK_VERSION="v1.25.0"
FBINK_URL="https://github.com/NiLuJe/FBInk/releases/download/${FBINK_VERSION}/fbink-${FBINK_VERSION}-armv7-linux-gnueabihf.tar.xz"
CACHE_DIR="${HOME}/.cache/nook-build"
FBINK_CACHE="${CACHE_DIR}/fbink-${FBINK_VERSION}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "FBInk Build Helper"
echo "=================="
echo ""

# Create cache directory
mkdir -p "$CACHE_DIR"

# Check if already cached
if [ -f "$FBINK_CACHE" ]; then
    echo -e "${GREEN}✓${NC} FBInk ${FBINK_VERSION} already cached"
    echo "  Location: $FBINK_CACHE"
else
    echo "Downloading FBInk ${FBINK_VERSION}..."
    
    # Download to temp file
    TEMP_FILE=$(mktemp)
    TEMP_DIR=$(mktemp -d)
    
    if wget -q -O "$TEMP_FILE" "$FBINK_URL"; then
        echo -e "${GREEN}✓${NC} Downloaded successfully"
        
        # Extract
        echo "Extracting..."
        tar -xJf "$TEMP_FILE" -C "$TEMP_DIR"
        
        # Find and cache the binary
        FBINK_BIN=$(find "$TEMP_DIR" -name "fbink" -type f -executable | head -1)
        
        if [ -n "$FBINK_BIN" ]; then
            cp "$FBINK_BIN" "$FBINK_CACHE"
            chmod +x "$FBINK_CACHE"
            echo -e "${GREEN}✓${NC} FBInk cached successfully"
        else
            echo -e "${YELLOW}⚠${NC} FBInk binary not found in archive"
            exit 1
        fi
        
        # Cleanup
        rm -rf "$TEMP_FILE" "$TEMP_DIR"
    else
        echo -e "${YELLOW}⚠${NC} Download failed"
        echo "  URL: $FBINK_URL"
        exit 1
    fi
fi

# Verify binary
if file "$FBINK_CACHE" | grep -q "ARM"; then
    echo -e "${GREEN}✓${NC} Binary verified (ARM architecture)"
else
    echo -e "${YELLOW}⚠${NC} Warning: Binary may not be ARM"
fi

# Show how to use in Dockerfile
echo ""
echo "To use in Dockerfile:"
echo "  COPY --from=build-cache $FBINK_CACHE /usr/local/bin/fbink"
echo ""
echo "Or directly:"
echo "  cp $FBINK_CACHE /usr/local/bin/fbink"

exit 0