#!/bin/bash
# JesterOS Test Configuration
# Central configuration for all test scripts
# Source this file to get consistent test settings

# Test Environment Configuration
export TEST_ENV="${TEST_ENV:-local}"  # local, docker, device
export TEST_STAGE="${TEST_STAGE:-post-build}"  # pre-build, post-build, runtime
export DEBUG="${DEBUG:-0}"  # Set to 1 for debug output
export LOG_RESULTS="${LOG_RESULTS:-0}"  # Set to 1 to log test results
export TEST_LOG_FILE="${TEST_LOG_FILE:-test-results.log}"

# Directory Paths (relative to tests/)
export PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export SOURCE_DIR="$PROJECT_ROOT/source"
export BUILD_DIR="$PROJECT_ROOT/build"
export TESTS_DIR="$PROJECT_ROOT/tests"
export RUNTIME_DIR="$PROJECT_ROOT/runtime"
export SCRIPTS_DIR="$PROJECT_ROOT/scripts"
export CONFIGS_DIR="$SOURCE_DIR/configs"

# Docker Configuration
export DEFAULT_DOCKER_IMAGE="jesteros-test"
export DOCKER_BUILD_TIMEOUT=300  # 5 minutes
export DOCKER_TEST_TIMEOUT=60    # 1 minute per test

# Memory Constraints (from CLAUDE.md)
export MAX_OS_MEMORY_MB=96       # Maximum OS memory usage
export MAX_SCRIPT_SIZE_KB=100    # Maximum individual script size
export MIN_WRITER_MEMORY_MB=160  # Minimum memory for writing
export TOTAL_DEVICE_MEMORY_MB=256 # Total Nook memory

# Test Thresholds
export MIN_SAFETY_HEADERS_PERCENT=80  # % of scripts with safety headers
export MIN_THEME_WORDS=10             # Minimum medieval theme words
export MAX_SILENT_FAILURES=5          # Maximum error suppressions
export MIN_ERROR_HANDLERS_PERCENT=50  # % of scripts with error handling

# File Patterns
export SHELL_SCRIPT_PATTERN="*.sh"
export CONFIG_FILE_PATTERN="*.conf"
export VIM_CONFIG_PATTERN="vimrc*"

# Expected Directories (created during boot)
export EXPECTED_DIRS=(
    "/root/notes"
    "/root/drafts"
    "/root/scrolls"
    "/var/jesteros"
    "/var/jesteros/typewriter"
    "/var/jesteros/health"
)

# Critical Files (must exist for boot)
export CRITICAL_FILES=(
    "$SCRIPTS_DIR/boot/init-jester.sh"
    "$SCRIPTS_DIR/menu/nook-menu.sh"
    "$SCRIPTS_DIR/lib/common-functions.sh"
)

# Dangerous Patterns (should never appear)
export DANGEROUS_PATTERNS=(
    "/dev/sda"
    "rm -rf /"
    "dd if=/dev/zero"
    "mkfs"
    "> /dev/sda"
)

# Medieval Theme Words (for experience testing)
export THEME_WORDS=(
    "jester"
    "scroll"
    "quill"
    "parchment"
    "scribe"
    "knight"
    "medieval"
    "court"
    "realm"
    "throne"
    "castle"
    "wizard"
)

# Test Categories (for run-tests.sh)
declare -A TEST_CATEGORIES
TEST_CATEGORIES["show_stopper"]="01-safety-check.sh 02-boot-test.sh"
TEST_CATEGORIES["writing_blocker"]="04-docker-smoke.sh 05-consistency-check.sh 06-memory-guard.sh"
TEST_CATEGORIES["experience"]="03-functionality.sh 07-writer-experience.sh"

# Test Timeouts (seconds)
declare -A TEST_TIMEOUTS
TEST_TIMEOUTS["01-safety-check.sh"]=5
TEST_TIMEOUTS["02-boot-test.sh"]=10
TEST_TIMEOUTS["03-functionality.sh"]=10
TEST_TIMEOUTS["04-docker-smoke.sh"]=30
TEST_TIMEOUTS["05-consistency-check.sh"]=15
TEST_TIMEOUTS["06-memory-guard.sh"]=10
TEST_TIMEOUTS["07-writer-experience.sh"]=10

# Expected Return Codes
export TEST_SUCCESS=0
export TEST_FAILURE=1
export TEST_WARNING=2
export TEST_SKIPPED=3

# Helper Functions

# Get test category for a test script
get_test_category() {
    local test_script="$1"
    
    for category in "${!TEST_CATEGORIES[@]}"; do
        if [[ " ${TEST_CATEGORIES[$category]} " == *" $test_script "* ]]; then
            echo "$category"
            return
        fi
    done
    echo "unknown"
}

# Get test priority (1=highest, 3=lowest)
get_test_priority() {
    local category="$(get_test_category "$1")"
    
    case "$category" in
        "show_stopper")
            echo 1
            ;;
        "writing_blocker")
            echo 2
            ;;
        "experience")
            echo 3
            ;;
        *)
            echo 99
            ;;
    esac
}

# Check if running in Docker
is_docker_env() {
    if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
        return 0
    fi
    return 1
}

# Check if running on actual Nook device
is_nook_device() {
    if [ -e /sys/devices/platform/omap3epfb.0 ] || \
       grep -q "OMAP3" /proc/cpuinfo 2>/dev/null; then
        return 0
    fi
    return 1
}

# Get appropriate script directory based on test stage
get_script_dir() {
    case "$TEST_STAGE" in
        "pre-build")
            # Pre-build tests check the scripts directory
            echo "$SCRIPTS_DIR"
            ;;
        "post-build")
            # Post-build tests check the runtime directory
            echo "$RUNTIME_DIR"
            ;;
        "runtime")
            # Runtime tests check scripts in the actual runtime location (in Docker)
            echo "/runtime"
            ;;
        *)
            echo "$RUNTIME_DIR"
            ;;
    esac
}

# Validate test environment
validate_test_env() {
    if [ ! -d "$PROJECT_ROOT" ]; then
        echo "Error: Project root not found: $PROJECT_ROOT"
        return 1
    fi
    
    if [ ! -d "$TESTS_DIR" ]; then
        echo "Error: Tests directory not found: $TESTS_DIR"
        return 1
    fi
    
    return 0
}

# Export all functions for use in test scripts
export -f get_test_category
export -f get_test_priority
export -f is_docker_env
export -f is_nook_device
export -f get_script_dir
export -f validate_test_env