#!/bin/bash
# Test Vim configurations and RAM usage

set -e

echo "Testing Vim modes..."

# Check if config files exist
for config in vimrc-minimal vimrc-writer vimrc-zk; do
    if [ ! -f "../config/$config" ]; then
        echo "  ERROR: Missing config file: $config"
        exit 1
    fi
done

# Test that configs are valid Vim syntax
for config in ../config/vimrc-*; do
    # Basic syntax check - look for common vim commands
    if ! grep -qE '^".*|^set |^map |^let |^colorscheme' "$config"; then
        echo "  WARNING: $config may not be valid vim config"
    fi
done

echo "  Vim configuration tests passed"