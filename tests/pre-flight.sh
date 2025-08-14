#!/bin/bash
# Pre-flight checklist for first hardware deployment
# Manual verification before risking actual hardware

echo "*** Pre-Flight Safety Checklist ***"
echo "===================================="
echo ""
echo "Before deploying to actual Nook hardware:"
echo ""

# Function to wait for user confirmation
confirm() {
    while true; do
        read -p "[CHECK] $1 [y/N]: " yn
        case $yn in
            [Yy]* ) echo "[PASS] Confirmed"; break;;
            [Nn]* ) echo "[FAIL] Please complete this step first"; exit 1;;
            * ) echo "[FAIL] Please complete this step first"; exit 1;;
        esac
    done
}

echo "*** SAFETY CHECKS: ***"
confirm "Nook internal storage is backed up"
confirm "Using SD card (NOT internal storage)"
confirm "Have a known-good SD card ready for rollback"
confirm "Smoke test passed (./tests/smoke-test.sh)"
confirm "Tested basic functionality in Docker first"

echo ""
echo "*** TECHNICAL CHECKS: ***"
confirm "Build completed without errors"
confirm "Kernel safety test passed (./tests/kernel-safety.sh)"
confirm "Kernel modules compiled successfully"  
confirm "No critical warnings in smoke test"
confirm "Tested kernel module loading simulation"

echo ""
echo "*** DEPLOYMENT READY: ***"
confirm "Ready to proceed with SD card flashing"

echo ""
echo "*** All checks passed! The Jester approves. ***"
echo ""
echo "Deploy with: sudo ./tools/deploy/flash-sd.sh"
echo "Safety: Remove SD card to revert to original Nook"
echo ""
echo "May your words flow like ink, good scribe!"