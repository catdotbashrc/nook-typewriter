# 📚 Nook Typewriter Project Index

A comprehensive index of all project components, documentation, and resources.

## 🗂️ Project Structure

### 📁 Root Directory
```
/nook/
├── README.md                    # Project overview and quick start
├── CLAUDE.md                    # Development guidelines and constraints
├── WINDOWS-SD-SETUP.md         # Windows deployment guide
├── LICENSE                      # GPL v2 license
├── PROJECT_INDEX.md            # This file
├── debian-build.log            # Build output log
├── test-vim-plugins.sh         # Plugin testing script
├── nookwriter.dockerfile       # Standard Docker build
├── nookwriter-optimized.dockerfile  # RAM-optimized builds
├── docker-compose.yml          # Standard compose config
└── docker-compose-optimized.yml    # Multi-mode compose
```

### 📂 Core Directories

#### `/boot/` - Boot Configuration
- `uEnv.txt` - U-Boot environment settings

#### `/config/` - System Configuration
```
├── colors/
│   └── eink.vim               # E-Ink optimized colorscheme
├── scripts/
│   ├── nook-menu.sh          # Main menu system
│   ├── nook-menu-zk.sh       # Menu with zk integration
│   ├── sync-notes.sh         # Cloud sync script
│   ├── writing-check.sh      # Writing analysis tools
│   ├── squire-menu.sh        # Medieval themed menu
│   ├── squireos-boot.sh      # Boot customization
│   └── dynamic-motd.sh       # Dynamic MOTD generator
├── system/
│   ├── fstab                 # File system mounts
│   ├── sysctl.conf          # Kernel parameters
│   ├── os-release           # SquireOS branding
│   ├── lsb-release          # LSB information
│   ├── issue                # Login banner
│   ├── issue.net            # Network login banner
│   └── motd                 # Message of the day
├── vim/
│   ├── draft.vim            # Draft writing config
│   └── zettel.vim           # Zettelkasten config
├── zk-templates/
│   ├── default.md           # Default note template
│   └── daily.md             # Daily note template
├── vimrc                    # Standard Vim config
├── vimrc-minimal           # No plugins (2MB RAM)
├── vimrc-writer           # Essential plugins (5MB)
├── vimrc-zk              # Zettelkasten config
└── zk-config.toml        # zk configuration
```

#### `/scripts/` - Build & Deployment Scripts
- `build-rootfs.sh` - Root filesystem builder
- `setup-kernel-build.sh` - Kernel build environment
- `verify-sd-card.sh` - SD card verification

#### `/archive/` - Deprecated Components
```
└── deprecated-scripts/
    ├── customize-kernel.sh
    ├── optimize-typewriter-kernel.sh
    ├── apply-branding.sh
    └── build-kernel.sh
```

#### `/nst-kernel/` - QuillKernel Source
```
├── README.md                  # Kernel overview
├── README-QUILLKERNEL.md     # QuillKernel features
├── SIMPLE-BUILD.md           # Build instructions
├── KERNEL_NOTES.md           # Development notes
├── squire-kernel-patch.sh    # Apply medieval patches
├── Dockerfile.build          # Kernel build container
├── setup-hooks.sh            # Git hooks setup
├── test-in-docker.sh         # Container testing
├── src/                      # Linux kernel source
├── build/                    # Build output
│   ├── uImage               # Compiled kernel
│   └── uImage.config        # Kernel configuration
├── test/                     # Test suite
│   ├── verify-build-simple.sh
│   ├── test-proc.sh
│   ├── test-typewriter.sh
│   ├── usb-automated-test.sh
│   └── run-all-tests.sh
└── docs/                     # Kernel documentation
```

#### `/docs/` - Project Documentation
```
├── index.md                  # Documentation hub
├── vim-optimization-results.md  # Performance analysis
├── branding-concept.md       # SquireOS branding
├── tutorials/
│   ├── 01-first-nook-setup.md
│   ├── 02-writing-your-first-note.md
│   └── 03-syncing-to-cloud.md
├── how-to/
│   ├── choose-vim-configuration.md
│   ├── install-custom-kernel.md
│   ├── build-custom-kernel.md
│   ├── customize-vim-plugins.md
│   ├── setup-wireless-keyboard.md
│   └── advanced-kernel-setup.md
├── explanation/
│   ├── architecture-overview.md
│   ├── why-debian-over-alpine.md
│   └── roadmap.md
└── reference/
    ├── writing-tools.md
    ├── keyboard-shortcuts.md
    └── system-requirements.md
```

## 📜 Script Reference

### 🎯 Core Menu Scripts

#### `nook-menu.sh`
Main menu interface for the Nook typewriter.
- Options: Write, List files, Sync, Word count, Shutdown
- Location: `/usr/local/bin/nook-menu.sh`

