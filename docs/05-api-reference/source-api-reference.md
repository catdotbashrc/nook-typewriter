# 📚 Nook Typewriter Source API Reference

*Generated: August 15, 2025*

## Overview

This document provides a comprehensive API reference for the Nook Typewriter project's source code, including kernel modules, shell scripts, and system interfaces.

---

## 🎭 Kernel Module APIs (`/source/kernel/`)

### JesterOS Core Module System

> **Current Status**: JesterOS has migrated to userspace services for better stability and development velocity. Kernel modules are now minimal and optional. See JesterOS Userspace Services section below for current implementation.

#### Configuration (`drivers/jokeros/Kconfig`)
*Should be renamed to: `drivers/jesteros/Kconfig`*

```kconfig
menuconfig JESTEROS
    tristate "JesterOS Jester Interface for Digital Typewriter"
    default y
```

**Sub-options:**
- `CONFIG_JESTEROS` - Enable base JesterOS system
- `CONFIG_JESTEROS_JESTER` - Enable ASCII jester companion
- `CONFIG_JESTEROS_TYPEWRITER` - Enable writing statistics
- `CONFIG_JESTEROS_WISDOM` - Enable wisdom quotes
- `CONFIG_JESTEROS_DEBUG` - Enable debug messages

#### Core Module (`jokeros_core.c`)
*Should be renamed to: `jesteros_core.c`*

**Module Information:**
```c
MODULE_LICENSE("GPL")
MODULE_VERSION("1.0.0")
MODULE_DESCRIPTION("JesterOS Jester Interface for Digital Jesters")
```

**Exported Symbols:**
- `jesteros_root` - Root proc directory entry
- `JESTEROS_VERSION` - Version string constant
- `JESTEROS_CODENAME` - Release codename

**Proc Filesystem Entries:**
| Path | Type | Permission | Description |
|------|------|------------|-------------|
| `/proc/jesteros/` | Directory | 755 | Root directory |
| `/proc/jesteros/motto` | File | 444 | System motto |
| `/proc/jesteros/version` | File | 444 | Version info |

**Functions:**
```c
static int __init jesteros_init(void)
    // Initialize JesterOS subsystem
    // Creates /proc/jesteros/ hierarchy
    // Returns: 0 on success, -ENOMEM on failure

static void __exit jesteros_exit(void)
    // Cleanup JesterOS subsystem
    // Removes all proc entries

static int version_show(char *buffer, char **start, off_t offset, 
                       int count, int *eof, void *data)
    // Display version information
    // Returns: Number of bytes written

static int motto_show(char *buffer, char **start, off_t offset,
                     int count, int *eof, void *data)
    // Display system motto
    // Returns: Number of bytes written
```

#### Jester Module (`jester.c`)

**Purpose:** ASCII art jester with dynamic moods

**Proc Interface:**
- `/proc/jesteros/jester` - Current jester mood display
- `/proc/jesteros/jester/mood` - Set/get current mood

**Mood States:**
```c
enum jester_mood {
    MOOD_HAPPY,      // Default, system healthy
    MOOD_WRITING,    // Active writing session
    MOOD_THINKING,   // Processing/loading
    MOOD_SLEEPING,   // Idle/power saving
    MOOD_ERROR       // System error state
};
```

**API Functions:**
```c
int jester_set_mood(enum jester_mood mood)
    // Change jester's mood
    // Returns: 0 on success, -EINVAL on invalid mood

const char* jester_get_ascii(enum jester_mood mood)
    // Get ASCII art for specified mood
    // Returns: Pointer to ASCII art string

void jester_update_stats(void)
    // Update jester based on system state
    // Called periodically by timer
```

#### Typewriter Module (`typewriter.c`)

**Purpose:** Track writing statistics and achievements

**Proc Interface:**
- `/proc/jesteros/typewriter/stats` - Current statistics
- `/proc/jesteros/typewriter/achievements` - Unlocked achievements
- `/proc/jesteros/typewriter/reset` - Reset statistics

**Statistics Structure:**
```c
struct typewriter_stats {
    uint32_t keystrokes;      // Total keystrokes
    uint32_t words;           // Total words written
    uint32_t sessions;        // Writing sessions
    uint32_t streak_days;     // Current writing streak
    time_t last_write;        // Last writing timestamp
    uint32_t longest_session; // Longest session (minutes)
};
```

