# 📜 Nook Typewriter Scripts Catalog

*Generated: December 13, 2024*

## Overview

The Nook Typewriter project includes a comprehensive collection of shell scripts organized into boot sequences, menu systems, services, and utility libraries. All scripts follow strict safety standards with input validation, error handling, and E-Ink display abstraction.

---

## 📋 Table of Contents

1. [Script Organization](#script-organization)
2. [Common Library](#common-library)
3. [Boot Scripts](#boot-scripts)
4. [Menu System](#menu-system)
5. [Service Daemons](#service-daemons)
6. [Utility Scripts](#utility-scripts)
7. [Script Standards](#script-standards)
8. [Dependencies](#dependencies)
9. [Error Handling](#error-handling)
10. [Testing Guidelines](#testing-guidelines)

---

## 📁 Script Organization

```
source/scripts/
├── lib/                    # Common libraries and functions
│   └── common.sh          # Shared functions and safety settings
├── boot/                  # Boot sequence scripts
│   ├── boot-jester.sh     # Main boot with jester display
│   ├── squireos-boot.sh   # System boot orchestrator
│   ├── squireos-init.sh   # System initialization
│   ├── load-squireos-modules.sh  # Kernel module loader
│   └── init.d/
│       └── squireos-modules  # SysV init script
├── menu/                  # Interactive menu systems
│   ├── nook-menu.sh       # Main writing menu
│   ├── nook-menu-zk.sh    # Zettelkasten menu
│   ├── nook-menu-plugin.sh # Plugin manager menu
│   └── squire-menu.sh     # Medieval-themed menu
├── services/              # Background services
│   ├── jester-daemon.sh   # Jester mood service
│   └── health-check.sh    # System health monitor
└── create-cwm-sdcard.sh   # SD card creation utility
```

---

## 🔧 Common Library

### `lib/common.sh`

**Purpose**: Shared functions and safety settings for all scripts

**Key Features**:
- Shell safety settings (`set -euo pipefail`)
- Error handling with context
- Input validation functions
- E-Ink display abstraction
- Common constants and paths

**Exported Functions**:

```bash
# Error handling
error_handler()         # Enhanced error handler with context
debug_log()             # Debug logging with timestamps

# Validation
validate_menu_choice()  # Validate numeric menu input
validate_path()         # Check path safety
var_exists()           # Safe variable existence check

# Display abstraction
has_eink()             # Check for E-Ink display
display_text()         # Display with E-Ink support
clear_display()        # Clear E-Ink or terminal
show_jester()          # Display jester ASCII art
e_sleep()              # E-Ink aware sleep

# File operations
safe_mkdir()           # Create directory with validation
safe_write()           # Write file with validation
```

**Constants**:
```bash
# Timing
BOOT_DELAY=2
MENU_TIMEOUT=3
JESTER_UPDATE_INTERVAL=30
QUICK_DELAY=0.3
MEDIUM_DELAY=0.8
LONG_DELAY=2

# Paths
SQUIREOS_PROC="/proc/squireos"
JESTER_DIR="/var/lib/jester"
NOTES_DIR="/root/notes"
DRAFTS_DIR="/root/drafts"
SCROLLS_DIR="/root/scrolls"
```

**Safety Flag**: `SQUIREOS_COMMON_LOADED=1` (set when loaded)

---

## 🚀 Boot Scripts

### `boot/boot-jester.sh`

**Purpose**: Main boot script with jester display

**Execution Flow**:
1. Source common library
2. Initialize E-Ink display
3. Load JesterOS kernel modules
4. Display jester ASCII art
5. Show system information
6. Launch menu system

**Key Functions**:
```bash
init_display()           # Initialize E-Ink display
load_jokeros_modules()   # Load kernel modules in order
show_system_info()       # Display system status
launch_menu()           # Start main menu system
```

**Module Loading Order**:
1. `jokeros_core.ko` (required first)
2. `jester.ko`
3. `typewriter.ko`
4. `wisdom.ko`

**Exit Codes**:
- 0: Success
- 1: Display initialization failed
- 2: Module loading failed

### `boot/squireos-boot.sh`

**Purpose**: System boot orchestrator

**Features**:
- Service startup coordination
- Network isolation enforcement
- Memory optimization
- Power management setup

**Boot Sequence**:
1. Mount essential filesystems
2. Configure network isolation
3. Set CPU governor
4. Load kernel modules
5. Start services
6. Display boot complete message

### `boot/squireos-init.sh`

**Purpose**: Early system initialization

**Tasks**:
- Create required directories
- Set permissions
- Initialize proc filesystem
- Configure terminal
- Prepare writing environment

### `boot/load-squireos-modules.sh`

**Purpose**: Kernel module management

**Features**:
- Dependency checking
- Module verification
- Load status reporting
- Fallback handling

**Module Dependencies**:
```bash
# Core modules (load first)
jokeros_core.ko

# Feature modules (load after core)
jester.ko
typewriter.ko
wisdom.ko
```

---

## 📱 Menu System

### `menu/nook-menu.sh`

**Purpose**: Main interactive writing menu

**Menu Options**:
- [Z] Zettelkasten Mode - Note-taking system
- [D] Draft Mode - Full-screen writing
- [R] Resume Session - Continue last document
- [S] Sync Notes - Synchronize with backup
- [J] Visit the Jester - Show jester status
- [Q] Shutdown - Safe system shutdown

**Key Functions**:
```bash
display_menu()          # Show menu on E-Ink
get_user_choice()       # Get input with timeout
launch_zettelkasten()   # Start ZK mode
launch_draft_mode()     # Start draft writing
resume_last_session()   # Open last document
sync_notes()           # Run sync process
visit_jester()         # Display jester mood
```

**Configuration**:
```bash
MENU_TIMEOUT=30        # Seconds before timeout
NOTES_DIR=$HOME/notes
DRAFTS_DIR=$HOME/drafts
```

### `menu/nook-menu-zk.sh`

**Purpose**: Zettelkasten note-taking menu

**Features**:
- Create new notes with timestamps
- Browse existing notes
- Search by tags
- Link notes together
- Export collections

**Note Format**:
```markdown
# {{title}}
Created: {{datetime}}
Tags: {{tags}}

## Content

## References
- [[linked-note]]
```

### `menu/nook-menu-plugin.sh`

**Purpose**: Plugin management interface

**Functions**:
- List installed plugins
- Enable/disable plugins
- Configure plugin settings
- Check plugin compatibility

### `menu/squire-menu.sh`

**Purpose**: Medieval-themed alternative menu

**Theme Elements**:
- Scroll-style borders
- Medieval vocabulary
- Jester interactions
- Achievement display

---

## 🔧 Service Daemons

### `services/jester-daemon.sh`

**Purpose**: Jester mood and interaction service

**Features**:
- Dynamic mood system
- ASCII art variations
- Writing statistics integration
- Achievement tracking

**Mood States**:
```bash
JESTER_HAPPY      # Default cheerful state
JESTER_CONFUSED   # Random silly state
JESTER_SLEEPY     # Low activity periods
JESTER_WRITING    # Active writing detected
JESTER_EXCITED    # Milestone achieved
```

**Files Created**:
```
/var/lib/jester/
├── state          # Current mood state
├── wisdom         # Quote rotation
├── achievements   # Writing milestones
└── stats          # Session statistics
```

**Update Interval**: 30 seconds

### `services/health-check.sh`

**Purpose**: System health monitoring

**Monitors**:
- Memory usage (<96MB limit)
- Storage space
- Battery level
- Temperature
- Module status

**Alert Thresholds**:
```bash
MEMORY_CRITICAL=96    # MB
STORAGE_CRITICAL=100  # MB free
BATTERY_LOW=20       # Percent
TEMP_HIGH=60         # Celsius
```

**Log Location**: `/var/log/health-check.log`

---

## 🛠️ Utility Scripts

### `create-cwm-sdcard.sh`

**Purpose**: Create bootable SD card for Nook

**Features**:
- Partition creation
- Filesystem formatting
- Bootloader installation
- Rootfs deployment
- Verification

**Usage**:
```bash
sudo ./create-cwm-sdcard.sh /dev/sdX
```

**Partitions Created**:
1. Boot partition (FAT32, 50MB)
2. Root partition (ext4, remaining space)

**Safety Features**:
- Device verification
- Size checking
- Confirmation prompt
- Backup warning

---

## 📏 Script Standards

### Shell Safety

All scripts implement:
```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
trap 'error_handler $LINENO $?' ERR
```

### Input Validation

```bash
# Numeric validation
validate_menu_choice() {
    local choice="${1:-}"
    local max="${2:-9}"
    
    [[ "$choice" =~ ^[0-9]+$ ]] || return 1
    (( choice >= 1 && choice <= max )) || return 1
}

# Path validation
validate_path() {
    local path="${1:-}"
    
    # No path traversal
    [[ "$path" != *".."* ]] || return 1
    # Must be under allowed directories
    [[ "$path" == /root/notes/* ]] || \
    [[ "$path" == /root/drafts/* ]] || \
    return 1
}
```

### Error Messages

Writer-friendly messages:
```bash
# BAD: Technical jargon
echo "Error: ENOENT - fbdev ioctl failed"

# GOOD: Clear message
echo "E-Ink display not found (normal in Docker)"

# BEST: Medieval theme
echo "Alas! The digital parchment is not ready!"
```

### Display Abstraction

```bash
# Check display type
if has_eink; then
    fbink -c "$text"
else
    echo "$text"
fi
```

---

## 📦 Dependencies

### Required Binaries

| Binary | Purpose | Fallback |
|--------|---------|----------|
| `fbink` | E-Ink display | Terminal output |
| `vim` | Text editor | None (required) |
| `insmod` | Module loading | Skip modules |
| `mount` | Filesystem | None (required) |
| `sync` | Data sync | Manual save |

### Optional Binaries

| Binary | Purpose | Impact if Missing |
|--------|---------|-------------------|
| `logger` | System logging | No logging |
| `fbink` | E-Ink refresh | Terminal mode |
| `rclone` | Cloud sync | No sync |
| `tmux` | Session management | Direct vim |

### Library Dependencies

- `common.sh` - Required for all scripts
- `/proc/jokeros/` - Required for jester features
- `/sys/class/power_supply/` - Battery monitoring

---

## ⚠️ Error Handling

### Error Handler Pattern

```bash
error_handler() {
    local line_no=$1
    local exit_code=$2
    local script_name="${BASH_SOURCE[1]##*/}"
    
    echo "Error in $script_name at line $line_no"
    
    # Log if available
    if command -v logger >/dev/null 2>&1; then
        logger -t "squireos" "Error: $script_name:$line_no"
    fi
    
    return $exit_code
}
```

### Exit Codes

Standard exit codes across all scripts:

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Missing dependency |
| 3 | Invalid input |
| 4 | Permission denied |
| 5 | Resource exhausted |
| 130 | User interrupt (Ctrl+C) |

### Recovery Strategies

1. **Display Fallback**: Terminal if no E-Ink
2. **Module Fallback**: Continue without modules
3. **Service Fallback**: Essential services only
4. **Menu Fallback**: Basic text menu

---

## 🧪 Testing Guidelines

### Test Environment

```bash
# Docker testing (no E-Ink)
docker run -it --rm nook-writer bash
source /usr/local/bin/common.sh
./test-script.sh

# Simulate E-Ink
export FBINK_MOCK=1
```

### Test Coverage

Each script should test:
1. Normal operation
2. Missing dependencies
3. Invalid input
4. Resource constraints
5. Error conditions

### Test Framework

```bash
# Test validation functions
test_validate_menu_choice() {
    validate_menu_choice "1" "9" || exit 1
    validate_menu_choice "10" "9" && exit 1
    validate_menu_choice "abc" "9" && exit 1
    echo "✓ Menu validation tests passed"
}

# Test display abstraction
test_display() {
    display_text "Test" 0
    has_eink || echo "✓ Fallback to terminal"
}
```

---

## 🎯 Best Practices

### Memory Optimization

1. **Avoid subshells** when possible
2. **Use built-ins** over external commands
3. **Clear variables** after use
4. **Minimize script size** (<10KB preferred)

### E-Ink Optimization

1. **Batch updates** to reduce flashing
2. **Use partial refresh** when possible
3. **Avoid rapid updates** (<1 per second)
4. **Clear screen** only when necessary

### Writer Experience

1. **Clear messages** without technical jargon
2. **Medieval theme** for fun and consistency
3. **Quick responses** (<500ms for menu)
4. **Graceful degradation** when features unavailable

---

## 📊 Script Metrics

### Size Analysis

| Script | Lines | Size | Complexity |
|--------|-------|------|------------|
| common.sh | ~300 | 8KB | High |
| boot-jester.sh | ~200 | 6KB | Medium |
| nook-menu.sh | ~250 | 7KB | Medium |
| jester-daemon.sh | ~180 | 5KB | Low |
| health-check.sh | ~150 | 4KB | Low |

### Performance Targets

| Operation | Target | Current |
|-----------|--------|---------|
| Boot to menu | <20s | ~15s |
| Menu response | <500ms | ~300ms |
| Module load | <2s | ~1s |
| Jester update | <100ms | ~50ms |

---

## 🔗 Related Documentation

- [Test Suite Documentation](TEST_SUITE_DOCUMENTATION.md)
- [Configuration Reference](CONFIGURATION_REFERENCE.md)
- [Deployment Documentation](DEPLOYMENT_DOCUMENTATION.md)
- [Kernel Documentation](kernel-reference/KERNEL_DOCUMENTATION.md)

---

*"By script and shell, we craft the writer's realm!"* 🎭

**Version**: 1.0.0  
**Shell**: Bash 4.4+  
**Last Updated**: December 13, 2024