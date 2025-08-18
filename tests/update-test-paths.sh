#!/bin/bash
# Update all test scripts to use test-config.sh for consistent path handling
# This eliminates confusion with hardcoded relative paths

set -euo pipefail

echo "Updating test scripts to use centralized configuration..."

# List of test scripts that should use test-config.sh
TEST_SCRIPTS=(
    "01-safety-check.sh"
    "02-boot-test.sh"
    "03-functionality.sh"
    "04-docker-smoke.sh"
    "06-memory-guard.sh"
    "07-writer-experience.sh"
)

# Template for sourcing test-config.sh
CONFIG_SOURCE='# Source test configuration for consistent paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/test-config.sh" ]; then
    source "$SCRIPT_DIR/test-config.sh"
else
    echo "Error: test-config.sh not found"
    exit 1
fi'

for script in "${TEST_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "Checking $script..."
        
        # Check if already sources test-config.sh
        if grep -q "source.*test-config.sh" "$script"; then
            echo "  ✓ Already uses test-config.sh"
        else
            echo "  → Would add test-config.sh sourcing (dry run)"
            # To actually update, uncomment the following:
            # sed -i '/^set -euo pipefail/a\\n'"$CONFIG_SOURCE" "$script"
        fi
    fi
done

echo ""
echo "Path Configuration Summary:"
echo "  test-config.sh defines:"
echo "    - PROJECT_ROOT: Root of the project"
echo "    - SOURCE_DIR: \$PROJECT_ROOT/source"
echo "    - SCRIPTS_DIR: \$SOURCE_DIR/scripts"
echo "    - get_script_dir(): Returns correct dir based on TEST_STAGE"
echo ""
echo "Usage in test scripts:"
echo '  source "$SCRIPT_DIR/test-config.sh"'
echo '  SCRIPT_DIR="$(get_script_dir)"'
echo ""
echo "This eliminates hardcoded paths like '../source/scripts' and '../runtime'"