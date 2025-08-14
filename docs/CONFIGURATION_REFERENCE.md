# ⚙️ Nook Typewriter Configuration Reference

*Generated: December 13, 2024*

## Overview

The Nook Typewriter project uses a comprehensive configuration system spanning system settings, Vim editor configurations, ASCII art resources, and service definitions. All configurations prioritize minimal RAM usage and E-Ink display compatibility.

---

## 📁 Configuration Structure

```
source/configs/
├── nook.conf              # Master configuration file
├── ascii/                 # ASCII art and visual resources
│   └── jester/           # Jester art variations
├── system/               # System-level configurations
│   ├── os-release        # OS identification
│   ├── services/         # SystemD/init services
│   └── boot configs      # Boot-time settings
├── vim/                  # Vim editor configurations
│   ├── vimrc-writer      # Production writing config
│   ├── vimrc-minimal     # Minimal RAM config
│   └── eink.vim          # E-Ink color scheme
└── zk-templates/         # Zettelkasten templates

```

---

## 🔧 Master Configuration (`nook.conf`)

### Overview
Central configuration file for all Nook scripts with environment variables, paths, and feature toggles.

### Configuration Sections

#### System Configuration
```bash
# Project paths
NOOK_PROJECT_DIR="/home/nook"
NOOK_CONFIG_DIR="$NOOK_PROJECT_DIR/config"
NOOK_SCRIPTS_DIR="$NOOK_PROJECT_DIR/scripts"
NOOK_DATA_DIR="$NOOK_PROJECT_DIR/data"

# User data paths
NOOK_NOTES_DIR="$HOME/notes"
NOOK_DRAFTS_DIR="$HOME/drafts"
NOOK_BACKUP_DIR="$HOME/backups"
```

#### Hardware Configuration
```bash
# SD Card settings
NOOK_SD_SIZE_GB="16"
NOOK_BOOT_PARTITION="/mnt/boot"
NOOK_ROOT_PARTITION="/mnt/root"

# E-Ink display settings
NOOK_DISPLAY_WIDTH="800"
NOOK_DISPLAY_HEIGHT="600"
NOOK_DISPLAY_COLORS="16"

# Memory constraints
NOOK_TOTAL_RAM_MB="256"
NOOK_AVAILABLE_RAM_MB="160"  # Sacred writing space
```

#### Software Configuration
```bash
# Editor settings
NOOK_EDITOR="vim"
NOOK_EDITOR_CONFIG="$HOME/.vimrc"

# Menu settings
NOOK_MENU_TIMEOUT="30"        # Seconds before timeout
NOOK_MENU_REFRESH="5"          # Refresh interval

# Sync settings (disabled by default)
NOOK_SYNC_ENABLED="false"
NOOK_SYNC_METHOD="rclone"
NOOK_SYNC_INTERVAL="3600"
```

#### JesterOS/JoKernel Settings
```bash
# Medieval theme
NOOK_ENABLE_JESTER="true"
NOOK_SHOW_WISDOM="true"
NOOK_MEDIEVAL_BOOT="true"

# Writing statistics
NOOK_TRACK_STATS="true"
NOOK_STATS_FILE="$NOOK_DATA_DIR/writing-stats.txt"

# Achievement milestones (words)
NOOK_MILESTONE_APPRENTICE="1000"
NOOK_MILESTONE_JOURNEYMAN="10000"
NOOK_MILESTONE_MASTER="50000"
NOOK_MILESTONE_CHRONICLER="100000"
```

#### Power Management
```bash
# Battery optimization
NOOK_POWER_SAVE="true"
NOOK_CPU_GOVERNOR="powersave"
NOOK_SCREEN_TIMEOUT="300"      # 5 minutes

# USB power limit
NOOK_USB_POWER_LIMIT_MA="100"  # Conserve battery
```

### Helper Functions

```bash
# Load configuration value with default
value=$(get_config "NOOK_EDITOR" "nano")

# Set configuration value
set_config "NOOK_EDITOR" "vim"

# Check if feature is enabled
if is_enabled "NOOK_DEBUG"; then
    echo "Debug mode active"
fi

# Validate configuration
validate_config || exit 1

# Export all config variables
export_config

# Load local overrides
load_local_config
```

