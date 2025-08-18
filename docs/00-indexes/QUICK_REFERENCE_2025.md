# ⚡ JesterOS Quick Reference Guide - 2025

*Essential commands and workflows for JesterOS development*

## 🚀 Quick Commands

### Build & Deploy
```bash
# Quick build (kernel only if unchanged)
make quick-build

# Full firmware build
make firmware

# Deploy to SD card (auto-detect)
make sd-deploy

# Deploy to specific device
make sd-deploy SD_DEVICE=/dev/sde

# Build specific Docker image
docker build -t jesteros-production -f build/docker/jesteros-production.dockerfile .
```

### Testing
```bash
# Run complete test suite
./tests/test-runner.sh

# Quick safety checks only
make test-quick

# Run specific test stage
./tests/01-safety-check.sh

# Test in Docker container
./tests/test-runner.sh jesteros-test validate-jesteros.sh

# Parallel testing (experimental)
make test-parallel
```

### Development Workflow
```bash
# 1. Load project context
/sc:load --refresh --cache

# 2. Make changes to runtime scripts
vim runtime/2-application/jesteros/daemon.sh

# 3. Run safety validation
./tests/01-safety-check.sh

# 4. Test in Docker
docker run -it --rm jesteros-production /usr/local/bin/nook-menu.sh

# 5. Deploy to SD card
sudo ./deploy-to-sd-gk61.sh
```

## 📁 Key File Locations

| Component | Path | Purpose |
|-----------|------|---------|
| **Main Build** | `Makefile` | Primary build system |
| **Docker Configs** | `build/docker/*.dockerfile` | Build environments |
| **Runtime Scripts** | `runtime/*/` | JesterOS services (36 files) |
| **Test Suite** | `tests/*.sh` | Testing scripts (26 files) |
| **Documentation** | `docs/00-indexes/` | Documentation hub |
| **Deployment** | `deploy-to-sd-gk61.sh` | SD card installer |

## 🏗️ Architecture Overview

```
Layer 1: UI (runtime/1-ui/)
  ├── menu/          # Menu systems
  ├── display/       # E-Ink management
  └── themes/        # ASCII art

Layer 2: Application (runtime/2-application/)
  ├── jesteros/      # Core services
  └── writing/       # Writing tools

Layer 3: System (runtime/3-system/)
  ├── common/        # Shared libraries
  ├── memory/        # Memory management
  └── services/      # System services

Layer 4: Hardware (runtime/4-hardware/)
  ├── eink/          # Display driver
  ├── input/         # Button/keyboard
  ├── power/         # Battery management
  └── sensors/       # Temperature monitoring
```

## 🧪 Test Stages

1. **Safety Check** (`01-safety-check.sh`) - Critical validation
2. **Boot Test** (`02-boot-test.sh`) - Boot sequence
3. **Functionality** (`03-functionality.sh`) - Feature testing
4. **Docker Smoke** (`04-docker-smoke.sh`) - Container validation
5. **Consistency** (`05-consistency-check.sh`) - File integrity
6. **Memory Guard** (`06-memory-guard.sh`) - RAM limits
7. **Writer Experience** (`07-writer-experience.sh`) - UX testing

## 💾 Memory Budget

| Component | Usage | Limit |
|-----------|-------|-------|
| **Android Base** | 188MB | Fixed |
| **JesterOS** | 10MB | Maximum |
| **Vim** | 8MB | Minimal config |
| **Available** | 27MB | For writing |
| **Total RAM** | 233MB | Hardware limit |

## 🔧 Common Issues & Fixes

### JesterOS Services Not Running
```bash
# Check service status
ps aux | grep jesteros

# View logs
cat /var/log/jesteros.log

# Manual start
/usr/local/bin/jesteros-userspace.sh
```

### Memory Exhaustion
```bash
# Check current usage
free -h

# Kill unnecessary processes
pkill -f unnecessary_service

# Clear caches
sync && echo 3 > /proc/sys/vm/drop_caches
```

### E-Ink Display Issues
```bash
# Manual refresh
fbink -c

# Check framebuffer
ls -la /dev/fb0

# Test display
echo "Test" | fbink -
```

### SD Card Mount Errors
```bash
# Check filesystem
sudo fsck.vfat -r /dev/sdX1

# Remount
sudo umount /mnt/nook_boot
sudo mount /dev/sdX1 /mnt/nook_boot
```

## 🎯 Performance Targets

| Metric | Target | Current |
|--------|--------|---------|
| **Boot Time** | <20s | ✅ 18s |
| **Vim Launch** | <2s | ✅ 1.5s |
| **Menu Response** | <500ms | ✅ 300ms |
| **RAM Usage** | <96MB | ✅ 85MB |
| **Battery Life** | 2 weeks | 🔄 Testing |

## 📝 Shell Script Safety Template

```bash
#!/bin/bash
# Script description
set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

# Source common functions
. "$(dirname "$0")/../lib/common.sh"

# Validate input
validate_path() {
    [[ "$1" =~ ^/root/(notes|drafts|scrolls)/ ]] || return 1
}

# Main logic
main() {
    # Implementation
}

main "$@"
```

## 🚦 Git Workflow

```bash
# Check current status
git status

# Stage changes
git add runtime/

# Commit with message
git commit -m "feat: improve jester mood system"

# Push to branch
git push origin dev

# Create pull request
gh pr create --title "Improve jester moods" --body "..."
```

## 📚 Essential Documentation

- **Philosophy**: [CLAUDE.md](../../CLAUDE.md)
- **Architecture**: [runtime/README_ARCHITECTURE.md](../../runtime/README_ARCHITECTURE.md)
- **Build Guide**: [docs/02-build/build-system-documentation.md](../02-build/build-system-documentation.md)
- **Test Guide**: [docs/08-testing/test-suite-documentation.md](../08-testing/test-suite-documentation.md)
- **Main Index**: [docs/00-indexes/comprehensive-index.md](comprehensive-index.md)

## 🎭 JesterOS Service Commands

```bash
# View jester mood
cat /var/jesteros/jester

# Check writing stats
cat /var/jesteros/typewriter/stats

# System health
cat /var/jesteros/health/status

# Service status
jesteros-service-manager.sh status

# Monitor all services
jesteros-service-manager.sh monitor
```

---

*"By quill and compiler, we craft digital magic!"* 🪶✨