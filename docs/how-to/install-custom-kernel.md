# How to Install a Custom Kernel

This guide shows you how to install a USB host kernel on your Nook Simple Touch, enabling keyboard support.

## Prerequisites

- Rooted Nook Simple Touch
- MicroSD card (any size)
- ClockworkMod Recovery installed
- USB host kernel file (.zip)

## Getting a Kernel

### Option 1: Download Pre-built

1. Visit [XDA Forums Nook Touch section](https://forum.xda-developers.com/c/barnes-noble-nook-touch.1129/)
2. Search for "USB host kernel"
3. Recommended kernels:
   - **mali100 kernel** (version 174+)
   - **Guevor kernel** (stable)
   - **latuk kernel** (good battery)

### Option 2: Build Your Own

See [Building a Custom Kernel](build-custom-kernel.md) guide.

## Installation Steps

### Step 1: Prepare Recovery SD Card

If you don't have ClockworkMod Recovery:

1. Download [CWM Recovery for NST](https://forum.xda-developers.com/t/cwm-based-recovery-for-nst.1360994/)
2. Extract the `.img` file
3. Write to SD card:
   ```bash
   sudo dd if=cwm-recovery.img of=/dev/sdX bs=4M
   ```

### Step 2: Copy Kernel to SD Card

1. Mount the SD card on your computer
2. Copy kernel zip to root directory
3. Safely eject SD card

### Step 3: Boot into Recovery

1. Power off your Nook completely
2. Insert recovery SD card
3. Power on - CWM Recovery will load
4. You'll see recovery menu

### Step 4: Create Backup (Important!)

Before installing:

1. Select "backup and restore"
2. Choose "backup"
3. Wait for backup to complete
4. This saves your working kernel!

### Step 5: Install Kernel

1. Select "install zip from sdcard"
2. Choose "choose zip from sdcard"
3. Navigate to your kernel zip
4. Select it and confirm "Yes"
5. Wait for installation
6. You'll see "Install complete"

### Step 6: Reboot

1. Go back to main menu
2. Select "reboot system now"
3. Remove SD card when prompted
4. Nook will boot with new kernel

## Verifying Installation

### Check Kernel Version

1. Boot your Nook typewriter
2. From menu, press 7 (Terminal)
3. Type: `uname -r`
4. Should show new kernel version

### Test USB Host

1. Connect USB keyboard via OTG cable
2. Try typing - should work immediately
3. If not, try different OTG cable

## Troubleshooting

### Boot Loop After Install

1. Boot with recovery SD card
2. Select "backup and restore"
3. Choose "restore"
4. Select your backup
5. Reboot

### Keyboard Still Not Working

Check these:
- Kernel version must be 166+ for USB host
- OTG cable must be proper type
- Try powered hub for some keyboards
- Test with different keyboard

### Black Screen on Boot

1. Wait 60 seconds (kernel may be loading)
2. If still black, boot recovery
3. Restore backup
4. Try different kernel

## Kernel Options Explained

### FastMode Kernels
- Faster E-Ink refresh
- More battery drain
- Good for active use

### Standard Kernels
- Normal refresh rate
- Better battery life
- Recommended for writing

### Overclocked Kernels
- CPU runs faster
- More responsive
- Significantly worse battery

## Making Kernel Persistent

To survive factory resets:

1. Boot with NookManager
2. Copy uImage to `/boot/`
3. Edit `/boot/menu.lst`
4. Add kernel entry

## SD Card Boot Deployment

For the Nook Typewriter project, you'll typically deploy QuillKernel to an SD card for non-destructive booting:

### QuillKernel on SD Card

1. **Build QuillKernel** (if not already built):
   ```bash
   cd nook/nst-kernel
   ./squire-kernel-patch.sh  # Apply medieval patches
   docker build -f Dockerfile.build -t quillkernel .
   
   # Extract kernel from container
   docker create --name kernel-extract quillkernel
   docker cp kernel-extract:/build/uImage ./build/
   docker rm kernel-extract
   ```

2. **Prepare SD Card** (if not already done):

   ```bash
   # Create 100MB FAT32 boot + F2FS root partitions
   sudo fdisk /dev/sdX  # Follow partitioning steps
   sudo mkfs.vfat -F32 /dev/sdX1
   sudo mkfs.f2fs /dev/sdX2
   ```

3. **Deploy Kernel to Boot Partition**:

   ```bash
   # Mount boot partition
   sudo mkdir -p /mnt/boot
   sudo mount /dev/sdX1 /mnt/boot
   
   # Copy QuillKernel
   sudo cp build/uImage /mnt/boot/
   
   # Create boot config
   cat << 'EOF' | sudo tee /mnt/boot/uEnv.txt
   bootargs=console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=f2fs rw rootwait mem=256M
   bootcmd=mmc rescan; fatload mmc 0:1 0x80300000 uImage; bootm 0x80300000
   EOF
   
   # Unmount
   sudo umount /mnt/boot
   ```

4. **Deploy Root Filesystem** (if creating full system):

   ```bash
   # Mount root partition
   sudo mount /dev/sdX2 /mnt/root
   
   # Extract Debian system
   sudo tar -xzf nook-writer.tar.gz -C /mnt/root/
   
   sudo umount /mnt/root
   ```

### Pre-built Kernel on SD Card

If using a pre-built kernel:

1. Extract `uImage` from the kernel zip file
2. Copy to SD card's boot partition as shown above
3. Ensure filename is exactly `uImage` (case sensitive)

## Advanced: Multi-Boot

Set up kernel selection menu:

1. Install U-Boot menu
2. Add multiple kernels
3. Choose at boot time

See [Advanced Kernel Setup](advanced-kernel-setup.md).

## Safety Tips

1. **Always backup first**
2. Keep working kernel on separate SD
3. Don't install random kernels
4. Test thoroughly before deleting backups
5. Document which kernel works

## Quick Command Reference

```bash
# Check current kernel
uname -r

# View kernel messages  
dmesg | less

# Check USB devices
lsusb

# Monitor system
top
```

---

⚠️ **Remember**: A bad kernel can prevent booting. Always keep backups and a recovery method ready!
**ONLY YOU CAN PREVENT KERNEL PANICS!**
