# Docker-Based QuillKernel Testing

This guide explains how to build and test QuillKernel using Docker, providing a consistent environment without needing to set up cross-compilation tools locally.

## Quick Start

```bash
# Run quick verification
./test-in-docker.sh verify

# Run full test suite
./test-in-docker.sh test

# Build the kernel in Docker
./test-in-docker.sh build

# Interactive shell for debugging
./test-in-docker.sh shell
```

## What Docker Testing Provides

### 1. Build Verification
- Checks if patches applied correctly
- Validates configuration files
- Ensures build environment is ready

### 2. Static Analysis
- Runs Sparse (if available)
- Checks for common C errors
- Validates QuillKernel-specific issues

### 3. Kernel Compilation
- Full cross-compilation setup
- Builds uImage for Nook
- No local toolchain needed

### 4. Software Tests
- Tests that don't require hardware
- Gracefully skips hardware-dependent tests
- Provides clear feedback

## Docker Environments

### Dockerfile.test (Quick Testing)
Simple environment for running tests:
- Debian 11 base
- Basic build tools
- Test scripts
- Fast to build

### Dockerfile.build (Full Build)
Complete build environment:
- Cross-compilation toolchain
- U-Boot tools for uImage
- Kernel build dependencies
- Multi-stage for efficiency

## Running Different Tests

### Quick Verification Only
```bash
docker-compose -f docker-compose.test.yml run verify-only
```
- Checks patches
- Validates config
- ~30 seconds

### Full Test Suite
```bash
docker-compose -f docker-compose.test.yml run test-suite
```
- Build verification
- Static analysis
- Software tests
- ~2-5 minutes

### Complete Kernel Build
```bash
docker-compose -f docker-compose.test.yml run build-test
```
- Applies patches
- Configures kernel
- Builds uImage
- ~10-30 minutes

## Understanding Docker Test Output

### Successful Build Verification
```
═══════════════════════════════════════════════════════════════
         QuillKernel Build Verification (Simple)
═══════════════════════════════════════════════════════════════

Tests Passed: 9
Tests Failed: 0
Warnings: 2

     .~"~.~"~.
    /  ^   ^  \    All tests passed!
   |  >  ◡  <  |   The kernel is ready to build.
```

### Tests Skipping Hardware
```
[SKIP] /proc/squireos directory missing!
[INFO] Running in Docker - hardware tests skipped
```

### Successful Kernel Build
```
Building QuillKernel (this will take time)...
  CC      init/main.o
  ...
  UIMAGE  arch/arm/boot/uImage
Image Name:   Linux-2.6.29-quill-scribe
Created:      Sun Aug 10 12:00:00 2024
Build successful!
```

## Extracting Build Artifacts

After building in Docker:

```bash
# Create container from image
docker create --name quill-extract quillkernel-test

# Copy out the kernel image
docker cp quill-extract:/kernel/uImage ./uImage-quillkernel

# Copy test results
docker cp quill-extract:/home/builder/test-results ./

# Clean up
docker rm quill-extract
```

## Advanced Docker Usage

### Custom Build Configuration
```bash
# Interactive configuration
docker run -it --rm quillkernel-test bash -c "
  cd /home/builder/nst-kernel/src
  make menuconfig
"
```

### Running Specific Tests
```bash
# Run only static analysis
docker run --rm quillkernel-test bash -c "
  cd /tests
  ./static-analysis.sh
"
```

### Debugging Build Issues
```bash
# Get a shell in the build environment
./test-in-docker.sh shell

# Inside container:
cd /home/builder/nst-kernel/src
make V=1 uImage  # Verbose output
```

## Docker Resource Requirements

- **Disk Space**: ~2GB for images and build
- **RAM**: 2GB minimum, 4GB recommended
- **CPU**: More cores = faster builds
- **Time**: 10-30 minutes for full build

## Troubleshooting

### Build Fails
```bash
# Check detailed logs
docker logs quillkernel-build-test

# Try verbose build
docker run -it --rm quillkernel-test bash
make V=1 uImage 2>&1 | tee build.log
```

### Out of Space
```bash
# Clean up Docker
docker system prune -a

# Remove old images
docker rmi $(docker images -q quillkernel-*)
```

### Permission Issues
```bash
# Ensure test-results is writable
chmod 777 test-results/

# Run as root if needed
docker run --user root ...
```

## Benefits of Docker Testing

1. **Consistent Environment** - Same tools every time
2. **No Local Setup** - Don't need ARM toolchain
3. **Isolation** - Won't affect your system
4. **Reproducible** - Others get same results
5. **CI/CD Ready** - Easy GitHub Actions integration

## Limitations

- Can't test hardware features
- No E-Ink display testing
- No USB keyboard testing
- No real boot testing
- Limited to software validation

For hardware testing, you still need an actual Nook!

```
     .~"~.~"~.
    /  o   o  \    Docker: Thy kernel builder
   |  >  ◡  <  |   in a convenient container!
    \  ___  /      
     |~|♦|~|       
```