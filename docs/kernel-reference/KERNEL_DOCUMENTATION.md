# 🏰 JesterOS Userspace Documentation

*Updated: August 14, 2025*

## Overview

JesterOS has transitioned from kernel modules to a lightweight userspace implementation. This change simplifies installation, improves reliability, and eliminates kernel compilation complexity while maintaining all the whimsical features writers love.

> **Important**: The kernel module approach described in older documentation is now deprecated. JesterOS runs entirely in userspace via shell scripts and creates its interface at `/var/jesteros/`.

---

## 📋 Table of Contents

1. [Architecture Changes](#architecture-changes)
2. [Userspace Implementation](#userspace-implementation)
3. [Installation](#installation)
4. [Interface Reference](#interface-reference)
5. [Service Management](#service-management)
6. [Migration from Kernel Modules](#migration-from-kernel-modules)
7. [Troubleshooting](#troubleshooting)

---

## 🏗️ Architecture Changes

### From Kernel to Userspace

**Old Approach (Deprecated)**:
- Custom kernel modules (`jokeros_core.ko`, `jester.ko`, etc.)
- Required kernel compilation with cross-compiler
- Created `/proc/jokeros/` interface
- Complex build process with Android NDK

**New Approach (Current)**:
- Simple shell scripts in userspace
- No kernel compilation needed
- Creates `/var/jesteros/` interface
- Easy installation with `install-jesteros-userspace.sh`

### Benefits of Userspace

1. **Simplicity**: No kernel compilation or cross-compilation toolchain needed
2. **Safety**: Can't crash the kernel or cause boot failures
3. **Portability**: Works on any Linux system with bash
4. **Debugging**: Easier to debug and modify shell scripts
5. **Performance**: Minimal overhead (~10KB memory usage)

---

## 🎭 Userspace Implementation

### Core Components

**Main Service** (`jesteros-userspace.sh`):
- Creates `/var/jesteros/` directory structure
- Manages jester moods and displays
- Handles writing statistics tracking
- Provides wisdom quotes

**Tracker Service** (`jesteros-tracker.sh`):
- Monitors keyboard input
- Updates writing statistics
- Tracks achievements and milestones

**Display Scripts**:
- `jester-splash.sh` - Terminal jester display
- `jester-splash-eink.sh` - E-Ink optimized display
- `jester-dance.sh` - Animated jester sequences

### File System Interface

```
/var/jesteros/
├── jester           # ASCII art jester (changes mood)
├── typewriter/
│   └── stats        # Writing statistics
└── wisdom           # Rotating quotes
```

---

## 📦 Installation

### Quick Install

```bash
# System-wide installation (requires root)
sudo ./install-jesteros-userspace.sh

# User-mode installation (for testing)
./install-jesteros-userspace.sh --user
```

### Manual Installation

```bash
# Create directories
sudo mkdir -p /var/jesteros/typewriter
sudo mkdir -p /usr/local/bin

# Copy scripts
sudo cp source/scripts/boot/jesteros-userspace.sh /usr/local/bin/
sudo cp source/scripts/services/jesteros-tracker.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/jesteros-*.sh

# Add to boot sequence
sudo cp source/configs/system/jesteros.init /etc/init.d/jesteros
sudo update-rc.d jesteros defaults
```

---

## 📖 Interface Reference

### `/var/jesteros/jester`

Displays ASCII art jester with dynamic moods based on system state.

**Moods**:
- Happy (😊) - Normal operation, good writing progress
- Thoughtful (🤔) - System idle, waiting for input
- Excited (🎉) - Milestone achieved
- Tired (😴) - Low battery or late hour

**Example**:
```bash
cat /var/jesteros/jester
```

### `/var/jesteros/typewriter/stats`

Writing statistics in simple text format.

**Format**:
```
Words today: 1,234
Keystrokes: 5,678
Session time: 2h 15m
Achievement: Scribe (1000+ words)
```

**Example**:
```bash
cat /var/jesteros/typewriter/stats
```

### `/var/jesteros/wisdom`

Rotating inspirational quotes for writers.

**Example**:
```bash
cat /var/jesteros/wisdom
# "The pen is mightier than the sword" - Edward Bulwer-Lytton
```

---

## 🔧 Service Management

### Starting Services

```bash
# Start all JesterOS services
sudo systemctl start jesteros

# Or manually
/usr/local/bin/jesteros-userspace.sh &
```

### Checking Status

```bash
# Check if services are running
ps aux | grep jesteros

# View service logs
tail -f /var/log/jesteros.log
```

### Stopping Services

```bash
# Stop services
sudo systemctl stop jesteros

# Or manually
pkill -f jesteros
```

---

## 🔄 Migration from Kernel Modules

### For Users

If you have the old kernel modules installed:

1. **Remove old modules**:
   ```bash
   sudo rmmod wisdom typewriter jester jokeros_core
   ```

2. **Install userspace version**:
   ```bash
   sudo ./install-jesteros-userspace.sh
   ```

3. **Update scripts** that reference `/proc/jokeros/` to use `/var/jesteros/`

### For Developers

Update any code that references the old paths:

```bash
# Old (deprecated)
cat /proc/jokeros/jester

# New
cat /var/jesteros/jester
```

---

## 🐛 Troubleshooting

### Services Not Starting

```bash
# Check for errors
sudo journalctl -u jesteros -n 50

# Verify installation
ls -la /usr/local/bin/jesteros-*
ls -la /var/jesteros/
```

### No Jester Display

```bash
# Check if service is running
ps aux | grep jesteros-userspace

# Manually start for debugging
bash -x /usr/local/bin/jesteros-userspace.sh
```

### Statistics Not Updating

```bash
# Check tracker service
ps aux | grep jesteros-tracker

# Check permissions
ls -la /var/jesteros/typewriter/
```

### E-Ink Display Issues

```bash
# Test E-Ink support
which fbink

# Fallback to terminal mode
JESTEROS_DISPLAY=terminal /usr/local/bin/jester-splash.sh
```

---

## 📚 Legacy Documentation

For historical reference, the original kernel module documentation has been preserved but is no longer applicable to the current implementation. The kernel build system remains for core kernel updates but JesterOS features are now entirely userspace.

---

*"By quill and candlelight, now in userspace we write!"* 🕯️📜