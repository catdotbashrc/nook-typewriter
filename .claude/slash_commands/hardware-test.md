---
description: Test hardware compatibility and graceful degradation
tools: ["Bash", "Read", "Grep", "Glob"]
---

# Hardware Compatibility Testing

Verify the Nook typewriter handles both real hardware and Docker environments gracefully. The system must work perfectly on actual Nooks while degrading gracefully in development.

## Testing Areas

### 1. E-Ink Display Handling
Verify FBInk integration works correctly:
- All FBInk commands have `|| true` fallbacks
- Menu system handles missing display
- Error messages are suppressed appropriately
- No infinite loops when display unavailable

Check patterns in scripts:
```bash
# GOOD: Graceful fallback
fbink -c || true
fbink -y 3 "Message" || echo "Message"

# BAD: Will fail in Docker
fbink -c
fbink -y 3 "Message"
```

### 2. USB Keyboard Support
Validate keyboard handling:
- Kernel configuration includes USB host mode
- Power requirements documented (< 100mA)
- OTG cable requirements clear
- Wireless keyboard limitations noted

Key areas to check:
- Kernel version requirements (174+)
- USB host patches applied
- Power management considerations
- Keyboard detection scripts

### 3. SD Card Compatibility
Verify SD card handling:
- Partition requirements (FAT32 + F2FS)
- Size recommendations (8-32GB)
- Boot configuration correct
- Speed class considerations

### 4. Power Management
Check power efficiency:
- WiFi disabled by default
- CPU governor settings
- Sleep/suspend handling
- Battery life estimates

### 5. QuillKernel Features
Test medieval kernel features:
- `/proc/squireos` interface
- Typewriter statistics module
- Achievement system
- Jester ASCII art

## Docker vs Hardware Testing

### Must Work in Docker
- Vim configuration
- Script logic flow
- Menu navigation
- File operations
- Build process

### Hardware-Only Features
- E-Ink display refresh
- USB keyboard input
- WiFi connectivity
- Power management
- Special kernel features

## Graceful Degradation Patterns

Look for these patterns:

### Good Examples
```bash
# Display with fallback
fbink_message() {
    fbink -y "$1" "$2" 2>/dev/null || echo "$2"
}

# Hardware detection
if [ -e /dev/fb0 ]; then
    HAS_EINK=true
else
    HAS_EINK=false
fi

# Kernel feature check
if [ -d /proc/squireos ]; then
    cat /proc/squireos/motto
else
    echo "QuillKernel not detected"
fi
```

### Bad Examples
```bash
# No fallback
fbink -c
fbink -y 3 "Starting..."

# Assumes hardware exists
cat /proc/squireos/stats

# No error handling
mount /dev/mmcblk0p2 /mnt
```

## Test Commands

```bash
# Test E-Ink fallback
docker run --rm nook-system fbink -c || echo "✓ Fallback works"

# Check USB configuration
grep -r "USB_HOST\|USB_OTG" nst-kernel/

# Verify SD card instructions
grep -r "mmcblk0\|sdX" docs/

# Test QuillKernel features
docker run --rm nook-system cat /proc/squireos/motto 2>/dev/null || echo "✓ Handles missing gracefully"
```

## Critical Files

- `config/scripts/nook-menu.sh` - Main interface
- `nst-kernel/squire-kernel-patch.sh` - Kernel patches
- `docs/tutorials/01-first-nook-setup.md` - Hardware setup
- Boot configuration files
- All shell scripts using FBInk

## Success Criteria

The system succeeds if:
1. **Docker development works** without hardware
2. **Real Nooks work** with full features
3. **Error messages are clear** when hardware missing
4. **No crashes or loops** in any environment
5. **Writers aren't confused** by technical errors

Remember: Most development happens in Docker, but the final product runs on a 2011-era e-reader with severe constraints.