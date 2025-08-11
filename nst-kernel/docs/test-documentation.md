# QuillKernel Test Documentation

This document provides detailed information about each test in the QuillKernel suite.

## Build Verification Tests

### verify-build-simple.sh

**Purpose**: Validates the kernel build environment before compilation.

**What it tests**:
1. Source file presence
   - Main Makefile
   - SquireOS headers
   - QuillKernel configuration
2. Medieval modifications
   - Jester branding in Makefile
   - Custom boot message files
3. Critical configurations
   - E-Ink driver support (FB_OMAP3EP)
   - USB host mode (MUSB_OTG)
4. Build environment
   - Cross-compiler availability
   - File permissions

**Expected output**:
```
Tests Passed: 9
Tests Failed: 0
Warnings: 2 (cross-compiler, Unicode in files)
```

**When to run**: Before building the kernel

## Static Analysis

### static-analysis.sh

**Purpose**: Catches bugs through code analysis without execution.

**Components**:
1. **Sparse analysis**
   - Type checking
   - Lock validation
   - Endianness issues
   - Address space validation

2. **Smatch analysis**
   - Null pointer detection
   - Memory leak identification
   - Missing break statements
   - Error handling verification

3. **QuillKernel checks**
   - Unicode in source files
   - Excessive boot delays
   - Unchecked allocations

**Interpreting results**:
- **Errors**: Must be fixed (type mismatches, obvious bugs)
- **Warnings**: Should be reviewed (potential issues)
- **Info**: Good to know (style suggestions)

## Runtime Hardware Tests

### test-boot.sh

**Purpose**: Validates kernel boot sequence and medieval theming.

**Requirements**: 
- Must run on actual Nook hardware
- QuillKernel must be installed

**Tests**:
1. Kernel version string contains "quill-scribe"
2. Medieval messages in dmesg
3. Jester ASCII art rendering
4. /proc/squireos directory creation
5. Boot timing (<3 second delay)
6. Memory usage after boot

### test-usb.sh & usb-automated-test.sh

**Purpose**: Comprehensive USB keyboard support validation.

**Hardware needed**:
- USB OTG adapter
- USB keyboard (wired recommended)

**Basic test (test-usb.sh)**:
- USB subsystem accessibility
- Keyboard detection
- Basic input testing

**Advanced test (usb-automated-test.sh)**:
1. USB subsystem validation
   - MUSB controller presence
   - Host/OTG mode verification
2. Power budget checks
   - <100mA consumption
   - Overcurrent protection
3. Keyboard detection methods
   - /dev/input/by-id
   - lsusb enumeration
   - /proc/bus/input/devices
4. Medieval message validation
5. Latency testing
6. Hot-plug functionality
7. Typewriter integration
8. Stress testing

**Common issues**:
- Wireless keyboards may need powered hub
- Some keyboards draw >100mA
- OTG adapter quality matters

### test-eink.sh

**Purpose**: E-Ink display performance and compatibility testing.

**What it measures**:
1. Framebuffer configuration
   - Driver verification (OMAP3EP)
   - Resolution check (800x600)
   - Bit depth (8-bit grayscale)
2. Refresh rates
   - Full refresh time
   - Partial update time
   - Fast mode performance
3. Unicode rendering
   - Medieval characters (♦◡✎)
   - ASCII art compatibility
4. Ghosting detection
5. Power consumption during updates
6. Typewriter display simulation

**Expected performance**:
- Full refresh: <1 second
- Partial update: <500ms
- No visible ghosting
- Unicode may not render (font-dependent)

## Software Tests

### test-proc.sh

**Purpose**: Validates /proc/squireos interface functionality.

**Tests**:
1. Directory structure and permissions
2. File readability (0444 permissions)
3. Content validation
   - Motto: "By quill and candlelight"
   - Wisdom: Rotating quotes
   - Jester: ASCII art
4. Stress testing
   - 1000 rapid reads
   - Memory stability
   - Concurrent access

### test-typewriter.sh

**Purpose**: Tests writing statistics tracking module.

**Validates**:
1. Keystroke counting accuracy
2. Word calculation (keystrokes ÷ 6)
3. Session tracking
4. Achievement progression
5. Rapid input handling
6. Memory leak detection

**Achievement levels tested**:
- Apprentice Scribe (0-999 words)
- Journeyman Wordsmith (1,000-9,999)
- Master Illuminator (10,000-49,999)
- Expert Chronicler (50,000-99,999)
- Grand Chronicler (100,000+)

### low-memory-test.sh

**Purpose**: Ensures stability under 256MB memory constraint.

**Test scenarios**:
1. Progressive memory allocation
2. /proc access under pressure
3. Near-OOM behavior
4. Typewriter tracking under stress
5. Memory leak detection

**Key metrics**:
- Page faults/second (>3 indicates pressure)
- Free memory threshold (>30MB critical)
- Response time under load

### benchmark.sh

**Purpose**: Performance baseline measurements.

**Metrics collected**:
1. Boot time analysis
2. Memory usage breakdown
3. CPU performance (prime calculation)
4. I/O throughput (read/write)
5. Power consumption
6. USB response time
7. E-Ink refresh performance
8. Module loading speed
9. System load analysis

**Performance targets**:
- Medieval message delay: <3 seconds
- Available memory: >50MB
- CPU benchmark: <10 seconds
- Module reload: <1 second

## Test Output Interpretation

### Understanding Results

Each test provides clear status indicators:
- **[PASS]**: Test succeeded
- **[FAIL]**: Test failed (must fix)
- **[WARN]**: Warning (should review)
- **[SKIP]**: Test skipped (missing hardware/module)
- **[INFO]**: Informational message

### The Jester's Feedback

Test results include medieval-themed feedback:

```
Success:
     .~"~.~"~.
    /  ^   ^  \    All tests passed!
   |  >  ◡  <  |   The kernel is ready!
    \  ___  /      
     |~|♦|~|       

Warnings:
     .~"~.~"~.
    /  o   o  \    Some warnings found.
   |  >  _  <  |   Could be better...
    \  ___  /      
     |~|♦|~|       

Failures:
     .~!!!~.
    / O   O \    Tests failed!
   |  >   <  |   Fix the issues!
    \  ~~~  /    
     |~|♦|~|     
```

## Log Files

Tests create detailed logs in:
- `/tmp/quillkernel-*-test-*.log`
- `test-results-*/` directories

Logs include:
- Timestamps for each operation
- Detailed error messages
- Performance measurements
- System state snapshots

## Troubleshooting Common Issues

### Build Tests Fail
1. Run `./squire-kernel-patch.sh` first
2. Check source directory structure
3. Verify cross-compiler installation

### USB Tests Fail
1. Check OTG adapter connection
2. Try different USB port/keyboard
3. Verify kernel has USB support enabled
4. Check `dmesg` for USB errors

### E-Ink Tests Skip
1. Ensure running on actual Nook
2. Check FBInk installation
3. Verify /dev/fb0 exists

### Memory Tests Fail
1. Close other applications
2. Check swap configuration
3. Monitor with `free -m`

### Performance Below Target
1. Check CPU governor settings
2. Disable debug options
3. Remove unnecessary kernel modules