**Achievement Levels:**
```c
enum achievement_level {
    APPRENTICE_SCRIBE,    // 100 words
    JOURNEYMAN_WRITER,    // 1,000 words
    MASTER_WORDSMITH,     // 10,000 words
    GRAND_CHRONICLER      // 100,000 words
};
```

**API Functions:**
```c
void typewriter_keystroke(void)
    // Record a keystroke

void typewriter_word_complete(void)
    // Record word completion

struct typewriter_stats* typewriter_get_stats(void)
    // Get current statistics
    // Returns: Pointer to stats structure

void typewriter_reset_stats(void)
    // Reset all statistics to zero

const char* typewriter_get_achievement(void)
    // Get current achievement level string
```

#### Wisdom Module (`wisdom.c`)

**Purpose:** Provide rotating writing quotes

**Proc Interface:**
- `/proc/jesteros/wisdom` - Display current quote
- `/proc/jesteros/wisdom/next` - Advance to next quote

**Quote Categories:**
```c
enum quote_category {
    QUOTE_INSPIRATION,    // Motivational quotes
    QUOTE_TECHNIQUE,      // Writing technique tips
    QUOTE_HUMOR,          // Humorous writing quotes
    QUOTE_MEDIEVAL        // Medieval-themed wisdom
};
```

**API Functions:**
```c
const char* wisdom_get_quote(void)
    // Get current quote
    // Returns: Quote string

void wisdom_next_quote(void)
    // Advance to next quote

const char* wisdom_get_by_category(enum quote_category cat)
    // Get quote from specific category
    // Returns: Quote string or NULL
```

---

## 🎭 JesterOS Userspace Services (`/source/scripts/services/`)

### Service Management System

JesterOS services now run in userspace for better reliability and easier development. The service management system provides a unified interface for managing all JesterOS components.

#### jesteros-service-manager.sh
**Purpose:** Central service management for all JesterOS services

**Usage:**
```bash
/usr/local/bin/jesteros-service-manager.sh {start|stop|restart|status|health|monitor} [service|all]
```

**Service Operations:**
```bash
start_service(service_name)
    # Start a JesterOS service
    # Parameters: $1 - Service name (jester|tracker|health)
    # Returns: 0 on success, 1 on failure

stop_service(service_name)
    # Stop a JesterOS service
    # Parameters: $1 - Service name
    # Returns: 0 on success, 1 on failure

health_check_service(service_name)
    # Perform health check on service
    # Parameters: $1 - Service name
    # Returns: 0 if healthy, 1 if unhealthy

monitor_services()
    # Continuous monitoring daemon
    # Auto-restarts failed services
    # Monitors: CPU, memory, and service-specific health
```

**Service Configuration Files:**
Services are configured via files in `/etc/jesteros/services/`:
- `jester.conf` - Court Jester service configuration
- `tracker.conf` - Royal Scribe writing statistics
- `health.conf` - Court Physician system health

#### service-functions.sh
**Purpose:** Shared service management utilities

**Key Functions:**
```bash
load_service_config(service_name)
    # Load service configuration from /etc/jesteros/services/
    # Parameters: $1 - Service name
    # Sets: SERVICE_NAME, SERVICE_EXEC, SERVICE_PIDFILE, etc.

is_service_running(pidfile)
    # Check if service process is running
    # Parameters: $1 - PID file path
    # Returns: 0 if running, 1 if stopped

auto_restart_service(service_name)
    # Auto-restart with exponential backoff
    # Parameters: $1 - Service name
    # Attempts: 3 tries with increasing delays

resolve_dependencies(service_name)
    # Resolve service startup dependencies
    # Parameters: $1 - Service name
    # Returns: Space-separated list of dependencies

update_global_status()
    # Update /var/jesteros/services/status with current state
    # Creates unified status file for all services
```

#### jester-daemon.sh
**Purpose:** The Court Jester - ASCII art companion with dynamic moods

**Jester Moods:**
```bash
set_jester_mood(mood)
    # Set current jester mood and ASCII art
    # Moods: happy, writing, thinking, sleeping, error, celebrating
    # Updates: /var/jesteros/jester with new ASCII art

get_system_mood()
    # Determine mood based on system state
    # Factors: CPU usage, memory, active processes, writing activity
    # Returns: Appropriate mood string

update_jester_display()
    # Refresh jester ASCII art based on current conditions
    # Called every 30 seconds by daemon
```

**JesterOS Interface Files:**
- `/var/jesteros/jester` - Current jester ASCII art
- `/var/jesteros/jester/mood` - Current mood state
- `/var/jesteros/jester/stats` - Jester activity statistics

