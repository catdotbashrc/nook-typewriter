#!/bin/bash
# JesterOS Test Library - Shared functions for test suite
# Improves maintainability and consistency across all test scripts
# Usage: source ./test-lib.sh

# Standard error codes for consistent test results
readonly TEST_SUCCESS=0
readonly TEST_FAILURE=1
readonly TEST_WARNING=2
readonly TEST_SKIPPED=3

# Color definitions for consistent output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Test result tracking
TEST_NAME=""
TEST_RESULTS=()
TEST_WARNINGS=()

# Initialize test with name and description
init_test() {
    local test_name="$1"
    local test_desc="${2:-}"
    
    TEST_NAME="$test_name"
    TEST_RESULTS=()
    TEST_WARNINGS=()
    
    echo "═══════════════════════════════════════════════════════════════"
    echo "  $test_name"
    if [ -n "$test_desc" ]; then
        echo "  $test_desc"
    fi
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
}

# Log test pass
pass() {
    local message="$1"
    echo -e "${GREEN}✓${NC} $message"
    TEST_RESULTS+=("PASS: $message")
    return $TEST_SUCCESS
}

# Log test failure
fail() {
    local message="$1"
    echo -e "${RED}✗${NC} $message"
    TEST_RESULTS+=("FAIL: $message")
    return $TEST_FAILURE
}

# Log warning (non-critical issue)
warn() {
    local message="$1"
    echo -e "${YELLOW}⚠${NC} $message"
    TEST_WARNINGS+=("WARN: $message")
    return $TEST_WARNING
}

# Log informational message
info() {
    local message="$1"
    echo -e "${BLUE}ℹ${NC} $message"
}

# Log debug message (only if DEBUG=1)
debug() {
    local message="$1"
    if [ "${DEBUG:-0}" = "1" ]; then
        echo -e "${CYAN}[DEBUG]${NC} $message"
    fi
}

# Check if a command exists
check_command() {
    local cmd="$1"
    local friendly_name="${2:-$cmd}"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        debug "$friendly_name is available"
        return $TEST_SUCCESS
    else
        debug "$friendly_name not found"
        return $TEST_FAILURE
    fi
}

# Check if a file exists and is readable
check_file() {
    local file="$1"
    local description="${2:-$file}"
    
    if [ -f "$file" ] && [ -r "$file" ]; then
        debug "$description exists and is readable"
        return $TEST_SUCCESS
    else
        debug "$description not found or not readable"
        return $TEST_FAILURE
    fi
}

# Check if a directory exists
check_directory() {
    local dir="$1"
    local description="${2:-$dir}"
    
    if [ -d "$dir" ]; then
        debug "$description exists"
        return $TEST_SUCCESS
    else
        debug "$description not found"
        return $TEST_FAILURE
    fi
}

# Check if a script has safety headers
check_script_safety() {
    local script="$1"
    local has_safety=false
    
    if grep -q "^set -[eu]" "$script" 2>/dev/null; then
        has_safety=true
    fi
    
    if grep -q "^set -o pipefail" "$script" 2>/dev/null; then
        has_safety=true
    fi
    
    if [ "$has_safety" = true ]; then
        debug "$script has safety headers"
        return $TEST_SUCCESS
    else
        debug "$script missing safety headers"
        return $TEST_FAILURE
    fi
}

# Check memory usage of a file/directory
check_memory_usage() {
    local path="$1"
    local max_size_mb="$2"
    local description="${3:-$path}"
    
    if [ ! -e "$path" ]; then
        debug "$description does not exist"
        return $TEST_FAILURE
    fi
    
    local size_kb=$(du -sk "$path" 2>/dev/null | cut -f1)
    local size_mb=$((size_kb / 1024))
    
    if [ "$size_mb" -le "$max_size_mb" ]; then
        debug "$description uses ${size_mb}MB (limit: ${max_size_mb}MB)"
        return $TEST_SUCCESS
    else
        debug "$description uses ${size_mb}MB (exceeds ${max_size_mb}MB limit)"
        return $TEST_FAILURE
    fi
}

# Run a test with timeout
run_with_timeout() {
    local timeout="$1"
    shift
    local command="$@"
    
    if command -v timeout >/dev/null 2>&1; then
        timeout "$timeout" bash -c "$command"
    else
        # Fallback if timeout command not available
        bash -c "$command" &
        local pid=$!
        local count=0
        while kill -0 $pid 2>/dev/null && [ $count -lt $timeout ]; do
            sleep 1
            count=$((count + 1))
        done
        if kill -0 $pid 2>/dev/null; then
            kill -9 $pid
            return $TEST_FAILURE
        fi
        wait $pid
    fi
}

# Check Docker availability
check_docker() {
    if ! check_command docker "Docker"; then
        return $TEST_FAILURE
    fi
    
    if ! docker info >/dev/null 2>&1; then
        debug "Docker daemon not running"
        return $TEST_FAILURE
    fi
    
    debug "Docker is available and running"
    return $TEST_SUCCESS
}

# Count files matching pattern
count_files() {
    local pattern="$1"
    local directory="${2:-.}"
    
    find "$directory" -name "$pattern" 2>/dev/null | wc -l
}

# Check if string contains substring
contains() {
    local string="$1"
    local substring="$2"
    
    if [[ "$string" == *"$substring"* ]]; then
        return $TEST_SUCCESS
    else
        return $TEST_FAILURE
    fi
}

