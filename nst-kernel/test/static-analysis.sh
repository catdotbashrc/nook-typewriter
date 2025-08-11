#!/bin/bash
# QuillKernel Static Analysis Script
# Runs Sparse and Smatch on kernel source

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "         QuillKernel Static Analysis"
echo "═══════════════════════════════════════════════════════════════"
echo ""

KERNEL_DIR="../src"
LOG_DIR="static-analysis-results-$(date +%Y%m%d_%H%M%S)"
SPARSE_LOG="$LOG_DIR/sparse.log"
SMATCH_LOG="$LOG_DIR/smatch.log"
SUMMARY_LOG="$LOG_DIR/summary.txt"

# Create log directory
mkdir -p "$LOG_DIR"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Counters
SPARSE_WARNINGS=0
SPARSE_ERRORS=0
SMATCH_WARNINGS=0
SMATCH_ERRORS=0

echo "Starting analysis at $(date)" | tee "$SUMMARY_LOG"
echo "" | tee -a "$SUMMARY_LOG"

# Function to check if tool is available
check_tool() {
    local tool=$1
    if ! command -v "$tool" > /dev/null 2>&1; then
        echo -e "${RED}[ERROR]${NC} $tool not found. Please install it first."
        echo "For Debian/Ubuntu: sudo apt-get install sparse"
        echo "For Smatch: git clone git://repo.or.cz/smatch.git && cd smatch && make"
        return 1
    fi
    return 0
}

# 1. Sparse Analysis
echo "1. Running Sparse Analysis"
echo "-------------------------"