#### jesteros-tracker.sh
**Purpose:** Royal Scribe - Writing activity tracking and statistics

**Writing Statistics:**
```bash
update_writing_stats()
    # Monitor and update writing statistics
    # Tracks: Total words, keystrokes, session time, daily goals
    # Updates: /var/jesteros/typewriter/stats

monitor_vim_activity()
    # Monitor vim processes for writing activity
    # Detects: New files, word count changes, session duration
    # Triggers: Jester mood updates, achievement notifications

count_words_in_file(filepath)
    # Count words in a text file
    # Parameters: $1 - File path to analyze
    # Returns: Word count integer

update_achievements()
    # Check and unlock writing achievements
    # Levels: Apprentice Scribe, Journeyman Writer, etc.
    # Updates: /var/jesteros/typewriter/achievements
```

**Statistics Files:**
- `/var/jesteros/typewriter/stats` - Current writing statistics
- `/var/jesteros/typewriter/achievements` - Unlocked achievements
- `/var/jesteros/typewriter/daily` - Daily writing goals and progress

#### health-check.sh
**Purpose:** Court Physician - System health monitoring

**Health Monitoring:**
```bash
perform_health_check()
    # Comprehensive system health assessment
    # Checks: Memory usage, disk space, CPU load, service status
    # Updates: /var/jesteros/health/status

check_memory_usage()
    # Monitor memory consumption
    # Warning: >80% usage, Critical: >90% usage
    # Sacred limit: Never exceed 96MB for OS

check_disk_space()
    # Monitor available disk space
    # Checks: Root partition, writing directories
    # Returns: Usage percentage and available space

monitor_services_health()
    # Check health of all JesterOS services
    # Validates: PID files, process health, resource usage
    # Auto-restart: Failed or unhealthy services
```

**Health Files:**
- `/var/jesteros/health/status` - Overall system health
- `/var/jesteros/health/memory` - Memory usage details
- `/var/jesteros/health/disk` - Disk space information
- `/var/jesteros/health/services` - Service health status

## 🔧 Shell Script APIs (`/source/scripts/`)

### Boot Scripts (`/boot/`)

#### init-jesteros.sh
**Purpose:** Complete JesterOS initialization at boot

**Initialization Sequence:**
```bash
main()
    # Main JesterOS initialization
    # 1. Show boot splash
    # 2. Create required directories
    # 3. Initialize service management
    # 4. Start all JesterOS services
    # 5. Create /var/jesteros interface
    # 6. Launch interactive menu if TTY

create_jesteros_interface()
    # Create /var/jesteros filesystem interface
    # Directories: jester/, typewriter/, health/, services/
    # Initial files: Default states and placeholder content

start_service_manager()
    # Initialize and start service management
    # Copies service configurations
    # Starts jesteros-service-manager daemon
```

#### boot-jester.sh
**Purpose:** Legacy boot animation (now calls init-jesteros.sh)

**Functions:**
```bash
show_jester_boot()
    # Display animated jester during boot
    # Uses FBInk for E-Ink or fallback to terminal

check_eink_available()
    # Check if E-Ink display is available
    # Returns: 0 if available, 1 if not

display_boot_progress()
    # Show boot progress with medieval messages
    # Parameters: $1 - Progress percentage
```

#### jesteros-boot-splash.sh
**Purpose:** JesterOS boot splash screen display

**Functions:**
```bash
show_splash()
    # Display JesterOS logo and branding
    # Supports: E-Ink display with FBInk, terminal fallback
    # Duration: 3 seconds (configurable)
```

#### load-squireos-modules.sh (Deprecated)
**Purpose:** Legacy kernel module loading (now optional)

**Migration Status:** JesterOS has moved to userspace services. This script is maintained for compatibility but is no longer required for normal operation.

**Functions:**
```bash
load_module()
    # Load a kernel module with error checking
    # Parameters: $1 - Module name
    # Returns: 0 on success, 1 on failure

verify_proc_entries()
    # Verify /proc/squireos entries exist (legacy)
    # Returns: 0 if all present, 1 if missing
```

### Menu System (`/menu/`)

#### squire-menu.sh
**Purpose:** Main menu system with medieval theme

**Menu Options:**
| Key | Function | Description |
|-----|----------|-------------|
| S | Scribe | Start new manuscript |
| C | Chronicle | View writing statistics |
| I | Illuminate | Continue last work |
| L | Library | Browse saved documents |
| M | Messenger | Sync to cloud (disabled) |
| W | Wisdom | Display writing guidance |
| T | Terminal | Drop to shell |
| Q | Quest Complete | Shutdown system |

