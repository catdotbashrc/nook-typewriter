# 📋 Script Maintainability Improvement Preview

## Executive Summary
Analysis of 24 shell scripts (3,844 lines) in `source/scripts/` identified key maintainability improvements that will enhance reliability, debugging, and long-term maintenance while preserving the writer-focused philosophy.

**Risk Level**: LOW - All changes are defensive improvements  
**Impact**: HIGH - Improved reliability and easier debugging  
**Effort**: MEDIUM - Systematic but straightforward changes

---

## 🔍 Current State Analysis

### Positive Findings ✅
- 15/24 scripts (62.5%) have basic safety headers (`set -e`)
- Common library exists (`lib/common.sh`) with error handling
- Consistent medieval theme in error messages
- Service management framework in place

### Issues Identified ⚠️
1. **Incomplete Safety Headers**: 9 scripts lack `set -euo pipefail`
2. **Inconsistent Error Handling**: Not all scripts use the common error handler
3. **Mixed Shell Types**: Both `/bin/bash` and `/bin/sh` used inconsistently
4. **Unquoted Variables**: 47+ instances of potentially unquoted variables
5. **Missing Function Documentation**: Limited inline documentation
6. **No Logging Standards**: Inconsistent logging approaches

---

## 🎯 Proposed Improvements

### 1. Standardize Safety Headers (Priority: HIGH)

**Current State**: Inconsistent safety headers across scripts

**Proposed Change**: Add standardized header to all scripts
```bash
#!/bin/bash
# [Script description]
# Part of JesterOS - Transform Nook into distraction-free writer

set -euo pipefail
IFS=$'\n\t'
trap 'error_handler $LINENO $?' ERR

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"
```

**Files Needing Updates** (9 scripts):
- `boot/jester-splash.sh`
- `boot/jester-dance.sh` 
- `boot/squireos-init.sh`
- `boot/jesteros-boot-splash.sh`
- `boot/boot-jester.sh`
- `boot/jester-splash-eink.sh`
- `menu/nook-menu.sh`
- `services/jester-daemon.sh`
- `services/jesteros-tracker.sh`

---

### 2. Create Enhanced Common Library

**Proposed**: Enhance `lib/common.sh` with additional functions

```bash
# === Logging Functions ===
log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2 | tee -a "$LOG_FILE"
}

log_debug() {
    [[ "${DEBUG:-0}" == "1" ]] && echo "[DEBUG] $*" >&2
}

# === Validation Functions ===
validate_writable_dir() {
    local dir="$1"
    [[ -d "$dir" && -w "$dir" ]] || {
        log_error "Directory not writable: $dir"
        return 1
    }
}

validate_executable() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1 || {
        log_error "Command not found: $cmd"
        return 1
    }
}

# === Resource Protection ===
check_memory_usage() {
    local max_mb="${1:-96}"
    local current_mb=$(free -m | awk 'NR==2{print $3}')
    if [[ $current_mb -gt $max_mb ]]; then
        log_error "Memory usage ($current_mb MB) exceeds limit ($max_mb MB)"
        return 1
    fi
}

# === E-Ink Safe Operations ===
safe_display_update() {
    local message="$1"
    if command -v fbink >/dev/null 2>&1; then
        fbink -c  # Clear screen
        echo "$message" | fbink -
    else
        echo "$message"
    fi
}
```

---

### 3. Variable Quoting Campaign

**Issue**: 47+ potentially unquoted variables found

**Proposed Fix Pattern**:
```bash
# BEFORE (unsafe)
echo $USER_INPUT
cd $NOTES_DIR
if [ $result = "success" ]; then

# AFTER (safe)
echo "$USER_INPUT"
cd "$NOTES_DIR"
if [ "$result" = "success" ]; then
```

**High-Risk Files to Fix First**:
- `services/health-check.sh` (17 instances)
- `services/jesteros-service-manager.sh` (4 instances)
- `boot/load-squireos-modules.sh` (3 instances)

---

### 4. Function Documentation Standard

**Proposed Format**:
```bash
# Purpose: Brief description of what function does
# Args:   $1 - parameter description
#         $2 - parameter description  
# Returns: 0 on success, 1 on error
# Example: function_name "arg1" "arg2"
function_name() {
    local param1="${1:?Error: missing parameter 1}"
    local param2="${2:-default_value}"
    # Implementation
}
```

---

### 5. Service Script Template

