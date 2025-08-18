#!/bin/bash
echo "Starting debug test..."

# Test basic structure
echo "Testing /runtime..."
ls -la /runtime/ | head -5

echo ""
echo "Testing /var/jesteros..."
ls -la /var/jesteros/ | head -5

echo ""
echo "Testing scripts..."
for script in "/runtime/2-application/jesteros/manager.sh" \
              "/runtime/3-system/services/usb-keyboard-manager.sh" \
              "/runtime/4-hardware/input/button-handler.sh"; do
    if [ -x "$script" ]; then
        echo "✓ $script"
    else
        echo "✗ $script"
    fi
done

echo ""
echo "Test complete!"
