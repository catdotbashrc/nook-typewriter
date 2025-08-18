# ⚡ Nook Typewriter Quick Reference

*Essential commands and paths for rapid development*

## 🚀 Most Used Commands

### Build & Deploy
```bash
make firmware          # Complete system build (kernel + rootfs)
make kernel           # Build kernel only
make lenny-rootfs     # Build rootfs only
make sd-deploy        # Deploy to SD card (with safety checks)
make installer        # Create Phoenix-compatible installer
```

### Testing & Validation
```bash
make test-quick       # Run show-stopper tests
make battery-check    # Check battery optimization
make touch-recovery-doc # View touch recovery info
docker run -it --rm jesteros-production vim  # Test locally
```

### Development
```bash
cd source/kernel      # Kernel source (Linux 2.6.29)
cd runtime/           # Userspace services (4 layers)
cd build/docker/      # Docker configurations
vim CLAUDE.md         # Update AI guidelines
```

## 📁 Key Directories

```
source/kernel/        → Kernel source & modules
source/scripts/       → Boot, menu, service scripts
source/configs/       → System configurations
build/docker/         → Docker build files
firmware/            → Build output
docs/00-indexes/     → Documentation hub
tests/               → Test suites
```

## 📄 Essential Files

| File | Purpose | Command |
|------|---------|---------|
| `README.md` | Project overview | `cat README.md` |
| `CLAUDE.md` | AI guidelines | `vim CLAUDE.md` |
| `Makefile` | Build system | `make help` |
| `build.conf` | Build config | `source build.conf` |
| `.project-context-cache.json` | Cached context | Auto-loaded |

## 🎯 Common Workflows

### 1. Quick Development Cycle
```bash
make quick-build      # Build changes
make test            # Validate
make sd-deploy       # Deploy to device
```

### 2. New Feature Development
```bash
# 1. Update code
vim source/scripts/menu/new-feature.sh

# 2. Test locally
docker run -it --rm nook-writer /bin/bash

# 3. Build & deploy
make firmware && make sd-deploy
```

### 3. Documentation Update
```bash
# Edit docs
vim docs/03-jesteros/new-guide.md

# Update index
vim PROJECT_INDEX.md

# Commit changes
git add -A && git commit -m "docs: add new guide"
```

## 🔧 Docker Commands

```bash
# Build images
docker build -t nook-writer -f build/docker/nookwriter-optimized.dockerfile .
docker build -t nook-mvp-rootfs -f build/docker/minimal-boot.dockerfile .

# Export for deployment
docker create --name nook-export nook-writer
docker export nook-export | gzip > nook-writer.tar.gz
docker rm nook-export

# Check memory usage
docker stats nook-writer --no-stream --format "RAM: {{.MemUsage}}"
```

## 🎭 JesterOS Paths

### On Device
```
/var/jesteros/jester           → ASCII mood display
/var/jesteros/typewriter/stats → Writing statistics  
/var/jesteros/wisdom           → Writing quotes
/usr/local/bin/jesteros-*      → Service scripts
```

### In Source
```
source/scripts/services/jesteros-userspace.sh
source/configs/ascii/jester_*.txt
```

## ⚠️ Memory Limits

```yaml
Total RAM:      256MB
OS Reserved:    95MB  ← MUST stay under
Vim Reserved:   10MB
Writing Space:  160MB ← NEVER touch
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Boot loop | See `docs/10-troubleshooting/boot-loop-fix.md` |
| No JesterOS | Run `/usr/local/bin/jesteros-userspace.sh` |
| Build fails | Check `build.log`, run `make clean` |
| Memory full | Check with `free -h`, remove vim plugins |
| No E-Ink | Normal in Docker, use `fbink -c` on device |

## 📝 Git Workflow

```bash
git status           # Check changes
git add -A          # Stage all
git commit -m "type: description"  # Commit
git push origin dev # Push to dev branch
```

### Commit Types
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `refactor:` Code refactoring
- `test:` Testing
- `chore:` Maintenance

## 🏰 Project Philosophy

> "Every feature is a potential distraction"
> "RAM saved is words written"  
> "E-Ink limitations are features"
> "By quill and candlelight"

## 🔗 Quick Links

- [Documentation Hub](docs/00-indexes/README.md)
- [Build Guide](docs/02-build/build-system-documentation.md)
- [JesterOS Guide](docs/03-jesteros/jesteros-userspace-solution.md)
- [Testing Guide](docs/08-testing/developer-testing-guide.md)
- [Troubleshooting](docs/10-troubleshooting/)

---
*Need more detail? Check [PROJECT_INDEX.md](PROJECT_INDEX.md) for complete navigation*