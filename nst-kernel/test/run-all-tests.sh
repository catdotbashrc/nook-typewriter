#!/bin/bash
# QuillKernel Comprehensive Test Runner
# Executes all tests and generates a report

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "         QuillKernel Test Suite Runner"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "     .~\"~.~\"~."
echo "    /  o   o  \\    Thy faithful squire shall"
echo "   |  >  ◡  <  |   test every aspect of"
echo "    \\  ___  /      QuillKernel thoroughly!"
echo "     |~|♦|~|       "
echo ""

# Setup
DATE=$(date +%Y%m%d_%H%M%S)
RESULTS_DIR="test-results-$DATE"
SUMMARY_FILE="$RESULTS_DIR/test-summary.txt"
HTML_REPORT="$RESULTS_DIR/test-report.html"

# Create results directory
mkdir -p "$RESULTS_DIR"

# Test configuration
declare -A TESTS=(
    ["verify-build-simple"]="Build Verification"
    ["static-analysis"]="Static Code Analysis"
    ["test-boot"]="Boot Sequence Test"
    ["test-proc"]="/proc/squireos Test"
    ["test-typewriter"]="Typewriter Module Test"
    ["test-usb"]="USB Keyboard Test (Basic)"
    ["usb-automated-test"]="USB Keyboard Test (Advanced)"
    ["test-eink"]="E-Ink Display Test"
    ["low-memory-test"]="Low Memory Stress Test"
    ["benchmark"]="Performance Benchmark"
)

# Test order (some tests depend on others)
TEST_ORDER=("verify-build-simple" "static-analysis" "test-boot" "test-proc" "test-typewriter" "test-usb" "usb-automated-test" "test-eink" "low-memory-test" "benchmark")

# Results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to run a test
run_test() {
    local test_name="$1"
    local test_desc="${TESTS[$test_name]}"
    local test_file="${test_name}.sh"
    local log_file="$RESULTS_DIR/${test_name}.log"
    
    echo ""
    echo "Running: $test_desc"
    echo "════════════════════════════════════════════"
    
    ((TOTAL_TESTS++))
    
    if [ ! -f "$test_file" ]; then
        echo -e "${YELLOW}[SKIP]${NC} Test script not found: $test_file"
        ((SKIPPED_TESTS++))
        echo "SKIPPED: $test_desc - Script not found" >> "$SUMMARY_FILE"
        return
    fi
    
    # Make executable
    chmod +x "$test_file"
    
    # Run test and capture output
    if ./"$test_file" > "$log_file" 2>&1; then
        echo -e "${GREEN}[PASS]${NC} $test_desc completed successfully"
        ((PASSED_TESTS++))
        echo "PASSED: $test_desc" >> "$SUMMARY_FILE"
        
        # Extract key metrics
        if [ "$test_name" = "benchmark" ]; then
            grep -E "memory:|time:|MB/s" "$log_file" | tail -5 >> "$SUMMARY_FILE"
        fi
    else
        EXIT_CODE=$?
        echo -e "${RED}[FAIL]${NC} $test_desc failed with exit code: $EXIT_CODE"
        ((FAILED_TESTS++))
        echo "FAILED: $test_desc (Exit code: $EXIT_CODE)" >> "$SUMMARY_FILE"
        
        # Show last few lines of error
        echo "Error output:" | tee -a "$SUMMARY_FILE"
        tail -10 "$log_file" | tee -a "$SUMMARY_FILE"
    fi
    
    echo "" >> "$SUMMARY_FILE"
}

# Function to check prerequisites
check_prerequisites() {
    echo "Checking test prerequisites..."
    
    # Check if running on actual Nook
    if [ -f /proc/cpuinfo ] && grep -q "OMAP" /proc/cpuinfo; then
        echo "✓ Running on OMAP hardware (likely Nook)"
        HARDWARE_TESTS=true
    else
        echo "⚠ Not running on Nook hardware - some tests will be limited"
        HARDWARE_TESTS=false
    fi
    
    # Check kernel version
    if uname -r | grep -q "quill"; then
        echo "✓ QuillKernel detected"
    else
        echo "⚠ QuillKernel not detected - some tests may fail"
    fi
    
    # Check for USB keyboard
    if lsusb 2>/dev/null | grep -qi "keyboard"; then
        echo "✓ USB keyboard detected"
    else
        echo "⚠ No USB keyboard - USB tests will be limited"
    fi
    
    echo ""
}

