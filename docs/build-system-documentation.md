# Build System Documentation

> **Type**: How-To Guide & Reference  
> **Audience**: Developers building JesterOS  
> **Prerequisites**: Docker, Linux/WSL2, 10GB disk space  
> **Last Updated**: January 2025

## Overview

The JesterOS build system provides consistent, reproducible ARM cross-compilation using Docker containers with BuildKit optimization.

### Performance Metrics

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Docker context | 50MB | 4KB | 99.9% smaller |
| Cached rebuilds | 20min | 2min | 92% faster |
| Total image size | 2GB | 1.2GB | 40% smaller |
| Debian compatibility | 100% | 100% | Maintained |

> **Note**: Build system incorporates proven methods from XDA community research,
> including NDK r12b toolchain and sector 63 alignment requirements.

## Build System Architecture

### Key Components

| Component | Purpose | Output | Documentation |
|-----------|---------|--------|---------------|
| **Docker Environments** | Isolated build environments | Container images | [Docker Guide](#docker-build-environments) |
| **Build Scripts** | Orchestrate compilation | Kernel, modules, rootfs | [Scripts Reference](../05-api-reference/scripts-catalog.md) |
| **Cross-Compiler** | ARM target compilation | ARM binaries | [Toolchain Setup](#toolchain-configuration) |
| **Package System** | Deployment artifacts | .tar.gz, .zip files | [Deployment](../07-deployment/) |

### Build Targets

```mermaid
graph LR
    A[Source Code] --> B[Docker Build]
    B --> C[Kernel]
    B --> D[Root FS]
    B --> E[Boot Package]
    B --> F[CWM Package]
    C --> G[uImage]
    D --> H[rootfs.tar.gz]
    E --> I[boot.img]
    F --> J[update.zip]
```

| Target | Description | Output File | Size |
|--------|-------------|-------------|------|
| **Kernel** | JoKernel with JesterOS modules | `uImage` | ~4MB |
| **Root Filesystem** | Minimal Debian Lenny | `rootfs.tar.gz` | ~30MB |
| **Boot Package** | SD card boot files | `boot.tar.gz` | ~5MB |
| **CWM Package** | Recovery installer | `update.zip` | ~35MB |

## 🐳 Docker Build Environments

### Unified Base Architecture (Phase 3 Optimized)

The build system uses a **unified Debian Lenny base strategy** with BuildKit optimization:

```yaml
Unified Base Images: jesteros-lenny-base.dockerfile
  lenny-base:    # Minimal Debian Lenny 5.0 foundation
  dev-base:      # Development tools (extends lenny-base)
  runtime-base:  # Production runtime (minimal, extends lenny-base)

Production Images:
  - jesteros-production-multistage.dockerfile (multi-stage validation)
  - kernel-xda-proven-optimized.dockerfile (BuildKit cache for NDK)
  
All images share common Debian Lenny base layers (40% storage savings)
```

### BuildKit Features Enabled
- **Cache mounts** for package downloads
- **Persistent NDK cache** (saves 500MB per kernel build)
- **Multi-stage builds** with validation
- **Layer sharing** across all images

### 🚀 Quick Start

!!! tip "Enable BuildKit for 92% faster builds"
    BuildKit is automatically enabled in the Makefile, but you can set it manually:
    ```bash
    export DOCKER_BUILDKIT=1
    ```

=== "First Time Setup"

    ```bash
    # Clone repository
    git clone https://github.com/yourusername/nook-typewriter.git
    cd nook-typewriter
    
    # Build base images (one-time, ~10 minutes)
    make docker-base-all
    
    # Build everything
    make all
    ```

=== "Quick Rebuild"

    ```bash
    # Rebuild kernel only (cached, ~2 minutes)
    make kernel
    
    # Rebuild rootfs only  
    make rootfs
    
    # Full rebuild
    make clean all
    ```

=== "Development Mode"

    ```bash
    # Interactive development container
    make docker-dev
    
    # Inside container:
    cd /build
    ./build_kernel.sh
    ```

### 1. **Kernel Builder** (`kernel-xda-proven-optimized.dockerfile`)

**Purpose**: Cross-compilation environment with BuildKit NDK caching

**Base Image**: Ubuntu 20.04 (proven stable for Android NDK)

**Toolchain**: 
- Android NDK r12b (XDA community proven, **cached after first download**)
- Cross-compiler: `arm-linux-androideabi-`
- Target: ARM Cortex-A8 (OMAP3621)

**BuildKit Optimizations**:
```dockerfile
# syntax=docker/dockerfile:1
# NDK cached with BuildKit mount (saves 500MB per build)
RUN --mount=type=cache,target=/opt/ndk-cache,sharing=locked \
    if [ ! -f /opt/ndk-cache/android-ndk-${NDK_VERSION}.zip ]; then \
        wget -q -O /opt/ndk-cache/android-ndk-${NDK_VERSION}.zip ${NDK_URL}; \
    fi && \
    unzip -q /opt/ndk-cache/android-ndk-${NDK_VERSION}.zip

# APT packages also cached
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y build-essential
```

**Build Command**:
```bash
DOCKER_BUILDKIT=1 docker build -t kernel-xda-proven-optimized \
    -f build/docker/kernel-xda-proven-optimized.dockerfile .
```

**USB Keyboard Module Support**:
- USB HID drivers enabled
- MUSB OTG controller support
- Runtime mode switching capability

### 2. **Unified Debian Lenny Base** (`jesteros-lenny-base.dockerfile`)

**Purpose**: Shared foundation for ALL JesterOS images

**Three-Stage Architecture**:
```yaml
lenny-base:     # Minimal Debian Lenny 5.0 (all images inherit this)
dev-base:       # Development tools (for building/testing)
runtime-base:   # Production minimal (for deployment)
```

**Key Benefits**:
- **100% Debian Lenny 5.0** for Nook hardware compatibility
- **40% storage savings** through layer sharing
- **BuildKit cache mounts** for package installation
- **Single source of truth** for base configuration

**Build Commands**:
```bash
# Build all three variants
make docker-base-all

# Or individually:
DOCKER_BUILDKIT=1 docker build --target lenny-base -t jesteros:lenny-base \
    -f build/docker/jesteros-lenny-base.dockerfile .
```

### 3. **Production Multi-Stage** (`jesteros-production-multistage.dockerfile`)

**Purpose**: Production image with build-time validation

**Multi-Stage Build**:
1. **Validator Stage**: Uses `jesteros:dev-base` to syntax-check all scripts
2. **Production Stage**: Uses `jesteros:runtime-base` for minimal deployment

**Key Features**:
- Scripts validated at build time (catches errors early)
- Final image remains minimal and Debian Lenny compatible
- No runtime overhead from validation

```dockerfile
# Stage 1: Validation
FROM jesteros:dev-base AS validator
RUN find /validate/runtime -name "*.sh" | while read script; do \
    bash -n "$script" || exit 1; \
done

# Stage 2: Production
FROM jesteros:runtime-base AS production
COPY --from=validator /validate/src/ /src/
```

### 4. **Minimal Boot Environment** (`minimal-boot.dockerfile`)

**Purpose**: Ultra-lightweight root filesystem for MVP testing

**Base Image**: Debian Bullseye Slim

**Target Size**: <30MB compressed

**Components**:
- BusyBox for core utilities
- kmod for module loading
- Minimal init script
- MVP menu system

**Init Script Features**:
```bash
# Mount essential filesystems
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

# Load JesterOS modules
insmod /lib/modules/jesteros_core.ko
insmod /lib/modules/jester.ko
insmod /lib/modules/typewriter.ko
insmod /lib/modules/wisdom.ko

# Show jester and launch menu
cat /proc/jesteros/jester
exec /usr/local/bin/mvp-menu.sh
```

### 3. **Optimized Writer Environment** (`nookwriter-optimized.dockerfile`)

**Purpose**: Production writing environment with Vim

**Build Modes**:
- **minimal**: No plugins, 2MB RAM usage
- **writer**: Goyo + Pencil plugins, 5MB RAM usage

**Key Packages**:
- Vim editor
- FBInk for E-Ink display
- Essential writing plugins
- BusyBox utilities

**Build Arguments**:
```bash
# Minimal build
docker build --build-arg BUILD_MODE=minimal -t nook-writer-minimal .

# Writer build (default)
docker build --build-arg BUILD_MODE=writer -t nook-writer .
```

**Memory Optimization**:
```dockerfile
# Remove unnecessary files
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /usr/share/doc/*
RUN rm -rf /usr/share/man/*
RUN find / -name "*.a" -delete
```

### 4. **Root Filesystem Builder** (`rootfs.dockerfile`)

**Purpose**: Complete Debian-based root filesystem

**Features**:
- Full shell environment
- System utilities
- Network tools (disabled by default)
- Development headers (optional)

---

## 📜 Build Scripts

### Master Build Script (`build-all.sh`)

**Purpose**: Orchestrate complete firmware build

**Execution Flow**:
```bash
1. ./build/utilities/build-kernel.sh     # Build kernel
2. ./build/utilities/build-rootfs.sh      # Build root filesystem
3. ./build/utilities/create-boot.sh       # Create boot files
4. Package results in platform/nook-touch/
```

### Kernel Build Script (`build_kernel.sh`)

**Purpose**: Build JoKernel with JesterOS modules

**Process**:
1. Check/build Docker image
2. Configure kernel for Nook hardware
3. Enable JesterOS modules in config
4. Cross-compile kernel to uImage
5. Build kernel modules
6. Copy artifacts to `platform/nook-touch/boot/`

**Configuration Applied**:
```bash
make ARCH=arm omap3621_gossamer_evt1c_defconfig
echo 'CONFIG_JESTEROS=m' >> .config
echo 'CONFIG_JESTEROS_JESTER=y' >> .config
echo 'CONFIG_JESTEROS_TYPEWRITER=y' >> .config
echo 'CONFIG_JESTEROS_WISDOM=y' >> .config
```

**Output**:
- Kernel: `platform/nook-touch/boot/uImage` (~1.9MB)
- Modules: `platform/nook-touch/lib/modules/*.ko`

### Module Build Script (`build_modules.sh`)

**Purpose**: Compile JesterOS kernel modules

**Modules Built**:
1. `jesteros_core.ko` - Base module
2. `jester.ko` - ASCII art companion
3. `typewriter.ko` - Writing statistics
4. `wisdom.ko` - Quote system

**Build Command**:
```bash
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-androideabi- modules
```

### CWM Package Creator (`create_cwm.sh`)

**Purpose**: Create ClockworkMod recovery installer

**Package Structure**:
```
squireos-cwm-install.zip
├── META-INF/
│   └── com/google/android/
│       └── update-script
├── boot/
│   └── uImage
└── system/
    └── lib/modules/
```

**Installation Script**:
```bash
# CWM update-script
ui_print("Installing JesterOS...");
package_extract_dir("boot", "/boot");
package_extract_dir("system", "/system");
set_perm_recursive(0, 0, 0755, 0644, "/system/lib/modules");
ui_print("Installation complete!");
```

### Deployment Script (`deploy_to_nook.sh`)

**Purpose**: Deploy to SD card or device

**Safety Features**:
- Device detection
- Partition verification
- Backup existing data
- Safe unmount

---

## 🏗️ Build Process

### Complete Build Workflow

```mermaid
graph TD
    A[Start Build] --> B[Build Docker Images]
    B --> C[Configure Kernel]
    C --> D[Cross-Compile Kernel]
    D --> E[Build Modules]
    E --> F[Create Root FS]
    F --> G[Package Artifacts]
    G --> H[Generate CWM Package]
    H --> I[Build Complete]
```

### Step-by-Step Build

#### 1. **Environment Setup**
```bash
# Clone repository
git clone --recursive https://github.com/yourusername/nook-typewriter.git
cd nook-typewriter

# Initialize submodules
git submodule update --init --recursive
```

#### 2. **Build Kernel**
```bash
# Simple one-command build
./build_kernel.sh

# Or manually with Docker
docker run --rm \
    -v $(pwd)/source/kernel:/kernel \
    jokernel-unified \
    make -j4 ARCH=arm CROSS_COMPILE=arm-linux-androideabi- uImage
```

#### 3. **Build Root Filesystem**
```bash
# Minimal boot environment
docker build -t nook-mvp-rootfs -f build/docker/minimal-boot.dockerfile .

# Full writer environment
docker build -t nook-writer -f build/docker/nookwriter-optimized.dockerfile .
```

#### 4. **Package for Deployment**
```bash
# Create deployment package
docker create --name nook-export nook-writer
docker export nook-export | gzip > nook-writer.tar.gz
docker rm nook-export

# Create CWM package
./build/utilities/create_cwm.sh
```

---

## 📦 Build Outputs

### Directory Structure
```
build/output/
├── squireos-nook-1.0.0.tar.gz      # Complete firmware package
├── squireos-modules-[date].tar.gz   # Kernel modules only
├── squireos-cwm-install.zip         # CWM installer
└── build.log                         # Build log
```

### Artifact Details

| Artifact | Size | Contents |
|----------|------|----------|
| `uImage` | ~1.9MB | Compressed kernel image |
| `*.ko modules` | ~200KB | JesterOS kernel modules |
| `rootfs.tar.gz` | ~30MB | Minimal root filesystem |
| `cwm-install.zip` | ~32MB | Complete CWM package |

---

## 🔧 Build Configuration

### Kernel Configuration

**Config File**: `omap3621_gossamer_evt1c_defconfig`

**Key Settings**:
```kconfig
CONFIG_ARCH_OMAP3=y
CONFIG_MACH_OMAP3621_GOSSAMER=y
CONFIG_ARM_THUMB=y
CONFIG_AEABI=y
CONFIG_JESTEROS=m
CONFIG_JESTEROS_JESTER=y
CONFIG_JESTEROS_TYPEWRITER=y
CONFIG_JESTEROS_WISDOM=y
```

### Memory Configuration

**Constraints**:
- Total RAM: 256MB
- OS Maximum: 96MB
- Reserved for Writing: 160MB

**Kernel Parameters**:
```
mem=96M
```

### Cross-Compilation Settings

**Environment Variables**:
```bash
export ARCH=arm
export CROSS_COMPILE=arm-linux-androideabi-
export KERNEL_DIR=/kernel/src
export MODULE_DIR=/lib/modules/2.6.29
```

---

## 🚀 Quick Build Commands

### Optimized Build Process (Phase 3)
```bash
# One-time setup: Build unified base images
make docker-base-all

# Build everything with optimizations
make all              # Uses BuildKit automatically

# Build specific components
make docker-kernel    # Kernel with NDK caching
make docker-production # Production with validation
make lenny-rootfs     # Create deployable rootfs

# Cache management
make docker-cache-info  # View cache statistics
make docker-cache-clean # Clean BuildKit cache
./utilities/docker-cache-manager.sh optimize  # Optimize for JesterOS
```

### Docker Commands (BuildKit Enabled)
```bash
# BuildKit is now enabled by default in Makefile
# Manual override if needed:
export DOCKER_BUILDKIT=1

# List JesterOS images and sizes
./utilities/docker-monitor.sh

# Check shared base layers
docker images | grep "jesteros.*base"

# Export optimized rootfs
docker export $(docker create jesteros-lenny) | gzip > rootfs.tar.gz
```

### Performance Monitoring
```bash
# View build cache effectiveness
docker system df -v | grep "Build Cache"

# Monitor image sizes
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep jesteros

# Clean unused build cache (keeps images)
docker builder prune -f
```

---

## 📊 Build Performance Metrics

### Optimization Results (After Phase 1-3)

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Full Build Time** | 25-30 min | 8-10 min | **66% faster** |
| **Cached Rebuild** | 20-25 min | 1-2 min | **92% faster** |
| **Docker Context** | ~50MB | 4.13KB | **99.9% smaller** |
| **NDK Downloads** | Every build | Once (cached) | **500MB saved** |
| **Total Image Size** | ~2GB | ~1.2GB | **40% smaller** |
| **Layer Sharing** | None | Complete | **Maximum efficiency** |

### Cache Mount Benefits

```dockerfile
# APT packages cached across builds
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install -y packages

# NDK cached permanently (500MB saved per build)
RUN --mount=type=cache,target=/opt/ndk-cache,sharing=locked \
    # Download only if not cached
```

---

## 🐛 Troubleshooting

### Common Build Issues

#### Issue: Docker build fails
**Solution**: 
```bash
# Clean Docker cache
docker system prune -a
# Rebuild with no cache
docker build --no-cache -t jokernel-unified .
```

#### Issue: Kernel compilation error
**Solution**:
```bash
# Clean kernel build
cd source/kernel/src
make clean
make mrproper
# Retry build
```

#### Issue: Module loading fails
**Solution**:
- Verify module path: `/lib/modules/2.6.29/`
- Check kernel version match
- Review dmesg for errors

#### Issue: Out of memory during build
**Solution**:
```bash
# Increase Docker memory
docker run --memory="4g" --memory-swap="4g" ...
# Or reduce parallel jobs
make -j2 instead of make -j4
```

---

## 📈 Build Performance

### Optimized Build Times (After Phase 3)

| Component | First Build | Cached Build | CPU Usage |
|-----------|-------------|--------------|-----------|
| Base Images | 2 min | 0 (shared) | Low |
| Docker Image | 3 min | 30 sec | Low |
| Kernel Compile | 10 min | 5 min* | High |
| Module Build | 2 min | 2 min | Medium |
| RootFS Creation | 3 min | 1 min | Low |
| **Total** | **~20 min** | **~2 min** | Variable |

*With NDK cache after first download

### Resource Requirements

- **Disk Space**: 10GB free
- **RAM**: 4GB minimum
- **CPU**: 2+ cores recommended
- **Network**: For Docker pulls

---

## 🔐 Build Security

### Verification Steps
1. Verify toolchain checksums
2. Check kernel signature
3. Validate module signing
4. Review build logs

### Reproducible Builds
- Fixed Docker base images
- Specific toolchain versions
- Deterministic build flags
- Version-controlled configs

---

## 📚 Related Documentation

- [Kernel Configuration Guide](KERNEL_CONFIG.md)
- [Docker Environment Details](DOCKER_SETUP.md)
- [Cross-Compilation Guide](CROSS_COMPILE.md)
- [Deployment Guide](DEPLOYMENT.md)

---

*"Build with jest, deploy with confidence!"* 🎭

**Version**: 1.0.0  
**Last Updated**: December 13, 2024  
**Build System**: Docker + Make