if check_tool "sparse"; then
    echo "Analyzing SquireOS modules..." | tee -a "$SUMMARY_LOG"
    
    # Run sparse on our custom files
    cd "$KERNEL_DIR"
    
    # Analyze squireos directory
    if [ -d "drivers/squireos" ]; then
        echo -n "  Checking drivers/squireos... "
        sparse drivers/squireos/*.c -Wbitwise -Wno-decl > "$LOG_DIR/sparse-squireos.log" 2>&1 || true
        
        WARNINGS=$(grep -c "warning:" "$LOG_DIR/sparse-squireos.log" || echo "0")
        ERRORS=$(grep -c "error:" "$LOG_DIR/sparse-squireos.log" || echo "0")
        
        SPARSE_WARNINGS=$((SPARSE_WARNINGS + WARNINGS))
        SPARSE_ERRORS=$((SPARSE_ERRORS + ERRORS))
        
        if [ "$ERRORS" -gt 0 ]; then
            echo -e "${RED}$ERRORS errors, $WARNINGS warnings${NC}"
        elif [ "$WARNINGS" -gt 0 ]; then
            echo -e "${YELLOW}$WARNINGS warnings${NC}"
        else
            echo -e "${GREEN}OK${NC}"
        fi
    fi
    
    # Analyze board files
    echo -n "  Checking board files... "
    find arch/arm/mach-omap2 -name "*squire*.c" -exec sparse {} -Wbitwise \; > "$LOG_DIR/sparse-board.log" 2>&1 || true
    
    WARNINGS=$(grep -c "warning:" "$LOG_DIR/sparse-board.log" || echo "0")
    ERRORS=$(grep -c "error:" "$LOG_DIR/sparse-board.log" || echo "0")
    
    SPARSE_WARNINGS=$((SPARSE_WARNINGS + WARNINGS))
    SPARSE_ERRORS=$((SPARSE_ERRORS + ERRORS))
    
    if [ "$ERRORS" -gt 0 ]; then
        echo -e "${RED}$ERRORS errors, $WARNINGS warnings${NC}"
    elif [ "$WARNINGS" -gt 0 ]; then
        echo -e "${YELLOW}$WARNINGS warnings${NC}"
    else
        echo -e "${GREEN}OK${NC}"
    fi
    
    cd - > /dev/null
    
    echo "" | tee -a "$SUMMARY_LOG"
    echo "Sparse Results:" | tee -a "$SUMMARY_LOG"
    echo "  Total Errors: $SPARSE_ERRORS" | tee -a "$SUMMARY_LOG"
    echo "  Total Warnings: $SPARSE_WARNINGS" | tee -a "$SUMMARY_LOG"
else
    echo "Sparse not available - skipping" | tee -a "$SUMMARY_LOG"
fi

echo ""

# 2. Smatch Analysis
echo "2. Running Smatch Analysis"
echo "-------------------------"

if check_tool "smatch"; then
    echo "Analyzing for common errors..." | tee -a "$SUMMARY_LOG"
    
    cd "$KERNEL_DIR"
    
    # Run smatch with common checks
    echo -n "  Checking for null pointer issues... "
    smatch --project=kernel drivers/squireos/*.c 2>&1 | grep -E "null|NULL" > "$LOG_DIR/smatch-null.log" || true
    NULL_ISSUES=$(wc -l < "$LOG_DIR/smatch-null.log")
    
    if [ "$NULL_ISSUES" -gt 0 ]; then
        echo -e "${YELLOW}$NULL_ISSUES potential issues${NC}"
        SMATCH_WARNINGS=$((SMATCH_WARNINGS + NULL_ISSUES))
    else
        echo -e "${GREEN}OK${NC}"
    fi
    
    echo -n "  Checking for memory leaks... "
    smatch --project=kernel drivers/squireos/*.c 2>&1 | grep -E "leak|free" > "$LOG_DIR/smatch-memory.log" || true
    LEAK_ISSUES=$(wc -l < "$LOG_DIR/smatch-memory.log")
    
    if [ "$LEAK_ISSUES" -gt 0 ]; then
        echo -e "${YELLOW}$LEAK_ISSUES potential issues${NC}"
        SMATCH_WARNINGS=$((SMATCH_WARNINGS + LEAK_ISSUES))
    else
        echo -e "${GREEN}OK${NC}"
    fi
    
    echo -n "  Checking for missing breaks... "
    smatch --project=kernel drivers/squireos/*.c 2>&1 | grep -i "break" > "$LOG_DIR/smatch-break.log" || true
    BREAK_ISSUES=$(wc -l < "$LOG_DIR/smatch-break.log")
    
    if [ "$BREAK_ISSUES" -gt 0 ]; then
        echo -e "${YELLOW}$BREAK_ISSUES potential issues${NC}"
        SMATCH_WARNINGS=$((SMATCH_WARNINGS + BREAK_ISSUES))
    else
        echo -e "${GREEN}OK${NC}"
    fi
    
    cd - > /dev/null
    
    echo "" | tee -a "$SUMMARY_LOG"
    echo "Smatch Results:" | tee -a "$SUMMARY_LOG"
    echo "  Total Issues: $SMATCH_WARNINGS" | tee -a "$SUMMARY_LOG"
else
    echo "Smatch not available - skipping" | tee -a "$SUMMARY_LOG"
fi

echo ""

# 3. Custom QuillKernel Checks
echo "3. QuillKernel-Specific Checks"
echo "-----------------------------"

cd "$KERNEL_DIR"

# Check for Unicode in C files (can cause issues)
echo -n "  Checking for Unicode in source files... "
UNICODE_FILES=$(find drivers/squireos arch/arm/mach-omap2 -name "*.c" -exec grep -l "[♦◡]" {} \; 2>/dev/null | wc -l)
if [ "$UNICODE_FILES" -gt 0 ]; then
    echo -e "${YELLOW}$UNICODE_FILES files with Unicode${NC}"
    find drivers/squireos arch/arm/mach-omap2 -name "*.c" -exec grep -l "[♦◡]" {} \; > "$LOG_DIR/unicode-files.log" 2>/dev/null
else
    echo -e "${GREEN}OK${NC}"
fi

# Check for long delays in boot path
echo -n "  Checking for excessive boot delays... "
LONG_DELAYS=$(grep -r "mdelay([0-9]\{4,\})" drivers/ arch/arm/mach-omap2/ 2>/dev/null | wc -l || echo "0")
if [ "$LONG_DELAYS" -gt 0 ]; then
    echo -e "${YELLOW}$LONG_DELAYS long delays found${NC}"
    grep -r "mdelay([0-9]\{4,\})" drivers/ arch/arm/mach-omap2/ > "$LOG_DIR/long-delays.log" 2>/dev/null || true
else
    echo -e "${GREEN}OK${NC}"
fi

# Check for proper error handling
echo -n "  Checking error handling patterns... "
NO_CHECK=$(grep -r "kmalloc\|kzalloc" drivers/squireos/ 2>/dev/null | grep -v "if.*==" | wc -l || echo "0")
if [ "$NO_CHECK" -gt 0 ]; then
    echo -e "${YELLOW}$NO_CHECK unchecked allocations${NC}"
else
    echo -e "${GREEN}OK${NC}"
fi

cd - > /dev/null

echo ""

# 4. Generate Summary Report
echo "═══════════════════════════════════════════════════════════════"
echo "                    Analysis Summary"
echo "═══════════════════════════════════════════════════════════════"
echo ""

TOTAL_ISSUES=$((SPARSE_ERRORS + SPARSE_WARNINGS + SMATCH_WARNINGS))

echo "Total Issues Found: $TOTAL_ISSUES" | tee -a "$SUMMARY_LOG"
echo "  Sparse Errors: $SPARSE_ERRORS" | tee -a "$SUMMARY_LOG"
echo "  Sparse Warnings: $SPARSE_WARNINGS" | tee -a "$SUMMARY_LOG"
echo "  Smatch Issues: $SMATCH_WARNINGS" | tee -a "$SUMMARY_LOG"
echo "" | tee -a "$SUMMARY_LOG"
echo "Detailed logs saved in: $LOG_DIR/" | tee -a "$SUMMARY_LOG"

# Show top issues if any
if [ "$TOTAL_ISSUES" -gt 0 ]; then
    echo ""
    echo "Top Issues to Address:"
    echo "---------------------"
    
    if [ -f "$LOG_DIR/sparse-squireos.log" ] && [ -s "$LOG_DIR/sparse-squireos.log" ]; then
        echo "From Sparse:"
        head -5 "$LOG_DIR/sparse-squireos.log"
    fi
    
    if [ -f "$LOG_DIR/smatch-null.log" ] && [ -s "$LOG_DIR/smatch-null.log" ]; then
        echo ""
        echo "From Smatch:"
        head -5 "$LOG_DIR/smatch-null.log"
    fi
fi

echo ""

# Final jester message
if [ "$TOTAL_ISSUES" -eq 0 ]; then
    echo "     .~\"~.~\"~."
    echo "    /  ^   ^  \\    Excellent! No issues found!"
    echo "   |  >  ◡  <  |   The code is as clean as"
    echo "    \\  ___  /      freshly pressed parchment!"
    echo "     |~|♦|~|       "
    exit 0
elif [ "$SPARSE_ERRORS" -eq 0 ] && [ "$TOTAL_ISSUES" -lt 10 ]; then
    echo "     .~\"~.~\"~."
    echo "    /  o   o  \\    Minor issues found."
    echo "   |  >  ◡  <  |   Nothing a good squire"
    echo "    \\  ___  /      can't fix!"
    echo "     |~|♦|~|       "
    exit 0
else
    echo "     .~!!!~."
    echo "    / O   O \\    $TOTAL_ISSUES issues found!"
    echo "   |  >   <  |   Time to polish the code!"
    echo "    \\  ~~~  /    "
    echo "     |~|♦|~|     "
    exit 1
fi