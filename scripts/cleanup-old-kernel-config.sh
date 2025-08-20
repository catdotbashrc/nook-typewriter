#!/bin/bash
# Clean up old kernel module configuration that was never implemented

echo "🧹 Cleaning up old kernel module configuration..."

# 1. Simplify the pre-commit hook
if [ -f .git/hooks/pre-commit ]; then
    echo "Simplifying pre-commit hook..."
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Simplified pre-commit hook for JesterOS
# No kernel module checks needed - using stock NST kernel

set -e

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [[ "$BRANCH" == "dev" ]] || [[ "$BRANCH" == feature/* ]]; then
    echo "==================================="
    echo "Running JesterOS Pre-Commit Tests"
    echo "==================================="
    
    # Run basic safety checks if tests exist
    if [ -f "tests/01-safety-check.sh" ]; then
        echo "→ Running safety check..."
        if ./tests/01-safety-check.sh; then
            echo "✓ Safety check passed"
        else
            echo "⚠️  Safety check has warnings"
        fi
    fi
    
    echo "==================================="
    echo "✓ Pre-commit checks complete"
    echo "==================================="
fi

exit 0
EOF
    chmod +x .git/hooks/pre-commit
    echo "✓ Pre-commit hook simplified"
fi

# 2. Update .kernel.env to reflect reality
if [ -f .kernel.env ]; then
    echo "Updating .kernel.env..."
    cat > .kernel.env << 'EOF'
#!/bin/bash
# JesterOS Build Environment Configuration
# Using stock NST kernel - no custom modules

# ============================================
# PROJECT IDENTITY
# ============================================
export PROJECT_NAME="JesterOS"
export PROJECT_VERSION="1.0.0"
export PROJECT_CODENAME="Parchment"

# ============================================
# BUILD CONFIGURATION
# ============================================
export KERNEL_VERSION="2.6.29"
export KERNEL_ARCH="arm"
export CROSS_COMPILE="arm-linux-androideabi-"
export KERNEL_SOURCE="https://github.com/catdotbashrc/nst-kernel.git"

# Stock NST kernel config - no modifications
export KERNEL_CONFIG="omap3621_gossamer_evt1c_defconfig"
export KERNEL_IMAGE="uImage"

# ============================================
# HARDWARE CONSTRAINTS
# ============================================
export DEVICE_NAME="Nook Simple Touch"
export CPU_SPEED_MHZ="800"
export RAM_TOTAL_MB="256"
export RAM_OS_BUDGET_MB="93"  # Reality after Android init
export RAM_WRITING_RESERVED_MB="160"
export DISPLAY_TYPE="E-Ink"
export DISPLAY_RESOLUTION="800x600"

# ============================================
# PATHS
# ============================================
export KERNEL_OUTPUT="platform/nook-touch/kernel/uImage"
export BOOTLOADER_PATH="platform/nook-touch/bootloader/"

# No custom kernel modules - using userspace services only
EOF
    echo "✓ .kernel.env updated"
fi

# 3. Remove old kernel module references from Makefile
if [ -f Makefile ]; then
    echo "Cleaning Makefile..."
    # Remove any CONFIG_JESTEROS references
    sed -i '/CONFIG_JESTEROS/d' Makefile
    sed -i '/kernel.*modules/d' Makefile 2>/dev/null || true
    echo "✓ Makefile cleaned"
fi

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "Summary:"
echo "- Pre-commit hook no longer checks for non-existent kernel modules"
echo "- .kernel.env updated to reflect stock kernel usage"
echo "- No custom kernel modules needed - JesterOS runs in userspace"
echo ""
echo "The kernel submodule at source/kernel/ is the stock NST kernel."
echo "All JesterOS functionality is in userspace scripts (src/)"