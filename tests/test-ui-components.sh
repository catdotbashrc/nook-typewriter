#!/bin/bash
#
# UI Component Test Suite for QuillKernel
# ========================================
# Tests display abstraction, menu system, and E-Ink optimization
#
# Run: ./test-ui-components.sh [component]

set -euo pipefail

# Test configuration
readonly TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SOURCE_DIR="$(dirname "$TEST_DIR")/source"
readonly UI_DIR="$SOURCE_DIR/ui"
readonly TEST_OUTPUT="/tmp/ui-test-output"
readonly TEST_LOG="/tmp/ui-test.log"

# Colors for test output (disabled on E-Ink)
if [[ -t 1 ]] && [[ ! -f /proc/squireos/jester ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly NC='\033[0m'
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly NC=''
fi

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# ═══════════════════════════════════════════════════════════════
# Test Framework
# ═══════════════════════════════════════════════════════════════

# Log test output
log_test() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$TEST_LOG"
}

# Run a test
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    ((TESTS_RUN++))
    echo -n "Testing $test_name... "
    
    if $test_function >> "$TEST_LOG" 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
        ((TESTS_PASSED++))
        log_test "✓ $test_name passed"
    else
        echo -e "${RED}FAILED${NC}"
        ((TESTS_FAILED++))
        log_test "✗ $test_name failed"
    fi
}

# Assert equality
assert_equal() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values not equal}"
    
    if [[ "$expected" != "$actual" ]]; then
        log_test "Assertion failed: $message"
        log_test "  Expected: $expected"
        log_test "  Actual: $actual"
        return 1
    fi
    return 0
}

# Assert file exists
assert_file_exists() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        log_test "File not found: $file"
        return 1
    fi
    return 0
}

# Assert command succeeds
assert_command() {
    local command="$1"
    
    if ! eval "$command" > /dev/null 2>&1; then
        log_test "Command failed: $command"
        return 1
    fi
    return 0
}

# ═══════════════════════════════════════════════════════════════
# Display Component Tests
# ═══════════════════════════════════════════════════════════════

test_display_init() {
    source "$UI_DIR/components/display.sh"
    
    # Test initialization
    display_init 1  # Force terminal mode for testing
    assert_equal "1" "$DISPLAY_INITIALIZED" "Display not initialized"
    assert_equal "0" "$HAS_EINK" "E-Ink should be disabled in test mode"
}

test_display_text() {
    source "$UI_DIR/components/display.sh"
    display_init 1
    
    # Test text display (output to file for verification)
    display_text 0 0 "Test Text" > "$TEST_OUTPUT"
    
    # In terminal mode, should output ANSI positioning
    grep -q "Test Text" "$TEST_OUTPUT" || return 1
}

test_display_box() {
    source "$UI_DIR/components/display.sh"
    display_init 1
    
    # Test box drawing
    display_box 0 0 10 5 "single" > "$TEST_OUTPUT" 2>&1
    
    # Should not error
    return $?
}

test_display_refresh() {
    source "$UI_DIR/components/display.sh"
    display_init 1
    
    # Test refresh modes
    display_refresh "$REFRESH_FULL"
    display_refresh "$REFRESH_PARTIAL"
    display_refresh "$REFRESH_NONE"
    
    # Should handle all modes without error
    return 0
}

