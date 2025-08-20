#!/bin/bash
# usb-keyboard-setup.sh - User-friendly GK61 keyboard setup for JesterOS
# Layer 1: UI - User interface for keyboard setup
set -euo pipefail

# Paths
USB_MANAGER="/src/3-system/services/usb-keyboard-manager.sh"
INPUT_HANDLER="/src/4-hardware/input/button-handler.sh"
SETUP_LOG="/var/log/jesteros-keyboard-setup.log"

# Colors for output (only in terminal)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Logging function
log_setup() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$SETUP_LOG"
}

# Display function with E-Ink consideration
display() {
    echo -e "$1"
    # Add to setup log
    echo "$1" | sed 's/\x1b\[[0-9;]*m//g' >> "$SETUP_LOG"
}

# Clear screen function (works with E-Ink)
clear_screen() {
    if command -v fbink >/dev/null 2>&1; then
        fbink -c
    else
        clear 2>/dev/null || true
    fi
}

# Show jester banner
show_banner() {
    display "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    display "${BLUE}                     ⌨️  GK61 Keyboard Setup  ⌨️                  ${NC}"
    display "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    display ""
    display "        ${YELLOW}🃏 The Jester's Keyboard Configuration Tool 🃏${NC}"
    display ""
    display "Transform your Nook into a professional writing station!"
    display ""
}

# Hardware checklist
check_hardware() {
    display "${BLUE}📋 Hardware Checklist${NC}"
    display "═══════════════════════════════════════════════════════════════"
    display ""
    
    local all_good=true
    
    # Check USB OTG controller
    display "🔌 Checking USB OTG controller..."
    if [ -f "/sys/devices/platform/musb_hdrc/mode" ]; then
        display "   ${GREEN}✓${NC} USB OTG controller found"
    else
        display "   ${RED}✗${NC} USB OTG controller not available"
        all_good=false
    fi
    
    # Check USB manager script
    display "⚙️  Checking USB keyboard manager..."
    if [ -x "$USB_MANAGER" ]; then
        display "   ${GREEN}✓${NC} USB keyboard manager available"
    else
        display "   ${RED}✗${NC} USB keyboard manager not found: $USB_MANAGER"
        all_good=false
    fi
    
    # Check input handler
    display "🎮 Checking input handler..."
    if [ -x "$INPUT_HANDLER" ]; then
        display "   ${GREEN}✓${NC} Input handler available"
    else
        display "   ${RED}✗${NC} Input handler not found: $INPUT_HANDLER"
        all_good=false
    fi
    
    display ""
    
    if $all_good; then
        display "${GREEN}✅ All software components ready!${NC}"
        display ""
        display "Required Hardware:"
        display "  1. Micro USB OTG cable (micro-B to USB-A)"
        display "  2. Powered USB hub (5V external power)"
        display "  3. Skyloong GK61 keyboard (USB-C or USB-A)"
        display "  4. USB-C to USB-A cable (for GK61 connection)"
        display ""
        return 0
    else
        display "${RED}❌ Some components are missing. Cannot proceed.${NC}"
        return 1
    fi
}

# Guide user through physical setup
physical_setup_guide() {
    display "${BLUE}🔧 Physical Setup Guide${NC}"
    display "═══════════════════════════════════════════════════════════════"
    display ""
    display "Follow these steps carefully:"
    display ""
    display "Step 1: Prepare the connection chain"
    display "  📱 Nook → 🔌 OTG Cable → 🔌 Powered Hub → ⌨️  GK61"
    display ""
    display "Step 2: Connect the OTG cable"
    display "  • Plug micro USB end into Nook's charging port"
    display "  • ${YELLOW}WARNING:${NC} This will disconnect ADB (debugging)"
    display ""
    display "Step 3: Connect the powered USB hub"
    display "  • Plug hub into OTG cable"
    display "  • Connect hub's power adapter (5V required)"
    display "  • Wait for hub power LED to turn on"
    display ""
    display "Step 4: Connect the GK61 keyboard"
    display "  • Use USB-C cable to connect GK61 to hub"
    display "  • GK61 should light up when connected"
    display ""
    
    read -p "Press Enter when hardware is connected..." -r
    display ""
}

# Test USB OTG functionality
test_usb_otg() {
    display "${BLUE}🧪 Testing USB OTG Functionality${NC}"
    display "═══════════════════════════════════════════════════════════════"
    display ""
    
    display "Checking USB OTG controller..."
    if ! "$USB_MANAGER" check >/dev/null 2>&1; then
        display "${RED}❌ USB OTG controller test failed${NC}"
        display "Check your OTG cable connection."
        return 1
    fi
    
    display "${GREEN}✓${NC} USB OTG controller is functional"
    display ""
    
    display "Switching to USB host mode..."
    if "$USB_MANAGER" host; then
        display "${GREEN}✓${NC} Successfully switched to host mode"
        sleep 2
        
        display "Detecting USB keyboard..."
        if "$USB_MANAGER" detect; then
            display "${GREEN}✅ GK61 keyboard detected!${NC}"
            
            # Show keyboard details
            local kb_name=$(cat /var/jesteros/keyboard/name 2>/dev/null || echo "Unknown")
            local kb_id=$(cat /var/jesteros/keyboard/vendor_product 2>/dev/null || echo "Unknown")
            
            display ""
            display "Keyboard Information:"
            display "  Name: $kb_name"
            display "  ID: $kb_id"
            display ""
            return 0
        else
            display "${YELLOW}⚠️  Keyboard not detected${NC}"
            display ""
            display "Troubleshooting tips:"
            display "  • Ensure powered hub is receiving 5V power"
            display "  • Try a different USB port on the hub"
            display "  • Check GK61 power switch (if present)"
            display "  • Verify USB-C cable is data-capable"
            display ""
            return 1
        fi
    else
        display "${RED}❌ Failed to switch to host mode${NC}"
        return 1
    fi
}

