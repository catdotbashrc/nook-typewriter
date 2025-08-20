# Project Constitution

## Project
- **Name**: JesterOS/JoKernel - Nook Typewriter
- **Description**: Medieval-themed embedded Linux distribution for Barnes & Noble Nook Simple Touch
- **Version**: 1.0.0-alpha.1

## Tech Stack
- **Languages**: C (kernel), Shell Script (runtime)
- **Kernel**: Linux 2.6.29-jester with Android init
- **Runtime**: JesterOS 4-Layer Architecture (35 scripts)
- **Base OS**: Debian Lenny 5.0
- **Build System**: Make + Docker (BuildKit optimized)
- **Cross-Compiler**: ARM toolchain (NDK r10e)

## Structure
```
runtime/        - 4-layer JesterOS architecture (UI/App/System/Hardware)
source/         - Linux kernel 2.6.29 source
tests/          - 3-stage test pipeline
docs/           - Medieval-themed documentation
build/          - Docker-based cross-compilation
firmware/       - Bootloaders, kernel, DSP firmware
docker/         - Container definitions
```

## Essential Commands
```bash
# Build complete firmware
make firmware

# Quick build (skip unchanged)
make quick-build

# Run test pipeline
make test         # Full 3-stage
make test-quick   # Critical only
make test-safety  # Safety checks

# Deploy to SD card
make detect-sd    # Find SD cards
make sd-deploy    # Deploy firmware

# Docker management
make docker-build # Build all images
```

## Critical Rules
- **NEVER violate 160MB sacred writing space** - Reserved for writers, inviolable
- **95MB OS limit is absolute** - Enforced by memory-guardian.sh
- **Test before hardware deployment** - Run test-safety minimum before SD deploy
- **Bootloaders are protected** - MLO/u-boot.bin preserved during clean
- **E-Ink awareness required** - 200-980ms refresh, design for minimal updates
- **Android init required** - Cannot bypass, hardware drivers depend on it
- **SanDisk Class 10 SD only** - Other brands proven unreliable (Phoenix Project)
- **Safety-first shell scripts** - set -euo pipefail mandatory
- **Medieval theme throughout** - Jester daemon, quill metaphors, candlelight focus

---

*"By quill and candlelight, we code for those who write"* 🕯️📜