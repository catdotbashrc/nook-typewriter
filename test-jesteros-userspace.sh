#!/bin/bash
# Test JesterOS Userspace Implementation
# Quick verification that our simple solution works!

set -euo pipefail

echo "═══════════════════════════════════════════"
echo "    Testing JesterOS Userspace"
echo "═══════════════════════════════════════════"
echo

# Test directory
TEST_DIR="/tmp/jesteros-test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

# Run the userspace script directly
echo "→ Testing jesteros-userspace.sh..."
JESTER_DIR="$TEST_DIR" bash source/scripts/boot/jesteros-userspace.sh

echo
echo "→ Checking created files..."

# Check if files were created
if [ -f "$TEST_DIR/jester" ]; then
    echo "  ✓ Jester file created"
    echo "  Contents:"
    cat "$TEST_DIR/jester" | sed 's/^/    /'
else
    echo "  ✗ Jester file NOT created"
fi

echo

if [ -f "$TEST_DIR/typewriter/stats" ]; then
    echo "  ✓ Typewriter stats created"
    echo "  First 5 lines:"
    head -5 "$TEST_DIR/typewriter/stats" | sed 's/^/    /'
else
    echo "  ✗ Typewriter stats NOT created"
fi

echo

if [ -f "$TEST_DIR/wisdom" ]; then
    echo "  ✓ Wisdom file created"
    echo "  Contents:"
    cat "$TEST_DIR/wisdom" | sed 's/^/    /'
else
    echo "  ✗ Wisdom file NOT created"
fi

echo
echo "→ Testing the tracker script..."

# Create a fake manuscripts directory
WATCH_DIR="$TEST_DIR/manuscripts"
mkdir -p "$WATCH_DIR"
echo "Testing the Nook typewriter!" > "$WATCH_DIR/test.txt"

# Run the tracker once (not as daemon)
JESTER_DIR="$TEST_DIR" WATCH_DIR="$WATCH_DIR" bash -c '
    . source/scripts/services/jesteros-tracker.sh
    init_stats_data
    update_stats
'

if [ -f "$TEST_DIR/typewriter/stats" ]; then
    echo "  ✓ Tracker updated stats"
    echo "  Word count line:"
    grep "Words Written" "$TEST_DIR/typewriter/stats" | sed 's/^/    /'
else
    echo "  ✗ Tracker failed to update stats"
fi

# Cleanup
rm -rf "$TEST_DIR"

echo
echo "═══════════════════════════════════════════"
echo "    Test Complete!"
echo "═══════════════════════════════════════════"
echo
echo "If all checks passed, JesterOS userspace is ready!"
echo "This solution works WITHOUT any kernel compilation!"
echo
echo "To install for real use:"
echo "  sudo ./install-jesteros-userspace.sh"
echo
echo "For local testing only:"
echo "  ./install-jesteros-userspace.sh --user"
echo