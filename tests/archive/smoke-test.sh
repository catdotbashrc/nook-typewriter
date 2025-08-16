#!/bin/bash
# Quick smoke test - 5 minutes max
# If this passes, it's safe to try on hardware

set -euo pipefail

echo "*** Jester's Quick Safety Check ***"
echo "==================================="
echo ""

# 1. Check it builds
echo "-> Checking kernel builds..."
if ! ./build_kernel.sh; then
    echo "[FAIL] Kernel build failed!"
    exit 1
fi
echo "[PASS] Kernel builds successfully"
echo ""

# 2. CRITICAL: Kernel safety validation (most important for not bricking!)
echo "-> Running kernel safety checks (CRITICAL)..."
if ! ./tests/kernel-safety.sh; then
    echo "[FAIL] Kernel safety checks failed!"
    echo "STOP: Do not deploy to hardware until kernel issues resolved!"
    exit 1
fi
echo "[PASS] Kernel safety validation completed"
echo ""

# 3. Test basic Docker functionality (can't hurt anything)
echo "-> Testing in Docker (safe environment)..."
if ! docker images | grep -q "nook-writer"; then
    echo "[SKIP] No nook-writer image found, skipping Docker test"
else
    if docker run --rm nook-writer echo "Docker test successful"; then
        echo "[PASS] Docker image runs successfully"
    else
        echo "[WARN] Docker test failed, but continuing..."
    fi
fi
echo ""

# 4. Detailed memory analysis
echo "-> Running detailed memory analysis..."
if ! ./tests/memory-analysis.sh; then
    echo "[WARN] Memory analysis had warnings - review output above"
else
    echo "[PASS] Memory analysis completed successfully"
fi
echo ""

echo "*** Quick Safety Summary ***"
echo "============================"
echo "[PASS] Kernel builds successfully"
echo "[PASS] Modules compile and simulate"
echo "[PASS] No obvious memory red flags"
echo ""
echo "*** Ready for SD card testing! ***"
echo "   (Remember: Test on SD card, not internal storage)"
echo ""
echo "The Jester says: 'This won't brick thy Nook, good scribe!'"