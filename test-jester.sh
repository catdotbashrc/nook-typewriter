#!/bin/bash
# Test the Court Jester in Docker

echo "═══════════════════════════════════════════════════════════════"
echo "     Testing the Court Jester"
echo "═══════════════════════════════════════════════════════════════"

# Build the Docker image with jester
echo "Building Nook writer system with Court Jester..."
docker build -t nook-jester -f nookwriter-optimized.dockerfile . || exit 1

# Run the jester test
echo ""
echo "Starting the Court Jester..."
docker run --rm -it nook-jester bash -c '
    # Start the jester daemon
    /usr/local/bin/jester-daemon.sh start
    
    # Wait for it to initialize
    sleep 2
    
    # Check jester status
    echo "Checking jester status..."
    /usr/local/bin/jester-daemon.sh status
    
    # Show the jester files
    echo ""
    echo "Jester files created:"
    ls -la /var/lib/jester/
    
    # Display the motto
    echo ""
    echo "Jester motto:"
    cat /var/lib/jester/motto
    
    # Test the menu with jester option
    echo ""
    echo "Testing menu (press J to visit jester, then Q to quit)..."
    echo -e "j\nq" | timeout 5 /usr/local/bin/nook-menu.sh || true
'

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "     Jester Test Complete!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "The Court Jester is ready to inspire writers!"