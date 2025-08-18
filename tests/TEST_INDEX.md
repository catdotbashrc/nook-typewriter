# Test Suite Index

## Structure
```
tests/
├── 01-07-*.sh         # Numbered integration tests
├── unit/              # Unit tests for specific functions
│   ├── test_apply_metadata.sh
│   ├── test_common.sh
│   ├── test_framework.sh
│   └── test_secure_chmod.sh
├── lib/               # Test libraries and frameworks
│   ├── test-lib.sh
│   ├── test-logger.sh
│   └── test-config.sh
├── tools/             # Test utilities
│   └── test-improvements.sh
├── archive/           # Obsolete tests
└── results/           # Test results and logs
```

## Running Tests

### All Tests
```bash
bash tests/run-all-tests.sh
```

### Specific Categories
```bash
# Integration tests only
bash tests/test-runner.sh

# Unit tests only
for test in tests/unit/test_*.sh; do bash "$test"; done

# Safety checks
bash tests/01-safety-check.sh
```

## Test Categories

### Integration Tests (01-07)
- 01-safety-check.sh - Kernel safety validation
- 02-boot-test.sh - Boot sequence testing
- 03-functionality.sh - Core functionality
- 04-docker-smoke.sh - Docker build verification
- 05-consistency-check.sh - Configuration consistency
- 06-memory-guard.sh - Memory constraints
- 07-writer-experience.sh - User experience

### Unit Tests
- test_apply_metadata.sh - Metadata application
- test_common.sh - Common functions
- test_framework.sh - Test framework itself
- test_secure_chmod.sh - Permission security
