# 🧪 Test Framework Quick Reference

*Essential reference for QuillKernel test development*

## Framework Architecture

```
tests/
├── test-framework.sh          # Core framework
├── run-all-tests.sh           # Master test runner
├── test-improvements.sh       # Safety validation
├── test-high-priority.sh      # Critical tests
├── test-medium-priority.sh    # Standard tests
└── unit/                      # Unit test suites
    ├── boot/                  # Boot sequence tests
    ├── memory/                # Memory constraint tests
    ├── modules/               # Kernel module tests
    ├── menu/                  # UI and menu tests
    ├── toolchain/             # Build environment tests
    └── theme/                 # Medieval theme tests
```

---

## Core Functions

### Test Lifecycle
```bash
init_test "Test Name"          # Initialize test with name
pass_test "Success message"    # Mark test as passed and exit
fail_test "Failure message"    # Mark test as failed and exit
skip_test "Skip reason"        # Skip test with reason and exit
```

### Basic Assertions
```bash
assert_equals "expected" "actual" "message"
assert_not_equals "unexpected" "actual" "message"
assert_contains "haystack" "needle" "message"
assert_not_contains "haystack" "needle" "message"
```

### File System Assertions
```bash
assert_file_exists "/path/to/file" "message"
assert_file_not_exists "/path/to/file" "message"
assert_directory_exists "/path/to/dir" "message"
assert_executable "/path/to/script" "message"
```

### Numeric Assertions
```bash
assert_greater_than "$value" "$threshold" "message"
assert_less_than "$value" "$threshold" "message"
```

### System Assertions
```bash
assert_command_exists "command_name" "message"
assert_docker_image_exists "image_name" "message"
```

---

## Standard Test Template

```bash
#!/bin/bash
# Unit Test: [Brief Description]
# [Detailed explanation of test purpose and scope]

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "[Test Display Name]"

# Constants (use readonly for immutable values)
readonly EXPECTED_FILE="$PROJECT_ROOT/path/to/file"
readonly -a REQUIRED_ITEMS=("item1" "item2" "item3")

# Test configuration
TEST_TIMEOUT=30
MEMORY_LIMIT_MB=256

# Setup function (optional)
setup_test() {
    # Prepare test environment
    mkdir -p /tmp/test_$$
    export TEST_DIR="/tmp/test_$$"
}

# Cleanup function (optional)  
cleanup() {
    # Clean up test artifacts
    rm -rf "$TEST_DIR" 2>/dev/null || true
}

# Register cleanup
trap cleanup EXIT

# Main test logic
setup_test

# Example validation
assert_file_exists "$EXPECTED_FILE" "Required file should exist"

# Success path
pass_test "All validations completed successfully"
```

---

## Enhanced Test Patterns

### Memory-Aware Testing
```bash
test_memory_constraint() {
    local max_memory_mb=96
    local process_name="$1"
    
    echo "  Testing memory usage for: $process_name"
    
    # Monitor memory usage
    local mem_usage
    mem_usage=$(docker run --rm -m "${max_memory_mb}m" "$process_name" \
        bash -c 'free -m | awk "/^Mem:/ {print \$3}"' 2>/dev/null || echo "0")
    
    assert_less_than "$mem_usage" "$max_memory_mb" \
        "Memory usage should be under ${max_memory_mb}MB"
    
    echo "  ✓ Memory usage: ${mem_usage}MB (limit: ${max_memory_mb}MB)"
}
```

### Multi-File Validation
```bash
test_file_collection() {
    local base_dir="$1"
    local -a required_files=("${@:2}")
    
    local found_count=0
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        local full_path="$base_dir/$file"
        if [[ -f "$full_path" ]]; then
            echo "  ✓ Found: $file"
            ((found_count++))
        else
            echo "  ✗ Missing: $file"
            missing_files+=("$file")
        fi
    done
    
    if [[ $found_count -eq ${#required_files[@]} ]]; then
        pass_test "All required files present ($found_count/${#required_files[@]})"
    elif [[ $found_count -gt 0 ]]; then
        pass_test "Essential files present ($found_count/${#required_files[@]}, missing: ${missing_files[*]})"
    else
        fail_test "Critical files missing (${#missing_files[@]} files not found)"
    fi
}
```

