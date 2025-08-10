# NST Kernel Notes

## Current Status
- Kernel Version: 2.6.29 (from 2009)
- Based on Barnes & Noble's official release
- Includes critical patches:
  - USB host mode fixes
  - Fast E-Ink display mode support
  - Nook-specific hardware drivers

## Why We're Stuck with 2.6.29

### Hardware-Specific Drivers
The following drivers are custom to the Nook and not in mainline Linux:
- **FB_OMAP3EP**: E-Paper framebuffer driver for the E-Ink display
- **TOUCHSCREEN_ZFORCE**: Neonode zForce infrared touchscreen
- **Battery Management**: BQ27510/BQ27520 with Nook-specific behavior
- **Power Management**: Custom suspend/resume for E-Ink

### Bootloader Constraints
- The Nook uses U-Boot 1.1.4 (also from 2009)
- May not support newer kernel image formats
- Device tree support wasn't standard in 2009

### Android Dependencies
- Based on Android 2.1 (Eclair) kernel requirements
- Uses Android-specific features (wakelocks, early suspend)
- These were replaced with different mechanisms in newer kernels

## Potential Upgrade Paths

### Option 1: Minimal Updates (Recommended)
- Keep 2.6.29 base but backport critical security fixes
- Focus on optimizing existing configuration
- This maintains maximum hardware compatibility

### Option 2: Port Drivers Forward (Very Difficult)
- Would need to port all custom drivers to modern kernel
- Risk breaking E-Ink support (most critical component)
- Months of development work

### Option 3: Find Middle Ground (Risky)
- Try 2.6.32 LTS or 2.6.35 (last pre-3.0 kernels)
- Still requires significant driver porting
- May not be worth the effort

## Current Configuration Analysis

### Already Optimized For
- Power management (CPU idle, frequency scaling)
- USB host mode with HID support
- Minimal I/O scheduler (NOOP)
- Size optimization (CONFIG_CC_OPTIMIZE_FOR_SIZE)

### Potential Optimizations
1. Disable unused network protocols
2. Remove unnecessary file systems
3. Disable unused device drivers
4. Optimize for specific USB keyboard usage
5. Tune suspend/resume for typewriter use

## Build System
- Uses Android NDK r23c with LLVM toolchain
- Cross-compilation for ARM
- Produces uImage format for U-Boot

## Next Steps
1. Create custom defconfig for typewriter use
2. Document any configuration changes
3. Test thoroughly on actual hardware
4. Consider security implications of old kernel