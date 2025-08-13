#!/bin/bash
# Memory Analysis for Nook Typewriter
# Detailed memory allocation and usage testing to validate our 96MB OS budget

set -euo pipefail

echo "*** Detailed Memory Analysis ***"
echo "================================="
echo ""
echo "Testing memory usage against our constraint:"
echo "Total RAM: 256MB | OS Budget: 96MB | Writing Space: 160MB (SACRED)"
echo ""

# 1. Docker memory analysis (safe simulation)
echo "-> Analyzing memory usage in Docker simulation..."
if docker images | grep -q "nook-writer"; then
    echo ""
    echo "=== Docker Container Memory Analysis ==="
    
    # Start container and get detailed memory info
    CONTAINER_ID=$(docker run -d nook-writer sleep 60)
    sleep 2  # Let it settle
    
    # Get detailed memory stats
    echo "Container memory usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}\t{{.MemPerc}}" $CONTAINER_ID
    
    # Get process-level memory usage inside container
    echo ""
    echo "Process-level memory usage inside container:"
    docker exec $CONTAINER_ID sh -c 'ps aux --sort=-%mem | head -10' 2>/dev/null || echo "[WARN] Could not get process list"
    
    # Get memory info from /proc
    echo ""
    echo "Container /proc/meminfo analysis:"
    docker exec $CONTAINER_ID sh -c 'grep -E "(MemTotal|MemFree|MemAvailable|Buffers|Cached)" /proc/meminfo' 2>/dev/null || echo "[WARN] Could not access /proc/meminfo"
    
    # Check vim memory usage specifically
    echo ""
    echo "Testing vim memory usage..."
    VIM_MEMORY=$(docker exec $CONTAINER_ID sh -c 'vim --version >/dev/null 2>&1 && echo "[PASS] Vim available" || echo "[FAIL] Vim not available"')
    echo "$VIM_MEMORY"
    
    # Cleanup
    docker stop $CONTAINER_ID >/dev/null
    docker rm $CONTAINER_ID >/dev/null
    
else
    echo "[SKIP] No nook-writer Docker image found"
    echo "Build with: docker build -t nook-writer -f build/docker/nookwriter-optimized.dockerfile ."
fi
echo ""

# 2. Kernel module memory analysis  
echo "-> Analyzing kernel module memory requirements..."
echo ""
echo "=== Kernel Module Memory Analysis ==="

MODULE_TOTAL_SIZE=0
if [ -d "source/kernel" ]; then
    echo "Kernel module sizes:"
    for ko_file in $(find source/kernel -name "*.ko" 2>/dev/null || true); do
        if [ -f "$ko_file" ]; then
            SIZE=$(du -k "$ko_file" | cut -f1)
            MODULE_TOTAL_SIZE=$((MODULE_TOTAL_SIZE + SIZE))
            printf "  %-30s %6dKB\n" "$(basename $ko_file)" "$SIZE"
        fi
    done
    
    if [ "$MODULE_TOTAL_SIZE" -gt 0 ]; then
        echo "  Total kernel modules:          ${MODULE_TOTAL_SIZE}KB"
        if [ "$MODULE_TOTAL_SIZE" -lt 1024 ]; then
            echo "  [PASS] Module memory usage looks reasonable"
        else
            echo "  [WARN] Large module memory usage: ${MODULE_TOTAL_SIZE}KB"
        fi
    else
        echo "  [INFO] No compiled kernel modules found"
        echo "  Build kernel first: ./build_kernel.sh"
    fi
else
    echo "[WARN] No kernel source directory found"
fi
echo ""

# 3. System component memory estimates
echo "-> Estimating system component memory usage..."
echo ""
echo "=== Memory Budget Breakdown ==="

