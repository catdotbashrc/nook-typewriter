# 🧪 Developer Testing Guide

*Practical testing workflows for QuillKernel development*

## Quick Start Testing

### Essential Pre-Development Tests
```bash
# Verify your environment
./tests/run-all-tests.sh --quick

# Test specific categories
./tests/test-high-priority.sh    # Critical functionality
./tests/test-improvements.sh     # Safety validations  
./tests/unit/memory/*.sh          # Memory constraints
```

### Development Workflow Testing
```bash
# Before committing code
make test-safety                  # Shell script safety
make test-memory                  # Memory usage validation
make test-modules                 # Kernel module checks

# Before deploying
make test-integration            # Full system integration
make test-security              # Security validation
```

---

## Test Categories Overview

### 🎯 Priority Testing Matrix

| Priority | Test Category | When to Run | Runtime |
|----------|---------------|-------------|---------|
| **Critical** | Memory Limits | Every build | 30s |
| **Critical** | Script Safety | Every commit | 45s |
| **High** | Boot Sequence | Before deploy | 2m |
| **High** | Module Loading | Kernel changes | 1m |
| **Medium** | Menu System | UI changes | 30s |
| **Medium** | ASCII Art | Theme changes | 15s |
| **Low** | Documentation | Doc updates | 20s |

### 🚀 Fast Development Tests
For rapid iteration during development:

```bash
# Quick safety check (< 30 seconds)
./tests/unit/memory/test-docker-memory-limit.sh
./tests/unit/boot/test-boot-scripts-exist.sh

# Module development check (< 1 minute)  
./tests/unit/modules/test-module-sources.sh
./tests/unit/toolchain/test-cross-compiler.sh

# UI/Menu changes (< 45 seconds)
./tests/unit/menu/test-menu-input-validation.sh
./tests/unit/theme/test-jester-ascii-art.sh
```

---

## Test Framework Deep Dive

### Available Assertion Functions

#### Basic Assertions
```bash
assert_equals "expected" "actual" "message"
assert_not_equals "unexpected" "actual" "message"
assert_contains "haystack" "needle" "message"
assert_not_contains "haystack" "needle" "message"
```

#### File System Assertions
```bash
assert_file_exists "/path/to/file" "message"
assert_file_not_exists "/path/to/file" "message"
assert_directory_exists "/path/to/dir" "message"
assert_executable "/path/to/script" "message"
```

#### Numeric Assertions
```bash
assert_greater_than "$value" "$threshold" "message"
assert_less_than "$value" "$threshold" "message"
```

#### Docker Assertions
```bash
assert_docker_image_exists "image_name" "message"
```

#### System Assertions
```bash
assert_command_exists "command_name" "message"
```

### Writing New Unit Tests

#### Test Template
```bash
#!/bin/bash
# Unit Test: [Test Description]
# [Brief explanation of what this test validates]

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "[Test Name]"

# Constants and configuration
readonly TEST_FILE="$PROJECT_ROOT/path/to/test/file"
readonly -a EXPECTED_VALUES=("value1" "value2" "value3")

# Test setup (if needed)
setup_test() {
    # Any setup required before testing
    true
}

# Test teardown (if needed)
cleanup() {
    # Cleanup after test
    rm -f /tmp/test_*
}

# Register cleanup
trap cleanup EXIT

# Main test logic
setup_test

# Example: Test file existence
assert_file_exists "$TEST_FILE" "Required test file should exist"

# Example: Test content validation
content=$(cat "$TEST_FILE" 2>/dev/null || echo "")
assert_contains "$content" "expected_pattern" "File should contain expected content"

# Example: Test numeric values
count=$(echo "$content" | wc -l)
assert_greater_than "$count" 0 "File should not be empty"

# Success
pass_test "All validations passed"
```

#### Test Categories and Naming

```bash
# File naming convention
tests/unit/[category]/test-[specific-feature].sh

# Categories:
boot/       # Boot sequence and initialization
build/      # Build system and compilation  
docs/       # Documentation validation
eink/       # E-Ink display functionality
memory/     # Memory usage and constraints
menu/       # Menu system and user interface
modules/    # Kernel modules and SquireOS
theme/      # Medieval theme and ASCII art
toolchain/  # Cross-compilation toolchain
```

---

## Common Testing Patterns

### Memory Constraint Testing
```bash
# Pattern for memory-sensitive tests
test_memory_usage() {
    local max_memory_mb=96
    
    # Start process/container
    local pid=$(start_test_process)
    
    # Monitor memory usage
    local mem_usage=$(get_memory_usage "$pid")
    
    # Validate constraint
    assert_less_than "$mem_usage" "$max_memory_mb" \
        "Memory usage should be under ${max_memory_mb}MB"
        
    # Cleanup
    kill "$pid" 2>/dev/null || true
}
```

