# 📜 JesterOS Scripts Complete Documentation

*Generated: August 15, 2025*

## Overview

This document provides comprehensive documentation for all scripts in the JesterOS project, organized by functional category with detailed usage, parameters, and implementation notes.

---

## 📁 Directory Structure

```
source/scripts/
├── boot/                    # Boot and initialization scripts
├── services/               # JesterOS userspace services
├── menu/                   # Menu systems
├── lib/                    # Common libraries and functions
└── create-cwm-sdcard.sh    # SD card preparation
```

---

## 🚀 Boot Scripts (`/boot/`)

### init-jesteros.sh
**Purpose**: Main JesterOS initialization script that starts all services at boot

**Usage**:
```bash
/usr/local/bin/init-jesteros.sh
```

**Functions**:
- `show_boot_splash()` - Display JesterOS boot splash if available
- `create_required_directories()` - Create `/var/jesteros/` structure
- `start_service_manager()` - Initialize service management system
- `create_jesteros_interface()` - Set up filesystem interface

**Boot Sequence**:
1. Show boot splash (3 seconds)
2. Create directory structure
3. Copy service configurations
4. Start service manager
5. Initialize interface files
6. Launch menu if interactive

**Dependencies**: 
- jesteros-boot-splash.sh
- jesteros-service-manager.sh
- Service configuration files

---

### boot-jester.sh
**Purpose**: Legacy boot script with jester animation (now calls init-jesteros.sh)

**Usage**:
```bash
/usr/local/bin/boot-jester.sh
```

**Functions**:
- `init_eink()` - Initialize E-Ink display if available
- `show_jester_animation()` - Display animated boot jester
- `load_modules()` - Legacy kernel module loading (optional)

**E-Ink Detection**:
```bash
if command -v fbink >/dev/null 2>&1; then
    EINK_AVAILABLE=1
    fbink -c  # Clear display
fi
```

**Status**: Maintained for compatibility, delegates to init-jesteros.sh

---

### jesteros-boot-splash.sh
**Purpose**: Display JesterOS ASCII art logo at boot

**Usage**:
```bash
/usr/local/bin/jesteros-boot-splash.sh [--daemon]
```

**Display Output**:
```
     ╔══════════════════════════════════════╗
     ║        JesterOS Boot System          ║
     ║     "By Quill and Jest We Boot!"    ║
     ╚══════════════════════════════════════╝
     
                  @ @ @@ @ @                         
                @@@ @@@@@@ @@@                       
               @@@@  @@@@  @@@@                      
              @@  @@@◉  ◉@@@  @@                     
             @@ @@    ⌣    @@ @@
```

**Parameters**:
- `--daemon` - Run without delay (for service mode)
- Default: 3-second display duration

---

### jester-splash.sh / jester-splash-eink.sh
**Purpose**: Jester boot animations optimized for different displays

**Display Modes**:
- **Terminal**: Full ASCII art with colors (if supported)
- **E-Ink**: Simplified art optimized for grayscale

**E-Ink Optimizations**:
- Reduced detail for clarity
- No rapid animations (ghosting prevention)
- Full refresh on completion

---

### jester-dance.sh
**Purpose**: Animated dancing jester boot sequence

**Animation Frames**: 5 unique jester poses
**Frame Delay**: 0.5 seconds
**Total Duration**: ~3 seconds

**Usage in Boot**:
```bash
# Optional festive boot
if [ "$FESTIVE_BOOT" = "1" ]; then
    /usr/local/bin/jester-dance.sh
fi
```

---

### boot-with-jester.sh
**Purpose**: Wrapper script for jester-themed boot

**Boot Options**:
- Normal boot with static jester
- Animated boot with dancing jester
- Quick boot (skip animations)

---

### create-jester-pbm.sh
**Purpose**: Generate PBM images for E-Ink display

**Output Format**: PBM (Portable Bitmap)
**Resolution**: 800x600 (Nook display)
**Usage**: Pre-generate boot images for faster display

---

### jesteros-userspace.sh
**Purpose**: Initialize JesterOS userspace services

