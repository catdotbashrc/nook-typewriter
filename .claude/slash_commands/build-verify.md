---
description: Verify build process and deployment readiness
tools: ["Bash", "Read", "Grep", "Glob", "LS"]
---

# Build and Deployment Verification

Ensure the Nook typewriter builds correctly, deploys reliably, and maintains quality across all components.

## Build Process Verification

### 1. Dockerfile Analysis
Check the main `nookwriter.dockerfile`:
- Base image is Debian 11 Slim (lightweight)
- No unnecessary packages installed
- FBInk compiled from source correctly
- Vim plugins installed properly
- Build stages optimized for size

Key concerns:
- Each `RUN` command adds a layer
- Combined commands reduce image size
- `apt-get clean` and cache removal essential
- No development tools left in final image

### 2. Cross-Platform Building
Verify ARM build process:
- Docker buildx configuration correct
- Platform specified as `linux/arm/v7`
- Build scripts handle architecture properly
- No x86-specific binaries included

### 3. QuillKernel Building
Check kernel build process:
- `squire-kernel-patch.sh` applies cleanly
- Docker build option available
- Cross-compilation toolchain not required for Docker
- Test suite runs successfully

### 4. Image Size Optimization
Monitor image sizes:
- Docker image < 800MB
- Compressed tar.gz < 400MB
- SD card usage reasonable
- No unnecessary files included

## Deployment Verification

### 1. SD Card Preparation
Verify deployment instructions:
- Partition scheme clear (FAT32 + F2FS)
- Size requirements documented
- Format commands correct
- Mount points properly specified

### 2. Boot Configuration
Check boot setup:
- `uEnv.txt` configuration correct
- Kernel path specified properly
- Root filesystem identified
- Memory limit set (256MB)

### 3. File Permissions
Ensure correct permissions:
- Scripts are executable
- Config files readable
- Writing directory writable
- No security issues

### 4. Recovery Mechanisms
Verify recovery options:
- Backup kernel available
- SD card can be mounted on PC
- Original Nook OS preserved
- Clear recovery instructions

## Test Suite Validation

### 1. Docker Tests
Verify tests work in containers:
- All test scripts handle missing hardware
- No infinite loops or hangs
- Clear SKIP messages for hardware features
- Exit codes correct

### 2. Hardware Tests
Check device-specific tests:
- USB keyboard detection
- E-Ink display tests
- Memory constraint tests
- Power consumption tests

### 3. Integration Tests
Verify complete workflows:
- Boot to writing
- Save and sync cycle
- Menu navigation
- Error recovery

## Quality Checks

### 1. Script Quality
All shell scripts should:
- Use `#!/bin/bash` (not sh)
- Have error handling
- Include helpful comments
- Handle missing dependencies

### 2. Documentation Quality
Verify documentation:
- README accurate and current
- Tutorials tested and working
- Commands copy-pasteable
- Troubleshooting comprehensive

### 3. Git Hygiene
Check repository:
- No large binary files
- `.gitignore` properly configured
- No sensitive information
- Clear commit messages

## Build Commands

```bash
# Standard x86 build
docker build -t nook-system -f nookwriter.dockerfile .

# ARM build for deployment
docker buildx build --platform linux/arm/v7 -t nook-system:armv7 -f nookwriter.dockerfile .

# Create deployment archive
docker create --name nook-export nook-system:armv7
docker export nook-export | gzip > nook-debian.tar.gz
docker rm nook-export

# Test the build
docker run --rm nook-system vim -c ':q'
docker run --rm nook-system fbink -c || echo "✓ Graceful degradation"
```

## Critical Files to Review

- `nookwriter.dockerfile` - Main build definition
- `docker-compose.yml` - Development setup
- `scripts/build-rootfs.sh` - Deployment script
- `nst-kernel/Dockerfile.build` - Kernel build
- `.github/workflows/*` - CI/CD if present

## Success Criteria

Build succeeds if:
1. **Docker image builds** without errors
2. **ARM cross-build works** for deployment
3. **Image size reasonable** (< 800MB)
4. **All tests pass** or skip gracefully
5. **Deployment instructions clear** and tested
6. **Writers can follow** setup guide

Remember: The build process must be simple enough for writers who want to customize their typewriter, not just Linux experts.