# Function to generate HTML report
generate_html_report() {
    cat > "$HTML_REPORT" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>QuillKernel Test Report</title>
    <style>
        body { font-family: monospace; background: #f5f5f5; margin: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .summary { background: white; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
        .passed { color: green; font-weight: bold; }
        .failed { color: red; font-weight: bold; }
        .skipped { color: orange; font-weight: bold; }
        .test-result { background: white; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .jester { text-align: center; margin: 20px; }
        pre { background: #f0f0f0; padding: 10px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="header">
        <h1>QuillKernel Test Report</h1>
        <pre>
     .~"~.~"~.
    /  o   o  \    Test Results
   |  >  ◡  <  |   ============
    \  ___  /      
     |~|♦|~|       
        </pre>
    </div>
EOF

    echo "<div class='summary'>" >> "$HTML_REPORT"
    echo "<h2>Summary</h2>" >> "$HTML_REPORT"
    echo "<p>Date: $(date)</p>" >> "$HTML_REPORT"
    echo "<p>Kernel: $(uname -r)</p>" >> "$HTML_REPORT"
    echo "<p>Total Tests: $TOTAL_TESTS</p>" >> "$HTML_REPORT"
    echo "<p class='passed'>Passed: $PASSED_TESTS</p>" >> "$HTML_REPORT"
    echo "<p class='failed'>Failed: $FAILED_TESTS</p>" >> "$HTML_REPORT"
    echo "<p class='skipped'>Skipped: $SKIPPED_TESTS</p>" >> "$HTML_REPORT"
    echo "</div>" >> "$HTML_REPORT"
    
    echo "<h2>Detailed Results</h2>" >> "$HTML_REPORT"
    
    # Add test details
    for test in "${TEST_ORDER[@]}"; do
        if [ -f "$RESULTS_DIR/${test}.log" ]; then
            echo "<div class='test-result'>" >> "$HTML_REPORT"
            echo "<h3>${TESTS[$test]}</h3>" >> "$HTML_REPORT"
            echo "<pre>" >> "$HTML_REPORT"
            head -50 "$RESULTS_DIR/${test}.log" | sed 's/</\&lt;/g; s/>/\&gt;/g' >> "$HTML_REPORT"
            echo "</pre>" >> "$HTML_REPORT"
            echo "</div>" >> "$HTML_REPORT"
        fi
    done
    
    echo "</body></html>" >> "$HTML_REPORT"
}

# Main execution
echo "Test suite starting at $(date)" | tee "$SUMMARY_FILE"
echo "Results directory: $RESULTS_DIR" | tee -a "$SUMMARY_FILE"
echo "" | tee -a "$SUMMARY_FILE"

# Check prerequisites
check_prerequisites | tee -a "$SUMMARY_FILE"

# Run tests in order
for test in "${TEST_ORDER[@]}"; do
    # Skip hardware-specific tests if not on Nook
    if [ "$test" = "test-boot" ] || [ "$test" = "test-usb" ]; then
        if [ "$HARDWARE_TESTS" = false ]; then
            echo ""
            echo "Skipping $test - requires Nook hardware"
            ((SKIPPED_TESTS++))
            ((TOTAL_TESTS++))
            echo "SKIPPED: ${TESTS[$test]} - Requires hardware" >> "$SUMMARY_FILE"
            continue
        fi
    fi
    
    run_test "$test"
done

# Generate summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                    Test Suite Complete"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Total Tests: $TOTAL_TESTS" | tee -a "$SUMMARY_FILE"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}" | tee -a "$SUMMARY_FILE"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}" | tee -a "$SUMMARY_FILE"
echo -e "Skipped: ${YELLOW}$SKIPPED_TESTS${NC}" | tee -a "$SUMMARY_FILE"
echo ""
echo "Results saved to: $RESULTS_DIR/"
echo "Summary: $SUMMARY_FILE"

# Generate HTML report
generate_html_report
echo "HTML Report: $HTML_REPORT"

# Show jester reaction
echo ""
if [ "$FAILED_TESTS" -eq 0 ] && [ "$SKIPPED_TESTS" -eq 0 ]; then
    echo "     .~\"~.~\"~."
    echo "    /  ^   ^  \\    Perfect score!"
    echo "   |  >  ◡  <  |   All tests passed!"
    echo "    \\  ___  /      QuillKernel is ready!"
    echo "     |~|♦|~|       "
    exit 0
elif [ "$FAILED_TESTS" -eq 0 ]; then
    echo "     .~\"~.~\"~."
    echo "    /  o   o  \\    Tests passed!"
    echo "   |  >  ◡  <  |   (Some were skipped)"
    echo "    \\  ___  /      "
    echo "     |~|♦|~|       "
    exit 0
else
    echo "     .~!!!~."
    echo "    / O   O \\    $FAILED_TESTS tests failed!"
    echo "   |  >   <  |   Check the logs!"
    echo "    \\  ~~~  /    "
    echo "     |~|♦|~|     "
    exit 1
fi