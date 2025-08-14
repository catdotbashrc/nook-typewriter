# Deployment Updates - Critical Corrections

*Last Updated: August 2025*  
*Based on XDA Community Research and Testing*

## ⚠️ Critical Changes Required

### 1. Toolchain Update (URGENT)
**Issue**: NDK r10e with GCC 4.8 causes boot loops on real Nook hardware  
**Solution**: Must switch to NDK r12b with GCC 4.9 (see Issue #8)  
**Impact**: Current kernel builds may not boot on actual devices

### 2. Boot Configuration Corrections

#### Previous (INCORRECT) Configuration
```bash
# This was wrong - will not boot
bootargs=console=ttymxc0,115200 root=/dev/mmcblk0p2 rootwait rw
```

#### Corrected Configuration
```bash
# CORRECT for Nook Simple Touch
bootargs=console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait rw init=/init
bootcmd=fatload mmc 0:1 0x70008000 uImage; bootm 0x70008000
uenvcmd=run bootcmd
```

**Key Corrections**:
- Console device: `ttyS0` (NOT `ttymxc0`)
- Memory address: `0x70008000` (verified by XDA)
- Init path: `/init` (required for MVP rootfs)

## 📝 Updated Deployment Process

### Prerequisites
- Nook Simple Touch device
- SD card (2GB minimum, Class 10 recommended)
- Linux environment with Docker
- USB SD card reader

### Step 1: Prepare SD Card

#### Windows Users (Recommended Tools)
1. **MiniTool Partition Wizard Free** - Best for partitioning
2. **DiskGenius Free** - Can write to ext4 partitions
3. **WSL2** - For Linux commands and file operations

#### Partition Layout
- Partition 1: 100MB FAT16 (label: NOOK_BOOT)
- Partition 2: Remaining space ext4 (label: NOOK_ROOT)

### Step 2: Build System Components

```bash
# Build kernel (currently uses NDK r10e - needs update)
./build_kernel.sh

# Build minimal rootfs
docker build -t nook-mvp-rootfs -f build/docker/minimal-boot.dockerfile .

# Export rootfs
docker create --name nook-export nook-mvp-rootfs
docker export nook-export | gzip > nook-mvp-rootfs.tar.gz
docker rm nook-export
```

### Step 3: Deploy to SD Card (WSL/Linux)

```bash
# Mount partitions
sudo mount /dev/sde1 ~/nook-mount/boot
sudo mount /dev/sde2 ~/nook-mount/root

# Copy kernel
sudo cp firmware/boot/uImage ~/nook-mount/boot/

# Create CORRECT boot configuration
sudo tee ~/nook-mount/boot/uEnv.txt << 'EOF'
bootargs=console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait rw init=/init
bootcmd=fatload mmc 0:1 0x70008000 uImage; bootm 0x70008000
uenvcmd=run bootcmd
EOF

# Extract rootfs
sudo tar -xzf nook-mvp-rootfs.tar.gz -C ~/nook-mount/root/

# Create modules directory
sudo mkdir -p ~/nook-mount/root/lib/modules/2.6.29

# Copy SquireOS modules (if available)
sudo find source/kernel/src/drivers/squireos -name "*.ko" \
  -exec cp {} ~/nook-mount/root/lib/modules/ \; 2>/dev/null || \
  echo "Modules not built yet - rebuild kernel after Makefile fix"

# Sync and unmount
sync
sudo umount ~/nook-mount/boot
sudo umount ~/nook-mount/root
```

### Step 4: Boot on Nook

1. **Power off** Nook completely
2. **Insert** SD card into Nook
3. **Hold both page-turn buttons** while pressing power button
4. **Watch for boot messages** on E-Ink display
5. **Expected result**: QuillKernel MVP menu appears

## 🔧 Troubleshooting

### Boot Loops or Kernel Panic
**Cause**: Using wrong toolchain (NDK r10e with GCC 4.8)  
**Solution**: Wait for Issue #8 implementation, rebuild with NDK r12b

### "No boot device" or SD Card Not Detected
**Cause**: Incorrect partition format or boot files  
**Solution**: 
- Ensure FAT16 (not FAT32) for boot partition
- Verify `uImage` is in root of boot partition
- Check `uEnv.txt` has correct format (Unix line endings)

### Console Shows Nothing
**Cause**: Wrong console device in bootargs  
**Solution**: Must use `console=ttyS0,115200` not `ttymxc0`

### Kernel Loads but Hangs
**Cause**: Missing or incorrect init process  
**Solution**: Ensure `init=/init` in bootargs and `/init` exists in rootfs

## 🚀 Next Steps

### Immediate Actions
1. **Switch toolchain** to NDK r12b (Issue #8)
2. **Rebuild kernel** with correct toolchain
3. **Fix SquireOS modules** compilation (source/kernel/src/drivers/Makefile)
4. **Test on hardware** with corrected boot configuration

### MVP Validation Checklist
- [ ] Kernel builds with NDK r12b
- [ ] SD card boots without loops
- [ ] Console output visible (ttyS0)
- [ ] Init process starts
- [ ] MVP menu appears
- [ ] SquireOS modules load (if included)

## 📚 References

- [XDA Research Findings](./XDA-RESEARCH-FINDINGS.md)
- [Original Deployment Guide](./DEPLOYMENT_INTEGRATION_GUIDE.md)
- [Issue #8: Toolchain Switch](https://github.com/catdotbashrc/nook-typewriter/issues/8)
- felixhaedicke/nst-kernel - Proven working configuration

## ⚠️ Known Issues

1. **Current kernel may not boot** - Built with wrong toolchain
2. **SquireOS modules not compiling** - Makefile path issue (fixed in source)
3. **USB keyboard support** - Not yet implemented (Issue #6)
4. **No automated image builder** - Manual SD card preparation required (Issue #7)

---

*This document supersedes previous deployment instructions with critical corrections from XDA community testing*