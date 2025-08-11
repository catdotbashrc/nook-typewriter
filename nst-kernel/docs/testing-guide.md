# QuillKernel Comprehensive Testing Guide

*"Test thy code as thoroughly as a medieval scribe checks his manuscripts"* - The Jester

## Overview

This guide documents QuillKernel's testing framework, which follows Linux kernel best practices while addressing the unique constraints of e-reader hardware (256MB RAM, E-Ink display, ARM processor).

```
     .~"~.~"~.
    /  o   o  \    A well-tested kernel
   |  >  ◡  <  |   is a happy kernel!
    \  ___  /      
     |~|♦|~|       
```

## Testing Architecture

### 1. In-Kernel Testing (KUnit)

Located in: `src/drivers/squireos/typewriter_test.c`

KUnit provides "white box" testing with direct access to kernel internals:
- Typewriter keystroke counting accuracy
- Word calculation algorithms
- Achievement system logic
- Memory pressure handling
- Session timeout behavior

**Running KUnit tests:**
```bash
# Enable in kernel config
CONFIG_KUNIT=y
CONFIG_SQUIREOS_TYPEWRITER_KUNIT_TEST=y

# Run tests at boot
./tools/testing/kunit/kunit.py run --kunitconfig=drivers/squireos
```

### 2. Userspace Testing (kselftest)

Located in: `src/tools/testing/selftests/squireos/`

Tests kernel interfaces from userspace:
- `/proc/squireos` file operations
- Typewriter statistics accuracy
- Memory stability under stress
- Concurrent access handling

**Running kselftests:**
```bash
cd src/tools/testing/selftests/squireos
make
./test_squireos.sh
```

### 3. Static Analysis

**Pre-commit hooks:** `.githooks/pre-commit`
- Coding style validation
- Debug code detection
- Memory allocation checks
- Theme consistency

**Full analysis:** `test/static-analysis.sh`
- Sparse: Type checking, lock validation
- Smatch: Logic errors, memory leaks
- Custom QuillKernel checks

**Setup:**
```bash
./setup-hooks.sh  # Enable git hooks
./test/static-analysis.sh  # Run full analysis
```

### 4. Hardware Testing

**Boot Validation:** `test/test-boot.sh`
- Medieval boot messages
- Jester ASCII art rendering
- /proc/squireos creation
- Memory usage baseline

**USB Testing:** `test/test-usb.sh`
- Keyboard detection
- Power consumption (<100mA)
- Custom USB messages
- Disconnect/reconnect handling

**E-Ink Testing:** `test/test-eink.sh`
- Refresh rate measurement
- Ghosting detection
- Unicode rendering
- Power draw during updates

### 5. Performance Testing

**Benchmark Suite:** `test/benchmark.sh`
- Boot time impact (<3s delay)
- Memory footprint
- CPU performance
- I/O throughput
- Module loading time

**Low Memory Testing:** `test/low-memory-test.sh`
- 256MB constraint validation
- Page fault monitoring
- OOM killer behavior
- Memory leak detection

## Test Execution Strategy

### Quick Validation (5 minutes)
```bash
cd test
./verify-build-simple.sh    # Build environment check
./static-analysis.sh        # Code quality
```

### Standard Testing (30 minutes)
```bash
./run-all-tests.sh         # Automated test suite
```

### Comprehensive Testing (2+ hours)
1. Build with all debug options enabled
2. Boot on actual Nook hardware
3. Run hardware-specific tests
4. Perform 24-hour stability test
5. Validate power consumption

## Critical Test Scenarios

### 1. Memory Pressure (256MB limit)
- Allocate 200MB+ and verify stability
- Test /proc file access under pressure
- Validate typewriter tracking continues
- Ensure no kernel panics

### 2. E-Ink Specific
- Full screen refresh with medieval banner
- Rapid partial updates during typing
- Power measurement during refresh
- Ghosting after extended use

### 3. USB Keyboard
- Hot-plug detection
- Power budget compliance
- Multiple keyboard types
- Wireless keyboard support

### 4. Extended Writing Session
- 4+ hour continuous typing
- 10,000+ keystroke sessions
- Achievement progression
- Memory stability over time

## Recovery Testing

**Scenarios to test:**
- Kernel panic recovery via SD card
- Serial console access
- Clockwork Recovery integration
- Rollback procedures

**Recovery validation:**
```bash
# Test recovery procedures
./test/test-recovery.sh

# Verify backup kernel
./test/verify-backup.sh
```

## Continuous Integration

### Build Matrix
- Cross-compiler versions
- Config variations (debug on/off)
- Architecture validation (ARMv7)

### Test Reporting
- TAP format for CI tools
- JUnit XML for Jenkins
- HTML reports for humans
- Performance baselines

### Automated Triggers
- Pre-commit: Style and static analysis
- Post-commit: Build and unit tests
- Pre-merge: Full test suite
- Nightly: Extended hardware tests

## Performance Targets

| Metric | Target | Critical |
|--------|--------|----------|
| Boot delay | <3s | <5s |
| Free memory | >50MB | >30MB |
| USB power | <100mA | <150mA |
| E-Ink refresh | <500ms | <1s |
| Keystroke latency | <50ms | <100ms |

## Known Test Limitations

1. **Docker Testing**: E-Ink commands fail gracefully (no hardware)
2. **Memory Tests**: Limited without actual 256MB constraint
3. **USB Tests**: Require OTG adapter and keyboard
4. **Power Tests**: Need instrumented hardware

## Test Development Guidelines

1. **All new features** must include:
   - KUnit tests for algorithms
   - Kselftest for interfaces
   - Documentation updates
   - Performance baseline

2. **Test naming**: `test_<component>_<scenario>`

3. **Expected failures**: Use `|| true` for hardware-dependent operations

4. **Medieval theme**: Include jester reactions in test output

## Troubleshooting Test Failures

### Build Verification Fails
```bash
# Apply patches first
./squire-kernel-patch.sh
# Verify with simple test
./verify-build-simple.sh
```

### Static Analysis Warnings
```bash
# Check specific file
sparse drivers/squireos/typewriter.c -Wbitwise
# Fix style issues
scripts/checkpatch.pl --file <filename>
```

### Hardware Test Failures
- Ensure kernel is actually QuillKernel (check `uname -r`)
- Verify USB OTG adapter is connected
- Check kernel messages with `dmesg | tail -50`
- Confirm E-Ink driver loaded (`dmesg | grep fb`)

## Software-Only Testing Approach

All QuillKernel tests are designed to work at the software level:
- No hardware modifications required
- No need to open the Nook
- USB testing via standard OTG adapter
- All debugging through standard Linux interfaces

## Future Testing Enhancements

1. **Fuzzing**: syzkaller integration for robustness
2. **Power profiling**: Software-based battery monitoring
3. **Stress testing**: 72-hour continuous operation
4. **Coverage**: GCOV/KCOV integration
5. **CI/CD**: GitHub Actions workflow

---

*"Remember: A bug found in testing saves a manuscript from corruption!"* - Ancient QA Wisdom

```
     .~"~.~"~.
    /  ^   ^  \    May your tests be green
   |  >  ◡  <  |   and your kernel stable!
    \  ___  /      
     |~|♦|~|       
```