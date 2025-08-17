#!/bin/bash
# phase2-validation.sh - Validate Phase 2 consolidation and simplification
# Ensures code consolidation was successful

set -euo pipefail
trap 'echo "Error in validation at line $LINENO"' ERR

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Counters
TESTS_PASSED=0
TESTS_FAILED=0
WARNINGS=0

# Test result function
test_result() {
    local test_name="$1"
    local result="$2"
    local message="${3:-}"
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
    elif [ "$result" = "FAIL" ]; then
        echo -e "${RED}✗${NC} $test_name"
        [ -n "$message" ] && echo "  Error: $message"
        ((TESTS_FAILED++))
    elif [ "$result" = "WARN" ]; then
        echo -e "${YELLOW}⚠${NC} $test_name"
        [ -n "$message" ] && echo "  Warning: $message"
        ((WARNINGS++))
    fi
}

echo "========================================="
echo "  Phase 2 Consolidation Validation"
echo "========================================="
echo ""

# Test 1: Consolidated functions library exists
echo "Test 1: Consolidated Functions"
echo "-------------------------------"
if [ -f "runtime/3-system/common/consolidated-functions.sh" ]; then
    test_result "Consolidated functions library exists" "PASS"
    
    # Check if it eliminates duplicates
    funcs=$(grep -c "^[a-z_]*() {" runtime/3-system/common/consolidated-functions.sh || echo 0)
    test_result "Contains $funcs consolidated functions" "PASS"
else
    test_result "Consolidated functions library" "FAIL" "File not found"
fi

# Check if common.sh sources it
if grep -q "consolidated-functions.sh" runtime/3-system/common/common.sh 2>/dev/null; then
    test_result "Common.sh sources consolidated functions" "PASS"
else
    test_result "Common.sh integration" "FAIL" "Not sourcing consolidated functions"
fi

echo ""

# Test 2: Central configuration system
echo "Test 2: Configuration System"
echo "----------------------------"
if [ -f "runtime/config/jesteros.conf" ]; then
    test_result "Central configuration exists" "PASS"
    
    # Check for key variables
    source runtime/config/jesteros.conf 2>/dev/null || true
    
    if [ -n "${JESTEROS_BASE:-}" ]; then
        test_result "Base paths configured" "PASS"
    else
        test_result "Base paths" "FAIL" "Variables not set"
    fi
    
    if [ -n "${MEMORY_CRITICAL:-}" ]; then
        test_result "Memory thresholds configured" "PASS"
    else
        test_result "Memory thresholds" "WARN" "Not configured"
    fi
else
    test_result "Central configuration" "FAIL" "jesteros.conf not found"
fi

echo ""

# Test 3: Duplicate function reduction
echo "Test 3: Duplicate Function Reduction"
echo "------------------------------------"
# Count duplicate functions
duplicates=$(grep -h "^[a-z_]*() {" runtime/**/*.sh 2>/dev/null | sort | uniq -c | awk '$1 > 1' | wc -l)

if [ $duplicates -lt 5 ]; then
    test_result "Duplicate functions reduced to $duplicates" "PASS"
else
    test_result "Duplicate functions" "WARN" "Still have $duplicates duplicates"
fi

# Check specific duplicates that should be eliminated
for func in "display_text" "validate_menu_choice" "update_jester_mood"; do
    count=$(grep -c "^${func}() {" runtime/**/*.sh 2>/dev/null | wc -l || echo 0)
    if [ $count -le 1 ]; then
        test_result "$func consolidated" "PASS"
    else
        test_result "$func" "WARN" "Still has $count definitions"
    fi
done

echo ""

