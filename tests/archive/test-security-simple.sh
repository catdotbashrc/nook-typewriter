#!/bin/bash
# Simplified JesterOS Security Test Suite
# Quick security validation checks

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

echo "════════════════════════════════════════════════════════════════"
echo "           JesterOS Security Test Suite (Simplified)"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Test 1: Check for hardcoded passwords
echo -n "Checking for hardcoded passwords... "
if ! grep -r "password=\|PASSWORD=\|secret=\|token=" source/scripts 2>/dev/null | grep -v "^Binary" > /dev/null; then
    echo -e "${GREEN}✅ PASS${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}❌ FAIL${NC}"
    FAILED=$((FAILED + 1))
fi

# Test 2: Check for writer user setup script
echo -n "Checking for non-root user setup... "
if [[ -f "scripts/setup-writer-user.sh" ]]; then
    echo -e "${GREEN}✅ PASS${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}❌ FAIL${NC}"
    FAILED=$((FAILED + 1))
fi

# Test 3: Check for install command usage
echo -n "Checking for install command usage... "
if grep -r "install -m" source/scripts 2>/dev/null > /dev/null; then
    echo -e "${GREEN}✅ PASS${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}⚠️  WARN${NC}"
fi

# Test 4: Check for input validation in menus
echo -n "Checking for input validation... "
if grep -r "validate_menu_choice\|validate_path" source/scripts/menu 2>/dev/null > /dev/null; then
    echo -e "${GREEN}✅ PASS${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}❌ FAIL${NC}"
    FAILED=$((FAILED + 1))
fi

# Test 5: Check for error handling
echo -n "Checking for error handling... "
SCRIPTS_WITH_TRAP=$(grep -l "^trap " source/scripts/**/*.sh 2>/dev/null | wc -l)
TOTAL_SCRIPTS=$(find source/scripts -name "*.sh" 2>/dev/null | wc -l)
if [[ $SCRIPTS_WITH_TRAP -gt 0 ]]; then
    echo -e "${GREEN}✅ PASS${NC} ($SCRIPTS_WITH_TRAP/$TOTAL_SCRIPTS scripts)"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}❌ FAIL${NC}"
    FAILED=$((FAILED + 1))
fi

# Test 6: Check for unsafe shell practices
echo -n "Checking for unsafe shell practices... "
if ! grep -r "eval " source/scripts 2>/dev/null | grep -v "^Binary" > /dev/null; then
    echo -e "${GREEN}✅ PASS${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}⚠️  WARN${NC}"
fi

# Test 7: Check for secure temp files
echo -n "Checking for secure temp file usage... "
if grep -r "mktemp" source/scripts 2>/dev/null > /dev/null; then
    echo -e "${GREEN}✅ PASS${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}⚠️  WARN${NC}"
fi

# Test 8: Check for path traversal prevention
echo -n "Checking for path validation... "
if grep -r "validate_path" source/scripts/lib 2>/dev/null > /dev/null; then
    echo -e "${GREEN}✅ PASS${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}❌ FAIL${NC}"
    FAILED=$((FAILED + 1))
fi

# Test 9: Check for proper sudoers configuration
echo -n "Checking sudoers configuration... "
if grep -q "NOPASSWD.*cat /var/jesteros" scripts/setup-writer-user.sh 2>/dev/null; then
    echo -e "${GREEN}✅ PASS${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}⚠️  WARN${NC}"
fi

# Test 10: Check file permissions script
echo -n "Checking for secure chmod replacements... "
if [[ -f "scripts/secure-chmod-replacements.sh" ]]; then
    echo -e "${GREEN}✅ PASS${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}❌ FAIL${NC}"
    FAILED=$((FAILED + 1))
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}"

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ All critical security tests passed!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some security tests failed - review needed${NC}"
    exit 1
fi