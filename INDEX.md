# JesterOS Project Index

## 🎯 Quick Navigation

### Core Files
- **[README.md](README.md)** - Project overview and quick start
- **[CLAUDE.md](CLAUDE.md)** - Development constraints and philosophy
- **[Makefile](Makefile)** - Build system entry point
- **[LICENSE](LICENSE)** - GPL v2 license

### 📁 Project Structure

```
nook/
├── build/           # Build system and Docker configurations
├── docs/            # Comprehensive documentation
├── firmware/        # Root filesystem and boot images
├── source/          # JesterOS source code
├── tests/           # Test suite and validation
├── tools/           # Development utilities
└── utilities/       # Helper scripts
```

## 📚 Documentation

### Getting Started
- **[docs/01-getting-started/](docs/01-getting-started/)** - Boot guides and setup
  - `quick-boot-guide.md` - 5-minute quickstart
  - `sd-card-boot-guide.md` - SD card preparation
  - `usb-keyboard-setup.md` - External keyboard setup

### Build System
- **[docs/02-build/](docs/02-build/)** - Build documentation
  - `build-system-documentation.md` - Docker and compilation
  - Build optimization summaries (Phase 2 & 3)
  - Workflow improvements

### JesterOS Core
- **[docs/03-jesteros/](docs/03-jesteros/)** - Userspace implementation
  - `jesteros-userspace-solution.md` - Architecture overview
  - `jesteros-api-complete.md` - Complete API reference
  - ASCII art and UI design

### Kernel & Modules
- **[docs/04-kernel/](docs/04-kernel/)** - Kernel documentation
  - `kernel-api-reference.md` - Module development
  - `kernel-build-reference.md` - Build process
  - Module guides and integration

### Hardware Reference
- **[docs/hardware/](docs/hardware/)** - Nook hardware specs
  - `NOOK_HARDWARE_REFERENCE.md` - Complete hardware details
  - E-Ink display, power management, sensors
  - USB keyboard and button navigation

## 🛠️ Source Code

### Core Components
- **[source/kernel/](source/kernel/)** - Linux 2.6.29 kernel (submodule)
- **[source/scripts/](source/scripts/)** - System scripts
  - `boot/` - Boot sequence scripts
  - `menu/` - Menu system implementation
  - `services/` - JesterOS services
  - `lib/` - Shared libraries

### Services (`/var/jesteros/`)
- **jester-daemon** - ASCII art companion
- **jesteros-tracker** - Writing statistics
- **health-check** - System monitoring
- **service-manager** - Service orchestration

## 🧪 Testing

### Test Categories
- **[tests/](tests/)** - Complete test suite
  - `test-runner.sh` - Main test orchestrator
  - Docker build verification
  - Kernel module testing
  - Service validation
  - Hardware compatibility

## 🔧 Build & Deploy

### Docker Images
- **[build/docker/](build/docker/)** - Dockerfiles
  - `jesteros-base.dockerfile` - Base system
  - `jesteros-production.dockerfile` - Production build

### Key Commands
```bash
make firmware        # Build complete system
make lenny-rootfs   # Build rootfs with vim
make test           # Run safety tests
./deploy-to-sd.sh   # Deploy to SD card
```

## 📊 Project Status

### ✅ Completed
- Userspace JesterOS implementation
- Docker build environment
- SD card deployment scripts
- ASCII jester with moods
- Writing statistics tracking
- Service architecture

### 🔄 In Progress
- Hardware boot verification
- Vim integration optimization
- Power management

### 📅 Future
- Spell checker integration
- Advanced analytics
- Battery optimization (2+ weeks)

## 🔍 Work Areas

### Scratch Space
- **[docs/.scratch/](docs/.scratch/)** - WIP documentation
  - `analysis/` - Research notes
  - `debug/` - Debug logs
  - `drafts/` - Document drafts
  - `research/` - Technical research
  - `todo/` - Task tracking

## 💾 Memory Budget

```
Android Base:  188MB (device measured)
JesterOS:       10MB (ABSOLUTE MAX)
Vim:             8MB (minimal config)
Writing Space:  27MB (sacred space)
```

## 🚀 Quick Commands

```bash
# Build
./build_kernel.sh
docker build -t jesteros-base -f build/docker/jesteros-base.dockerfile .

# Test
./tests/test-runner.sh jesteros-base simple-test.sh

# Deploy
sudo ./deploy-to-sd.sh

# Services
jesteros-service-manager.sh start all
cat /var/jesteros/jester
```

## 📜 Philosophy

> **Writers > Features**  
> **RAM saved = Words written**  
> **By quill and compiler, we craft digital magic!**

---

*Last Updated: January 2025*  
*Version: JesterOS 1.0 (Userspace)*