test_display_zones() {
    source "$UI_DIR/components/display.sh"
    display_init 1
    
    # Test zone marking
    _mark_zone_dirty 100 50
    
    # Check if zone was marked
    [[ ${#DIRTY_ZONES[@]} -gt 0 ]] || return 1
}

# ═══════════════════════════════════════════════════════════════
# Menu Component Tests
# ═══════════════════════════════════════════════════════════════

test_menu_create() {
    source "$UI_DIR/components/display.sh"
    source "$UI_DIR/components/menu.sh"
    
    display_init 1
    
    # Create menu
    menu_create "test_menu" "Test Menu" 10 5 50 15
    
    assert_equal "test_menu" "$MENU_ID" "Menu ID incorrect"
    assert_equal "Test Menu" "$MENU_TITLE" "Menu title incorrect"
    assert_equal "50" "$MENU_WIDTH" "Menu width incorrect"
}

test_menu_add_items() {
    source "$UI_DIR/components/display.sh"
    source "$UI_DIR/components/menu.sh"
    
    display_init 1
    menu_create "test_menu" "Test Menu" 10 5 50 15
    
    # Add items
    menu_add_item "Item 1" "echo 1" "1"
    menu_add_item "Item 2" "echo 2" "2"
    menu_add_separator
    menu_add_item "Item 3" "echo 3" "3" "disabled"
    
    assert_equal "4" "$MENU_ITEM_COUNT" "Item count incorrect"
    assert_equal "Item 1" "${MENU_ITEMS[0]}" "First item incorrect"
    assert_equal "disabled" "${MENU_STATES[3]}" "Item state incorrect"
}

test_menu_navigation() {
    source "$UI_DIR/components/display.sh"
    source "$UI_DIR/components/menu.sh"
    
    display_init 1
    menu_create "test_menu" "Test Menu" 10 5 50 15
    
    menu_add_item "Item 1" "echo 1" "1"
    menu_add_item "Item 2" "echo 2" "2"
    menu_add_item "Item 3" "echo 3" "3"
    
    # Test navigation
    assert_equal "0" "$MENU_SELECTED" "Initial selection incorrect"
    
    menu_move_down
    assert_equal "1" "$MENU_SELECTED" "Down navigation failed"
    
    menu_move_down
    assert_equal "2" "$MENU_SELECTED" "Second down navigation failed"
    
    menu_move_up
    assert_equal "1" "$MENU_SELECTED" "Up navigation failed"
}

test_menu_hotkeys() {
    source "$UI_DIR/components/display.sh"
    source "$UI_DIR/components/menu.sh"
    
    display_init 1
    menu_create "test_menu" "Test Menu" 10 5 50 15
    
    menu_add_item "Write" "echo write" "W"
    menu_add_item "Library" "echo library" "L"
    
    # Test hotkey lookup
    assert_equal "0" "${MENU_HOTKEYS[key_W]}" "Hotkey W not mapped"
    assert_equal "1" "${MENU_HOTKEYS[key_L]}" "Hotkey L not mapped"
}

# ═══════════════════════════════════════════════════════════════
# Memory Usage Tests
# ═══════════════════════════════════════════════════════════════

test_memory_usage() {
    # Measure memory before loading
    local mem_before=$(ps aux | grep $$ | awk '{print $6}')
    
    # Load all UI components
    source "$UI_DIR/components/display.sh"
    source "$UI_DIR/components/menu.sh"
    
    # Create and populate a menu
    display_init 1
    menu_create "test" "Test" 0 0 80 25
    for i in {1..10}; do
        menu_add_item "Item $i" "echo $i" "$i"
    done
    
    # Measure memory after loading
    local mem_after=$(ps aux | grep $$ | awk '{print $6}')
    local mem_used=$((mem_after - mem_before))
    
    log_test "Memory used by UI components: ${mem_used}KB"
    
    # Should be less than 500KB
    [[ $mem_used -lt 500 ]] || return 1
}

# ═══════════════════════════════════════════════════════════════
# Performance Tests
# ═══════════════════════════════════════════════════════════════

test_display_performance() {
    source "$UI_DIR/components/display.sh"
    display_init 1
    
    # Measure display operations
    local start_time=$(date +%s%N)
    
    for i in {1..100}; do
        display_text 0 0 "Performance test $i" "$REFRESH_NONE"
    done
    
    local end_time=$(date +%s%N)
    local elapsed=$(( (end_time - start_time) / 1000000 ))
    
    log_test "100 display operations took ${elapsed}ms"
    
    # Should be less than 1000ms (10ms per operation)
    [[ $elapsed -lt 1000 ]] || return 1
}

test_menu_performance() {
    source "$UI_DIR/components/display.sh"
    source "$UI_DIR/components/menu.sh"
    
    display_init 1
    
    # Create large menu
    menu_create "perf_test" "Performance Test" 0 0 80 25
    
    local start_time=$(date +%s%N)
    
    for i in {1..50}; do
        menu_add_item "Item $i" "echo $i"
    done
    
    local end_time=$(date +%s%N)
    local elapsed=$(( (end_time - start_time) / 1000000 ))
    
    log_test "Adding 50 menu items took ${elapsed}ms"
    
    # Should be less than 100ms
    [[ $elapsed -lt 100 ]] || return 1
}

# ═══════════════════════════════════════════════════════════════
# E-Ink Simulation Tests
# ═══════════════════════════════════════════════════════════════

test_ghosting_management() {
    source "$UI_DIR/components/display.sh"
    display_init 1
    
    # Simulate many partial refreshes
    for i in {1..60}; do
        display_refresh "$REFRESH_PARTIAL"
    done
    
    # Should trigger anti-ghosting
    [[ $GHOSTING_COUNTER -eq 0 ]] || return 1
}

test_refresh_zones() {
    source "$UI_DIR/components/display.sh"
    display_init 1
    
    # Test zone calculation
    _mark_zone_dirty 0 0      # Zone 0
    _mark_zone_dirty 400 0    # Zone 2
    _mark_zone_dirty 0 300    # Zone 4
    _mark_zone_dirty 400 300  # Zone 6
    
    # Should have 4 dirty zones
    assert_equal "4" "${#DIRTY_ZONES[@]}" "Zone marking incorrect"
}

# ═══════════════════════════════════════════════════════════════
# ASCII Art Tests
# ═══════════════════════════════════════════════════════════════

test_ascii_art_display() {
    source "$UI_DIR/components/display.sh"
    display_init 1
    
    local jester="  .·:·.  
 ( o o ) 
 | > < | 
  \___/  
  |♦|♦|  "
    
    # Test ASCII art display
    display_ascii_art 0 0 "$jester" "$REFRESH_NONE" > "$TEST_OUTPUT" 2>&1
    
    # Should complete without error
    return $?
}

test_ascii_art_centering() {
    source "$UI_DIR/components/display.sh"
    display_init 1
    
    local test_art="TEST
CENTERING
ART"
    
    display_ascii_art_centered 10 "$test_art" "$REFRESH_NONE" > "$TEST_OUTPUT" 2>&1
    
    # Should complete without error
    return $?
}

# ═══════════════════════════════════════════════════════════════
# Integration Tests
# ═══════════════════════════════════════════════════════════════

test_main_menu_integration() {
    # Check if main menu script exists and is valid
    assert_file_exists "$UI_DIR/layouts/main-menu.sh"
    
    # Test syntax
    bash -n "$UI_DIR/layouts/main-menu.sh" || return 1
    
    return 0
}

test_theme_consistency() {
    # Check theme files exist
    assert_file_exists "$SOURCE_DIR/ui/themes/ascii-art-library.txt"
    
    # Verify ASCII art library has required sections
    grep -q "JESTER COLLECTION" "$SOURCE_DIR/ui/themes/ascii-art-library.txt" || return 1
    grep -q "BORDERS & FRAMES" "$SOURCE_DIR/ui/themes/ascii-art-library.txt" || return 1
    grep -q "MEDIEVAL ICONS" "$SOURCE_DIR/ui/themes/ascii-art-library.txt" || return 1
    
    return 0
}

# ═══════════════════════════════════════════════════════════════
# Main Test Runner
# ═══════════════════════════════════════════════════════════════

main() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "           QuillKernel UI Component Test Suite"
    echo "═══════════════════════════════════════════════════════════════"
    echo
    
    # Initialize test environment
    rm -f "$TEST_LOG" "$TEST_OUTPUT"
    touch "$TEST_LOG"
    
    # Component selection
    local component="${1:-all}"
    
    case "$component" in
        display)
            echo "Testing Display Component..."
            run_test "Display initialization" test_display_init
            run_test "Display text output" test_display_text
            run_test "Display box drawing" test_display_box
            run_test "Display refresh modes" test_display_refresh
            run_test "Display zones" test_display_zones
            run_test "Display performance" test_display_performance
            ;;
        
        menu)
            echo "Testing Menu Component..."
            run_test "Menu creation" test_menu_create
            run_test "Menu item addition" test_menu_add_items
            run_test "Menu navigation" test_menu_navigation
            run_test "Menu hotkeys" test_menu_hotkeys
            run_test "Menu performance" test_menu_performance
            ;;
        
        eink)
            echo "Testing E-Ink Features..."
            run_test "Ghosting management" test_ghosting_management
            run_test "Refresh zones" test_refresh_zones
            run_test "ASCII art display" test_ascii_art_display
            run_test "ASCII art centering" test_ascii_art_centering
            ;;
        
        memory)
            echo "Testing Memory Usage..."
            run_test "UI component memory" test_memory_usage
            ;;
        
        integration)
            echo "Testing Integration..."
            run_test "Main menu integration" test_main_menu_integration
            run_test "Theme consistency" test_theme_consistency
            ;;
        
        all|*)
            echo "Running All Tests..."
            
            # Display tests
            echo -e "\n${YELLOW}Display Component:${NC}"
            run_test "Display initialization" test_display_init
            run_test "Display text output" test_display_text
            run_test "Display box drawing" test_display_box
            run_test "Display refresh modes" test_display_refresh
            run_test "Display zones" test_display_zones
            
            # Menu tests
            echo -e "\n${YELLOW}Menu Component:${NC}"
            run_test "Menu creation" test_menu_create
            run_test "Menu item addition" test_menu_add_items
            run_test "Menu navigation" test_menu_navigation
            run_test "Menu hotkeys" test_menu_hotkeys
            
            # E-Ink tests
            echo -e "\n${YELLOW}E-Ink Features:${NC}"
            run_test "Ghosting management" test_ghosting_management
            run_test "Refresh zones" test_refresh_zones
            run_test "ASCII art display" test_ascii_art_display
            run_test "ASCII art centering" test_ascii_art_centering
            
            # Performance tests
            echo -e "\n${YELLOW}Performance:${NC}"
            run_test "Display performance" test_display_performance
            run_test "Menu performance" test_menu_performance
            
            # Memory tests
            echo -e "\n${YELLOW}Memory Usage:${NC}"
            run_test "UI component memory" test_memory_usage
            
            # Integration tests
            echo -e "\n${YELLOW}Integration:${NC}"
            run_test "Main menu integration" test_main_menu_integration
            run_test "Theme consistency" test_theme_consistency
            ;;
    esac
    
    # Summary
    echo
    echo "═══════════════════════════════════════════════════════════════"
    echo "Test Results:"
    echo "  Total:  $TESTS_RUN"
    echo -e "  Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "  Failed: ${RED}$TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}✓ All tests passed!${NC}"
    else
        echo -e "\n${RED}✗ Some tests failed. Check $TEST_LOG for details.${NC}"
        exit 1
    fi
    
    echo "═══════════════════════════════════════════════════════════════"
}

# Run main function
main "$@"