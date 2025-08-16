#!/bin/bash
# Fix Docker-created file permissions
# Run after any Docker operations that create files as root

set -euo pipefail
trap 'echo "Error at line $LINENO" >&2' ERR

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Fixing Docker permission issues..."

# Fix lenny-rootfs if it exists
if [ -d "lenny-rootfs" ]; then
    echo -e "${YELLOW}→${NC} Fixing lenny-rootfs permissions..."
    sudo chown -R "$USER:$USER" lenny-rootfs/
    echo -e "${GREEN}✓${NC} Fixed lenny-rootfs"
fi

# Fix any other Docker-created directories
for dir in firmware deployment_package output; do
    if [ -d "$dir" ]; then
        echo -e "${YELLOW}→${NC} Fixing $dir permissions..."
        sudo chown -R "$USER:$USER" "$dir" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Fixed $dir"
    fi
done

# Fix any tar.gz files created by Docker
for tarfile in *.tar.gz; do
    if [ -f "$tarfile" ] && [ ! -w "$tarfile" ]; then
        echo -e "${YELLOW}→${NC} Fixing $tarfile permissions..."
        sudo chown "$USER:$USER" "$tarfile"
        echo -e "${GREEN}✓${NC} Fixed $tarfile"
    fi
done

echo -e "${GREEN}✓${NC} Permission fixes complete!"
echo ""
echo "You can now use git add without permission errors."