**Service Initialization Order**:
1. Service manager daemon
2. Jester daemon (ASCII art)
3. Tracker service (writing stats)
4. Health monitor

**Interface Creation**:
```bash
mkdir -p /var/jesteros/{jester,typewriter,health,services}
```

---

### squireos-boot.sh / squireos-init.sh
**Purpose**: Legacy SquireOS boot scripts (deprecated)

**Status**: Replaced by JesterOS initialization
**Maintained For**: Backwards compatibility only

---

### load-squireos-modules.sh
**Purpose**: Load kernel modules (optional, legacy)

**Modules Loaded** (if available):
- squireos_core.ko / jokeros_core.ko
- jester.ko
- typewriter.ko
- wisdom.ko

**Current Status**: Optional - JesterOS runs in userspace

---

## 🎭 Service Scripts (`/services/`)

### jesteros-service-manager.sh
**Purpose**: Central service management daemon

**Usage**:
```bash
jesteros-service-manager.sh {command} [target]

Commands:
  start   [service|all]  - Start service(s)
  stop    [service|all]  - Stop service(s)
  restart [service|all]  - Restart service(s)
  status  [service|all]  - Check status
  health  [service|all]  - Health check
  monitor               - Continuous monitoring
  init                  - Initialize system
```

**Key Functions**:
- `start_all_services()` - Start services in dependency order
- `stop_all_services()` - Stop in reverse dependency order
- `health_check_all()` - Comprehensive health assessment
- `monitor_services()` - Daemon with auto-restart (30s intervals)
- `resolve_dependencies()` - Handle service dependencies
- `auto_restart_service()` - Restart with exponential backoff

**Service Configuration Format**:
```bash
SERVICE_NAME="Service Display Name"
SERVICE_DESC="Service description"
SERVICE_EXEC="/path/to/executable"
SERVICE_PIDFILE="/var/run/jesteros/service.pid"
SERVICE_ARGS="--daemon"
SERVICE_DEPS="dependency1 dependency2"
SERVICE_START_MSG="🎭 Starting message"
SERVICE_STOP_MSG="🎭 Stopping message"
SERVICE_HEALTH_CHECK="test command"
```

**Memory Monitoring**:
- Tracks individual service memory
- Enforces 1MB per service soft limit
- Total services must stay under 15MB
- Alerts at 80%, 90%, 95% thresholds

---

### jester-daemon.sh
**Purpose**: ASCII art jester companion with mood system

**Usage**:
```bash
jester-daemon.sh [--daemon]
```

**Mood System**:
```bash
MOODS:
  happy       - Default, system healthy
  writing     - Active writing detected
  thinking    - High CPU/processing
  sleeping    - Idle > 5 minutes
  error       - System issues detected
  celebrating - Achievement unlocked
```

**Mood Detection Logic**:
```bash
get_system_mood() {
    # Check for active writing
    if pgrep -x vim > /dev/null; then
        echo "writing"
    # Check CPU usage
    elif [ "$cpu_usage" -gt 50 ]; then
        echo "thinking"
    # Check idle time
    elif [ "$idle_minutes" -gt 5 ]; then
        echo "sleeping"
    # Check for errors
    elif [ -f /var/jesteros/error ]; then
        echo "error"
    else
        echo "happy"
    fi
}
```

**ASCII Art Collection**:
- 6 unique jester designs
- Mood-specific messages
- Medieval-themed phrases

**Interface Files**:
- `/var/jesteros/jester` - Current ASCII art
- `/var/jesteros/jester/mood` - Current mood
- `/var/jesteros/jester/stats` - Activity statistics

**Update Frequency**: Every 30 seconds

---

### jesteros-tracker.sh
**Purpose**: Monitor writing activity and track statistics

**Usage**:
```bash
jesteros-tracker.sh [--daemon]
```

**Tracking Features**:
- Word count monitoring
- Keystroke estimation
- Session duration
- Daily goals (500 words default)
- Writing streaks
- Achievement system

