# JesterOS Test Suite - Comprehensive Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Test Categories](#test-categories)
4. [Individual Test Scripts](#individual-test-scripts)
5. [Test Orchestration](#test-orchestration)
6. [Common Issues and Solutions](#common-issues-and-solutions)
7. [Development Guidelines](#development-guidelines)
8. [Maintenance](#maintenance)

## Overview

The JesterOS test suite provides comprehensive validation for the Nook TypeWriter project, ensuring device safety, functionality, and user experience. Following a "hobby robust" philosophy, it focuses on practical validation without enterprise-level complexity.

### Philosophy
> "Test enough to sleep well, not to pass an audit"

The suite prioritizes:
1. **Device Safety** - Prevent bricking the Nook
2. **Writer Functionality** - Ensure writing capabilities work
3. **User Experience** - Maintain pleasant, themed interface

### Quick Start
```bash
# Run all tests with default configuration
make test

# Run specific test stage
TEST_STAGE=post-build make test

# Run individual test
./01-safety-check.sh

# Run comprehensive validation
./comprehensive-validation.sh
```

## Architecture

### Three-Stage Testing Model

The test suite operates in three distinct stages:

#### 1. Pre-Build Stage
- **Purpose**: Validate build tools and scripts before compilation
- **Target**: Development and deployment scripts
- **Directory**: `scripts/` (build scripts)
- **Tests Run**: Safety checks only

#### 2. Post-Build Stage (Default)
- **Purpose**: Test Docker-generated output
- **Target**: Runtime scripts that will run on Nook
- **Directory**: `source/scripts/` (runtime scripts)
- **Tests Run**: All 7 core tests

#### 3. Runtime Stage
- **Purpose**: Test actual execution in containers
- **Target**: Live behavior validation
- **Environment**: Docker container
- **Tests Run**: Subset focused on runtime behavior

### Test Priority System

Tests are categorized by criticality:

1. **🛡️ Show Stoppers (MUST PASS)**
   - Critical safety checks
   - Boot capability validation
   - Risk: Device could be bricked

2. **🚧 Writing Blockers (SHOULD PASS)**
   - Core functionality tests
   - Memory constraint validation
   - Risk: Writing experience impaired

3. **✨ Writer Experience (NICE TO PASS)**
   - User experience features
   - Theme consistency
   - Risk: Experience degraded but functional

## Test Categories

### Show Stoppers (Critical)

These tests MUST pass before any hardware deployment:

| Test | Purpose | Failure Impact |
|------|---------|----------------|
| 01-safety-check.sh | Validates no dangerous operations | Device damage risk |
| 02-boot-test.sh | Ensures boot components exist | Device won't boot |

### Writing Blockers (Important)

These tests SHOULD pass for proper functionality:

| Test | Purpose | Failure Impact |
|------|---------|----------------|
| 04-docker-smoke.sh | Runtime environment validation | Features may not work |
| 05-consistency-check.sh | Script interconnection validation | Scripts may fail |
| 06-memory-guard.sh | Memory constraint enforcement | Writing space reduced |

### Writer Experience (Nice to Have)

These tests improve user experience:

| Test | Purpose | Failure Impact |
|------|---------|----------------|
| 03-functionality.sh | Fun features and themes | Less enjoyable |
| 07-writer-experience.sh | Error quality and UX | Harder to debug |

## Individual Test Scripts

### 01-safety-check.sh
**Purpose**: Critical safety validation before hardware deployment

**Checks Performed**:
1. Kernel image existence
2. No dangerous `/dev/sda` references
3. SD card protection in Makefile
4. Build system readiness

**Key Code**:
```bash
# Check for dangerous device references
if grep -r "/dev/sda" ../source/scripts 2>/dev/null | grep -v "sda-sdd" | grep -v "#" | grep -q .; then
    fail "DANGER! Found /dev/sda references!"
fi
```

**Common Issues**:
- Missing kernel image → Build kernel first
- `/dev/sda` references → Update to use safe device names

### 02-boot-test.sh
**Purpose**: Validate boot sequence components

**Checks Performed**:
1. Boot scripts in `/runtime/init/`
2. JesterOS service availability
3. Menu system presence
4. Common library functions
5. Boot configuration (uEnv.txt)

**Key Code**:
```bash
# Check boot scripts with proper error handling
if [ -d "../runtime/init" ]; then
    boot_count=$(find ../runtime/init -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
    boot_count=${boot_count:-0}
else
    boot_count=0
fi
```

**Common Issues**:
- Missing boot scripts → Check Docker build output
- No menu system → Non-critical but affects UX

### 03-functionality.sh
**Purpose**: Check non-critical but nice features

**Checks Performed**:
1. ASCII art availability
2. Service script count
3. Vim configuration
4. Total script count (bloat check)
5. Docker environment readiness

**Key Code**:
```bash
# Check script count with whitespace handling
if [ -d "../source/scripts" ]; then
    total_scripts=$(find ../source/scripts -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
    total_scripts=${total_scripts:-0}
else
    total_scripts=0
fi
```

**Common Issues**:
- High script count → Remove unnecessary scripts
- Missing Docker images → Run `make docker-build`

### 04-docker-smoke.sh
**Purpose**: Quick Docker environment validation

**Checks Performed**:
1. Container startup
2. Menu system syntax
3. Vim installation
4. Service directory creation
5. Basic write workflow

**Requirements**:
- Docker daemon running
- Test images built

### 05-consistency-check.sh
**Purpose**: Validate script interconnections

**Checks Performed**:
1. Valid script references
2. No kernel module attempts
3. Consistent JesterOS naming
4. Common library usage
5. Service path consistency

**Key Code**:
```bash
# Check for deprecated module references
if [ -d "$SCRIPT_DIR" ]; then
    DEPRECATED_REFS=$(grep -r "load_module\|\.ko" "$SCRIPT_DIR" 2>/dev/null | grep -v "^#" | wc -l | tr -d ' ')
else
    DEPRECATED_REFS=0
fi
```

### 06-memory-guard.sh
**Purpose**: Protect the 160MB writing space

**Memory Budget**:
- Total RAM: 256MB
- OS Target: <96MB
- Writing Space: 160MB (sacred!)

**Checks Performed**:
1. Script and config sizes
2. Large file detection (>1MB)
3. Forbidden directories (node_modules)
4. Binary count
5. Docker image size

### 07-writer-experience.sh
**Purpose**: Validate user experience quality

**Checks Performed**:
1. Error handling coverage (>80% target)
2. Friendly error messages
3. Medieval theme consistency
4. No silent failures
5. Recovery help availability
6. Menu usability
7. Boot feedback quality

**Key Code**:
```bash
# Calculate error handling percentage
if [ "$TOTAL_SCRIPTS" -gt 0 ]; then
    PERCENTAGE=$((SCRIPTS_WITH_TRAP * 100 / TOTAL_SCRIPTS))
fi
```

## Test Orchestration

### run-tests.sh
**Purpose**: Three-stage test runner with prioritized validation

**Usage**:
```bash
# Default (post-build stage)
./run-tests.sh

# Specific stage
TEST_STAGE=pre-build ./run-tests.sh
TEST_STAGE=runtime ./run-tests.sh
```

**Stage Selection Logic**:
- Pre-build: Tests build tools only
- Post-build: Tests Docker output (default)
- Runtime: Tests execution in container

### comprehensive-validation.sh
**Purpose**: Runs all 7 tests in organized phases

**Phases**:
1. **Safety & Prerequisites** (Tests 01-02)
2. **Core Functionality** (Tests 03-04)
3. **Quality & Experience** (Tests 05-07)

**Usage**:
```bash
./comprehensive-validation.sh
```

### test-runner.sh
**Purpose**: Docker-based test execution with image management

**Features**:
- Image building and management
- Test script mounting
- Result collection
- Multiple image support

**Commands**:
```bash
./test-runner.sh                    # Default test
./test-runner.sh build              # Build images
./test-runner.sh list               # List images/tests
./test-runner.sh jesteros-test     # Test specific image
```

## Common Issues and Solutions

### Issue: Integer Expression Expected
**Error**:
```
line 30: [: 0
0: integer expression expected
```

**Cause**: `wc -l` outputs numbers with whitespace

**Solution**: Strip whitespace with `tr -d ' '`:
```bash
# Fixed version
count=$(find . -name "*.sh" | wc -l | tr -d ' ')
```

### Issue: Missing Directories
**Error**: Tests fail when directories don't exist

**Solution**: Check directory existence first:
```bash
if [ -d "../source/scripts" ]; then
    # Perform operations
else
    # Set default value
    count=0
fi
```

### Issue: Docker Not Available
**Error**: Docker tests fail

**Solution**:
1. Install Docker
2. Start Docker daemon
3. Build images: `make docker-build`

### Issue: High Memory Usage
**Error**: Memory guard fails

**Solution**:
1. Remove unnecessary files
2. Reduce script count
3. Optimize Docker images

## Development Guidelines

### Adding New Tests

1. **Choose appropriate category**:
   - Safety critical → Show Stopper
   - Functionality → Writing Blocker
   - Nice to have → Writer Experience

2. **Follow naming convention**:
   - Format: `NN-descriptive-name.sh`
   - Numbers: 01-09 for core tests

3. **Include standard header**:
```bash
#!/bin/bash
# Test name - Brief description
#
# Usage: ./test-name.sh
# Returns: 0 on success, 1 on failure
# Category: Show Stopper|Writing Blocker|Writer Experience

set -euo pipefail
```

4. **Use library functions** (if available):
```bash
source "$(dirname "$0")/test-lib.sh"
init_test "Test Name" "Description"
# ... test logic ...
summarize_test
```

### Best Practices

1. **Always handle missing directories**:
```bash
if [ -d "$dir" ]; then
    # operations
fi
```

2. **Strip whitespace from numeric outputs**:
```bash
count=$(command | wc -l | tr -d ' ')
```

3. **Provide meaningful messages**:
```bash
echo "✓ Check passed"      # Success
echo "✗ Check failed"      # Failure
echo "⚠ Warning"          # Warning
```

4. **Use consistent exit codes**:
```bash
exit 0  # Success
exit 1  # Failure
```

## Maintenance

### Regular Tasks

1. **Weekly**:
   - Run full test suite
   - Review test results
   - Update thresholds if needed

2. **Monthly**:
   - Clean test artifacts
   - Update documentation
   - Review test coverage

3. **Per Release**:
   - Run comprehensive validation
   - Document any new tests
   - Archive obsolete tests

### Test Configuration

Key configuration in `test-config.sh`:
```bash
# Memory constraints
export MAX_OS_MEMORY_MB=96
export MIN_WRITER_MEMORY_MB=160

# Test thresholds
export MIN_SAFETY_HEADERS_PERCENT=80
export MIN_THEME_WORDS=10
export MAX_SILENT_FAILURES=5
```

### Logging and Reports

Enable logging:
```bash
LOG_RESULTS=1 ./run-tests.sh
```

Generate reports:
```bash
./test-logger.sh report weekly-report.md
```

Clean old logs:
```bash
./test-logger.sh clean
```

## Test Library Reference

### Available Functions

The `test-lib.sh` provides common functions:

| Function | Purpose | Usage |
|----------|---------|-------|
| `init_test` | Initialize test | `init_test "Name" "Description"` |
| `pass` | Log success | `pass "Check passed"` |
| `fail` | Log failure | `fail "Check failed"` |
| `warn` | Log warning | `warn "Non-critical issue"` |
| `check_file` | Verify file exists | `check_file "/path/to/file"` |
| `check_directory` | Verify directory | `check_directory "/path"` |
| `check_command` | Check command exists | `check_command "docker"` |
| `summarize_test` | Print summary | `summarize_test` |

### Error Codes

Standard exit codes used throughout:
- `0` - TEST_SUCCESS
- `1` - TEST_FAILURE
- `2` - TEST_WARNING
- `3` - TEST_SKIPPED

## Performance Metrics

### Execution Times

| Test | Average Time | Timeout |
|------|--------------|---------|
| 01-safety-check.sh | <1s | 5s |
| 02-boot-test.sh | <2s | 10s |
| 03-functionality.sh | <2s | 10s |
| 04-docker-smoke.sh | <10s | 30s |
| 05-consistency-check.sh | <3s | 15s |
| 06-memory-guard.sh | <2s | 10s |
| 07-writer-experience.sh | <3s | 10s |
| **Total Suite** | <30s | 2min |

### Resource Usage

- Memory: <10MB for test execution
- Disk: <1MB for logs and artifacts
- CPU: Minimal (single-threaded)

## Troubleshooting Guide

### Test Won't Run

1. Check permissions:
```bash
chmod +x *.sh
```

2. Verify shell:
```bash
#!/bin/bash  # Must be first line
```

3. Check dependencies:
```bash
which bash docker find grep
```

### False Failures

1. **Directory issues**: Ensure correct working directory
2. **Whitespace problems**: Check for `tr -d ' '` in numeric operations
3. **Path issues**: Use absolute or proper relative paths

### Debugging Tests

Enable debug output:
```bash
DEBUG=1 ./test-name.sh
```

Run with trace:
```bash
bash -x ./test-name.sh
```

Check specific stage:
```bash
TEST_STAGE=post-build ./05-consistency-check.sh
```

## Summary

The JesterOS test suite provides practical, focused validation for the Nook TypeWriter project. With its three-stage architecture, priority-based categorization, and robust error handling, it ensures safe deployment while maintaining the project's "hobby robust" philosophy.

Key achievements:
- ✅ Prevents device bricking
- ✅ Validates core functionality
- ✅ Maintains user experience
- ✅ Runs in under 30 seconds
- ✅ Handles edge cases gracefully

---
*"By quill and candlelight, we test with wisdom!"* 🕯️📜