**Functions:**
```bash
display_menu()
    # Show main menu with jester
    # Uses FBInk for E-Ink display

process_choice()
    # Handle user menu selection
    # Parameters: $1 - User choice character

show_statistics()
    # Display writing statistics from kernel
    # Reads from /proc/jesteros/typewriter/stats

launch_vim()
    # Start Vim with optimized settings
    # Parameters: $1 - Optional file path
```

#### nook-menu.sh
**Purpose:** Main writing menu system with JesterOS integration

**Enhanced Features:**
- Reads jester from `/var/jesteros/jester`
- Displays writing stats from `/var/jesteros/typewriter/stats`
- Shows wisdom quotes from `/var/jesteros/wisdom`
- Integrated with JesterOS service status

**JesterOS Integration:**
```bash
display_jester()
    # Display current jester mood from userspace service
    # Source: /var/jesteros/jester

show_writing_stats()
    # Display writing statistics from tracker service
    # Source: /var/jesteros/typewriter/stats

get_wisdom_quote()
    # Show inspirational writing quote
    # Source: /var/jesteros/wisdom
```

### Legacy Service Scripts (Migrated to /services/)

> **Note:** Individual service scripts have been integrated into the unified JesterOS service management system. See JesterOS Userspace Services section above for current implementation.

#### Legacy Functions (now in jesteros-service-manager.sh):
- `health-check.sh` → `health_check_service()`
- `jester-daemon.sh` → `jester_daemon()` in service manager
- Individual daemon scripts → Service configuration files in `/etc/jesteros/services/`

### Library Functions (`/lib/`)

#### common.sh
**Purpose:** Shared utility functions with enhanced safety and JesterOS integration

**Safety and Validation:**
```bash
validate_menu_choice(choice, max)
    # Enhanced input validation with range checking
    # Parameters: $1 - Input string, $2 - Maximum valid choice
    # Returns: 0 if valid (1-max), 1 if invalid
    # Security: Prevents injection attacks, validates numeric input

validate_path(path)
    # Path traversal protection
    # Parameters: $1 - Path to validate
    # Security: Prevents ../ attacks, restricts to allowed directories
    # Allowed: /root/notes/, /root/drafts/, /root/scrolls/

sanitize_input(input)
    # Input sanitization
    # Parameters: $1 - User input string
    # Returns: Cleaned input (control chars removed, length limited)
    # Security: Removes control characters, limits to 100 chars
```

**Display Abstraction:**
```bash
display_text(text, refresh)
    # Abstract display with E-Ink optimization
    # Parameters: $1 - Text to display, $2 - Force refresh (0/1)
    # Auto-detection: FBInk for E-Ink, terminal fallback

clear_display()
    # Clear display with proper E-Ink handling
    # E-Ink: fbink -c, Terminal: clear command

display_banner(title)
    # Formatted banner display
    # Parameters: $1 - Banner title text
    # Format: Bordered banner with consistent width

has_eink()
    # E-Ink capability detection
    # Returns: 0 if FBInk available, 1 if terminal only
```

**Error Handling:**
```bash
error_handler(line_no, exit_code)
    # Enhanced error handler with context
    # Parameters: $1 - Line number, $2 - Exit code
    # Features: Writer-friendly messages, system logging
    # Example: "Alas! The digital parchment has encountered an error!"

log_message(level, message)
    # Structured logging with timestamps
    # Parameters: $1 - Log level, $2 - Message text
    # Output: /var/log/squireos.log with timestamp

debug_log(message)
    # Debug logging (only if DEBUG=1)
    # Parameters: $1 - Debug message
    # Conditional: Only logs when debug mode enabled
```

**JesterOS Integration:**
```bash
# Constants for JesterOS userspace interface
JESTER_DIR="/var/lib/jester"           # Jester data directory
NOTES_DIR="/root/notes"                 # Notes storage
DRAFTS_DIR="/root/drafts"               # Draft documents
SCROLLS_DIR="/root/scrolls"             # Finished works
SQUIREOS_PROC="/proc/squireos"          # Legacy kernel interface

# Timing constants for E-Ink optimization
BOOT_DELAY=2                           # Boot sequence delay
MENU_TIMEOUT=3                         # Menu input timeout
JESTER_UPDATE_INTERVAL=30              # Jester mood update frequency
```

---

## 🎨 UI Components (`/source/ui/`)

### Display Component (`components/display.sh`)

