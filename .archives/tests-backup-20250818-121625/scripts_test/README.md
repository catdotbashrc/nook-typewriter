# Script Testing Framework

## Overview

This directory contains a comprehensive unit testing framework for the Nook scripts. The framework provides assertion functions, test runners, and CI/CD integration for ensuring script quality and reliability.

## Structure

```
scripts/test/
├── test_framework.sh      # Core testing framework with assertions
├── test_common.sh         # Tests for lib/common.sh
├── test_apply_metadata.sh # Tests for apply_metadata.sh
├── test_secure_chmod.sh   # Tests for secure-chmod-replacements.sh
├── run_all_tests.sh       # Main test runner
├── Makefile              # Make targets for testing
└── README.md             # This file
```

## Running Tests

### Run All Tests
```bash
# From the test directory
./run_all_tests.sh

# Using make
make test

# From project root
make -C scripts/test test
```

### Run Specific Test Suite
```bash
# Test common library only
./test_common.sh

# Or using make
make test-common
```

### Run Tests with Pattern
```bash
# Run tests matching a pattern
./run_all_tests.sh common
```

## Test Framework Features

### Assertion Functions

The framework provides comprehensive assertion functions:

- `assert_equals` - Check if two values are equal
- `assert_not_equals` - Check if two values are not equal
- `assert_true` - Check if condition is true (returns 0)
- `assert_false` - Check if condition is false (returns non-0)
- `assert_contains` - Check if string contains substring
- `assert_matches` - Check if string matches regex pattern
- `assert_file_exists` - Check if file exists
- `assert_dir_exists` - Check if directory exists
- `assert_success` - Check if command succeeds
- `assert_failure` - Check if command fails
- `assert_function_exists` - Check if function is defined
- `assert_var_set` - Check if variable is set
- `assert_output_contains` - Check command output contains text

### Test Structure

```bash
#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/test_framework.sh"

test_suite "My Test Suite"

test_case "Test something"
if assert_equals "expected" "actual"; then
    test_pass
fi

test_case "Test with skip"
if [[ $SKIP_SLOW_TESTS ]]; then
    test_skip "Slow test skipped"
else
    # Run test
    test_pass
fi

test_summary
```

### Utilities

- `create_test_dir` - Create temporary test directory
- `cleanup_test_dir` - Clean up test directory
- `mock_command` - Mock a command for testing
- `unmock_command` - Restore original command

## Writing New Tests

1. Create a new test file: `test_yourscript.sh`
2. Source the test framework
3. Source or reference the script to test
4. Write test cases using assertions
5. End with `test_summary`

Example:
```bash
#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/test_framework.sh"

test_suite "My Script Tests"

test_case "Script exists"
if assert_file_exists "../myscript.sh"; then
    test_pass
fi

test_summary
```

## CI/CD Integration

### GitHub Actions

Tests run automatically on:
- Push to main/dev branches
- Pull requests
- Manual workflow dispatch

### Local CI Testing

```bash
# Run CI test target
make ci-test
```

## Test Coverage

Current test coverage:

| Script | Coverage | Status |
|--------|----------|--------|
| lib/common.sh | High | ✅ |
| apply_metadata.sh | Medium | ✅ |
| secure-chmod-replacements.sh | Medium | ✅ |
| setup-writer-user.sh | Low | ⚠️ |
| deployment/create-sd-image.sh | Low | ⚠️ |
| version-control.sh | Low | ⚠️ |

## Best Practices

1. **Isolation**: Each test should be independent
2. **Cleanup**: Always clean up test artifacts
3. **Mocking**: Mock external dependencies
4. **Clear Names**: Use descriptive test names
5. **Fast Tests**: Keep tests fast and focused
6. **Error Messages**: Provide helpful failure messages

## Troubleshooting

### Tests Failing Locally

1. Check script permissions: `chmod +x *.sh`
2. Verify paths are correct
3. Clean test artifacts: `make clean`
4. Run with verbose: `make test-verbose`

### CI Tests Failing

1. Check GitHub Actions logs
2. Verify all files are committed
3. Ensure scripts have execute permissions in git
4. Check for environment differences

## Contributing

When adding new scripts:
1. Create corresponding test file
2. Add at least basic validation tests
3. Update this README with coverage info
4. Ensure tests pass before committing

## Medieval Theme 🏰

In keeping with the Nook's medieval theme:
- ✅ Pass = "Quest completed!"
- ❌ Fail = "Alas, the quest failed!"
- ⊗ Skip = "Quest deferred to another day"

*"By quill and candlelight, we test with might!"* 🕯️📜