#!/bin/bash
# Centralized Path Configuration for JesterOS Utilities
# This file defines all paths used across the project to ensure consistency
# and eliminate relative path issues

# ============================================================================
# AUTOMATIC PATH DETECTION
# ============================================================================

# Get the absolute path of this config file (works in both bash and zsh)
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    # Bash
    CONFIG_FILE="${BASH_SOURCE[0]}"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
    # Zsh - use ${0:a} for absolute path or fallback
    if [[ "$0" != "-zsh" ]] && [[ "$0" != "zsh" ]]; then
        CONFIG_FILE="${0:a}"
    else
        # Being sourced interactively, use fallback
        CONFIG_FILE="/home/jyeary/projects/personal/nook/utilities/config/paths.sh"
    fi
else
    # Fallback
    CONFIG_FILE="/home/jyeary/projects/personal/nook/utilities/config/paths.sh"
fi

# Get directory of config file
if [[ -f "$CONFIG_FILE" ]]; then
    CONFIG_DIR="$(cd "$(dirname "$CONFIG_FILE")" && pwd)"
else
    # Fallback if file detection fails
    CONFIG_DIR="/home/jyeary/projects/personal/nook/utilities/config"
fi

# Project root detection (utilities is one level below project root)
PROJECT_ROOT="$(cd "$CONFIG_DIR/../.." && pwd)"

# Utilities root
UTILITIES_ROOT="$(cd "$CONFIG_DIR/.." && pwd)"

# ============================================================================
# DIRECTORY PATHS
# ============================================================================

# Main directories
export JESTEROS_PROJECT_ROOT="$PROJECT_ROOT"
export JESTEROS_UTILITIES="$UTILITIES_ROOT"

# Utilities subdirectories
export JESTEROS_LIB="$UTILITIES_ROOT/lib"
export JESTEROS_BUILD="$UTILITIES_ROOT/build"
export JESTEROS_DEPLOY="$UTILITIES_ROOT/deploy"
export JESTEROS_MAINTAIN="$UTILITIES_ROOT/maintain"
export JESTEROS_SETUP="$UTILITIES_ROOT/setup"
export JESTEROS_MIGRATE="$UTILITIES_ROOT/migrate"
export JESTEROS_TEST="$UTILITIES_ROOT/test"
export JESTEROS_TEST_TESTS="$UTILITIES_ROOT/test/tests"
export JESTEROS_PLATFORM="$UTILITIES_ROOT/platform"
export JESTEROS_EXTRAS="$UTILITIES_ROOT/extras"
export JESTEROS_CONFIG="$UTILITIES_ROOT/config"

# Platform-specific
export JESTEROS_PLATFORM_WINDOWS="$UTILITIES_ROOT/platform/windows"
export JESTEROS_PLATFORM_WSL="$UTILITIES_ROOT/platform/wsl"

# ============================================================================
# FILE PATHS
# ============================================================================

# Core libraries
export JESTEROS_COMMON_LIB="$JESTEROS_LIB/common.sh"
export JESTEROS_VALIDATION_LIB="$JESTEROS_LIB/validation.sh"

# Test framework
export JESTEROS_TEST_FRAMEWORK="$JESTEROS_TEST/framework.sh"
export JESTEROS_TEST_RUNNER="$JESTEROS_TEST/run-all.sh"

# ============================================================================
# PROJECT STRUCTURE PATHS
# ============================================================================

# Source directories
export JESTEROS_SOURCE="$PROJECT_ROOT/source"
export JESTEROS_FIRMWARE="$PROJECT_ROOT/firmware"
export JESTEROS_BUILD_DIR="$PROJECT_ROOT/build"
export JESTEROS_DOCS="$PROJECT_ROOT/docs"
export JESTEROS_TESTS_ROOT="$PROJECT_ROOT/tests"

# Backup directory
export JESTEROS_BACKUPS="$PROJECT_ROOT/backups"

# ============================================================================
# VALIDATION FUNCTIONS
# ============================================================================

# Verify that a path exists
verify_path() {
    local path="$1"
    local type="${2:-any}"  # file, dir, or any
    
    case "$type" in
        file)
            [[ -f "$path" ]] && return 0
            ;;
        dir)
            [[ -d "$path" ]] && return 0
            ;;
        any)
            [[ -e "$path" ]] && return 0
            ;;
    esac
    
    return 1
}

# Get absolute path (resolves symlinks)
get_absolute_path() {
    local path="$1"
    if [[ -e "$path" ]]; then
        echo "$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
    else
        echo ""
        return 1
    fi
}

# Ensure directory exists (create if necessary)
ensure_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || return 1
    fi
    return 0
}

# ============================================================================
# PATH VALIDATION ON LOAD
# ============================================================================

# Validate critical paths exist
validate_paths() {
    local errors=0
    
    # Check critical directories
    for dir in "$JESTEROS_UTILITIES" "$JESTEROS_LIB" "$JESTEROS_CONFIG"; do
        if ! verify_path "$dir" "dir"; then
            echo "Warning: Directory not found: $dir" >&2
            ((errors++))
        fi
    done
    
    # Check critical files
    if ! verify_path "$JESTEROS_COMMON_LIB" "file"; then
        echo "Warning: Common library not found: $JESTEROS_COMMON_LIB" >&2
        ((errors++))
    fi
    
    return $errors
}

# ============================================================================
# USAGE HELPERS
# ============================================================================

# Print all configured paths (for debugging)
print_paths() {
    echo "JesterOS Path Configuration:"
    echo "============================="
    echo "PROJECT_ROOT:        $JESTEROS_PROJECT_ROOT"
    echo "UTILITIES:          $JESTEROS_UTILITIES"
    echo ""
    echo "Utilities Directories:"
    echo "  LIB:              $JESTEROS_LIB"
    echo "  BUILD:            $JESTEROS_BUILD"
    echo "  DEPLOY:           $JESTEROS_DEPLOY"
    echo "  MAINTAIN:         $JESTEROS_MAINTAIN"
    echo "  SETUP:            $JESTEROS_SETUP"
    echo "  MIGRATE:          $JESTEROS_MIGRATE"
    echo "  TEST:             $JESTEROS_TEST"
    echo "  PLATFORM:         $JESTEROS_PLATFORM"
    echo "  CONFIG:           $JESTEROS_CONFIG"
    echo ""
    echo "Core Files:"
    echo "  COMMON_LIB:       $JESTEROS_COMMON_LIB"
    echo "  TEST_FRAMEWORK:   $JESTEROS_TEST_FRAMEWORK"
}

# ============================================================================
# AUTO-VALIDATION (optional - can be disabled for performance)
# ============================================================================

# Uncomment to enable validation on every source
# validate_paths

# Export validation functions for use in other scripts (bash only)
# Note: zsh doesn't support export -f, so these functions won't be exported in zsh
if [[ -n "${BASH_VERSION:-}" ]]; then
    export -f verify_path
    export -f get_absolute_path
    export -f ensure_directory
    export -f print_paths
fi