#!/bin/bash
# phase3-validation.sh - Validate Phase 3 documentation cleanup
# Ensures documentation is properly organized and consolidated

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
echo "  Phase 3 Documentation Validation"
echo "========================================="
echo ""

# Test 1: Archive structure created
echo "Test 1: Archive Organization"
echo "----------------------------"
if [ -d "docs/archive" ]; then
    test_result "Archive directory exists" "PASS"
    
    # Check subdirectories
    for subdir in "analysis-reports" "indexes" "migration"; do
        if [ -d "docs/archive/$subdir" ]; then
            count=$(find "docs/archive/$subdir" -type f 2>/dev/null | wc -l || echo 0)
            if [ $count -gt 0 ]; then
                test_result "$subdir contains $count archived files" "PASS"
            else
                test_result "$subdir subdirectory" "WARN" "Empty directory"
            fi
        else
            test_result "$subdir subdirectory" "WARN" "Not found - creating"
            mkdir -p "docs/archive/$subdir"
        fi
    done
else
    test_result "Archive directory" "FAIL" "docs/archive not found"
fi

# Count total archived files
total_archived=$(find docs/archive -type f -name "*.md" 2>/dev/null | wc -l || echo 0)
if [ $total_archived -gt 20 ]; then
    test_result "Archived $total_archived analysis documents" "PASS"
else
    test_result "Document archival" "WARN" "Only $total_archived files archived"
fi

echo ""

# Test 2: Current documentation structure
echo "Test 2: Current Documentation"
echo "-----------------------------"
if [ -f "docs/current/README.md" ]; then
    test_result "Current documentation README exists" "PASS"
    
    # Check content completeness
    if grep -q "Phase 1.*COMPLETED" docs/current/README.md && \
       grep -q "Phase 2.*COMPLETED" docs/current/README.md; then
        test_result "Phase completion documented" "PASS"
    else
        test_result "Phase documentation" "WARN" "Missing phase details"
    fi
else
    test_result "Current documentation" "WARN" "docs/current/README.md not found"
fi

echo ""

# Test 3: README consolidation
echo "Test 3: README Files"
echo "--------------------"
# Check main README
if [ -f "README.md" ]; then
    lines=$(wc -l < README.md)
    if [ $lines -lt 500 ]; then
        test_result "Main README is concise ($lines lines)" "PASS"
    else
        test_result "Main README" "WARN" "Too long: $lines lines"
    fi
else
    test_result "Main README" "FAIL" "Not found"
fi

# Check for README updates
if grep -q "JesterOS" README.md 2>/dev/null; then
    test_result "README updated with JesterOS branding" "PASS"
else
    test_result "README branding" "WARN" "Still using old branding"
fi

echo ""

# Test 4: Documentation duplication
echo "Test 4: Documentation Quality"
echo "-----------------------------"
# Count duplicate documentation topics
duplicates=$(find docs -name "*.md" -exec basename {} \; 2>/dev/null | \
    sort | uniq -c | awk '$1 > 1' | wc -l || echo 0)

if [ $duplicates -eq 0 ]; then
    test_result "No duplicate documentation files" "PASS"
else
    test_result "Documentation duplicates" "WARN" "$duplicates duplicate topics found"
fi

# Check for orphaned references
orphans=$(grep -r "docs/.*\.md" docs/*.md 2>/dev/null | \
    grep -v archive | grep -v current | wc -l || echo 0)

if [ $orphans -lt 5 ]; then
    test_result "Minimal orphaned references ($orphans)" "PASS"
else
    test_result "Orphaned references" "WARN" "$orphans references to old structure"
fi

echo ""

# Test 5: Essential documentation present
echo "Test 5: Essential Documentation"
echo "-------------------------------"
essential_docs=(
    "docs/01-getting-started"
    "docs/02-build"
    "docs/03-architecture"
    "docs/07-deployment"
)

for doc_dir in "${essential_docs[@]}"; do
    if [ -d "$doc_dir" ]; then
        test_result "$(basename $doc_dir) documentation present" "PASS"
    else
        test_result "$(basename $doc_dir)" "FAIL" "Essential documentation missing"
    fi
done

echo ""

# Test 6: Archive README present
echo "Test 6: Archive Documentation"
echo "-----------------------------"
if [ -f "docs/archive/README.md" ]; then
    test_result "Archive README exists" "PASS"
    
    if grep -q "Why Archived" docs/archive/README.md; then
        test_result "Archive explanation provided" "PASS"
    else
        test_result "Archive explanation" "WARN" "Missing context"
    fi
else
    test_result "Archive README" "FAIL" "Not found"
fi

echo ""

# Test 7: Documentation metrics
echo "Test 7: Documentation Metrics"
echo "-----------------------------"
# Count total documentation files
total_docs=$(find docs -name "*.md" -type f | wc -l)
active_docs=$(find docs -name "*.md" -type f -not -path "*/archive/*" | wc -l)
archived_docs=$(find docs/archive -name "*.md" -type f | wc -l)

echo "  Total documentation files: $total_docs"
echo "  Active documentation: $active_docs"
echo "  Archived documentation: $archived_docs"

reduction_percent=$(( (archived_docs * 100) / total_docs ))
if [ $reduction_percent -gt 30 ]; then
    test_result "Documentation reduced by ${reduction_percent}%" "PASS"
else
    test_result "Documentation reduction" "WARN" "Only ${reduction_percent}% archived"
fi

echo ""

# Test 8: Deployment readiness
echo "Test 8: Deployment Documentation"
echo "--------------------------------"
if [ -f "docs/07-deployment/deployment-documentation.md" ]; then
    test_result "Deployment guide exists" "PASS"
    
    # Check for key sections
    if grep -q "Quick.*[Dd]eploy\|[Dd]eployment.*[Ss]teps" docs/07-deployment/*.md; then
        test_result "Quick deployment steps documented" "PASS"
    else
        test_result "Deployment steps" "WARN" "Missing quick deployment section"
    fi
else
    test_result "Deployment documentation" "FAIL" "Not found"
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
    echo -e "${GREEN}✓ Phase 3 validation PASSED!${NC}"
    echo ""
    echo "Documentation achievements:"
    echo "  • $total_archived documents archived"
    echo "  • Documentation structure simplified"
    echo "  • Essential guides preserved"
    echo "  • Deployment documentation ready"
    echo "  • ${reduction_percent}% documentation overhead reduced"
    echo ""
    echo "System ready for deployment!"
    exit 0
else
    echo -e "${RED}✗ Phase 3 validation FAILED!${NC}"
    echo ""
    echo "Issues to address:"
    echo "  • $TESTS_FAILED critical tests failed"
    echo "  • $WARNINGS warnings need review"
    exit 1
fi