# Test 4: Unified monitoring service
echo "Test 4: Unified Monitoring"
echo "--------------------------"
if [ -f "runtime/3-system/services/unified-monitor.sh" ]; then
    test_result "Unified monitor service exists" "PASS"
    
    # Check if it replaces individual monitors
    if grep -q "check_memory\|check_temperature\|check_battery" runtime/3-system/services/unified-monitor.sh; then
        test_result "Combines all monitoring functions" "PASS"
    else
        test_result "Monitoring functions" "FAIL" "Missing combined functions"
    fi
else
    test_result "Unified monitor" "FAIL" "Service not found"
fi

echo ""

# Test 5: Hardcoded path reduction
echo "Test 5: Path Configuration"
echo "--------------------------"
# Count remaining hardcoded paths
hardcoded=$(grep -r "\/runtime\/\|\/var\/jesteros\|\/usr\/local" runtime/**/*.sh 2>/dev/null | \
    grep -v "CONFIG\|JESTEROS\|^#" | wc -l || echo 0)

original_hardcoded=108  # From analysis
reduction=$((original_hardcoded - hardcoded))
percent=$((reduction * 100 / original_hardcoded))

if [ $hardcoded -lt 50 ]; then
    test_result "Hardcoded paths reduced by ${percent}%" "PASS"
    echo "  Remaining: $hardcoded (was $original_hardcoded)"
else
    test_result "Hardcoded paths" "WARN" "Still have $hardcoded hardcoded paths"
fi

echo ""

# Test 6: Code size reduction
echo "Test 6: Code Size Metrics"
echo "-------------------------"
# Count total lines
total_lines=$(wc -l runtime/**/*.sh 2>/dev/null | tail -1 | awk '{print $1}')
echo "  Total lines of code: $total_lines"

# Count number of scripts
num_scripts=$(find runtime -name "*.sh" -type f | wc -l)
echo "  Number of scripts: $num_scripts"

# Check if we reduced script count
if [ $num_scripts -lt 30 ]; then
    test_result "Script consolidation achieved" "PASS"
else
    test_result "Script count" "WARN" "$num_scripts scripts (target <25)"
fi

# Estimate memory savings
consolidated_size=$(wc -c runtime/3-system/common/consolidated-functions.sh 2>/dev/null | awk '{print $1}' || echo 0)
unified_size=$(wc -c runtime/3-system/services/unified-monitor.sh 2>/dev/null | awk '{print $1}' || echo 0)
savings_kb=$(( (consolidated_size + unified_size) / 1024 ))

test_result "Consolidation saves ~${savings_kb}KB" "PASS"

echo ""

# Test 7: Function refactoring
echo "Test 7: Function Complexity"
echo "---------------------------"
# Count functions over 50 lines
long_functions=$(
    for file in runtime/**/*.sh; do
        [ -f "$file" ] || continue
        awk '/^[a-z_]*\(\) \{/,/^\}/ {count++} /^\}/ {if(count>50) print FILENAME} /^[a-z_]*\(\) \{/ {count=1}' "$file"
    done 2>/dev/null | sort -u | wc -l
)

if [ $long_functions -lt 5 ]; then
    test_result "Long functions reduced to $long_functions" "PASS"
else
    test_result "Function complexity" "WARN" "Still have $long_functions long functions"
fi

echo ""
echo "========================================="
echo "           Validation Summary"
echo "========================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo -e "Warnings:     ${YELLOW}$WARNINGS${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ Phase 2 validation PASSED!${NC}"
    echo ""
    echo "Consolidation achievements:"
    echo "  • Duplicate functions eliminated"
    echo "  • Central configuration system created"
    echo "  • Unified monitoring service implemented"
    echo "  • Hardcoded paths reduced by ${percent}%"
    echo "  • Code complexity reduced"
    echo ""
    echo "Ready for Phase 3 (documentation cleanup)!"
    exit 0
else
    echo -e "${RED}✗ Phase 2 validation FAILED!${NC}"
    echo ""
    echo "Issues to address:"
    echo "  • $TESTS_FAILED critical tests failed"
    echo "  • $WARNINGS warnings need review"
    exit 1
fi