# Test keyboard input
test_keyboard_input() {
    display "${BLUE}⌨️  Testing Keyboard Input${NC}"
    display "═══════════════════════════════════════════════════════════════"
    display ""
    
    display "Starting keyboard test mode..."
    display "Type some keys to test functionality."
    display "Press ${YELLOW}F10${NC} to exit test mode."
    display ""
    
    # Start input handler in background for testing
    "$INPUT_HANDLER" monitor &
    local input_pid=$!
    
    # Monitor for F10 press or timeout
    local timeout=30
    local elapsed=0
    
    while [ $elapsed -lt $timeout ]; do
        if [ ! -d "/proc/$input_pid" ]; then
            display ""
            display "${RED}Input handler stopped unexpectedly${NC}"
            return 1
        fi
        
        # Check if F10 was pressed (would trigger restore)
        if [ "$(cat /var/jesteros/usb/mode 2>/dev/null || echo 'unknown')" = "b_idle" ]; then
            display ""
            display "${GREEN}✓${NC} F10 detected - keyboard input working!"
            break
        fi
        
        sleep 1
        elapsed=$((elapsed + 1))
    done
    
    # Clean up
    kill $input_pid 2>/dev/null || true
    wait $input_pid 2>/dev/null || true
    
    if [ $elapsed -ge $timeout ]; then
        display ""
        display "${YELLOW}⚠️  Test timed out. Keyboard may not be working.${NC}"
        return 1
    fi
    
    return 0
}

# Setup complete
setup_complete() {
    display "${GREEN}🎉 Setup Complete!${NC}"
    display "═══════════════════════════════════════════════════════════════"
    display ""
    display "Your GK61 keyboard is now configured for JesterOS!"
    display ""
    display "${BLUE}Quick Reference:${NC}"
    display "  ${YELLOW}ESC${NC}     - Return to main menu"
    display "  ${YELLOW}F1${NC}      - Show jester mood"
    display "  ${YELLOW}F2${NC}      - Show writing statistics"
    display "  ${YELLOW}F3${NC}      - Save document"
    display "  ${YELLOW}F4${NC}      - Save and exit vim"
    display "  ${YELLOW}F5${NC}      - Refresh/reload file"
    display "  ${YELLOW}F10${NC}     - Return to ADB mode"
    display ""
    display "${BLUE}Usage:${NC}"
    display "  • To enable keyboard: $USB_MANAGER setup"
    display "  • To start input monitoring: $INPUT_HANDLER monitor"
    display "  • To return to ADB: $USB_MANAGER restore"
    display "  • To check status: $USB_MANAGER status"
    display ""
    display "${YELLOW}🃏 The jester approves of your enhanced scribing setup!${NC}"
    display ""
}

# Error recovery
error_recovery() {
    display ""
    display "${RED}❌ Setup failed. Attempting recovery...${NC}"
    display ""
    
    # Try to restore ADB mode
    if "$USB_MANAGER" restore; then
        display "${GREEN}✓${NC} ADB connectivity restored"
        display "You can try setup again or troubleshoot the hardware."
    else
        display "${RED}⚠️  Could not restore ADB mode automatically${NC}"
        display "Manual recovery may be required."
    fi
    
    display ""
    display "Troubleshooting resources:"
    display "  • Setup log: $SETUP_LOG"
    display "  • USB log: /var/log/jesteros-usb.log"
    display "  • Help: $0 help"
    display ""
}

# Main setup workflow
main_setup() {
    clear_screen
    show_banner
    
    log_setup "Starting GK61 keyboard setup"
    
    # Check software prerequisites
    if ! check_hardware; then
        log_setup "Hardware check failed"
        return 1
    fi
    
    read -p "Continue with setup? [y/N]: " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        display "Setup cancelled."
        return 0
    fi
    
    clear_screen
    show_banner
    
    # Guide through physical setup
    physical_setup_guide
    
    # Test USB OTG functionality
    if ! test_usb_otg; then
        log_setup "USB OTG test failed"
        error_recovery
        return 1
    fi
    
    # Test keyboard input
    display ""
    read -p "Test keyboard input? [Y/n]: " -r
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        if ! test_keyboard_input; then
            log_setup "Keyboard input test failed"
            error_recovery
            return 1
        fi
    fi
    
    # Setup complete
    clear_screen
    setup_complete
    
    log_setup "GK61 keyboard setup completed successfully"
    return 0
}

# Command handling
case "${1:-setup}" in
    setup|start)
        main_setup
        ;;
        
    check)
        check_hardware
        ;;
        
    test)
        test_keyboard_input
        ;;
        
    recovery)
        error_recovery
        ;;
        
    help|*)
        cat <<EOF
GK61 Keyboard Setup Tool for JesterOS

Usage: $0 [command]

Commands:
    setup     - Full interactive setup (default)
    check     - Check hardware and software prerequisites
    test      - Test keyboard input functionality
    recovery  - Attempt error recovery
    help      - Show this help

This tool guides you through setting up a Skyloong GK61 keyboard
with your Nook running JesterOS.

Hardware Required:
    • Micro USB OTG cable
    • Powered USB hub (5V)
    • Skyloong GK61 keyboard
    • USB-C to USB-A cable

Files:
    Setup Log: $SETUP_LOG
    USB Manager: $USB_MANAGER
    Input Handler: $INPUT_HANDLER

For more help, see the documentation or run the individual components
with their help commands.

EOF
        ;;
esac