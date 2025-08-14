# 📚 Nook Typewriter Source API Reference

*Generated: December 13, 2024*

## Overview

This document provides a comprehensive API reference for the Nook Typewriter project's source code, including kernel modules, shell scripts, and system interfaces.

---

## 🎭 Kernel Module APIs (`/source/kernel/`)

### JesterOS Core Module System

> **Note**: The kernel module files are currently in `/drivers/jokeros/` directory but should be renamed to `/drivers/jesteros/` to match the JesterOS naming convention.

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

## 🔧 Shell Script APIs (`/source/scripts/`)

### Boot Scripts (`/boot/`)

#### boot-jester.sh
**Purpose:** Initialize boot sequence with jester animation

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

#### load-jesteros-modules.sh
**Purpose:** Load JesterOS kernel modules in correct order

**Load Sequence:**
1. `jesteros_core.ko` - Base module (required) *Currently: jokeros_core.ko*
2. `jester.ko` - Jester companion
3. `typewriter.ko` - Writing statistics
4. `wisdom.ko` - Quote system

**Functions:**
```bash
load_module()
    # Load a kernel module with error checking
    # Parameters: $1 - Module name
    # Returns: 0 on success, 1 on failure

verify_proc_entries()
    # Verify /proc/jesteros entries exist
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
**Purpose:** Legacy menu system (fallback)

**Differences from squire-menu.sh:**
- No jester integration
- Basic text display
- Simplified options

### Service Scripts (`/services/`)

#### health-check.sh
**Purpose:** Monitor system health

**Health Checks:**
```bash
check_memory()
    # Verify memory usage < 96MB
    # Returns: 0 if OK, 1 if exceeded

check_modules()
    # Verify kernel modules loaded
    # Returns: 0 if all loaded, 1 if missing

check_filesystem()
    # Check filesystem integrity
    # Returns: 0 if healthy, 1 if errors

update_jester_mood()
    # Update jester based on health
    # Writes to /proc/jesteros/jester/mood
```

#### jester-daemon.sh
**Purpose:** Background jester mood updater

**Daemon Functions:**
```bash
monitor_activity()
    # Monitor user activity
    # Updates jester mood accordingly

track_idle_time()
    # Track idle periods
    # Switch to sleeping mood after threshold

respond_to_events()
    # React to system events
    # Update mood based on events
```

### Library Functions (`/lib/`)

#### common.sh
**Purpose:** Shared utility functions

**Utility Functions:**
```bash
validate_menu_choice()
    # Validate user input
    # Parameters: $1 - Input string
    # Returns: 0 if valid, 1 if invalid

validate_path()
    # Check path safety
    # Parameters: $1 - Path to validate
    # Returns: 0 if safe, 1 if unsafe

error_handler()
    # Unified error handling
    # Parameters: $1 - Error message

display_text()
    # Abstract display method
    # Parameters: $1 - Text to display
    # Uses FBInk or terminal fallback

is_eink_available()
    # Check E-Ink availability
    # Returns: 0 if available, 1 if not
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

### Kernel ↔ Userspace

**Proc Filesystem:**
- Read: `cat /proc/jesteros/[entry]`
- Write: `echo "value" > /proc/jesteros/[entry]`

**Module Loading:**
```bash
# Load modules (current filenames still use jokeros)
insmod /lib/modules/2.6.29/jokeros_core.ko  # Should be jesteros_core.ko
insmod /lib/modules/2.6.29/jester.ko

# Verify loading
lsmod | grep jesteros
```

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

### Reading Statistics
```bash
# From shell
cat /proc/jesteros/typewriter/stats

# From C
int fd = open("/proc/jesteros/typewriter/stats", O_RDONLY);
read(fd, buffer, sizeof(buffer));
close(fd);
```

### Setting Jester Mood
```bash
# From shell
echo "writing" > /proc/jesteros/jester/mood

# From script
if [ "$USER_ACTIVE" = "1" ]; then
    echo "writing" > /proc/jesteros/jester/mood
else
    echo "sleeping" > /proc/jesteros/jester/mood
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

### Adding New Kernel Module

1. Create module source in `/source/kernel/src/drivers/jesteros/` (currently `/drivers/jokeros/`)
2. Add to `Kconfig` in the jesteros directory
3. Update `Makefile`
4. Implement init/exit functions
5. Create proc entries under `/proc/jesteros/`
6. Add to load sequence in `load-jesteros-modules.sh`

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

**Version**: 1.0.0  
**Last Updated**: December 13, 2024  
**License**: GPL v2