# Base system estimates (from research and similar embedded systems)
echo "Estimated memory allocation:"
echo "  Kernel core:                   ~25MB"
echo "  Kernel modules (JokerOS):      ~${MODULE_TOTAL_SIZE}KB" 
echo "  Basic system processes:        ~15MB"
echo "  Bash shell:                    ~2MB"
echo "  Init and services:             ~5MB"
echo "  Vim editor:                    ~8MB"
echo "  E-Ink framebuffer:             ~3MB (800x600x1 bit)"
echo "  System buffers/cache:          ~10MB"
echo "  Emergency reserve:             ~5MB"
echo "  --------------------------------"

ESTIMATED_TOTAL=$((25 + MODULE_TOTAL_SIZE/1024 + 15 + 2 + 5 + 8 + 3 + 10 + 5))
echo "  ESTIMATED TOTAL:               ~${ESTIMATED_TOTAL}MB"
echo ""

if [ "$ESTIMATED_TOTAL" -le 96 ]; then
    echo "[PASS] Estimated usage within 96MB budget (${ESTIMATED_TOTAL}MB)"
    REMAINING=$((96 - ESTIMATED_TOTAL))
    echo "[INFO] Estimated ${REMAINING}MB remaining for writing buffer"
else
    echo "[FAIL] Estimated usage EXCEEDS 96MB budget!"
    OVERAGE=$((ESTIMATED_TOTAL - 96))
    echo "[CRITICAL] Over budget by ${OVERAGE}MB - need optimization!"
fi
echo ""

# 4. Build artifact analysis
echo "-> Analyzing build artifact sizes..."
echo ""
echo "=== Build Artifact Analysis ==="

if [ -d "firmware" ]; then
    echo "Build artifact sizes:"
    
    # Kernel image
    if [ -f "firmware/boot/uImage" ]; then
        KERNEL_SIZE=$(du -h firmware/boot/uImage | cut -f1)
        echo "  Kernel image (uImage):         $KERNEL_SIZE"
    fi
    
    # Root filesystem
    if [ -d "firmware/rootfs" ]; then
        ROOTFS_SIZE=$(du -sh firmware/rootfs | cut -f1)
        echo "  Root filesystem:               $ROOTFS_SIZE"
    fi
    
    # Total firmware
    TOTAL_SIZE=$(du -sh firmware | cut -f1)
    echo "  Total firmware:                $TOTAL_SIZE"
    
    echo ""
    echo "[INFO] These are storage sizes, not RAM usage"
    echo "[INFO] RAM usage will be different when running"
    
else
    echo "[INFO] No firmware directory found"
    echo "Build firmware first: make firmware"
fi
echo ""

# 5. Memory testing recommendations
echo "-> Memory testing recommendations..."
echo ""
echo "=== Real Hardware Testing Needed ==="
echo ""
echo "IMPORTANT: These are estimates! Real memory testing requires:"
echo ""
echo "1. Boot on actual Nook hardware"
echo "2. Check /proc/meminfo for real usage:"
echo "   cat /proc/meminfo"
echo ""
echo "3. Monitor process memory usage:"
echo "   ps aux --sort=-%mem"
echo "   top -b -n1"
echo ""
echo "4. Check kernel module memory:"
echo "   cat /proc/modules"
echo "   lsmod"
echo ""
echo "5. Monitor during vim usage:"
echo "   Start vim and check memory again"
echo "   Open large files and monitor"
echo ""

echo "*** Memory Analysis Summary ***"
echo "==============================="
echo ""
echo "Estimated OS memory usage: ${ESTIMATED_TOTAL}MB / 96MB budget"

if [ "$ESTIMATED_TOTAL" -le 96 ]; then
    echo "[PASS] Within estimated budget"
    echo "[ACTION] Proceed with hardware testing to validate"
else
    echo "[FAIL] Over estimated budget!"
    echo "[ACTION] Optimize before hardware testing:"
    echo "  - Remove unnecessary services"
    echo "  - Optimize kernel modules"
    echo "  - Consider minimal build mode"
fi

echo ""
echo "CRITICAL REMINDER:"
echo "These are ESTIMATES based on typical embedded systems."
echo "Real memory validation MUST be done on actual hardware!"
echo ""
echo "The Memory Jester says: 'Count thy bytes well, for RAM is precious!'"