#!/bin/bash
# Simple JesterOS Test - Quick validation
# "A quick test of the realm!"

set -euo pipefail

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    JESTEROS SIMPLE TEST                       ║"
echo "║                                                                ║"
echo "║              \"Quick validation of the realm!\"                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Test 1: Basic structure
echo "🏗️  Testing basic structure..."
if [ -d "/runtime" ] && [ -d "/var/jesteros" ]; then
    echo "✅ Directory structure OK"
else
    echo "❌ Directory structure FAILED"
    exit 1
fi

# Test 2: USB Keyboard Manager
echo "⌨️  Testing USB keyboard manager..."
if /runtime/3-system/services/usb-keyboard-manager.sh help >/dev/null 2>&1; then
    echo "✅ USB keyboard manager OK"
else
    echo "❌ USB keyboard manager FAILED"
    exit 1
fi

# Test 3: Input Handler
echo "🎮 Testing input handler..."
if /runtime/4-hardware/input/button-handler.sh help >/dev/null 2>&1; then
    echo "✅ Input handler OK"
else
    echo "❌ Input handler FAILED"
    exit 1
fi

# Test 4: Setup Script
echo "⚙️  Testing setup script..."
if /runtime/1-ui/setup/usb-keyboard-setup.sh help >/dev/null 2>&1; then
    echo "✅ Setup script OK"
else
    echo "❌ Setup script FAILED"
    exit 1
fi

echo ""
echo "🎭 All simple tests passed! The modular approach works!"
echo "📦 Base image: $(hostname)"
echo "🕒 Test completed: $(date)"