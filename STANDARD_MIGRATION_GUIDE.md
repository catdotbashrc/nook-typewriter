# JesterOS Standard Structure Migration Guide

> **Purpose**: Migrate to industry-standard directory structure  
> **Benefit**: Any developer can understand and contribute immediately  
> **Time**: ~30 minutes

## Target Structure (Industry Standard)

```
nook/
├── src/                     # All source code
│   ├── init/               # System initialization
│   ├── core/               # Core services
│   ├── hal/                # Hardware abstraction layer
│   ├── services/           # System services
│   └── apps/               # User applications
├── platform/               # Platform-specific files
│   └── nook-touch/         # Nook hardware files
├── config/                 # Configuration files
├── scripts/                # Build/deploy scripts
├── test/                   # Test suite
├── docs/                   # Documentation
├── docker/                 # Docker files
├── vendor/                 # Third-party code
└── build/                  # Build outputs (gitignored)
```

## Migration Steps

### Step 1: Create Standard Structure
```bash
# Create the industry-standard directories
mkdir -p src/{init,core,hal,services,apps}
mkdir -p platform/nook-touch/{bootloader,kernel,firmware}
mkdir -p config/{kernel,system,user}
mkdir -p scripts/{build,deploy,test}
mkdir -p test/{unit,integration,system}
mkdir -p docker
mkdir -p vendor
mkdir -p assets/{fonts,images,themes}
```

### Step 2: Migrate Runtime → src/
```bash
# Init and boot scripts → src/init/
git mv runtime/init/*.sh src/init/

# Core system functions → src/core/
git mv runtime/3-system/common/*.sh src/core/
git mv runtime/3-system/memory/*.sh src/core/

# Hardware abstraction → src/hal/
mkdir -p src/hal/{eink,buttons,power,usb}
git mv runtime/4-hardware/input/button-handler.sh src/hal/buttons/
git mv runtime/4-hardware/input/usb-keyboard*.sh src/hal/usb/
git mv runtime/4-hardware/power/*.sh src/hal/power/
git mv runtime/4-hardware/sensors/*.sh src/hal/sensors/
git mv runtime/4-hardware/eink/*.sh src/hal/eink/

# Services → src/services/
mkdir -p src/services/{jester,menu,tracker}
git mv runtime/1-ui/display/*.sh src/services/menu/
git mv runtime/1-ui/menu/*.sh src/services/menu/
git mv runtime/2-application/jesteros/jester*.sh src/services/jester/
git mv runtime/2-application/jesteros/tracker.sh src/services/tracker/

# Applications → src/apps/
mkdir -p src/apps/{vim,git}
git mv runtime/2-application/writing/git*.sh src/apps/git/
```

### Step 3: Migrate Firmware → platform/
```bash
# Platform-specific files
git mv firmware/boot/MLO platform/nook-touch/bootloader/
git mv firmware/boot/u-boot.bin platform/nook-touch/bootloader/
git mv firmware/boot/uImage platform/nook-touch/kernel/
git mv firmware/kernel/uImage platform/nook-touch/kernel/

# Proprietary firmware blobs
git mv firmware/dsp/* platform/nook-touch/firmware/
git mv firmware/android/* platform/nook-touch/firmware/
```

### Step 4: Migrate Configs → config/
```bash
# System configuration
git mv runtime/config/*.conf config/system/
git mv runtime/configs/system/* config/system/

# User configuration
git mv runtime/configs/vim/* config/user/vim/

# Kernel configuration
git mv build/kernel/*.config config/kernel/
```

### Step 5: Migrate Build Scripts → scripts/
```bash
# Build scripts
git mv build/scripts/build*.sh scripts/build/
git mv build/scripts/create*.sh scripts/build/

# Deployment scripts
git mv build/scripts/deploy*.sh scripts/deploy/
git mv build/scripts/extract*.sh scripts/deploy/

# Docker scripts
git mv docker/*.dockerfile docker/
git mv build/scripts/fix-docker*.sh scripts/build/
```

