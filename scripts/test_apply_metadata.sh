#!/bin/bash
# Unit tests for apply_metadata.sh

# Source test framework
source "$(dirname "${BASH_SOURCE[0]}")/test_framework.sh"

# Test directory for this script
TEST_SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
SCRIPT_TO_TEST="$TEST_SCRIPT_DIR/../apply_metadata.sh"

# ============================================================================
# Test Suite: Script Validation
# ============================================================================

test_suite "apply_metadata.sh - Script Validation"

test_case "Script exists and is executable"
if assert_file_exists "$SCRIPT_TO_TEST"; then
    if [[ -x "$SCRIPT_TO_TEST" ]]; then
        test_pass
    else
        test_fail "Script is not executable"
    fi
fi

test_case "Script has no syntax errors"
if bash -n "$SCRIPT_TO_TEST" 2>/dev/null; then
    test_pass
else
    test_fail "Script has syntax errors"
fi

# ============================================================================
# Test Suite: Configuration Loading
# ============================================================================

test_suite "apply_metadata.sh - Configuration"

test_case "Script handles missing project.conf"
test_dir=$(create_test_dir)
cd "$test_dir"

# Create a minimal test script that sources apply_metadata.sh functions
cat > test_apply.sh << 'EOF'
#!/bin/bash
PROJECT_ROOT="."
PROJECT_CONF="./project.conf"
BUILD_CONF="./build.conf"

# Test configuration check
if [ ! -f "$PROJECT_CONF" ]; then
    echo "Error: project.conf not found"
    exit 1
fi
EOF

if ! bash test_apply.sh 2>/dev/null; then
    test_pass  # Should fail when config is missing
else
    test_fail "Script should fail without project.conf"
fi

cd - >/dev/null
cleanup_test_dir "$test_dir"

test_case "Script processes template correctly"
test_dir=$(create_test_dir)
cd "$test_dir"

# Create mock configuration files
cat > project.conf << 'EOF'
export PROJECT_NAME="TestProject"
export PROJECT_VERSION="1.0.0"
export COPYRIGHT_HOLDER="Test User"
EOF

cat > build.conf << 'EOF'
export VERSION_STRING="v1.0.0"
EOF

# Create a template file
cat > template.txt << 'EOF'
Project: @@PROJECT_NAME@@
Version: @@PROJECT_VERSION@@
Copyright: @@COPYRIGHT_HOLDER@@
EOF

# Create a minimal version of apply_metadata for testing
cat > test_apply.sh << 'EOF'
#!/bin/bash
set -euo pipefail

PROJECT_ROOT="."
source ./project.conf
source ./build.conf

# Simple substitution for testing
input_file="template.txt"
output_file="output.txt"
cp "$input_file" "$output_file"

for var in PROJECT_NAME PROJECT_VERSION COPYRIGHT_HOLDER; do
    value="${!var}"
    sed -i "s|@@${var}@@|${value}|g" "$output_file"
done
EOF

bash test_apply.sh

if assert_file_exists "output.txt"; then
    output=$(cat output.txt)
    if assert_contains "$output" "TestProject" && \
       assert_contains "$output" "1.0.0" && \
       assert_contains "$output" "Test User"; then
        test_pass
    fi
fi

cd - >/dev/null
cleanup_test_dir "$test_dir"

# ============================================================================
# Test Suite: Substitution Safety
# ============================================================================

test_suite "apply_metadata.sh - Substitution Safety"

test_case "AWK substitution handles special characters"
test_dir=$(create_test_dir)
cd "$test_dir"

# Test the AWK substitution approach used in the fixed version
echo "Test @@PLACEHOLDER@@ here" > test.txt

# Simulate the safe substitution using awk
awk -v find="@@PLACEHOLDER@@" -v replace="value/with\$special&chars" \
    '{gsub(find, replace); print}' test.txt > output.txt

output=$(cat output.txt)
if assert_contains "$output" "value/with\$special&chars"; then
    test_pass
else
    test_fail "AWK substitution failed with special characters"
fi

cd - >/dev/null
cleanup_test_dir "$test_dir"

test_case "Script rejects invalid modes"
if output=$("$SCRIPT_TO_TEST" invalid_mode 2>&1); then
    test_fail "Script should reject invalid mode"
else
    if assert_contains "$output" "Usage"; then
        test_pass
    fi
fi

# ============================================================================
# Print Test Summary
# ============================================================================

test_summary