---

## 📝 Vim Configurations

### Writer Configuration (`vimrc-writer`)

**Purpose**: Optimized for prose writing with ~5MB RAM usage

**Key Features**:
```vim
" E-Ink Optimization
set lazyredraw              " Reduce screen refreshes
set updatetime=180000       " Auto-save every 3 minutes
set t_Co=2                  " Monochrome for E-Ink
syntax off                  " Save RAM

" Writing Environment
set wrap
set linebreak
set spell spelllang=en_us
set spellsuggest=best,10

" Minimal Plugins
" - Goyo: Distraction-free mode
" - Pencil: Soft wrap for prose
" - Litecorrect: Auto-correct typos

" Goyo Configuration
let g:goyo_width = 72       " Comfortable reading width
let g:goyo_height = '90%'   " Use most of screen
```

### Minimal Configuration (`vimrc-minimal`)

**Purpose**: Absolute minimum for <2MB RAM usage

**Features**:
```vim
" Ultra-minimal settings
set nocompatible
set noswapfile
set nobackup
set noundofile
syntax off
filetype off
" No plugins loaded
```

### E-Ink Color Scheme (`eink.vim`)

**Purpose**: Optimized colors for E-Ink display

```vim
" High contrast monochrome
highlight Normal ctermfg=black ctermbg=white
highlight LineNr ctermfg=gray
highlight CursorLine ctermbg=lightgray
highlight SpellBad cterm=underline
" No color syntax highlighting
```

### Zettelkasten Configuration (`vimrc-zk`)

**Purpose**: Note-taking and knowledge management

**Features**:
- Wiki-style links
- Note templates
- Tag system
- Quick note creation

---

## 🎨 ASCII Art Resources

### Jester Variations (`ascii/jester/`)

#### Available Art Files

| File | Purpose | Size |
|------|---------|------|
| `jester-logo.txt` | Boot screen logo | 15 lines |
| `jester-variations.txt` | Mood variations | 5 moods |
| `medieval-elements.txt` | Decorative borders | Various |
| `silly-jester-collection.txt` | Fun animations | 10 frames |
| `system-messages.txt` | Status messages | Themed |

#### Jester Moods

```
Happy:
    .~"~.~"~.
   /  ^   ^  \
  |  >  ◡  <  |
   \  ___  /
    |~|♦|~|

Writing:
    .~"~.~"~.
   /  -   -  \
  |  >  _  <  |
   \  ___  /
    |~|♦|~|

Thinking:
    .~"~.~"~.
   /  ?   ?  \
  |  >  ~  <  |
   \  ___  /
    |~|♦|~|
```

---

## 🖥️ System Configurations

### OS Release (`system/os-release`)

**JesterOS Identity**:
```ini
NAME="JesterOS"
VERSION="1.0.0"
ID=jesteros
ID_LIKE=debian
PRETTY_NAME="JesterOS 1.0.0 (Parchment)"
VERSION_CODENAME=parchment
DEBIAN_CODENAME=bullseye
SQUIRE_MOTTO="By quill and candlelight"
MASCOT="The Derpy Court Jester"
```

### File System Table (`system/fstab`)

```bash
# <device>          <mount>    <type>   <options>           <dump> <pass>
/dev/mmcblk0p1      /boot      vfat     defaults,noatime    0      2
/dev/mmcblk0p2      /          ext4     defaults,noatime    0      1
tmpfs               /tmp       tmpfs    size=10M            0      0
tmpfs               /var/log   tmpfs    size=5M             0      0
```

### System Control (`system/sysctl.conf`)

**Memory & Performance Tuning**:
```bash
# Memory management
vm.swappiness=10                    # Minimize swap usage
vm.vfs_cache_pressure=50            # Balance cache/memory
vm.dirty_background_ratio=5         # Start writing earlier
vm.dirty_ratio=10                   # Force write at 10%

# Network (disabled for distraction-free)
net.ipv4.ip_forward=0
net.ipv6.conf.all.disable_ipv6=1
```

