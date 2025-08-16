# Nook Typewriter Test Suite Documentation

## Overview

The Nook Typewriter test suite provides comprehensive validation for transforming a Nook SimpleTouch into a distraction-free writing device. Tests are organized by priority and category to ensure safe deployment to hardware while maintaining the project's writer-first philosophy.

## Test Philosophy

> "Test Enough to Sleep Well, Not to Pass an Audit"

This is a hobby project for fun and learning. Testing focuses on:
- **Kernel safety** (prevents bricking)
- **Basic functionality** (can write and save)
- **Memory constraints** (stays under 96MB OS usage)
- **Safe deployment** (SD card testing first)

## Test Categories

### 🚨 Critical Safety Tests

These tests MUST pass before any hardware deployment.

#### `smoke-test.sh`
**Purpose**: Quick 5-minute safety validation  
**Priority**: CRITICAL  
**Description**: Validates kernel builds, runs safety checks, tests Docker functionality, and performs memory analysis. If this passes, it's safe to try on hardware.

#### `kernel-safety.sh`
**Purpose**: Kernel safety validation (most important for not bricking!)  
**Priority**: CRITICAL  
**Description**: Validates JesterOS userspace implementation, checks for unsafe kernel patterns, and ensures no kernel modules that could brick the device.

#### `pre-flight.sh`
**Purpose**: Automated pre-flight checklist for hardware deployment  
**Priority**: HIGH  
**Description**: Comprehensive validation of build artifacts, test results, and deployment readiness with automated safety checks.

### 💾 Memory Management Tests

Ensures the system stays within the sacred 256MB hardware limit.

#### `memory-analysis.sh`
**Purpose**: Detailed memory allocation and usage validation  
**Description**: Validates the 96MB OS budget, analyzes component memory usage, and ensures 160MB remains for writing.

#### `memory-profiler.sh`
**Purpose**: Comprehensive memory profiling with data collection  
**Description**: Collects detailed memory metrics during various operations and generates profiles for optimization.

#### `docker-memory-profiler.sh`
**Purpose**: Realistic Nook memory testing in Docker environment  
**Description**: Simulates Nook's 256MB constraint in Docker with memory limits and realistic workload testing.

#### `memory-optimizer.sh`
**Purpose**: Memory optimization analysis and recommendations  
**Description**: Analyzes memory profiles and suggests specific optimizations to reduce memory footprint.

#### `hardware-memory-test.sh`
**Purpose**: Real hardware memory validation  
**Description**: Tests actual memory usage on Nook hardware with comprehensive monitoring.

### 🃏 JesterOS Tests

Validates the jester-themed userspace services and boot system.

#### `test-jesteros-integration.sh`
**Purpose**: Complete JesterOS integration testing  
**Description**: Tests boot sequence, service startup, menu system, and complete user workflow with JesterOS services.

#### `test-jesteros-userspace.sh`
**Purpose**: JesterOS userspace service validation  
**Description**: Tests the jester mood system, typewriter statistics, and wisdom quotes running in userspace.

#### `test-jesteros-config.sh`
**Purpose**: JesterOS configuration and kernel integration  
**Description**: Validates kernel configuration options and JesterOS service setup.

#### `test-service-management.sh`
**Purpose**: Service management and lifecycle testing  
**Description**: Tests service startup, shutdown, and management of JesterOS userspace services.

### 🏗️ Build & Infrastructure Tests

#### `test-rootfs.sh`
**Purpose**: Root filesystem validation  
**Description**: Tests rootfs structure, permissions, boot scripts, and essential system files.

#### `test-sd-image-builder.sh`
**Purpose**: SD card image building and validation  
**Description**: Tests the complete SD card image creation process for deployment.

#### `docker-test.sh`
**Purpose**: Docker environment safety testing  
**Description**: Safe testing environment that can't break hardware, validates Docker builds and functionality.

#### `test-improvements.sh`
**Purpose**: Script improvement validation  
**Description**: Tests recent improvements to shell scripts including safety measures and error handling.

### 🎨 UI & Theme Tests

#### `test-ui-components.sh`
**Purpose**: UI component testing for E-Ink display  
**Description**: Tests menu system, jester displays, and other UI components for E-Ink compatibility.

#### `test-font-setup.sh`
**Purpose**: Font configuration for E-Ink readability  
**Description**: Validates font setup and rendering for optimal E-Ink display.

### 🧪 Unit Tests

Located in `tests/unit/`, organized by component:

#### Boot Tests (`unit/boot/`)
- `test-boot-scripts-exist.sh`: Validates boot script presence
- `test-module-loading-sequence.sh`: Tests module loading order

#### Kernel Tests (`unit/kernel/`)
- `test-kernel-integration.sh`: Kernel integration validation
- `test-squireos-core.sh`: Core SquireOS functionality
- `test-jester-module.sh`: Jester module testing
- `test-typewriter-module.sh`: Typewriter statistics module
- `test-wisdom-module.sh`: Wisdom quotes module