#### `nook-menu-zk.sh`
Enhanced menu with zk note management.
- Features: New note, Daily note, Search, Recent notes, Ideas
- Requires: zk binary installed
- Location: `/usr/local/bin/nook-menu-zk.sh`

#### `writing-check.sh`
Writing analysis and statistics tools.
- Features: Word count, readability scores, writing patterns
- Location: `/usr/local/bin/writing-check.sh`

### 🔧 Build & Deployment Scripts

#### `verify-sd-card.sh`
Verification script for SD card deployment.
- Checks: Partitions, files, permissions, space usage
- Usage: `./verify-sd-card.sh [boot_partition] [root_partition]`
- For: WSL/Linux deployment verification

#### `squire-kernel-patch.sh`
Apply QuillKernel medieval patches.
- Features: Jester, achievements, typewriter stats
- Location: `/nst-kernel/squire-kernel-patch.sh`

#### `test-vim-plugins.sh`
Test Vim plugin memory usage.
- Measures: RAM impact of different configurations
- Output: Comparison of minimal vs writer vs full modes

### 🧪 Testing Scripts

#### `run-all-tests.sh`
Execute complete test suite.
- Tests: Build, USB, proc filesystem, typewriter features
- Location: `/nst-kernel/test/run-all-tests.sh`

#### `verify-build-simple.sh`
Quick kernel build verification.
- Checks: Binary existence, proc entries, USB support
- Location: `/nst-kernel/test/verify-build-simple.sh`

## ⚙️ Configuration Files

### 📝 Vim Configurations

| File | Purpose | RAM Usage | Plugins |
|------|---------|-----------|---------|
| `vimrc-minimal` | Bare minimum | ~2MB | None |
| `vimrc-writer` | Writing focused | ~5MB | Goyo, Pencil, Litecorrect |
| `vimrc-zk` | Zettelkasten | ~6MB | zk integration |
| `vimrc` | Standard | ~8MB | Full suite |

### 🐳 Docker Configurations

| File | Purpose | Build Modes |
|------|---------|-------------|
| `nookwriter.dockerfile` | Standard build | Single mode |
| `nookwriter-optimized.dockerfile` | RAM-optimized | minimal, writer |
| `docker-compose.yml` | Standard services | nook-system |
| `docker-compose-optimized.yml` | Multi-mode | minimal, writer, standard |

### 🔧 System Configuration

| File | Purpose |
|------|---------|
| `boot/uEnv.txt` | U-Boot parameters |
| `config/system/fstab` | File system mounts |
| `config/system/sysctl.conf` | Kernel tuning |
| `config/zk-config.toml` | Zettelkasten settings |

## 📊 Quick Commands

### Docker Build Commands
```bash
# Standard build
docker build -t nook-system -f nookwriter.dockerfile .

# Minimal mode (2MB RAM)
docker build --build-arg BUILD_MODE=minimal -t nook-minimal -f nookwriter-optimized.dockerfile .

# Writer mode (5MB RAM)
docker build --build-arg BUILD_MODE=writer -t nook-writer -f nookwriter-optimized.dockerfile .
```

### Testing Commands
```bash
# Test Vim plugins
./test-vim-plugins.sh

# Verify SD card deployment
./scripts/verify-sd-card.sh /mnt/e /mnt/d

# Run kernel tests
cd nst-kernel && ./test/run-all-tests.sh
```

### Deployment Commands
```bash
# Create deployment tarball
docker create --name nook-export nook-system
docker export nook-export | gzip > nook-debian.tar.gz
docker rm nook-export

# Extract to SD card (WSL)
sudo tar -xzf nook-debian.tar.gz -C /mnt/d/
```

## 🔗 Key Documentation Links

### Getting Started
- [First Nook Setup](docs/tutorials/01-first-nook-setup.md)
- [Windows SD Setup](WINDOWS-SD-SETUP.md)
- [Architecture Overview](docs/explanation/architecture-overview.md)

### Configuration
- [Choose Vim Configuration](docs/how-to/choose-vim-configuration.md)
- [Vim Optimization Results](docs/vim-optimization-results.md)
- [Writing Tools Reference](docs/reference/writing-tools.md)

### Development
- [CLAUDE.md](CLAUDE.md) - Development guidelines
- [Build Custom Kernel](docs/how-to/build-custom-kernel.md)
- [QuillKernel README](nst-kernel/README-QUILLKERNEL.md)

## 📌 Important Notes

### Memory Constraints
- Total RAM: 256MB
- OS overhead: ~95MB
- Writing space: 160MB (sacred, do not touch)
- Plugin budget: 2-8MB depending on mode

### Design Philosophy
- Writers over features
- Simplicity over complexity
- Distractions are bugs, not features
- E-Ink limitations are features

### Target Users
- Digital minimalist writers
- Retro computing enthusiasts
- Budget-conscious creators
- Environmental advocates

---

*Last updated: Check git log for latest changes*
*Maintained as part of the Nook Typewriter project*