### Docker Environment Testing
```bash
# Pattern for Docker-based tests
test_in_docker() {
    local image="$1"
    local test_command="$2"
    
    # Check image exists
    assert_docker_image_exists "$image" "Docker image should be available"
    
    # Run test in container
    local result
    result=$(docker run --rm "$image" bash -c "$test_command" 2>&1)
    local exit_code=$?
    
    # Validate result
    if [ $exit_code -eq 0 ]; then
        echo "  ✓ Docker test passed: $result"
    else
        fail_test "Docker test failed: $result"
    fi
}
```

### Input Validation Testing
```bash
# Pattern for security validation
test_input_validation() {
    local validation_function="$1"
    
    # Test valid inputs
    local -a valid_inputs=("valid1" "valid2" "valid3")
    for input in "${valid_inputs[@]}"; do
        if $validation_function "$input"; then
            echo "  ✓ Valid input accepted: $input"
        else
            fail_test "Valid input rejected: $input"
        fi
    done
    
    # Test invalid inputs
    local -a invalid_inputs=("../../../etc/passwd" "; rm -rf /" "\$(whoami)")
    for input in "${invalid_inputs[@]}"; do
        if ! $validation_function "$input" 2>/dev/null; then
            echo "  ✓ Invalid input rejected: $input"
        else
            fail_test "SECURITY RISK: Invalid input accepted: $input"
        fi
    done
}
```

---

## Integration Testing Workflows

### Pre-Commit Testing
```bash
#!/bin/bash
# pre-commit-tests.sh - Run before every commit

echo "🔍 Running pre-commit tests..."

# Critical safety tests
./tests/test-improvements.sh || exit 1

# Memory constraint validation
./tests/unit/memory/test-docker-memory-limit.sh || exit 1

# Security validation
./tests/unit/menu/test-menu-input-validation.sh || exit 1

echo "✅ Pre-commit tests passed!"
```

### Pre-Deploy Testing
```bash
#!/bin/bash
# pre-deploy-tests.sh - Run before deployment

echo "🚀 Running pre-deployment tests..."

# Full test suite
./tests/run-all-tests.sh || exit 1

# Build validation
./build_kernel.sh || exit 1

# Memory and performance validation
./tests/test-high-priority.sh || exit 1

# Integration testing
docker build -t nook-test -f minimal-boot.dockerfile . || exit 1
docker run --rm nook-test echo "Boot test successful" || exit 1

echo "✅ Pre-deployment tests passed!"
```

### Continuous Integration
```bash
#!/bin/bash
# ci-pipeline.sh - Full CI testing pipeline

set -euo pipefail

echo "🏭 Starting CI testing pipeline..."

# Environment setup
export CI=true
export TEST_RESULTS_DIR="/tmp/ci_results"
mkdir -p "$TEST_RESULTS_DIR"

# Test categories in dependency order
test_categories=(
    "Script Safety:tests/test-improvements.sh"
    "Build System:./build_kernel.sh"  
    "Unit Tests:./tests/run-all-tests.sh"
    "Memory Tests:./tests/test-high-priority.sh"
    "Integration:./tests/test-ui-components.sh"
)

failed_tests=0

for category in "${test_categories[@]}"; do
    name="${category%%:*}"
    script="${category##*:}"
    
    echo ""
    echo "📋 Testing: $name"
    echo "Command: $script"
    
    if timeout 300 bash -c "$script" 2>&1 | tee "$TEST_RESULTS_DIR/${name// /_}.log"; then
        echo "✅ $name: PASSED"
    else
        echo "❌ $name: FAILED"
        ((failed_tests++))
    fi
done

# Summary
echo ""
echo "📊 CI Pipeline Results:"
if [ $failed_tests -eq 0 ]; then
    echo "🎉 All tests passed! Ready for deployment."
    exit 0
else
    echo "💥 $failed_tests categories failed. Review logs in $TEST_RESULTS_DIR"
    exit 1
fi
```

---

## Debugging Test Failures

### Test Output Analysis
```bash
# Enable detailed test debugging
export TEST_DEBUG=1
export TEST_VERBOSE=1

# Run single test with full output
bash -x ./tests/unit/memory/test-docker-memory-limit.sh

# Capture test output for analysis
./tests/unit/modules/test-module-sources.sh 2>&1 | tee test_debug.log
```

### Common Failure Patterns

#### Memory Test Failures
```bash
# Problem: Docker memory limits not enforced
# Solution: Test detects this and skips appropriately
# Status: Expected behavior in development environments

# Problem: Memory usage exceeds 96MB
# Solution: Review Docker image size, remove unnecessary packages
# Command: docker images --format "table {{.Repository}}\t{{.Size}}"
```

#### Module Test Failures
```bash
# Problem: Kernel modules not found
# Solution: Run kernel build first
# Command: ./build_kernel.sh

# Problem: Cross-compiler not available
# Solution: Verify Docker image is built
# Command: docker images | grep quillkernel-unified
```

#### Security Test Failures
```bash
# Problem: Input validation missing
# Solution: Add validation functions to scripts
# Pattern: validate_menu_choice, validate_path

# Problem: Path traversal vulnerability
# Solution: Use realpath and validate paths
# Function: validate_path in common.sh
```

### Test Environment Issues