**Statistics Structure**:
```bash
Words: 12,847
Characters: 67,234
Keystrokes: 89,156
Sessions: 47
Total Time: 23h 18m
Streak: 12 days
Last Write: 2025-08-15 14:30:22
Today: 347 words
Goal Progress: 69% (347/500)
Achievement: Master Wordsmith
```

**Achievement Levels**:
```bash
APPRENTICE_SCRIBE=100      # First milestone
JOURNEYMAN_WRITER=1000     # Getting serious
MASTER_WORDSMITH=10000     # Dedicated writer
GRAND_CHRONICLER=100000    # Epic achievement
DAILY_DEDICATION=500       # Daily goal met
STREAK_KEEPER=7           # Week-long streak
MARATHON_WRITER=2000      # Single session record
```

**File Monitoring**:
```bash
MONITORED_PATHS:
  /root/notes/     # Zettelkasten notes
  /root/drafts/    # Work in progress
  /root/scrolls/   # Completed works
```

**Update Triggers**:
- File modification detected
- Vim process started/stopped
- Manual save in vim
- Session timeout (30 minutes idle)

---

### health-check.sh
**Purpose**: System health monitoring and reporting

**Usage**:
```bash
health-check.sh [--daemon|--once]
```

**Health Checks**:
1. **Memory Usage**
   - Total OS usage vs 96MB limit
   - Individual service memory
   - Available writing space (160MB sacred)

2. **Disk Space**
   - Root partition free space
   - Writing directories capacity
   - Log file sizes

3. **CPU Load**
   - 1, 5, 15 minute averages
   - Per-service CPU usage

4. **Service Status**
   - All JesterOS services running
   - PID file validity
   - Health check command results

**Output Format**:
```
=== COURT PHYSICIAN'S REPORT ===
Date: 2025-08-15 14:30:22
Overall Health: EXCELLENT

VITAL SIGNS:
Memory: 67.2MB/96MB (70%) - GOOD
Disk Space: 2.3GB free - EXCELLENT
CPU Load: 0.23 (5min) - EXCELLENT
Services: 3/3 running - EXCELLENT
```

**Alert Thresholds**:
- Memory: Warning at 80%, Critical at 90%
- Disk: Warning at 500MB, Critical at 100MB
- CPU: Warning at 1.5, Critical at 2.0

**Daemon Mode**: Runs every 60 seconds, logs to `/var/log/jesteros/health.log`

---

### jesteros-mood-selector.sh
**Purpose**: Manual mood selection for jester

**Interactive Mode**:
```bash
Select Jester Mood:
1) Happy
2) Writing
3) Thinking
4) Sleeping
5) Error
6) Celebrating
Choice:
```

**Scripted Usage**:
```bash
echo "celebrating" | jesteros-mood-selector.sh
```

---

### service-functions.sh
**Purpose**: Shared service management utilities

**Key Functions**:

**Service Lifecycle**:
```bash
load_service_config(service_name)
is_service_running(pidfile)
start_service(service_name)
stop_service(service_name)
restart_service(service_name)
```

**Health Management**:
```bash
health_check_service(service_name)
auto_restart_service(service_name)
update_service_status(service_name, status)
update_global_status()
```

**Dependency Resolution**:
```bash
resolve_dependencies(service_name)
# Returns ordered list of dependencies
# Detects circular dependencies
# Handles multi-level deps
```

**Directory Management**:
```bash
init_service_dirs()
# Creates:
#   /etc/jesteros/services/
#   /var/run/jesteros/
#   /var/log/jesteros/
#   /var/jesteros/services/
```

---

## 📱 Menu Scripts (`/menu/`)

### nook-menu.sh
**Purpose**: Main writing environment menu with JesterOS integration

**Menu Options**:
```
╔═══════════════════════════════════════╗
║        NOOK WRITING SYSTEM            ║
╠═══════════════════════════════════════╣
║  1. New Manuscript (Zettelkasten)     ║
║  2. Continue Draft                    ║
║  3. Resume Last Session               ║
║  4. View Statistics                   ║
║  5. Sync Notes (disabled)             ║
║  6. Visit the Jester                  ║
║  7. Shutdown                          ║
╚═══════════════════════════════════════╝
```

