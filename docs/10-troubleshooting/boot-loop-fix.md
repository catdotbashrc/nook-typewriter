# Boot Loop Fix Documentation - Issue #18

## Problem Summary
JoKernel v1.0.0 enters an endless boot loop when using ClockworkMod's recovery initrd (uRamdisk). The kernel loads but crashes immediately after showing the boot logo.

## Root Cause
The 2011-era CWM initrd is incompatible with our 2025 JoKernel. The kernel expects different initrd structures and fails when trying to use the old recovery filesystem.

## Solution Overview
Boot the kernel directly without an initrd, using the rootfs on partition 2 instead.

## Fix Implementation

### Method 1: Quick Fix (If SD card is already prepared)
```bash
# Mount the SD card boot partition
sudo mount /dev/sdX1 /tmp/cwm_boot

# Run the fix script
./fix-boot-loop.sh

# Unmount and test
sync
sudo umount /tmp/cwm_boot
```

### Method 2: Complete SD Card Creation
```bash
# Use the new SD creator script
sudo ./create-mvp-sd.sh /dev/sdX
```

## Technical Changes

### Original Boot Script (BROKEN)
```bash
run setbootargs
mmcinit 0
mmcinit 1
fatload mmc 0 0x81c00000 uImage      # Load kernel
fatload mmc 0 0x81f00000 uRamdisk    # Load incompatible initrd
bootm 0x81c00000 0x81f00000          # Boot with both = CRASH
```

### Fixed Boot Script (WORKING)
```bash
setenv bootargs 'console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rw init=/init noinitrd'
mmcinit 0
mmcinit 1
fatload mmc 0 0x81c00000 uImage      # Load kernel only
bootm 0x81c00000                     # Boot without initrd = SUCCESS
```

### Key Changes
1. **No uRamdisk loading** - Removed the problematic initrd
2. **Direct root mount** - Boot args point to `/dev/mmcblk0p2`
3. **noinitrd flag** - Explicitly tell kernel not to expect initrd
4. **init=/init** - Specify init program location

## Testing Procedure

### Pre-Test Checklist
- [ ] SD card has CWM base image
- [ ] JoKernel uImage copied to boot partition
- [ ] Boot script updated (no uRamdisk)
- [ ] Minimal init created on partition 2

### Boot Test Steps
1. Insert SD card into Nook
2. Power off Nook completely (hold power 10 seconds)
3. Power on Nook
4. Watch for boot messages

### Success Indicators
- ✅ MLO loads (quick flash)
- ✅ U-Boot loads (boot messages appear)
- ✅ Kernel loads (penguin logo or boot text)
- ✅ "JOKERNEL BOOTED SUCCESSFULLY!" message
- ✅ System stays running (no reboot)

### Failure Indicators
- ❌ Screen flashes repeatedly (boot loop)
- ❌ Device reboots after logo
- ❌ Black screen after 30 seconds
- ❌ Watchdog reset messages

## Troubleshooting

### If boot loop continues:
1. **Verify kernel image**:
   ```bash
   file firmware/boot/uImage
   # Should show: "u-boot legacy uImage, Linux-2.6.29..."
   ```

2. **Check boot script compilation**:
   ```bash
   mkimage -l /tmp/cwm_boot/boot.scr
   # Should show script details
   ```

3. **Ensure rootfs has init**:
   ```bash
   ls -la /tmp/cwm_root/init
   # Should exist and be executable
   ```

### Serial Console Debug (Advanced)
If you have UART access:
```bash
# Connect at 115200 8N1
# Watch for kernel panic messages
# Check where boot fails
```

## Next Steps After Fix

Once boot loop is fixed:

1. **Add full rootfs**:
   ```bash
   # Extract Debian minimal rootfs
   sudo tar -xzf nook-mvp-rootfs.tar.gz -C /mnt/sd_root/
   ```

2. **Install kernel modules**:
   ```bash
   # Copy JokerOS modules
   cp *.ko /mnt/sd_root/lib/modules/2.6.29/
   ```

3. **Add menu system**:
   ```bash
   # Install boot scripts
   cp firmware/boot/*.sh /mnt/sd_root/boot/
   ```

4. **Test writing environment**:
   - Boot to menu
   - Launch vim
   - Verify E-Ink display

## Issue Resolution

When boot loop is fixed:

1. Test boot 3 times to ensure consistency
2. Document working configuration
3. Update Issue #18 with results:
   ```bash
   gh issue comment 18 --body "Boot loop FIXED! 
   
   Solution: Removed incompatible CWM initrd, boot kernel directly.
   
   Test results:
   - Kernel boots successfully
   - No watchdog resets
   - System stable
   
   See BOOT_LOOP_FIX.md for details."
   ```

4. Close issue:
   ```bash
   gh issue close 18
   ```

## Prevention

To avoid future boot issues:
- Never mix old initrd with new kernel
- Test boot configuration in stages
- Keep boot scripts simple
- Document all boot parameters

## Related Files
- `fix-boot-loop.sh` - Quick fix script
- `create-mvp-sd.sh` - Complete SD creator
- `/tmp/cwm_boot/boot.scr` - Compiled boot script
- `firmware/boot/uImage` - JoKernel image

---

*Boot loop begone! The jester shall dance, not spin in circles!*