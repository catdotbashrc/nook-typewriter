# Missing Nook Hardware Files Analysis
*Date: 2025-01-18*  
*Status: DRAFT - Investigation Notes*

## Critical Finding
Current JesterOS trying to boot Linux directly. Nook REQUIRES Android layer first!

## Missing Files Discovered

### Android Boot Layer (P0 - CRITICAL)
- [ ] `/init.rc` - Main Android init
- [ ] `/init.gossamer.rc` - OMAP3621 specific
- [ ] `/system/build.prop` - System properties  
- [ ] `/default.prop` - Default properties
- [ ] `/init` binary - Android init executable

**Source**: Can extract from NookManager.img

### E-Ink Display (P0 - CRITICAL)
- [ ] FBInk binary (ARM compiled)
- [ ] E-Ink kernel module
- [ ] Waveform data files
- [ ] Refresh control scripts

**Source**: Compile FBInk from GitHub

### Touch Controller (P0 - CRITICAL)
- [ ] `zforce.ko` kernel module
- [ ] `/data/misc/zforce/zforce.cal` calibration
- [ ] IR grid init scripts

**Source**: Extract from stock Nook firmware

### Power Management (P1 - HIGH)
- [ ] `batteryd` daemon
- [ ] Sleep/wake scripts
- [ ] CPU governor settings

**Source**: Stock firmware

## Extraction Commands

```bash
# Mount NookManager to extract Android files
sudo mount -o loop,offset=$((32*512)) images/NookManager.img /mnt/nook

# Extract init files
cp /mnt/nook/init* firmware/android-layer/

# Get system properties
cp -r /mnt/nook/system firmware/android-layer/
```

## FBInk Compilation

```bash
git clone https://github.com/NiLuJe/FBInk.git
cd FBInk
make CROSS_COMPILE=arm-linux-androideabi- MINIMAL=1
```

## Architecture Change Required

**Current**: U-Boot → Linux (FAILS - no hardware init)

**Required**: U-Boot → Android init → Hardware init → Chroot to Linux → JesterOS

## Next Steps
1. Extract Android layer from NookManager.img
2. Compile FBInk for ARM
3. Modify init.rc to launch Linux after hardware init
4. Test on actual device with ADB

---
*These are investigation notes, not final documentation*