# JesterOS Test Suite Style Guide

## Overview
Consistent style guidelines for shell scripts in the JesterOS test suite.

## Shell Script Best Practices

### File Headers
Every test script should include:
```bash
#!/bin/bash
# Script name - Brief description
# Longer description if needed
#
# Usage: ./script.sh [args]
# Returns: 0 on success, 1 on failure
# Dependencies: List any dependencies (optional)
# Test Category: Show Stopper|Writing Blocker|Writer Experience
```

### Safety Settings
Always include at the top of scripts:
```bash
set -euo pipefail
```
- `-e`: Exit on error
- `-u`: Exit on undefined variable
- `-o pipefail`: Pipe failures cause script to exit

### Variable Naming

#### Constants (readonly variables)
```bash
readonly TEST_NAME="Safety Check"
readonly MAX_RETRIES=3
readonly CONFIG_FILE="/etc/config.conf"
```

#### Local Variables
Use lowercase with underscores:
```bash
local file_count=0
local current_dir="$(pwd)"
local temp_file="/tmp/test-$$"
```

#### Global Variables
Use uppercase for globals (sparingly):
```bash
BOOTABLE=true
TEST_PASSED=0
```

### Function Style

#### Function Declaration
```bash
# Brief description of function
# Arguments:
#   $1 - Description of first argument
#   $2 - Description of second argument (optional)
# Returns:
#   0 on success, 1 on failure
function_name() {
    local arg1="${1}"
    local arg2="${2:-default}"
    
    # Function body
    return 0
}
```

### Output Formatting

#### Use printf instead of echo
```bash
# Good
printf "Testing: %s\n" "${test_name}"
printf "✓ Check passed\n"

# Avoid
echo "Testing: $test_name"
```

#### Consistent Status Indicators
```bash
printf "✓ Check passed\n"      # Success
printf "✗ Check failed\n"      # Failure
printf "⚠ Warning\n"          # Warning
printf "ℹ Information\n"       # Info
printf "⏳ In progress\n"      # Progress
```

### Conditionals

#### Preferred Style
```bash
# Good - explicit and clear
if [ -f "${file}" ]; then
    process_file "${file}"
fi

# Good - multiple conditions
if [ -f "${file}" ] && \
   [ -r "${file}" ]; then
    read_file "${file}"
fi
```

#### Command Checks
```bash
# Check if command exists
if command -v docker >/dev/null 2>&1; then
    run_docker_test
fi
```

### Error Handling

#### Trap Errors
```bash
trap 'echo "Error at line $LINENO"' ERR
```

#### Check Critical Operations
```bash
if ! critical_operation; then
    printf "Error: Critical operation failed\n" >&2
    exit 1
fi
```

### Comments

#### Section Headers
```bash
# ============================================================================
# SECTION NAME - Description
# ============================================================================
```

#### Inline Comments
```bash
# Check 1: Verify kernel exists (prevents unbootable device)
local kernel_path="../kernel/uImage"  # Default kernel location
```

### Quoting

#### Always Quote Variables
```bash
# Good
if [ -f "${file}" ]; then
    rm "${file}"
fi

# Bad - can break with spaces
if [ -f $file ]; then
    rm $file
fi
```

#### Quote Command Substitutions
```bash
# Good
local count="$(find . -name "*.sh" | wc -l)"

# Bad
local count=$(find . -name *.sh | wc -l)
```

### File Operations

#### Safe Path Handling
```bash
# Use parameter expansion for paths
local dir_name="${file%/*}"
local base_name="${file##*/}"
local extension="${file##*.}"
```

#### Check Before Operations
```bash
# Always check before destructive operations
if [ -f "${file}" ]; then
    rm "${file}"
fi
```

### Process Substitution

#### Avoid Useless Use of Cat
```bash
# Good
while IFS= read -r line; do
    process_line "${line}"
done < "${file}"

# Bad
cat "${file}" | while read line; do
    process_line "${line}"
done
```

### Arrays (Bash 4+)

#### Declaration and Usage
```bash
# Declare array
declare -a test_files=("test1.sh" "test2.sh" "test3.sh")

# Iterate array
for file in "${test_files[@]}"; do
    run_test "${file}"
done

# Array length
local count="${#test_files[@]}"
```

### Exit Codes

#### Standard Exit Codes
```bash
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1
readonly EXIT_WARNING=2
readonly EXIT_SKIPPED=3
```

#### Explicit Exit
```bash
# Always use explicit exit codes
if [ "${test_passed}" = true ]; then
    exit "${EXIT_SUCCESS}"
else
    exit "${EXIT_FAILURE}"
fi
```

## Style Improvements Applied

### Changes Made to Test Scripts

1. **Consistent Headers**
   - Added test category classification
   - Included dependency documentation
   - Standardized usage format

2. **Variable Naming**
   - Changed UPPERCASE to lowercase for local variables
   - Made constants readonly where appropriate
   - Used descriptive names (boot_count vs BOOT_COUNT)

3. **Output Formatting**
   - Replaced echo with printf for consistency
   - Added proper escape sequences (\n)
   - Used format strings for variables

4. **Comment Style**
   - Added section headers with separators
   - Numbered checks for clarity
   - Improved inline documentation

5. **Quoting**
   - Properly quoted all variable expansions
   - Used ${var} format for clarity
   - Protected against word splitting

6. **Conditionals**
   - Added line continuations with backslash
   - Improved readability with consistent spacing
   - Used command -v for command checks

## Shellcheck Compliance

All scripts should pass shellcheck with minimal warnings:
```bash
shellcheck -x *.sh
```

Common shellcheck fixes:
- SC2086: Double quote to prevent globbing
- SC2181: Check exit code directly with if
- SC2004: $/${} is unnecessary on arithmetic variables
- SC2155: Declare and assign separately

## Testing Style Changes

After applying style changes, verify:
1. Scripts still execute correctly
2. Output formatting is preserved
3. Exit codes remain consistent
4. No functional changes introduced

## Benefits of Consistent Style

1. **Readability**: Easier to understand and maintain
2. **Reliability**: Fewer bugs from quoting issues
3. **Portability**: Works across different shells
4. **Professionalism**: Clean, consistent codebase
5. **Debugging**: Easier to trace errors

## Tools and Automation

### Formatting Tools
- `shfmt`: Auto-format shell scripts
- `shellcheck`: Lint and find issues
- `bashate`: Style checker for bash

### Pre-commit Hooks
Consider adding:
```bash
#!/bin/bash
# .git/hooks/pre-commit
for file in $(git diff --cached --name-only | grep "\.sh$"); do
    shellcheck "${file}" || exit 1
done
```

---
*"By quill and candlelight, we write clean code!"* 🕯️📜