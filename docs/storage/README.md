# Storage Documentation

## Overview

This directory contains documentation for JesterOS's resilient 4-partition storage architecture, providing enterprise-grade recovery capabilities while maximizing space for user writing.

## Documents

### [PARTITION_STRATEGY.md](PARTITION_STRATEGY.md)
Complete 4-partition SD card strategy with recovery architecture.

**Key Features:**
- System protection through read-only mounting
- Automatic recovery after failures
- User data preservation across all operations
- A/B update capability for safe upgrades
- 80%+ of storage dedicated to writing

## Quick Reference

### Partition Layout

| Partition | Size | Purpose | Mount |
|-----------|------|---------|-------|
| **BOOT** | 512MB | Bootloader, kernel, recovery flags | `/boot` |
| **SYSTEM** | 1.5GB | JesterOS root filesystem | `/` (read-only) |
| **RECOVERY** | 1.5GB | Factory image & recovery tools | Not mounted |
| **WRITING** | Remaining | User documents & data | `/home` (read-write) |

### Recovery Triggers

1. **Hardware**: Hold Power + Home during boot
2. **Software**: Create `/boot/RECOVERY_MODE` file
3. **Auto**: System recovers after 3 failed boots
4. **Menu**: Select from JesterOS system menu

### Critical Requirements

⚠️ **MUST start at sector 63** - Nook bootloader requirement  
⚠️ **MLO copied first** - Must be contiguous on disk  
⚠️ **File order matters** - MLO → u-boot → kernel → scripts

## Related Documentation

- [SD Card Boot Guide](../01-getting-started/sd-card-boot-guide.md) - Complete boot process
- [Build Guide](../02-build/jesteros-build-guide.md) - Building JesterOS
- [Deployment Guide](../07-deployment/deployment-documentation.md) - Installation procedures
- [Hardware Reference](../hardware/) - Device specifications

## Benefits

### For Writers
- **80%+ storage** for actual writing (12.9GB on 16GB card)
- **Data safety** - writings survive all system operations
- **No data loss** - factory reset preserves documents

### For Developers
- **Unbreakable** - multiple recovery layers
- **Safe updates** - test in recovery partition first
- **Easy rollback** - instant reversion if issues occur

### For Users
- **Simple recovery** - just hold two buttons
- **Auto-healing** - system fixes itself
- **Peace of mind** - always recoverable

## Implementation

### Creating an SD Card

```bash
# Automated (recommended)
wget https://jesteros.com/tools/create-4part-sdcard.sh
chmod +x create-4part-sdcard.sh
sudo ./create-4part-sdcard.sh /dev/sdX

# Manual (see PARTITION_STRATEGY.md for details)
```

### Entering Recovery

```bash
# Software method
touch /boot/RECOVERY_MODE
reboot

# Hardware method
Hold Power + Home during boot

# Will automatically trigger after 3 failed boots
```

### Factory Reset (Preserves Data)

From recovery menu:
1. Select "Factory Reset (keep writings)"
2. System restored to factory state
3. All documents in WRITING partition preserved

---

*Storage Architecture v2.0*  
*"Built to survive, designed to write"*  
*JesterOS Development Team*