### Docker Environment Testing
```bash
test_docker_functionality() {
    local image="$1"
    local test_command="$2"
    local expected_pattern="$3"
    
    # Verify image exists
    assert_docker_image_exists "$image" "Docker image should be available"
    
    echo "  Running test command in container..."
    
    # Execute test in container with timeout
    local output
    output=$(timeout 60 docker run --rm "$image" bash -c "$test_command" 2>&1)
    local exit_code=$?
    
    # Validate exit code
    if [[ $exit_code -ne 0 ]]; then
        fail_test "Docker command failed (exit $exit_code): $output"
    fi
    
    # Validate output pattern (if provided)
    if [[ -n "$expected_pattern" ]]; then
        assert_contains "$output" "$expected_pattern" "Output should contain expected pattern"
    fi
    
    echo "  ✓ Docker test completed successfully"
}
```

### Security Validation Pattern
```bash
test_input_security() {
    local validation_func="$1"
    local test_description="$2"
    
    echo "  Testing security: $test_description"
    
    # Valid inputs should pass
    local -a valid_inputs=("valid_input_1" "valid_input_2")
    for input in "${valid_inputs[@]}"; do
        if $validation_func "$input" >/dev/null 2>&1; then
            echo "    ✓ Valid input accepted: $input"
        else
            fail_test "Valid input rejected: $input"
        fi
    done
    
    # Malicious inputs should be rejected
    local -a malicious_inputs=(
        "../../../etc/passwd"
        "; rm -rf /"
        "\$(whoami)"
        "'; DROP TABLE users; --"
        "\`cat /etc/shadow\`"
    )
    
    for input in "${malicious_inputs[@]}"; do
        if ! $validation_func "$input" >/dev/null 2>&1; then
            echo "    ✓ Malicious input rejected: $input"
        else
            fail_test "SECURITY VIOLATION: Malicious input accepted: $input"
        fi
    done
    
    echo "  ✓ Security validation passed"
}
```

### Performance Measurement
```bash
test_performance_benchmark() {
    local operation="$1"
    local max_time_seconds="$2"
    local description="$3"
    
    echo "  Benchmarking: $description"
    
    local start_time
    start_time=$(date +%s.%N)
    
    # Execute operation
    eval "$operation" >/dev/null 2>&1
    local exit_code=$?
    
    local end_time
    end_time=$(date +%s.%N)
    
    local duration
    duration=$(echo "$end_time - $start_time" | bc)
    
    echo "  ⏱️ Duration: ${duration}s (limit: ${max_time_seconds}s)"
    
    # Check operation success
    if [[ $exit_code -ne 0 ]]; then
        fail_test "Operation failed with exit code $exit_code"
    fi
    
    # Check performance constraint
    if (( $(echo "$duration <= $max_time_seconds" | bc -l) )); then
        echo "  ✓ Performance within acceptable limits"
    else
        fail_test "Performance exceeded limit: ${duration}s > ${max_time_seconds}s"
    fi
}
```

---

## Color and Output Standards

### Color Codes
```bash
RED='\033[0;31m'      # Failures, errors
GREEN='\033[0;32m'    # Success, pass
YELLOW='\033[1;33m'   # Warnings, skip
BLUE='\033[0;34m'     # Information, test names
PURPLE='\033[0;35m'   # Special highlights
NC='\033[0m'          # Reset/no color
```

### Output Symbols
```bash
✓  # Success indicator
✗  # Failure indicator  
⚠  # Warning indicator
⏱️  # Performance/timing
🔍 # Investigation/analysis
📊 # Metrics/statistics
🎯 # Target/goal
🛡️ # Security related
```

### Message Format Standards
```bash
echo "  ✓ Component validated: $component_name"
echo "  ✗ Component failed: $component_name ($error_reason)"
echo "  ⚠ Component warning: $component_name ($warning_reason)"
```

---

## Environment Variables

### Framework Variables
```bash
TEST_ROOT          # Test directory root
PROJECT_ROOT       # Project directory root
TEST_NAME          # Current test name
TEST_PASSED        # Test pass flag
TEST_FAILED        # Test fail flag
```

### Configuration Variables
```bash
TEST_DEBUG=1       # Enable debug output
TEST_VERBOSE=1     # Enable verbose output
TEST_TIMEOUT=60    # Default test timeout
CI=true           # CI environment flag
```

### Project-Specific Variables
```bash
DOCKER_IMAGE="quillkernel-unified"    # Default Docker image
MEMORY_LIMIT_MB=256                   # Hardware memory limit
MEMORY_THRESHOLD_MB=96                # OS memory threshold
```

---

## Test Result Codes