**Create**: `lib/service-template.sh`
```bash
#!/bin/bash
# Service: [NAME]
# Purpose: [DESCRIPTION]
# Interface: /var/jesteros/[SERVICE]/

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"
source "${SCRIPT_DIR}/../lib/service-functions.sh"

# Service configuration
readonly SERVICE_NAME="[NAME]"
readonly PID_FILE="/var/run/jesteros/${SERVICE_NAME}.pid"
readonly INTERFACE_DIR="/var/jesteros/${SERVICE_NAME}"
readonly UPDATE_INTERVAL=30

# Service implementation
run_service() {
    log_info "Starting ${SERVICE_NAME}"
    
    while true; do
        # Check memory budget
        check_memory_usage 96 || {
            log_error "Memory limit exceeded"
            exit 1
        }
        
        # Service logic here
        update_service_interface
        
        sleep "$UPDATE_INTERVAL"
    done
}

# Entry point
main() {
    validate_environment
    create_interface_dirs
    run_service
}

main "$@"
```

---

## 📊 Implementation Plan

### Phase 1: Foundation (Week 1)
1. ✅ Enhance `lib/common.sh` with new functions
2. ✅ Create service template
3. ✅ Document standards in `SCRIPT_STANDARDS.md`

### Phase 2: Critical Scripts (Week 2)
1. ✅ Update boot scripts with safety headers
2. ✅ Fix variable quoting in service scripts
3. ✅ Add error handling to menu scripts

### Phase 3: Complete Coverage (Week 3)
1. ✅ Apply template to all service scripts
2. ✅ Add function documentation
3. ✅ Create test suite for scripts

---

## 🧪 Testing Strategy

### Pre-Implementation Tests
```bash
# Backup current scripts
tar -czf scripts-backup-$(date +%Y%m%d).tar.gz source/scripts/

# Test shellcheck on all scripts
find source/scripts -name "*.sh" -exec shellcheck {} \;

# Memory usage baseline
./tests/memory-baseline.sh
```

### Post-Implementation Tests
```bash
# Verify scripts still work
./tests/test-script-functionality.sh

# Check memory usage hasn't increased
./tests/memory-comparison.sh

# Validate error handling
./tests/test-error-scenarios.sh
```

---

## ⚠️ Risk Mitigation

### Safeguards
1. **No Functional Changes**: Only adding safety, not changing logic
2. **Preserve Theme**: Keep medieval error messages
3. **Memory First**: All changes validated against 96MB limit
4. **Incremental**: Apply changes script by script
5. **Rollback Ready**: Full backup before changes

### What We're NOT Changing
- ❌ Core functionality or behavior
- ❌ Memory allocation patterns
- ❌ E-Ink refresh strategies
- ❌ Medieval theme elements
- ❌ Writing space allocation

---

## 📈 Expected Benefits

### Immediate
- 🛡️ **Reduced Crashes**: Proper error handling prevents cascading failures
- 🔍 **Better Debugging**: Clear error messages with line numbers
- 📊 **Consistent Logging**: Easier to track issues

### Long-term
- 👥 **Easier Contribution**: Clear patterns for new developers
- 🔧 **Faster Fixes**: Standardized structure speeds debugging
- 📚 **Better Documentation**: Self-documenting code patterns
- ✅ **Automated Testing**: Scripts become testable with shellcheck

---

## 🎯 Success Metrics

| Metric | Current | Target |
|--------|---------|--------|
| Scripts with safety headers | 62.5% | 100% |
| Variable quoting compliance | ~60% | 95%+ |
| Function documentation | ~20% | 80%+ |
| ShellCheck passing | Unknown | 100% |
| Memory usage | <96MB | <96MB (unchanged) |

---

## 💡 Next Steps

### To Apply These Changes:
1. Review this preview document
2. Run `make test` to establish baseline
3. Apply changes incrementally with:
   ```bash
   /improve @source/scripts/lib/common.sh --safe
   /improve @source/scripts/boot/ --safe  
   /improve @source/scripts/services/ --safe
   ```
4. Test after each phase
5. Document changes in git commits

### To Generate Detailed Script:
```bash
# Generate automated improvement script
cat > improve-scripts.sh << 'EOF'
#!/bin/bash
# Apply maintainability improvements to scripts
set -euo pipefail

# Your approval required at each step
echo "This will improve script maintainability. Continue? (y/n)"
read -r response
[[ "$response" == "y" ]] || exit 0

# Implementation steps here...
EOF
```

---

*Generated with safety-first approach - No files modified*  
*Review carefully before applying any changes*  
*"By quill and compiler, we maintain quality!"* 🪶