**JesterOS Integration**:
```bash
# Display current jester
cat /var/jesteros/jester

# Show writing stats
cat /var/jesteros/typewriter/stats

# Display wisdom quote
cat /var/jesteros/wisdom
```

**Safety Features**:
- Input validation via `validate_menu_choice()`
- Path protection for file operations
- Safe vim launch with proper environment

---

### squire-menu.sh
**Purpose**: Medieval-themed menu system

**Enhanced Features**:
- Jester integration at startup
- Medieval language throughout
- Achievement notifications
- Writing wisdom display

**Menu Structure**:
```
     ╔════════════════════════════════╗
     ║    DIGITAL SCRIPTORIUM         ║
     ╠════════════════════════════════╣
     ║  S - Scribe (New Manuscript)   ║
     ║  C - Chronicle (Statistics)    ║
     ║  I - Illuminate (Continue)      ║
     ║  L - Library (Browse)          ║
     ║  W - Wisdom (Quotes)           ║
     ║  Q - Quest Complete (Exit)     ║
     ╚════════════════════════════════╝
```

---

### nook-menu-zk.sh
**Purpose**: Zettelkasten-optimized menu (if zk installed)

**Zettelkasten Features**:
- Note ID generation
- Backlink support
- Tag management
- Search integration

**Requirements**: `zk` command-line tool

---

### nook-menu-plugin.sh
**Purpose**: Plugin system for menu extensions

**Plugin Loading**:
```bash
PLUGIN_DIR="/usr/local/lib/nook-menu/plugins"
for plugin in "$PLUGIN_DIR"/*.sh; do
    source "$plugin"
done
```

---

## 📚 Library Scripts (`/lib/`)

### common.sh
**Purpose**: Shared utilities and safety functions

**Safety Functions**:

**Input Validation**:
```bash
validate_menu_choice(choice, max)
# Validates numeric input 1-max
# Prevents injection attacks

validate_path(path)
# Prevents directory traversal
# Restricts to allowed directories

sanitize_input(input)
# Removes control characters
# Limits length to 100 chars
```

**Display Abstraction**:
```bash
display_text(text, refresh)
# Auto-detects E-Ink vs terminal
# Handles refresh modes

clear_display()
# Proper E-Ink clearing
# Terminal fallback

display_banner(title)
# Consistent formatting
# Medieval theme borders
```

**Error Handling**:
```bash
error_handler(line_no, exit_code)
# Writer-friendly messages
# Logging integration
# Context preservation

log_message(level, message)
# Structured logging
# Timestamp inclusion
# Severity levels
```

**E-Ink Detection**:
```bash
has_eink()
# Returns 0 if FBInk available
# Falls back to terminal mode
```

**Constants**:
```bash
# Directories
JESTER_DIR="/var/lib/jester"
NOTES_DIR="/root/notes"
DRAFTS_DIR="/root/drafts"
SCROLLS_DIR="/root/scrolls"

# Timing (E-Ink optimized)
BOOT_DELAY=2
MENU_TIMEOUT=3
JESTER_UPDATE_INTERVAL=30
```

---

### font-setup.sh
**Purpose**: Console font configuration for readability

**Font Selection**:
- Terminus font preferred (if available)
- Fallback to system defaults
- E-Ink optimized sizes

**Setup Process**:
```bash
if [ -f /usr/share/consolefonts/ter-132n.psf.gz ]; then
    setfont ter-132n
fi
```

---

### service-functions.sh (duplicated in services/)
**Purpose**: Service management utilities
**Note**: Symlinked from services/ for library access

---

## 🔧 Utility Scripts

### create-cwm-sdcard.sh
**Purpose**: Create ClockworkMod-compatible SD card for Nook

**Usage**:
```bash
./create-cwm-sdcard.sh [options]

Options:
  --kernel PATH    Path to uImage kernel
  --modules PATH   Path to modules directory
  --output PATH    Output ZIP file path
```

**Process**:
1. Validate dependencies
2. Create CWM directory structure
3. Generate installation scripts
4. Create update-binary
5. Package as ZIP
6. Sign for CWM compatibility

