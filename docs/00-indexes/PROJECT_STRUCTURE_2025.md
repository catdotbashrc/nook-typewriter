# 📁 JesterOS Project Structure - January 2025

*Complete directory structure with current state documentation*

## 🏗️ Root Structure

```
nook/
├── README.md                    # Main project introduction
├── CLAUDE.md                    # AI development guidelines  
├── QUICK_START.md              # 5-minute setup guide
├── PROJECT_INDEX_2024.md       # [SUPERSEDED] Old index
├── Makefile                    # Main build system
├── BOOT_ROADMAP.md            # Boot process documentation
├── DEPLOYMENT_SUCCESS.md      # SD card deployment guide
└── deploy-to-sd-gk61.sh       # USB keyboard deployment script
```

## 🐳 Build System (`build/`)

```
build/
├── docker/                     # Docker build environments
│   ├── jesteros-production.dockerfile    # Production image
│   ├── kernel-xda-proven.dockerfile      # Kernel builder
│   ├── modern-packager.dockerfile        # Package builder
│   └── vanilla-debian-lenny.dockerfile   # Base Debian image
└── scripts/                    # Build automation
    └── build-rootfs.sh        # Rootfs creation script
```

## 🏃 Runtime System (`runtime/`)

**36 shell scripts implementing JesterOS userspace services**

```
runtime/
├── README_ARCHITECTURE.md      # 4-layer architecture guide
├── init/                       # Boot initialization (5 scripts)
│   ├── jesteros-init.sh       # Main init system
│   ├── jesteros-boot.sh       # Boot sequence
│   ├── jesteros-service-init.sh # Service startup
│   └── boot-jester.sh          # ASCII jester display
│
├── 1-ui/                       # User Interface Layer
│   ├── menu/                  # Menu systems (7 scripts)
│   │   ├── nook-menu.sh       # Main menu
│   │   ├── jester-menu.sh     # JesterOS menu
│   │   ├── git-menu.sh        # Git integration
│   │   └── power-menu.sh      # Power management
│   ├── display/               # Display management (2 scripts)
│   └── setup/                 # UI setup (1 script)
│
├── 2-application/             # Application Layer
│   ├── jesteros/             # Core services (7 scripts)
│   │   ├── daemon.sh         # Main daemon
│   │   ├── tracker.sh        # Writing statistics
│   │   ├── mood.sh           # Jester moods
│   │   ├── health-check.sh   # System health
│   │   └── manager.sh        # Service manager
│   └── writing/              # Writing tools (2 scripts)
│       ├── git-manager.sh    # Version control
│       └── git-installer.sh  # Git setup
│
├── 3-system/                  # System Services Layer
│   ├── common/               # Shared libraries (3 scripts)
│   │   ├── common.sh         # Common functions
│   │   ├── consolidated-functions.sh
│   │   └── service-functions.sh
│   ├── display/              # Display services (1 script)
│   ├── memory/               # Memory management (1 script)
│   └── services/             # System services (2 scripts)
│       ├── unified-monitor.sh
│       └── usb-keyboard-manager.sh
│
└── 4-hardware/               # Hardware Interface Layer
    ├── eink/                 # E-Ink display (1 script)
    ├── input/                # Input handling (1 script)
    │   └── button-handler.sh # Button events
    ├── power/                # Power management (2 scripts)
    │   ├── battery-monitor.sh
    │   └── power-optimizer.sh
    └── sensors/              # Sensor monitoring (2 scripts)
        └── temperature-monitor.sh
```

## 🧪 Testing (`tests/`)

**26 test scripts with comprehensive validation**