### SystemD Services

#### JesterOS Boot Service (`squireos-boot.service`)
```ini
[Unit]
Description=JesterOS Boot Sequence
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/boot-jester.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

#### Module Loading Service (`squireos-modules.service`)
```ini
[Unit]
Description=Load JesterOS Kernel Modules
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/load-squireos-modules.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

#### Jester Daemon Service (`jester.service`)
```ini
[Unit]
Description=JesterOS Mood Daemon
After=squireos-modules.service

[Service]
Type=simple
ExecStart=/usr/local/bin/jester-daemon.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

---

## 📋 Zettelkasten Templates

### Daily Note Template (`zk-templates/daily.md`)

```markdown
# {{date}}

## Morning Thoughts
- 

## Today's Writing Goal
- [ ] 

## Notes & Ideas
- 

## Evening Reflection
- 

Tags: #daily #journal
```

### Default Note Template (`zk-templates/default.md`)

```markdown
# {{title}}

Created: {{datetime}}

## Summary


## Content


## References
- 

Tags: #
```

---

## 🔐 Configuration Security

### File Permissions

```bash
# Configuration files
/source/configs/nook.conf           644 root:root
/source/configs/vim/*                644 user:user
/source/configs/system/*             644 root:root
/source/configs/ascii/*              644 root:root

# Service files  
/etc/systemd/system/*.service        644 root:root
/etc/init.d/*                        755 root:root
```

### Sensitive Data

**Never store in configs**:
- Passwords
- API keys  
- Personal information
- Network credentials

**Use instead**:
- Local override files (`.local`)
- Environment variables
- Encrypted storage

---

## 🔄 Configuration Loading

### Boot Sequence

1. **Kernel Parameters** → `/proc/cmdline`
2. **System Config** → `/etc/os-release`
3. **Services** → SystemD/init scripts
4. **User Config** → `nook.conf`
5. **Local Overrides** → `nook.conf.local`
6. **Vim Config** → `.vimrc`

### Runtime Loading

```bash
# In scripts
source /path/to/nook.conf

# Validate before use
validate_config || {
    echo "Configuration error"
    exit 1
}

# Access values
editor=$(get_config "NOOK_EDITOR" "vim")
```

---

## 📈 Performance Impact

### Memory Usage by Config

| Configuration | RAM Usage | Notes |
|---------------|-----------|-------|
| Minimal Vim | <2MB | No plugins |
| Writer Vim | ~5MB | Essential plugins |
| Full Vim | ~10MB | All features |
| ASCII Art | <100KB | Cached |
| Config Files | <50KB | Text only |

### Optimization Tips

1. **Disable unused features** in `nook.conf`
2. **Use minimal Vim** for quick edits
3. **Disable sync** to save resources
4. **Reduce menu timeout** for faster response
5. **Use powersave governor** for battery

---

## 🛠️ Customization Guide

### Creating Local Overrides

```bash
# Create local config
cp nook.conf nook.conf.local

# Edit settings
vim nook.conf.local

# Test changes
source nook.conf.local
validate_config
```

### Adding Custom ASCII Art

1. Create art file in `ascii/custom/`
2. Keep under 20 lines for E-Ink
3. Use ASCII characters only
4. Test display with `cat` command

### Custom Vim Plugins

```vim
" In vimrc-custom
" Only add if <5MB RAM impact
Plug 'plugin/name'

" Configure for E-Ink
let g:plugin_option = 'minimal'
```

---

## 📚 Related Documentation

- [Vim Configuration Guide](VIM_CONFIG_GUIDE.md)
- [ASCII Art Creation](ASCII_ART_GUIDE.md)
- [Service Management](SERVICE_MANAGEMENT.md)
- [Performance Tuning](PERFORMANCE_TUNING.md)

---

*"Configure wisely, write freely!"* 🎭

**Version**: 1.0.0  
**Last Updated**: December 13, 2024  
**Config Format**: Shell, Vim, INI