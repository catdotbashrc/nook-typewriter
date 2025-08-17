# PROJECT_INDEX_2024.md - SUPERSEDED

**This project index has been superseded by the comprehensive documentation index.**

Please refer to:
- `/docs/00-indexes/comprehensive-index.md` - Current complete index with better organization
- Individual documentation in organized `/docs/` structure

This file scheduled for removal to save memory (~15KB).

---

## 🎯 Quick Navigation

### Primary Entry Points
- **[README.md](README.md)** - Project overview and philosophy
- **[CLAUDE.md](CLAUDE.md)** - Essential guidance for Claude Code
- **[QUICK_START.md](QUICK_START.md)** - Getting started guide
- **[runtime/README_ARCHITECTURE.md](runtime/README_ARCHITECTURE.md)** - 4-layer architecture

### Recent Updates
- **[DOCS_UPDATE_SUMMARY.md](DOCS_UPDATE_SUMMARY.md)** - Documentation improvements (60+ fixes)
- **[CLEANUP_DRY_RUN_REPORT.md](CLEANUP_DRY_RUN_REPORT.md)** - Cleanup analysis
- **[.context-cache.json](.context-cache.json)** - Cached project context

---

## 🏗️ Architecture & Design

### Core Architecture
- **[ARCHITECTURE_4LAYER.md](ARCHITECTURE_4LAYER.md)** - 4-layer system design
- **[runtime/README_ARCHITECTURE.md](runtime/README_ARCHITECTURE.md)** - Runtime structure
- **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** - Directory organization

### Migration & Evolution
- **[ARCHITECTURE_RESTRUCTURE.md](ARCHITECTURE_RESTRUCTURE.md)** - Restructuring details
- **[runtime/MIGRATION_COMPLETED.md](runtime/MIGRATION_COMPLETED.md)** - Migration status
- **[docs/archive/migration/](docs/archive/migration/)** - Historical migration docs

---

## 💻 Runtime Implementation (4-Layer Architecture)

### Layer 1: User Interface (`runtime/1-ui/`)
- **[runtime/1-ui/menu/](runtime/1-ui/menu/)** - Menu systems
  - `menu.sh` - Main menu interface
  - `jester-menu.sh` - JesterOS menu
  - `power-menu.sh` - Power management menu
- **[runtime/1-ui/display/](runtime/1-ui/display/)** - Display management
- **[runtime/1-ui/themes/](runtime/1-ui/themes/)** - ASCII art and themes

### Layer 2: Application Services (`runtime/2-application/`)
- **[runtime/2-application/jesteros/](runtime/2-application/jesteros/)** - JesterOS services
  - `daemon.sh` - Core daemon orchestrator
  - `mood.sh` - ASCII art jester mood system
  - `tracker.sh` - Writing statistics tracker
  - `manager.sh` - Service management
- **[runtime/2-application/writing/](runtime/2-application/writing/)** - Writing tools

### Layer 3: System Services (`runtime/3-system/`)
- **[runtime/3-system/common/](runtime/3-system/common/)** - Common libraries
  - `common.sh` - Core library functions
  - `service-functions.sh` - Service utilities
- **[runtime/3-system/boot/](runtime/3-system/boot/)** - Boot scripts
- **[runtime/3-system/memory/](runtime/3-system/memory/)** - Memory management

### Layer 4: Hardware Abstraction (`runtime/4-hardware/`)
- **[runtime/4-hardware/eink/](runtime/4-hardware/eink/)** - E-Ink display control
- **[runtime/4-hardware/power/](runtime/4-hardware/power/)** - Power management
- **[runtime/4-hardware/sensors/](runtime/4-hardware/sensors/)** - Temperature monitoring
- **[runtime/4-hardware/input/](runtime/4-hardware/input/)** - Button/USB input

---

## 📖 Documentation

### Primary Documentation (`docs/`)
- **[docs/00-indexes/](docs/00-indexes/)** - Documentation indexes
- **[docs/01-getting-started/](docs/01-getting-started/)** - Quick start guides
- **[docs/02-build/](docs/02-build/)** - Build system documentation
- **[docs/03-jesteros/](docs/03-jesteros/)** - JesterOS documentation
- **[docs/04-kernel/](docs/04-kernel/)** - Kernel build reference
- **[docs/05-api-reference/](docs/05-api-reference/)** - API documentation
- **[docs/06-configuration/](docs/06-configuration/)** - Configuration guides
- **[docs/07-deployment/](docs/07-deployment/)** - Deployment procedures
- **[docs/08-testing/](docs/08-testing/)** - Testing documentation
- **[docs/09-ui-design/](docs/09-ui-design/)** - UI design specs
- **[docs/10-troubleshooting/](docs/10-troubleshooting/)** - Problem solving
- **[docs/11-guides/](docs/11-guides/)** - Style and usage guides

### Hardware Documentation
- **[docs/hardware/](docs/hardware/)** - Hardware reference
- **[docs/kernel/](docs/kernel/)** - Kernel API documentation
- **[docs/storage/](docs/storage/)** - Storage strategy

### Archives
- **[docs/archive/](docs/archive/)** - Historical documentation
- **[docs/archive/analysis-reports/](docs/archive/analysis-reports/)** - Analysis reports
- **[docs/archive/indexes/](docs/archive/indexes/)** - Old index files
- **[docs/archive/migration/](docs/archive/migration/)** - Migration history

---

## 🛠️ Build & Deployment

### Build System
- **[build/](build/)** - Build infrastructure
- **[build/docker/](build/docker/)** - Docker configurations
- **[development/docker/](development/docker/)** - Docker files
  - `nookwriter-optimized.dockerfile` - Main build image
  - `minimal-boot.dockerfile` - Minimal boot environment

