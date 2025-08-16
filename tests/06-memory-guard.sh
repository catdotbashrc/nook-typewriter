#!/bin/bash
# Memory guard - Protect the sacred 160MB writing space
# Ensures OS stays under 96MB to preserve writer's workspace

set -euo pipefail

echo "💾 MEMORY GUARD - Protecting writer's space"
echo "==========================================="
echo ""
echo "Target: OS < 96MB, leaving 160MB for writing"
echo ""

MEMORY_OK=true
TOTAL_SIZE=0

# Check 1: Script and config size
echo -n "✓ Scripts & configs size... "
SCRIPT_SIZE=$(du -sh ../source/scripts 2>/dev/null | cut -f1 || echo "0")
CONFIG_SIZE=$(du -sh ../source/configs 2>/dev/null | cut -f1 || echo "0")
echo "$SCRIPT_SIZE scripts, $CONFIG_SIZE configs"

# Check 2: No large unnecessary files
echo -n "✓ No large bloat files... "
LARGE_FILES=$(find ../source -type f -size +1M 2>/dev/null | wc -l || echo "0")
if [ "$LARGE_FILES" -eq 0 ]; then
    echo "YES"
else
    echo "WARNING ($LARGE_FILES files >1MB)"
    find ../source -type f -size +1M -exec ls -lh {} \; 2>/dev/null | head -5
fi

# Check 3: No forbidden directories
echo -n "✓ No node_modules... "
if find .. -type d -name "node_modules" 2>/dev/null | grep -q .; then
    echo "DANGER! node_modules found!"
    MEMORY_OK=false
else
    echo "YES"
fi

echo -n "✓ No database files... "
if find ../source -type f \( -name "*.db" -o -name "*.sqlite" -o -name "*.sql" \) 2>/dev/null | grep -q .; then
    echo "WARNING - Database files found"
else
    echo "YES"
fi

echo -n "✓ No compiled binaries... "
BINARY_COUNT=$(find ../source -type f -executable -exec file {} \; 2>/dev/null | grep -c "ELF\|executable" || echo "0")
if [ "$BINARY_COUNT" -eq 0 ]; then
    echo "YES"
elif [ "$BINARY_COUNT" -lt 3 ]; then
    echo "OK ($BINARY_COUNT essential binaries)"
else
    echo "WARNING ($BINARY_COUNT binaries - too many?)"
fi

# Check 4: Docker image size (if available)
if command -v docker >/dev/null 2>&1; then
    echo -n "✓ Docker image size... "
    IMAGE_SIZE=$(docker images --format "table {{.Repository}}\t{{.Size}}" 2>/dev/null | grep -E "nook-writer|jesteros|jokernel|quillkernel" | head -1 | awk '{print $2}' || echo "N/A")
    if [ "$IMAGE_SIZE" != "N/A" ]; then
        echo "$IMAGE_SIZE"
        # Check if it's reasonable (under 200MB is good for minimal system)
        SIZE_NUM=$(echo "$IMAGE_SIZE" | sed 's/[^0-9.]//g')
        SIZE_UNIT=$(echo "$IMAGE_SIZE" | sed 's/[0-9.]//g')
        if [[ "$SIZE_UNIT" == "GB" ]] || ([[ "$SIZE_UNIT" == "MB" ]] && (( $(echo "$SIZE_NUM > 200" | bc -l 2>/dev/null || echo 1) ))); then
            echo "    WARNING: Image seems large for minimal system"
        fi
    else
        echo "No image built yet"
    fi
fi

# Check 5: Reasonable script count
echo -n "✓ Script count... "
SCRIPT_COUNT=$(find ../source/scripts -name "*.sh" 2>/dev/null | wc -l || echo "0")
if [ "$SCRIPT_COUNT" -lt 30 ]; then
    echo "EXCELLENT ($SCRIPT_COUNT scripts)"
elif [ "$SCRIPT_COUNT" -lt 50 ]; then
    echo "GOOD ($SCRIPT_COUNT scripts)"
elif [ "$SCRIPT_COUNT" -lt 75 ]; then
    echo "OK ($SCRIPT_COUNT scripts - getting heavy)"
else
    echo "TOO MANY ($SCRIPT_COUNT scripts!)"
    echo "    Each script = more RAM at runtime"
    MEMORY_OK=false
fi

# Check 6: No memory leaks in scripts
echo -n "✓ No obvious memory leaks... "
INFINITE_LOOPS=$(grep -r "while true\|while :" ../source/scripts 2>/dev/null | grep -v "sleep\|read\|wait" | wc -l || echo "0")
if [ "$INFINITE_LOOPS" -eq 0 ]; then
    echo "YES"
else
    echo "WARNING ($INFINITE_LOOPS infinite loops without sleep)"
    echo "    Add 'sleep' to prevent CPU/memory issues"
fi

# Check 7: Vim plugin restraint
echo -n "✓ Vim plugins minimal... "
if [ -d "../source/configs/vim/pack" ] || [ -d "../source/configs/vim/bundle" ]; then
    PLUGIN_COUNT=$(find ../source/configs/vim -type d -name "plugin" 2>/dev/null | wc -l || echo "0")
    if [ "$PLUGIN_COUNT" -gt 5 ]; then
        echo "WARNING ($PLUGIN_COUNT plugins - each uses RAM!)"
    else
        echo "YES ($PLUGIN_COUNT plugins)"
    fi
else
    echo "YES (no plugin directory)"
fi

# Summary
echo ""
echo "Memory Budget Analysis:"
echo "  Total RAM:        256MB"
echo "  Reserved for OS:   96MB (target)"
echo "  Writing space:    160MB (sacred!)"
echo "  Script count:     $SCRIPT_COUNT (affects runtime RAM)"
echo ""

if [ "$MEMORY_OK" = true ]; then
    echo "✅ MEMORY GUARD PASSED"
    echo "Writing space should be protected"
    exit 0
else
    echo "❌ MEMORY ISSUES DETECTED"
    echo "Reduce OS footprint to protect writing space!"
    exit 1
fi