```bash
0   # Test passed successfully
1   # Test failed with errors
2   # Test skipped (dependency not met)
3   # Test timeout
4   # Test setup failure
130 # Test interrupted (SIGINT)
```

---

## Common Test Scenarios

### Boot Script Validation
```bash
test_boot_scripts() {
    local boot_dir="$PROJECT_ROOT/source/scripts/boot"
    local -a required_scripts=("boot-jester.sh" "squireos-boot.sh")
    
    assert_directory_exists "$boot_dir" "Boot scripts directory"
    
    for script in "${required_scripts[@]}"; do
        local script_path="$boot_dir/$script"
        assert_file_exists "$script_path" "Boot script: $script"
        assert_executable "$script_path" "Boot script should be executable: $script"
        
        # Validate script safety
        if grep -q "set -euo pipefail" "$script_path"; then
            echo "  ✓ Safety headers present: $script"
        else
            fail_test "Missing safety headers in: $script"
        fi
    done
}
```

### Module Compilation Check
```bash
test_module_compilation() {
    local module_dir="$PROJECT_ROOT/source/kernel/src/drivers/squireos"
    local -a required_modules=("squireos_core.c" "jester.c" "typewriter.c" "wisdom.c")
    
    for module in "${required_modules[@]}"; do
        local module_path="$module_dir/$module"
        
        if [[ -f "$module_path" ]]; then
            # Check for valid kernel module structure
            if grep -q "module_init\|MODULE_LICENSE" "$module_path"; then
                echo "  ✓ Valid kernel module: $module"
            else
                fail_test "Invalid kernel module structure: $module"
            fi
        else
            echo "  ⚠ Module source not found: $module"
        fi
    done
}
```

### Security Validation
```bash
test_script_security() {
    local script="$1"
    
    echo "  Validating security for: $(basename "$script")"
    
    # Check for dangerous patterns
    local -a dangerous_patterns=(
        "rm -rf /"
        "sudo.*rm"
        "chmod.*777"
        "eval.*\$"
        "exec.*\$"
    )
    
    for pattern in "${dangerous_patterns[@]}"; do
        if grep -q "$pattern" "$script"; then
            fail_test "Dangerous pattern found in $script: $pattern"
        fi
    done
    
    # Check for input validation
    if grep -q "validate_\|check_\|\[\[.*-n.*\]\]" "$script"; then
        echo "  ✓ Input validation present"
    else
        echo "  ⚠ Limited input validation detected"
    fi
}
```

---

## Debugging and Troubleshooting

### Debug Mode
```bash
# Enable maximum debugging
export TEST_DEBUG=1
export TEST_VERBOSE=1
set -x

# Run test with trace
bash -x ./tests/unit/memory/test-docker-memory-limit.sh
```

### Common Issues and Solutions

| Issue | Symptom | Solution |
|-------|---------|----------|
| Docker not available | "docker: command not found" | Install Docker, add user to docker group |
| Permission denied | "Permission denied" on test files | `chmod +x tests/**/*.sh` |
| Image not found | "docker: Error response from daemon" | Build required Docker images first |
| Memory test fails | Memory usage exceeds limits | Check for memory leaks, optimize containers |
| Module test fails | "Module not found" | Run `./build_kernel.sh` to compile modules |
| Path validation fails | Security tests reject valid paths | Update path validation rules |

### Test Output Analysis
```bash
# Capture full test output
./tests/run-all-tests.sh 2>&1 | tee test_output.log

# Analyze failures
grep -E "(FAIL|✗)" test_output.log

# Check performance
grep -E "(⏱️|Duration)" test_output.log

# Review security issues  
grep -E "(SECURITY|🛡️)" test_output.log
```

---

## Integration with Build System

### Makefile Integration
```makefile
# Test targets
test: test-unit test-integration
test-unit:
	@./tests/run-all-tests.sh
test-integration:
	@./tests/test-high-priority.sh
test-safety:
	@./tests/test-improvements.sh
test-memory:
	@./tests/unit/memory/test-docker-memory-limit.sh
```

### CI/CD Integration
```yaml
# Example GitHub Actions integration
steps:
  - name: Run unit tests
    run: ./tests/run-all-tests.sh
  - name: Run safety tests
    run: ./tests/test-improvements.sh
  - name: Upload test results
    uses: actions/upload-artifact@v2
    with:
      name: test-results
      path: /tmp/test_results/
```

---

*Test Framework Reference v1.0*  
*Quick reference for QuillKernel test development* 🕯️📜