### Deployment
- **[deployment_package/](deployment_package/)** - Ready-to-deploy artifacts
- **[tools/deployment/](tools/deployment/)** - Deployment scripts
- **[scripts/deployment/](scripts/deployment/)** - SD card creation

### Firmware & Boot
- **[firmware/boot/](firmware/boot/)** - Kernel and bootloaders
  - `uImage` - Linux 2.6.29 kernel
  - `u-boot.bin` - Bootloader
- **[boot/](boot/)** - Boot configuration files

---

## 🧪 Testing & Quality

### Test Infrastructure
- **[tests/](tests/)** - Main test suite
  - `run-tests.sh` - Primary test runner
  - `test-improvements.sh` - Improvement validation
  - `phase*-validation.sh` - Phased testing
- **[scripts/test/](scripts/test/)** - Test framework
- **[tools/testing/](tools/testing/)** - Test utilities

### Reports
- **[TEST_REPORT.md](TEST_REPORT.md)** - Latest test results
- **[SCRIPT_QUALITY_REPORT.md](SCRIPT_QUALITY_REPORT.md)** - Script quality analysis
- **[SECURITY_IMPROVEMENTS_SUMMARY.md](SECURITY_IMPROVEMENTS_SUMMARY.md)** - Security updates
- **[tests/reports/](tests/reports/)** - Historical test reports

---

## 🔧 Tools & Utilities

### Development Tools
- **[tools/](tools/)** - Development utilities
- **[tools/maintenance/](tools/maintenance/)** - Maintenance scripts
- **[tools/debug/](tools/debug/)** - Debugging tools
- **[tools/setup/](tools/setup/)** - Setup utilities

### Scripts
- **[scripts/](scripts/)** - Core scripts
- **[scripts/lib/common.sh](scripts/lib/common.sh)** - Common library

---

## 📋 Configuration

### System Configuration
- **[runtime/configs/](runtime/configs/)** - Runtime configurations
  - `nook.conf` - Main configuration
  - `system/` - System configs
  - `services/` - Service configs
  - `vim/` - Vim configurations

### Environment
- **[.env](.env)** - Build environment variables
- **[build.conf](build.conf)** - Build configuration
- **[project.conf](project.conf)** - Project settings

---

## 📊 Recent Work & Status

### Completed Improvements
- ✅ Migrated from 5-layer to 4-layer architecture
- ✅ Transitioned JesterOS from kernel modules to userspace
- ✅ Fixed 60+ documentation references (source/ → runtime/)
- ✅ Standardized naming (SquireOS → JesterOS)
- ✅ Created comprehensive cleanup analysis

### Pending Tasks
- 📝 20+ documentation files still have old references
- 🗑️ 4 empty directories to clean up
- 📦 Archive 4 migration documents
- 📚 Consolidate 18 duplicate README files

### Key Reports
- **[IMPROVEMENT_REPORT.md](IMPROVEMENT_REPORT.md)** - Recent improvements
- **[CLEANUP_SUMMARY.md](CLEANUP_SUMMARY.md)** - Cleanup status
- **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)** - Deployment steps
- **[DEPLOYMENT_ESTIMATE.md](DEPLOYMENT_ESTIMATE.md)** - Time estimates

---

## 🎭 JesterOS Components

### Core Services
- `/var/jesteros/` - Userspace interface (not /proc/)
- `jester` - ASCII art mood system
- `typewriter/stats` - Writing statistics
- `wisdom` - Inspirational quotes

### Documentation
- **[JESTEROS_README_SUPPLEMENT.md](JESTEROS_README_SUPPLEMENT.md)** - JesterOS details
- **[docs/03-jesteros/](docs/03-jesteros/)** - Complete JesterOS docs

---

## 🔍 Quick Reference

### Memory Budget
- Total: 256MB
- OS Reserved: 95MB
- Vim Reserved: 10MB
- Writing Space: 160MB (SACRED)

### Performance Targets
- Boot: <20 seconds
- Vim Launch: <2 seconds
- Menu Response: <500ms
- File Save: <1 second

### Hardware Specs
- Device: Nook Simple Touch
- CPU: 800MHz ARM OMAP3621
- Display: 6" E-Ink (800x600, 16 grayscale)
- Storage: SD card based

---

## 📝 Important Notes

### Philosophy
> "Writers over features - Transform a $20 e-reader into a $400 distraction-free writing device"

### Key Principles
1. **Userspace-only** - JesterOS runs entirely in userspace (no kernel modules)
2. **4-Layer Architecture** - UI → Application → System → Hardware
3. **Memory Sacred** - 160MB reserved for writing (DO NOT TOUCH)
4. **E-Ink Aware** - All interfaces designed for E-Ink constraints

### Recent Context
- Project uses 4-layer architecture (simplified from 5-layer)
- JesterOS moved from kernel modules to userspace services
- Documentation being updated to reflect new structure
- Cleanup in progress to remove migration artifacts

---

## 🔗 External Resources

### Development
- **[KERNEL_COMPILATION_DESIGN.md](KERNEL_COMPILATION_DESIGN.md)** - Kernel build design
- **[REVERSE_ENGINEERING.md](REVERSE_ENGINEERING.md)** - Hardware analysis
- **[HARDWARE_CONSTRAINED_CONTEXT.md](HARDWARE_CONSTRAINED_CONTEXT.md)** - Hardware limits

### Workflow
- **[SC_WORKFLOW.md](SC_WORKFLOW.md)** - SuperClaude workflow
- **[JESTEROS_SUPERCLAUDE_GUIDE.md](JESTEROS_SUPERCLAUDE_GUIDE.md)** - SC guide

---

*Last Updated: December 2024*  
*Index Version: 2.0*  
*"By quill and candlelight, we organize for clarity!"* 🕯️📜