**Directory Structure Created**:
```
cwm_package/
├── META-INF/
│   └── com/
│       └── google/
│           └── android/
│               ├── update-binary
│               └── updater-script
├── kernel/
│   └── uImage
└── modules/
    └── *.ko files
```

---

## 🔐 Security Features

### Input Validation
All scripts implement:
- Menu choice validation (numeric, range)
- Path traversal prevention
- Input sanitization (control char removal)
- Length limiting (prevent overflow)

### Error Handling
Consistent error handling:
- `set -euo pipefail` in all scripts
- Error trapping with line numbers
- Writer-friendly error messages
- Logging to system log

### Path Protection
File operations restricted to:
- `/root/notes/` - Zettelkasten notes
- `/root/drafts/` - Work in progress
- `/root/scrolls/` - Completed works

---

## 🎯 Best Practices

### Shell Script Standards
```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
trap 'error_handler $LINENO $?' ERR
```

### Service Development
1. Always source common.sh
2. Implement health checks
3. Create interface files
4. Handle signals properly
5. Log important events

### E-Ink Optimization
- Minimize screen refreshes
- Use partial updates when possible
- Avoid rapid animations
- Clear display before major updates

### Memory Management
- Stay under 96MB OS limit
- Monitor service memory usage
- Free resources when idle
- Use efficient data structures

---

## 📊 Performance Metrics

### Service Timing
| Service | Startup Time | Memory Usage | CPU (idle) |
|---------|-------------|--------------|------------|
| service-manager | <1s | 2.1MB | 0.1% |
| jester-daemon | <1s | 2.3MB | 0.2% |
| tracker | <1s | 4.2MB | 0.3% |
| health-check | <1s | 8.6MB | 0.5% |
| **Total** | <2s | ~15MB | ~1% |

### Update Frequencies
- Jester mood: 30 seconds
- Writing stats: 60 seconds
- Health check: 60 seconds
- Achievement check: On file save

---

## 🐛 Troubleshooting

### Common Issues

**Services Won't Start**:
```bash
# Check permissions
ls -la /usr/local/bin/jester*.sh

# View logs
tail -f /var/log/jesteros/service-manager.log

# Manual start
/usr/local/bin/jester-daemon.sh --daemon
```

**Interface Files Missing**:
```bash
# Reinitialize
sudo jesteros-service-manager.sh init

# Check structure
ls -la /var/jesteros/
```

**High Memory Usage**:
```bash
# Check current usage
cat /var/jesteros/health/memory

# Restart services
sudo jesteros-service-manager.sh restart all
```

### Debug Mode
Enable verbose logging:
```bash
export DEBUG=1
jesteros-service-manager.sh status
```

---

## 📝 Configuration Files

### Service Configurations
Location: `/etc/jesteros/services/`

Files:
- `jester.conf` - Jester service config
- `tracker.conf` - Tracker service config
- `health.conf` - Health service config

### System Configuration
- `/etc/nook.conf` - System-wide settings
- `/root/.vimrc` - Vim configuration

---

## 🔄 Integration Points

### With Vim
- Tracker monitors vim processes
- Stats update on file saves
- Jester mood changes during writing

### With E-Ink Display
- FBInk integration for display
- Optimized refresh rates
- Fallback to terminal mode

### With File System
- `/var/jesteros/` interface
- Service status files
- Log file management

---

## 📈 Future Enhancements

### Planned Features
1. More jester moods and animations
2. Daily writing goal customization
3. Export statistics to various formats
4. Plugin system for custom services
5. Network-optional backup system

### Performance Improvements
1. Lazy loading of ASCII art
2. Cached statistics calculations
3. Optimized file monitoring
4. Reduced disk I/O

---

## 📄 License & Attribution

**License**: GPL v2
**Project**: JesterOS Nook Typewriter
**Purpose**: Distraction-free writing environment

---

*"By quill and code, we craft digital magic!"* 🎭📜

**Generated**: August 15, 2025
**Total Scripts**: 30+ documented
**Lines of Code**: ~5,000+ shell script lines