**Display API:**
```bash
init_display()
    # Initialize display system
    # Detects E-Ink or terminal

clear_screen()
    # Clear display
    # Uses fbink -c or clear

refresh_display()
    # Force display refresh
    # E-Ink full refresh

show_text()
    # Display text at position
    # Parameters: $1 - Y position, $2 - Text

show_ascii_art()
    # Display ASCII art
    # Parameters: $1 - Art file path
```

### Menu Component (`components/menu.sh`)

**Menu API:**
```bash
create_menu()
    # Create menu structure
    # Parameters: Array of options

display_menu_item()
    # Show single menu item
    # Parameters: $1 - Key, $2 - Description

get_menu_choice()
    # Get user selection
    # Returns: Selected character

highlight_item()
    # Highlight menu item (if supported)
    # Parameters: $1 - Item index
```

---

## 📝 Configuration Files (`/source/configs/`)

### System Configuration

#### nook.conf
**Purpose:** Main system configuration

```ini
# Memory limits
MAX_OS_MEMORY=96M
SACRED_WRITING_SPACE=160M

# Display settings
EINK_REFRESH_MODE=partial
EINK_CLEAR_ON_BOOT=true

# Jester settings
JESTER_ENABLED=true
JESTER_DEFAULT_MOOD=happy
JESTER_IDLE_TIMEOUT=300

# Writing settings
DEFAULT_EDITOR=vim
AUTOSAVE_INTERVAL=60
```

### Vim Configuration

#### vimrc-writer
**Purpose:** Optimized Vim settings for writing

**Key Settings:**
```vim
" Writing mode optimizations
set spell                  " Enable spell checking
set wrap                   " Wrap long lines
set linebreak             " Break at word boundaries
set textwidth=72          " Standard text width

" E-Ink optimizations
set lazyredraw            " Reduce screen updates
set noshowcmd             " Disable command display
set noruler               " Disable ruler

" Goyo integration
let g:goyo_width=72       " Focused writing width
let g:goyo_height='90%'   " Use most of screen
```

---

## 🔌 Integration Points

### JesterOS Userspace ↔ System Integration

**JesterOS Interface Filesystem:**
- Read: `cat /var/jesteros/[service]/[entry]`
- Write: `echo "value" > /var/jesteros/[service]/[entry]`

**Service Management:**
```bash
# Start all JesterOS services
/usr/local/bin/jesteros-service-manager.sh start all

# Check service status
/usr/local/bin/jesteros-service-manager.sh status

# Monitor services (daemon mode)
/usr/local/bin/jesteros-service-manager.sh monitor
```

**JesterOS Interface Structure:**
```
/var/jesteros/
├── jester                    # Current jester ASCII art
├── jester/
│   ├── mood                  # Current mood state
│   └── stats                 # Jester activity metrics
├── typewriter/
│   ├── stats                 # Writing statistics
│   ├── achievements          # Unlocked achievements
│   └── daily                 # Daily writing goals
├── health/
│   ├── status                # Overall system health
│   ├── memory                # Memory usage details
│   ├── disk                  # Disk space information
│   └── services              # Service health status
├── wisdom                    # Current wisdom quote
└── services/
    └── status                # Global service status
```

**Legacy Kernel Interface (Optional):**
- `/proc/squireos/` - Legacy kernel module interface
- Not required for normal operation
- Maintained for compatibility only

### Scripts ↔ Display

**FBInk Integration:**
```bash
# Text display
fbink -y [line] "text"

# Clear screen
fbink -c

# Image display (if supported)
fbink -i image.png
```

**Fallback to Terminal:**
```bash
# All scripts should include
command -v fbink >/dev/null 2>&1 || USE_TERMINAL=1

# Then use conditional display
if [ "$USE_TERMINAL" = "1" ]; then
    echo "text"
else
    fbink "text"
fi
```

---

## 🚨 Error Codes

### Kernel Module Errors
| Code | Meaning | Resolution |
|------|---------|------------|
| -ENOMEM | Out of memory | Reduce memory usage |
| -ENOENT | Entry not found | Check proc path |
| -EINVAL | Invalid argument | Validate input |
| -EBUSY | Resource busy | Retry operation |

### Script Exit Codes
| Code | Meaning | Context |
|------|---------|---------|
| 0 | Success | Normal completion |
| 1 | General error | Check error message |
| 2 | Invalid input | Validate user input |
| 3 | Missing dependency | Install requirements |
| 4 | Memory exceeded | Free memory |
| 5 | Module load failed | Check kernel logs |