```
tests/
├── test-runner.sh              # Main test orchestrator
├── run-tests.sh               # Quick test launcher
├── validate-jesteros.sh       # JesterOS validation
├── comprehensive-validation.sh # Full test suite
│
├── Core Test Stages/
│   ├── 01-safety-check.sh    # Critical safety validation
│   ├── 02-boot-test.sh       # Boot sequence testing
│   ├── 03-functionality.sh   # Feature testing
│   ├── 04-docker-smoke.sh    # Docker validation
│   ├── 05-consistency-check.sh # File consistency
│   ├── 06-memory-guard.sh    # Memory limits
│   └── 07-writer-experience.sh # User experience
│
├── Test Infrastructure/
│   ├── test-config.sh         # Test configuration
│   ├── test-lib.sh           # Test library
│   └── test-logger.sh        # Test logging
│
└── archive/                   # Obsolete tests (preserved)
    └── obsolete-runners/      # 13 deprecated scripts
```

## 📚 Documentation (`docs/`)

**106+ documentation files across 12 categories**

```
docs/
├── 00-indexes/                # Master indexes (12 files)
│   ├── comprehensive-index.md # Main documentation hub
│   ├── BUILD_SYSTEM_INDEX.md # Docker build index
│   ├── deep-index-api-reference.md
│   └── deep-index-scripts-catalog.md
│
├── 01-getting-started/        # Setup guides (4 files)
├── 02-build/                  # Build documentation (11 files)
├── 03-jesteros/              # JesterOS docs (8 files)
├── 04-kernel/                # Kernel docs (10 files)
├── 05-api-reference/         # API docs (4 files)
├── 06-configuration/         # Config docs (3 files)
├── 07-deployment/            # Deployment guides (7 files)
├── 08-testing/               # Test docs (3 files)
├── 09-ui-design/             # UI/UX docs (3 files)
├── 10-troubleshooting/       # Fix guides (2 files)
├── 11-guides/                # Style guides (2 files)
│
├── hardware/                  # Hardware reference (10 files)
├── kernel-reference/         # Kernel 2.6.29 docs (6 files)
├── storage/                  # Storage strategy (2 files)
│
└── archive/                  # Historical docs (40+ files)
    ├── analysis-reports/     # Deep analysis
    ├── docker-experiments/   # Docker history
    ├── indexes/             # Old indexes
    └── migration/           # Migration records
```

## 🎨 Resources & Tools

```
tools/
├── fix-architecture-paths.sh  # Path correction utility
└── maintenance/               # Maintenance scripts

firmware/                      # Firmware binaries (generated)
images/                       # Boot images
releases/                     # Release packages
backups/                      # SD card backups
```

## 📊 Project Statistics

| Category | Count | Description |
|----------|-------|-------------|
| **Runtime Scripts** | 36 | Shell scripts for JesterOS services |
| **Test Scripts** | 26 | Active test suite (13 archived) |
| **Documentation** | 106+ | Markdown documentation files |
| **Docker Images** | 4 | Production build environments |
| **Architecture Layers** | 4 | UI → Application → System → Hardware |
| **Memory Budget** | 35MB | Available RAM for writing |
| **Boot Time** | <20s | Target boot to menu |

## 🚦 Current State (January 2025)

### ✅ Completed
- 4-layer runtime architecture implementation
- Comprehensive test suite with runner
- Docker build system consolidation
- USB keyboard support (GK61)
- JesterOS userspace services
- Complete documentation index

### 🔄 Active Development
- Hardware testing on actual Nook device
- Power management optimization
- Memory usage refinement

### 📅 Planned
- Spell checker integration
- Advanced writing analytics
- Battery life optimization (2+ weeks target)

## 💡 Key Paths for Development

| Task | Primary Files |
|------|--------------|
| **Build System** | `Makefile`, `build/docker/*.dockerfile` |
| **Runtime Services** | `runtime/2-application/jesteros/*.sh` |
| **Testing** | `tests/test-runner.sh`, `tests/0*.sh` |
| **Documentation** | `docs/00-indexes/comprehensive-index.md` |
| **Deployment** | `deploy-to-sd-gk61.sh`, `docs/07-deployment/` |

---

*Generated: January 2025 | JesterOS Version 1.0.0*