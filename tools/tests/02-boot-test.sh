#!/bin/bash
# Boot test - Check if basic boot components exist
# If these pass, the device should at least boot
#
# Usage: ./02-boot-test.sh
# Returns: 0 if bootable, 1 if missing critical components
# Dependencies: None (standalone test)
# Test Category: Show Stopper (MUST PASS)

set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

# ============================================================================
# BOOT TEST - Will it boot?
# ============================================================================

# Determine script location and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
RUNTIME_DIR="${PROJECT_ROOT}/runtime"
BOOT_DIR="${PROJECT_ROOT}/boot"

# Validate we're in the correct location
if [ ! -d "${RUNTIME_DIR}" ]; then
    echo "Error: Cannot find runtime directory at ${RUNTIME_DIR}"
    echo "Please run this script from the tests/ directory"
    exit 1
fi

printf '\n🥾 BOOT TEST - Will it boot?\n'
printf '============================\n\n'

# Test state tracking
readonly TEST_NAME="Boot Test"
BOOTABLE=true  # Flag for boot readiness
ISSUES=()      # Array to track issues
WARNINGS=()    # Array to track warnings

# Check 1: Boot scripts (required for system initialization)
printf "✓ Boot scripts exist... "
if [ -d "${RUNTIME_DIR}/init" ]; then
    boot_count=$(find "${RUNTIME_DIR}/init" -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
    boot_count=${boot_count:-0}
    
    # Check if scripts are executable
    if [ "${boot_count}" -gt 0 ]; then
        non_exec_count=$(find "${RUNTIME_DIR}/init" -name "*.sh" ! -perm -111 2>/dev/null | wc -l | tr -d ' ')
        if [ "${non_exec_count}" -gt 0 ]; then
            printf "YES (%d scripts, %d not executable)\n" "${boot_count}" "${non_exec_count}"
            WARNINGS+=("${non_exec_count} boot scripts are not executable")
        else
            printf "YES (%d scripts, all executable)\n" "${boot_count}"
        fi
    else
        printf "NO - No boot scripts!\n"
        BOOTABLE=false
        ISSUES+=("No boot scripts found in ${RUNTIME_DIR}/init")
    fi
else
    boot_count=0
    printf "NO - Directory missing!\n"
    BOOTABLE=false
    ISSUES+=("Boot directory ${RUNTIME_DIR}/init does not exist")
fi

# Check 2: JesterOS service (provides writer environment)
printf "✓ JesterOS service... "
jesteros_found=false
jesteros_locations=()

if [ -f "${RUNTIME_DIR}/init/jesteros-boot.sh" ]; then
    jesteros_found=true
    jesteros_locations+=("init/jesteros-boot.sh")
fi

if [ -f "${RUNTIME_DIR}/services/jester/daemon.sh" ]; then
    jesteros_found=true
    jesteros_locations+=("services/jester/daemon.sh")
fi

if [ "${jesteros_found}" = true ]; then
    printf "YES (found: %s)\n" "${jesteros_locations[*]}"
else
    printf "MISSING (but not critical)\n"
    WARNINGS+=("JesterOS service not found - writing features unavailable")
fi

# Check 3: Menu system (user interface)
printf "✓ Menu system... "
if [ -f "${RUNTIME_DIR}/services/menu/nook-menu.sh" ]; then
    # Validate menu script syntax
    if bash -n "${RUNTIME_DIR}/services/menu/nook-menu.sh" 2>/dev/null; then
        printf "YES (syntax valid)\n"
    else
        printf "YES (syntax error!)\n"
        WARNINGS+=("Menu script has syntax errors")
    fi
else
    printf "MISSING (will boot but no menu)\n"
    WARNINGS+=("Menu system not found - no user interface")
fi

# Check 4: Common library (shared functions)
printf "✓ Common functions... "
if [ -f "${RUNTIME_DIR}/services/system/common.sh" ]; then
    # Check if it's readable
    if [ -r "${RUNTIME_DIR}/services/system/common.sh" ]; then
        printf "YES (readable)\n"
    else
        printf "YES (not readable!)\n"
        WARNINGS+=("Common library exists but is not readable")
    fi
else
    printf "MISSING (scripts may fail)\n"
    WARNINGS+=("Common functions library missing - scripts may fail")
fi

# Check 5: Boot configuration (U-Boot settings)
printf "✓ Boot config... "
if [ -f "${BOOT_DIR}/uEnv.txt" ]; then
    # Check if it contains basic boot parameters
    if grep -q "bootargs\|kernel" "${BOOT_DIR}/uEnv.txt" 2>/dev/null; then
        printf "YES (configured)\n"
    else
        printf "YES (empty/unconfigured)\n"
        WARNINGS+=("Boot config exists but appears unconfigured")
    fi
else
    printf "MISSING (using defaults)\n"
    # This is often OK as defaults work
fi

# Additional Check 6: Critical binaries
printf "✓ Critical binaries... "
critical_bins=("sh" "mount" "init")
missing_bins=()

for bin in "${critical_bins[@]}"; do
    if ! command -v "$bin" >/dev/null 2>&1; then
        missing_bins+=("$bin")
    fi
done

if [ ${#missing_bins[@]} -eq 0 ]; then
    printf "YES (all present)\n"
else
    printf "MISSING (%s)\n" "${missing_bins[*]}"
    ISSUES+=("Critical binaries missing: ${missing_bins[*]}")
    BOOTABLE=false
fi

# Test result summary
printf '\n'
printf '═══════════════════════════════════════════\n'
printf 'BOOT TEST SUMMARY\n'
printf '═══════════════════════════════════════════\n'

# Report issues if any
if [ ${#ISSUES[@]} -gt 0 ]; then
    printf '\n❌ CRITICAL ISSUES:\n'
    for issue in "${ISSUES[@]}"; do
        printf '   - %s\n' "$issue"
    done
fi

# Report warnings if any
if [ ${#WARNINGS[@]} -gt 0 ]; then
    printf '\n⚠️  WARNINGS:\n'
    for warning in "${WARNINGS[@]}"; do
        printf '   - %s\n' "$warning"
    done
fi

# Final verdict
printf '\n'
if [ "${BOOTABLE}" = true ]; then
    if [ ${#WARNINGS[@]} -eq 0 ]; then
        printf '✅ SHOULD BOOT SUCCESSFULLY\n'
        printf 'All critical components present and valid\n'
    else
        printf '✅ SHOULD BOOT (with limitations)\n'
        printf 'Device will boot but some features may be unavailable\n'
    fi
    exit 0
else
    printf '❌ WILL NOT BOOT\n'
    printf 'Critical components missing - fix issues before deploying\n'
    exit 1
fi