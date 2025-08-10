# System Requirements

Complete hardware and software requirements for the Nook typewriter system.

## Hardware Requirements

### Essential Hardware

| Component | Requirement | Notes |
|-----------|-------------|-------|
| **E-Reader** | Barnes & Noble Nook Simple Touch | Model BNRV300 only |
| **SD Card** | 8GB minimum, 16GB recommended | Class 10 for best performance |
| **USB OTG Cable** | Micro-USB OTG adapter | Must support host mode |
| **Keyboard** | USB keyboard (wired) | Low power consumption preferred |

### Recommended Hardware

| Component | Recommendation | Reason |
|-----------|----------------|--------|
| **SD Card** | SanDisk 16GB Class 10 | Reliable, good F2FS support |
| **Keyboard** | Dell/Logitech wired USB | Known low power draw |
| **USB Hub** | Powered 4-port hub | For wireless keyboards |
| **Card Reader** | USB 3.0 reader | Faster image deployment |

### Optional Hardware

- **Wireless Keyboard**: Requires powered USB hub
- **USB Light**: For night writing (very low power)
- **Protective Case**: With keyboard storage
- **Extra SD Cards**: For different setups

## Nook Specifications

### Model Compatibility

| Model | Compatible | Notes |
|-------|------------|-------|
| Nook Simple Touch (NST) | ✅ Yes | Full support |
| Nook Simple Touch GlowLight | ⚠️ Maybe | Untested, should work |
| Nook Color | ❌ No | Different architecture |
| Nook Tablet | ❌ No | Different architecture |
| Other Nooks | ❌ No | ARM64 or different SoC |

### Hardware Specifications

| Component | Specification |
|-----------|---------------|
| **CPU** | TI OMAP 3621 @ 800 MHz |
| **Architecture** | ARMv7 (32-bit) |
| **RAM** | 256MB LPDDR |
| **Storage** | 2GB internal + microSD slot |
| **Display** | 6" Pearl E-Ink, 800x600, 16-level grayscale |
| **WiFi** | 802.11 b/g/n (2.4GHz only) |
| **USB** | Micro-USB (OTG capable with kernel) |
| **Battery** | 1500 mAh Li-ion |

## Software Requirements

### For Building

| Software | Version | Purpose |
|----------|---------|---------|
| **Docker** | 20.10+ | Container runtime |
| **Docker Compose** | 2.0+ | Multi-container management |
| **Git** | Any recent | Source code management |
| **Host OS** | Linux/Mac/Windows | Any with Docker support |

### Build Resources

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| **RAM** | 2GB | 4GB+ |
| **Storage** | 2GB free | 5GB free |
| **Internet** | Required | Fast connection |
| **Time** | 20 minutes | 10 minutes |

## Kernel Requirements

### USB Host Support

The stock Nook kernel lacks USB host mode. You need:

| Kernel Version | USB Support | Source |
|----------------|-------------|---------|
| Stock | ❌ No | Pre-installed |
| 166 | ❌ No | Early custom |
| 174+ | ✅ Yes | XDA Forums |
| nst-kernel | ✅ Yes | GitHub |

### Kernel Features Required

```
CONFIG_USB=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_OTG=y
CONFIG_USB_HID=y
```

## SD Card Requirements

### Partitioning

| Partition | Size | Format | Purpose |
|-----------|------|--------|---------|
| 1 (Boot) | 100MB | FAT32 | Kernel & boot files |
| 2 (Root) | Remaining | F2FS | Linux system |

### File System Support

| FS Type | Support | Notes |
|---------|---------|-------|
| FAT32 | Required | Boot partition |
| F2FS | Recommended | Best for flash |
| ext4 | Works | Slower on SD |
| NTFS | ❌ No | Don't use |

### SD Card Brands

Tested and working:
- SanDisk (all models)
- Samsung EVO
- Kingston
- Lexar

Problematic:
- Some generic brands
- Very old cards (<Class 4)

## Network Requirements

### WiFi Networks

| Type | Support | Notes |
|------|---------|-------|
| WPA2 | ✅ Yes | Recommended |
| WPA | ✅ Yes | Works |
| WEP | ✅ Yes | Not secure |
| Open | ✅ Yes | No password |
| WPA3 | ❌ No | Too new |
| 5GHz | ❌ No | 2.4GHz only |

### Cloud Services

For sync functionality:

| Service | Requirements |
|---------|--------------|
| Google Drive | Google account + app password |
| Dropbox | Account + API token |
| Custom | WebDAV or SSH server |

## Power Requirements

### USB Power Budget

The Nook provides limited USB power:

| Device | Power Draw | Works? |
|--------|------------|--------|
| Wired keyboard | 50-100mA | ✅ Yes |
| Wireless receiver | 100-250mA | ⚠️ Maybe |
| USB hub (unpowered) | 100mA+ | ❌ No |
| USB hub (powered) | 0mA | ✅ Yes |

### Battery Life Estimates

| Usage | Battery Life |
|-------|--------------|
| Writing only | 20-30 hours |
| With WiFi | 12-15 hours |
| Standby | 2-3 weeks |
| With backlight | N/A (NST has none) |

## System Limits

### Memory Constraints

| Component | Memory Use |
|-----------|------------|
| Kernel | ~15MB |
| Base system | ~80MB |
| Vim + plugins | ~10MB |
| Free for writing | ~150MB |

### Storage Limits

| Storage | Capacity | Usage |
|---------|----------|-------|
| Internal | 2GB | Original Nook OS |
| SD Card | 8-32GB | Linux system + documents |
| Per file | <100MB | E-Ink refresh limits |

### Performance Limits

| Operation | Limit | Impact |
|-----------|-------|--------|
| File save | <1 sec | Up to 1MB |
| Screen refresh | 0.5 sec | Full refresh |
| Boot time | 20-30 sec | From power on |
| App launch | 1-3 sec | Vim startup |

## Version Compatibility

### Debian Version

| Version | Status | Notes |
|---------|--------|-------|
| Debian 11 (Bullseye) | ✅ Current | Full support |
| Debian 12 (Bookworm) | ⚠️ Untested | Should work |
| Debian 10 (Buster) | ✅ Works | Older packages |
| Ubuntu | ⚠️ Maybe | Not tested |

### Software Versions

| Software | Version | Notes |
|----------|---------|-------|
| Vim | 8.2+ | With Python3 support |
| FBInk | Latest | Compiled from source |
| rclone | 1.53+ | For cloud sync |
| bash | 5.0+ | Menu system |

## Pre-Flight Checklist

Before starting, verify you have:

- [ ] Nook Simple Touch (charged)
- [ ] MicroSD card (8GB+)
- [ ] SD card reader
- [ ] USB OTG cable
- [ ] USB keyboard
- [ ] Computer with Docker
- [ ] Internet connection
- [ ] 1 hour of time

Missing any requirement? Check [alternatives](../how-to/work-with-limitations.md).

---

📋 **Quick Check**: Nook Simple Touch + 8GB SD card + USB keyboard + Docker = Ready to build!