---

## 📖 Usage Examples

### Reading Writing Statistics
```bash
# Current writing statistics
cat /var/jesteros/typewriter/stats

# Example output:
# Words: 1,247
# Keystrokes: 8,231
# Sessions: 15
# Streak: 7 days
# Last Write: 2025-08-15 14:30:22
# Achievement: Journeyman Writer

# Daily progress
cat /var/jesteros/typewriter/daily

# Unlocked achievements
cat /var/jesteros/typewriter/achievements
```

### Viewing Current Jester
```bash
# Display current jester ASCII art
cat /var/jesteros/jester

# Check jester's current mood
cat /var/jesteros/jester/mood

# View jester activity stats
cat /var/jesteros/jester/stats
```

### Service Management Examples
```bash
# Start specific service
sudo /usr/local/bin/jesteros-service-manager.sh start jester

# Check all service health
/usr/local/bin/jesteros-service-manager.sh health all

# Monitor services with auto-restart
/usr/local/bin/jesteros-service-manager.sh monitor &

# View global service status
cat /var/jesteros/services/status
```

### System Health Monitoring
```bash
# Overall system health
cat /var/jesteros/health/status

# Memory usage details
cat /var/jesteros/health/memory

# Check if under memory budget
if grep -q "MEMORY: OK" /var/jesteros/health/status; then
    echo "Memory budget maintained"
else
    echo "Warning: Approaching memory limit"
fi
```

### Launching Writing Session
```bash
# Start new document
/usr/local/bin/squire-menu.sh
# Press 'S' for Scribe mode

# Or directly
vim ~/scrolls/new_manuscript.md
```

---

## 🔧 Development Guidelines

### Adding New JesterOS Service

1. Create service script in `/source/scripts/services/`
2. Add service configuration in `/etc/jesteros/services/[service].conf`
3. Define service dependencies and health checks
4. Update service manager to include new service
5. Create interface files under `/var/jesteros/[service]/`
6. Test service start/stop/health operations

**Example Service Configuration:**
```ini
# /etc/jesteros/services/newservice.conf
SERVICE_NAME="New Service Name"
SERVICE_DESC="Service description"
SERVICE_EXEC="/usr/local/bin/newservice-daemon.sh"
SERVICE_PIDFILE="/var/run/jesteros/newservice.pid"
SERVICE_ARGS="--daemon"
SERVICE_DEPS="jester"  # Dependencies
SERVICE_START_MSG="🎪 New Service awakens!"
SERVICE_STOP_MSG="🎪 New Service rests..."
SERVICE_HEALTH_CHECK="test -f /var/jesteros/newservice/status"
```

### Adding New Menu Option

1. Edit `squire-menu.sh`
2. Add case in process_choice()
3. Implement handler function
4. Update display_menu()
5. Test with both E-Ink and terminal

### Memory Optimization

- Always check current usage: `free -h`
- Kernel modules should use < 1MB each
- Scripts should avoid large variables
- Use streaming for file operations
- Clear variables after use

---

## 📚 Further Reading

- [Kernel Module Guide](KERNEL_MODULES_GUIDE.md)
- [Linux 2.6.29 API Reference](kernel-reference/QUICK_REFERENCE_2.6.29.md)
- [E-Ink Programming Guide](EINK_PROGRAMMING.md)
- [Medieval Theme Guidelines](MEDIEVAL_THEME.md)

---

*"In code we jest, in bytes we trust!"* 🎭

**Version**: 2.0.0  
**Last Updated**: August 15, 2025  
**License**: GPL v2

---

## 🔄 Migration Notes

### JesterOS Userspace Migration

JesterOS has successfully migrated from kernel modules to userspace services for improved:
- **Stability**: No kernel panics from service failures
- **Development Velocity**: Faster iteration without kernel rebuilds
- **Memory Efficiency**: Better resource management and monitoring
- **Debugging**: Easier troubleshooting with standard tools

### Key Changes:
1. **Service Architecture**: Unified service management system
2. **Interface Files**: `/var/jesteros/` replaces `/proc/jesteros/`
3. **Configuration**: Service configs in `/etc/jesteros/services/`
4. **Monitoring**: Built-in health checks and auto-restart
5. **Memory Management**: Service-aware memory budgeting

### Backwards Compatibility:
- Legacy `/proc/squireos/` interface maintained (optional)
- Existing scripts continue to work with minor path updates
- Kernel modules available but not required

**Migration Status**: ✅ Complete - Production Ready