#### Menu Tests (`unit/menu/`)
- `test-menu-exists.sh`: Menu system presence
- `test-menu-input-validation.sh`: Input validation
- `test-menu-error-handling.sh`: Error handling

#### Module Tests (`unit/modules/`)
- `test-module-sources.sh`: Module source validation
- `test-module-makefile.sh`: Makefile structure
- `test-module-kconfig.sh`: Kernel configuration

#### Theme Tests (`unit/theme/`)
- `test-jester-ascii-art.sh`: ASCII art validation
- `test-medieval-messages.sh`: Medieval theme consistency

#### Toolchain Tests (`unit/toolchain/`)
- `test-cross-compiler.sh`: ARM cross-compiler validation
- `test-docker-image.sh`: Docker build environment
- `test-ndk-version.sh`: Android NDK compatibility

#### Other Unit Tests
- `unit/eink/test-display-abstraction.sh`: E-Ink display abstraction
- `unit/memory/test-docker-memory-limit.sh`: Docker memory constraints
- `unit/memory/test-kernel-memory-config.sh`: Kernel memory configuration
- `unit/docs/test-xda-research-docs.sh`: Documentation validation

### 🔧 Utility & Framework Tests

#### `test-framework.sh`
**Purpose**: Common test framework functions  
**Description**: Provides pass_test(), fail_test(), skip_test() functions for all unit tests.

#### `run-all-tests.sh`
**Purpose**: Complete test suite execution  
**Description**: Runs all unit tests and generates comprehensive test report.

#### `test-high-priority.sh`
**Purpose**: High-priority test aggregation  
**Description**: Runs critical tests that must pass before deployment.

#### `test-medium-priority.sh`
**Purpose**: Medium-priority test aggregation  
**Description**: Runs important but non-critical tests.

#### `test-userspace-services.sh`
**Purpose**: Userspace service validation  
**Description**: Tests all userspace services and their interactions.

#### `test_menuconfig_search.sh`
**Purpose**: Kernel configuration search testing  
**Description**: Validates menuconfig search functionality.

## Test Execution Order

### Before Hardware Deployment

1. **Run Critical Safety Tests** (5 minutes)
   ```bash
   ./tests/smoke-test.sh
   ./tests/kernel-safety.sh
   ./tests/pre-flight.sh
   ```

2. **Validate in Docker** (10 minutes)
   ```bash
   ./tests/docker-test.sh
   ./tests/docker-memory-profiler.sh
   ```

3. **Run Integration Tests** (15 minutes)
   ```bash
   ./tests/test-jesteros-integration.sh
   ./tests/test-rootfs.sh
   ```

4. **Full Test Suite** (if making major changes)
   ```bash
   ./tests/run-all-tests.sh
   ```

### Performance Targets

- **Boot time**: < 20 seconds
- **Vim launch**: < 2 seconds
- **Menu response**: < 500ms
- **Writing save**: < 1 second
- **Total RAM usage**: < 96MB

## Test Reports & Artifacts

### Generated Reports
- `tests/reports/test_report_*.md`: Markdown test reports
- `tests/reports/test_log_*.txt`: Detailed test logs
- `tests/memory-profiles/memory_profile_*.txt`: Memory usage profiles

### Deployment Checklist
- `tests/deployment-checklist.md`: Manual deployment verification steps

## Dependencies

### Required Tools
- Docker (for containerized testing)
- Bash 4.0+ (for test scripts)
- ARM cross-compiler (for kernel modules)
- Android NDK r10e (for kernel compilation)

### Docker Images
- `jokernel-builder`: Main kernel build environment
- `nook-writer`: Optimized writing environment
- `nook-mvp-rootfs`: Minimal boot environment

## Writing Custom Tests

### Using the Test Framework

```bash
#!/bin/bash
source tests/test-framework.sh

init_test "My Custom Test"

if [ -f "expected_file.txt" ]; then
    pass_test "File exists"
else
    fail_test "File missing"
fi

# Test completed automatically with summary
```

### Test Naming Convention
- Critical tests: `*-safety.sh`, `smoke-*.sh`
- Integration tests: `test-*-integration.sh`
- Unit tests: `unit/category/test-*.sh`
- Utility scripts: No `test-` prefix

## Troubleshooting

### Common Test Failures

**"Kernel build failed"**
- Check Docker is running
- Verify `jokernel-builder` image exists
- Check disk space for build artifacts

**"Memory analysis warnings"**
- Review component memory usage
- Run `memory-optimizer.sh` for suggestions
- Consider removing unused features

**"JesterOS services not found"**
- Run `./install-jesteros-userspace.sh`
- Check `/usr/local/bin/` for service scripts
- Verify `/var/jesteros/` directory exists

**"Docker test timeout"**
- Increase memory limits in test script
- Check for infinite loops in services
- Verify Docker daemon resources

## Contributing

When adding new tests:
1. Follow the naming convention
2. Use the test framework functions
3. Add appropriate priority classification
4. Update this documentation
5. Ensure tests are idempotent
6. Keep tests focused and fast

Remember: **Time spent over-testing = less time spent writing!**

---

*"By quill and candlelight, we test for those who write"* 🕯️📜