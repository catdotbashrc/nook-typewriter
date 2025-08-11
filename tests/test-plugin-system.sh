#!/bin/bash
# Test plugin system

set -e

echo "Testing plugin system..."

# Check if plugin directory structure exists
if [ ! -d "../config/plugins" ]; then
    echo "  ERROR: Plugin directory not found"
    exit 1
fi

# Check if README exists
if [ ! -f "../config/plugins/README.md" ]; then
    echo "  ERROR: Plugin README not found"
    exit 1
fi

# Check if template exists
if [ ! -f "../config/plugins/template.sh.example" ]; then
    echo "  ERROR: Plugin template not found"
    exit 1
fi

# Check if health monitor plugin exists
if [ ! -f "../config/plugins/health-monitor.sh" ]; then
    echo "  ERROR: Health monitor plugin not found"
    exit 1
fi

# Test that plugin menu script has register_menu_item function
if ! grep -q "register_menu_item" "../config/scripts/nook-menu-plugin.sh"; then
    echo "  ERROR: Plugin menu missing register_menu_item function"
    exit 1
fi

echo "  Plugin system tests passed"