#### Docker Issues
```bash
# Permission denied
sudo usermod -aG docker $USER
newgrp docker

# Image not found
docker build -t quillkernel-unified -f build/docker/kernel-xda-proven.dockerfile build/docker/

# Memory constraints not working
# This is expected in some Docker configurations - tests handle gracefully
```

#### File Permission Issues
```bash
# Test scripts not executable
find tests/ -name "*.sh" -exec chmod +x {} \;

# Build directory permissions
sudo chown -R $USER:$USER source/kernel/
```

---

## Performance Testing

### Memory Profiling
```bash
#!/bin/bash
# memory-profile.sh - Profile memory usage

echo "📊 Memory profiling for QuillKernel..."

# Docker container memory
echo "Container memory usage:"
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}" \
    $(docker ps --format "{{.Names}}" | grep nook)

# Image size analysis
echo "Image sizes:"
docker images --format "table {{.Repository}}\t{{.Size}}" | grep nook

# Module memory estimation
echo "Module sizes:"
find source/kernel -name "*.ko" -exec ls -lh {} \; 2>/dev/null || echo "No compiled modules found"
```

### Boot Time Testing
```bash
#!/bin/bash
# boot-time-test.sh - Measure boot performance

echo "⏱️ Boot time testing..."

# Container boot time
start_time=$(date +%s.%N)
docker run --rm quillkernel-unified echo "Boot complete" >/dev/null 2>&1
end_time=$(date +%s.%N)

boot_time=$(echo "$end_time - $start_time" | bc)
echo "Container boot time: ${boot_time}s"

# Target validation (should be <20s on device)
if (( $(echo "$boot_time < 10" | bc -l) )); then
    echo "✅ Boot time acceptable"
else
    echo "⚠️ Boot time high (may be acceptable for container)"
fi
```

---

## Test Maintenance

### Adding New Tests

1. **Identify test category** based on feature area
2. **Create test file** following naming convention
3. **Use test template** for consistency
4. **Add to appropriate test suite** (high/medium/low priority)
5. **Update documentation** if needed

### Test Review Checklist

```bash
# Checklist for test reviews
- [ ] Test follows template pattern
- [ ] Uses appropriate assertion functions
- [ ] Has proper error handling (set -euo pipefail)
- [ ] Includes cleanup function if needed
- [ ] Tests both positive and negative cases
- [ ] Has meaningful test messages
- [ ] Follows naming conventions
- [ ] Is categorized correctly
- [ ] Runs in reasonable time (< 2 minutes)
- [ ] Is documented appropriately
```

### Test Metrics

```bash
#!/bin/bash
# test-metrics.sh - Generate test coverage metrics

echo "📈 Test metrics for QuillKernel..."

# Count tests by category
echo "Test distribution:"
for category in tests/unit/*/; do
    count=$(find "$category" -name "*.sh" | wc -l)
    echo "  $(basename "$category"): $count tests"
done

# Test execution times
echo "Test execution times:"
time ./tests/run-all-tests.sh >/dev/null 2>&1

# Coverage analysis
echo "Coverage analysis:"
scripts_total=$(find source/scripts -name "*.sh" | wc -l)
tested_scripts=$(grep -r "source/scripts" tests/unit/ | grep -o "source/scripts/[^\"]*" | sort -u | wc -l)
coverage=$((tested_scripts * 100 / scripts_total))
echo "Script coverage: $tested_scripts/$scripts_total ($coverage%)"
```

---

## Best Practices

### Test Writing Guidelines

1. **Keep tests focused** - One test per feature
2. **Use descriptive names** - Test purpose should be clear
3. **Test edge cases** - Invalid inputs, boundary conditions
4. **Be environment aware** - Handle Docker vs hardware differences
5. **Clean up resources** - Use trap for cleanup functions
6. **Validate thoroughly** - Don't just check existence, check correctness
7. **Maintain medieval theme** - Even in test output messages

### Performance Guidelines

1. **Respect memory limits** - Tests shouldn't consume >160MB
2. **Keep tests fast** - Individual tests <2 minutes
3. **Batch operations** - Reduce Docker container startup overhead
4. **Use appropriate tools** - Docker for isolation, native for speed
5. **Monitor resource usage** - Profile tests regularly

### Security Guidelines

1. **Test input validation** - All user-facing inputs
2. **Check path security** - Prevent traversal attacks
3. **Validate permissions** - Don't require unnecessary privileges
4. **Test error handling** - Security implications of failures
5. **Document security assumptions** - What the test validates

---

## Conclusion

This testing guide provides the practical knowledge needed for effective QuillKernel development. The testing infrastructure is designed to:

- **Catch issues early** through fast, focused unit tests
- **Ensure quality** through comprehensive integration testing  
- **Maintain security** through rigorous input validation
- **Preserve constraints** through continuous memory monitoring
- **Support development** through clear debugging workflows

Remember the QuillKernel philosophy: *"By quill and candlelight, quality prevails!"*

---

*Developer Testing Guide v1.0*  
*Generated for QuillKernel development team* 🕯️📜