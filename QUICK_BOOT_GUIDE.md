# Quick Boot Guide - QuillKernel on Nook Simple Touch

## The Problem
Your current SD card at `~/nook-mount/` only has:
- `boot/uImage` - Our kernel
- `boot/uEnv.txt` - Boot config  
- `root/` - Root filesystem

**This won't boot** because it's missing the bootloaders (MLO and u-boot).

## The Solution: Use NookManager as Base

### Step 1: Get NookManager
```bash
# Download the proven bootable image
wget https://github.com/doozan/NookManager/releases/download/0.5.0/NookManager-0.5.0.img.gz
gunzip NookManager-0.5.0.img.gz
```

### Step 2: Write to SD Card
```bash
# Find your SD card device (check carefully!)
lsblk

# Write the complete image (replace sdX with your device)
sudo dd if=NookManager-0.5.0.img of=/dev/sdX bs=4M status=progress
sync
```

### Step 3: Test NookManager First
1. Insert SD card into Nook
2. Power on - should boot to NookManager menu
3. This confirms SD card boot works

### Step 4: Replace Kernel with QuillKernel
```bash
# Mount the SD card (it will show as multiple partitions)
# Find the boot partition (usually first, FAT partition)
mount /dev/sdX1 /mnt

# Backup original kernel
sudo cp /mnt/uImage /mnt/uImage.backup

# Copy our QuillKernel
sudo cp firmware/boot/uImage /mnt/uImage

# Unmount
sudo umount /mnt
```

### Step 5: Boot Test
1. Insert modified SD card into Nook
2. Power on
3. Should boot with QuillKernel

## What You'll See

### Success Signs:
- Kernel boot messages on screen
- JesterOS jester might appear (if display works)
- System boots to some interface

### Failure Signs:
- Black screen → Bootloader issue
- Boot loop → Kernel panic
- Stuck at logo → Kernel OK but rootfs issue

## Recovery
- **Always**: Just remove SD card to boot normally
- **If needed**: Restore backup kernel on SD card

## Why This Works
NookManager provides:
- ✅ MLO (first-stage bootloader)
- ✅ u-boot (second-stage bootloader)
- ✅ Proper partition structure
- ✅ Correct boot configuration

We're just replacing the kernel, keeping everything else that works.

## Next Steps After Success
1. Extract MLO and u-boot from NookManager
2. Create minimal QuillKernel-specific image
3. Remove unnecessary NookManager components

---

**Bottom Line**: Don't try to boot from your current `~/nook-mount/` setup. Use NookManager as a proven base first.