# Summarize test results
summarize_test() {
    local failed=0
    local passed=0
    
    for result in "${TEST_RESULTS[@]}"; do
        if [[ "$result" == PASS:* ]]; then
            ((passed++))
        elif [[ "$result" == FAIL:* ]]; then
            ((failed++))
        fi
    done
    
    echo ""
    echo "Summary for $TEST_NAME:"
    echo "  Passed: $passed"
    echo "  Failed: $failed"
    echo "  Warnings: ${#TEST_WARNINGS[@]}"
    
    if [ "$failed" -eq 0 ]; then
        echo -e "${GREEN}✅ TEST PASSED${NC}"
        return $TEST_SUCCESS
    else
        echo -e "${RED}❌ TEST FAILED${NC}"
        return $TEST_FAILURE
    fi
}

# Log test results to file (optional)
log_results() {
    local log_file="${1:-test-results.log}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    {
        echo "[$timestamp] $TEST_NAME"
        echo "Results:"
        for result in "${TEST_RESULTS[@]}"; do
            echo "  $result"
        done
        if [ "${#TEST_WARNINGS[@]}" -gt 0 ]; then
            echo "Warnings:"
            for warning in "${TEST_WARNINGS[@]}"; do
                echo "  $warning"
            done
        fi
        echo ""
    } >> "$log_file"
}

# Display a progress bar
show_progress() {
    local current="$1"
    local total="$2"
    local width=50
    
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    
    printf "\r["
    printf "%${filled}s" | tr ' ' '='
    printf "%$((width - filled))s" | tr ' ' ' '
    printf "] %d%%" "$percent"
    
    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}

# Medieval theme banner
show_banner() {
    local title="$1"
    local subtitle="${2:-}"
    
    echo "╔════════════════════════════════════════════════════════════════╗"
    printf "║%-64s║\n" "  $title"
    if [ -n "$subtitle" ]; then
        printf "║%-64s║\n" "  \"$subtitle\""
    fi
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
}

# Check test prerequisites
check_prerequisites() {
    local prerequisites=("$@")
    local all_met=true
    
    info "Checking prerequisites..."
    
    for prereq in "${prerequisites[@]}"; do
        if check_command "$prereq"; then
            pass "$prereq available"
        else
            fail "$prereq not found"
            all_met=false
        fi
    done
    
    if [ "$all_met" = true ]; then
        return $TEST_SUCCESS
    else
        return $TEST_FAILURE
    fi
}

# Export test stage for consistency
export_test_stage() {
    local stage="${1:-post-build}"
    export TEST_STAGE="$stage"
    info "Test stage: $TEST_STAGE"
}

# Validate path safety (no traversal)
validate_safe_path() {
    local path="$1"
    
    # Check for path traversal attempts
    if contains "$path" ".." || contains "$path" "~"; then
        debug "Path contains unsafe characters: $path"
        return $TEST_FAILURE
    fi
    
    # Check for absolute paths to system directories
    if [[ "$path" == /dev/* ]] || [[ "$path" == /sys/* ]] || [[ "$path" == /proc/* ]]; then
        debug "Path points to system directory: $path"
        return $TEST_FAILURE
    fi
    
    debug "Path appears safe: $path"
    return $TEST_SUCCESS
}

# Check theme consistency
check_theme_words() {
    local file="$1"
    local min_count="${2:-5}"
    
    local theme_words="jester|scroll|quill|parchment|scribe|knight|medieval|court|realm"
    local count=$(grep -iE "$theme_words" "$file" 2>/dev/null | wc -l)
    
    if [ "$count" -ge "$min_count" ]; then
        debug "$file has $count theme references (minimum: $min_count)"
        return $TEST_SUCCESS
    else
        debug "$file has only $count theme references (minimum: $min_count)"
        return $TEST_FAILURE
    fi
}

# Cleanup function for test artifacts
cleanup_test_artifacts() {
    local test_dir="${1:-/tmp/test-$$}"
    
    if [ -d "$test_dir" ]; then
        rm -rf "$test_dir"
        debug "Cleaned up test artifacts in $test_dir"
    fi
}

# Set up test environment
setup_test_env() {
    # Set safe defaults
    set -euo pipefail
    
    # Set up error handling
    trap 'echo "Test failed at line $LINENO"' ERR
    
    # Create test directory if needed
    export TEST_DIR="/tmp/test-$$"
    mkdir -p "$TEST_DIR"
    
    # Set consistent locale
    export LC_ALL=C
    
    debug "Test environment initialized"
}

# Compare versions
version_compare() {
    local version1="$1"
    local operator="$2"
    local version2="$3"
    
    # Simple version comparison (works for x.y.z format)
    case "$operator" in
        "==")
            [ "$version1" = "$version2" ]
            ;;
        "!=")
            [ "$version1" != "$version2" ]
            ;;
        ">")
            [ "$(printf '%s\n' "$version1" "$version2" | sort -V | tail -n1)" = "$version1" ] && [ "$version1" != "$version2" ]
            ;;
        ">=")
            [ "$(printf '%s\n' "$version1" "$version2" | sort -V | tail -n1)" = "$version1" ]
            ;;
        "<")
            [ "$(printf '%s\n' "$version1" "$version2" | sort -V | head -n1)" = "$version1" ] && [ "$version1" != "$version2" ]
            ;;
        "<=")
            [ "$(printf '%s\n' "$version1" "$version2" | sort -V | head -n1)" = "$version1" ]
            ;;
        *)
            return $TEST_FAILURE
            ;;
    esac
}