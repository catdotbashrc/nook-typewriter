#!/bin/bash
# Boot test - Check if basic boot components exist
# If these pass, the device should at least boot

set -euo pipefail

echo "🥾 BOOT TEST - Will it boot?"
echo "============================"
echo ""

BOOTABLE=true

# Check boot scripts
echo -n "✓ Boot scripts exist... "
BOOT_COUNT=$(ls ../runtime/init/*.sh 2>/dev/null | wc -l || echo "0")
if [ "$BOOT_COUNT" -gt 0 ]; then
    echo "YES ($BOOT_COUNT scripts)"
else
    echo "NO - No boot scripts!"
    BOOTABLE=false
fi

# Check JesterOS service
echo -n "✓ JesterOS service... "
if [ -f "../runtime/init/jesteros-boot.sh" ] || 
   [ -f "../runtime/2-application/jesteros/daemon.sh" ]; then
    echo "YES"
else
    echo "MISSING (but not critical)"
fi

# Check menu system
echo -n "✓ Menu system... "
if [ -f "../runtime/1-ui/menu/nook-menu.sh" ]; then
    echo "YES"
else
    echo "MISSING (will boot but no menu)"
fi

# Check common library
echo -n "✓ Common functions... "
if [ -f "../runtime/3-system/common/common.sh" ]; then
    echo "YES"
else
    echo "MISSING (scripts may fail)"
fi

# Check for boot configuration
echo -n "✓ Boot config... "
if [ -f "../boot/uEnv.txt" ]; then
    echo "YES"
else
    echo "MISSING (using defaults)"
fi

echo ""
if [ "$BOOTABLE" = true ]; then
    echo "✅ SHOULD BOOT"
    echo "The device should boot to at least a shell"
    exit 0
else
    echo "⚠️  MIGHT NOT BOOT"
    echo "Fix critical issues before deploying"
    exit 1
fi