### Step 6: Migrate Assets
```bash
# Themes and ASCII art
git mv runtime/configs/ascii/* assets/themes/
git mv runtime/1-ui/themes/* assets/themes/
```

### Step 7: Move Base Images → vendor/
```bash
# External base images
mkdir -p vendor/images
git mv images/*.img vendor/images/
git mv docker/base-images/*.img vendor/images/ 2>/dev/null || true
```

### Step 8: Update Path References
```bash
# Update all script paths
find src -type f -name "*.sh" -exec sed -i \
  -e 's|/runtime/|/src/|g' \
  -e 's|runtime/|src/|g' \
  -e 's|/firmware/|/platform/nook-touch/|g' {} \;

# Update Dockerfile paths
find docker -type f -name "*[Dd]ockerfile*" -exec sed -i \
  -e 's|runtime/|src/|g' \
  -e 's|firmware/|platform/nook-touch/|g' {} \;

# Update Makefile
sed -i \
  -e 's|runtime/|src/|g' \
  -e 's|firmware/|platform/nook-touch/|g' \
  -e 's|SCRIPTS_DIR :=.*|SCRIPTS_DIR := scripts|g' \
  -e 's|DOCKER_DIR :=.*|DOCKER_DIR := docker|g' Makefile

# Update test paths
find test -type f -name "*.sh" -exec sed -i \
  -e 's|runtime/|src/|g' \
  -e 's|firmware/|platform/nook-touch/|g' {} \;
```

### Step 9: Clean Up
```bash
# Remove empty directories
find . -type d -empty -delete

# Remove old structure
rmdir runtime 2>/dev/null || true
rmdir firmware 2>/dev/null || true
rmdir images 2>/dev/null || true
```

### Step 10: Update Documentation
```bash
# Update key documentation
sed -i 's|runtime/|src/|g' README.md
sed -i 's|firmware/|platform/nook-touch/|g' README.md
sed -i 's|runtime/|src/|g' docs/*.md
sed -i 's|firmware/|platform/nook-touch/|g' docs/*.md

# Update CLAUDE.md
sed -i 's|runtime/|src/|g' CLAUDE.md
sed -i 's|firmware/|platform/nook-touch/|g' CLAUDE.md
```

## Create Standard Root Files

### 1. Update README.md Header
```markdown
# JesterOS

Transform a Barnes & Noble Nook into a distraction-free writing device.

## Quick Start

```bash
make build    # Build the system
make test     # Run tests
make deploy   # Deploy to SD card
```

## Project Structure

- `src/` - Source code
- `config/` - Configuration files
- `platform/` - Hardware-specific files
- `scripts/` - Build and deployment tools
- `test/` - Test suite
- `docs/` - Documentation
```

### 2. Create CONTRIBUTING.md
```bash
cat > CONTRIBUTING.md << 'EOF'
# Contributing to JesterOS

## Development Setup
1. Clone the repository
2. Run `scripts/setup.sh`
3. Build with `make`

## Code Style
- Shell scripts: Use shellcheck
- C code: Follow Linux kernel style
- Documentation: Markdown

## Testing
Run `make test` before submitting PRs.
EOF
```

### 3. Add .editorconfig
```bash
cat > .editorconfig << 'EOF'
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.{sh,bash}]
indent_size = 2

[Makefile]
indent_style = tab

[*.md]
trim_trailing_whitespace = false
EOF
```

## Verification

### Check Structure
```bash
tree -L 2 -d
# Should show clean standard structure
```

### Test Build
```bash
make clean && make
```

### Run Tests
```bash
make test
```

## Benefits of Standard Structure

1. **Instant Recognition**: Any developer knows `src/` = source code
2. **Tool Support**: IDEs and tools expect these paths
3. **Clear Separation**: Source, config, platform, build clearly separated
4. **Industry Standard**: Follows embedded Linux conventions
5. **Onboarding**: New developers productive in minutes

## Rollback

If needed:
```bash
git reset --hard HEAD
# Or restore from backup branch
git checkout backup-before-migration
```

---

**Ready?** This creates a structure any embedded Linux developer will recognize instantly.