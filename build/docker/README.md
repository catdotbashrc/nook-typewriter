# JesterOS Docker Build Infrastructure

Production Docker build files for JesterOS on Nook SimpleTouch.

## 📦 Build Architecture

```
build/docker/
├── vanilla-debian-lenny.dockerfile  # 🏛️  Base Debian Lenny 5.0 (2009)
├── jesteros-lenny.dockerfile       # 🎭 JesterOS on Lenny for Nook
├── kernel-xda-proven.dockerfile    # 🔧 Kernel build environment  
├── modern-packager.dockerfile      # 📦 SD card packaging tools
└── README.md                       # 📖 This file

tests/
├── test-runner.sh              # 🧪 Test orchestrator
├── *-test.sh                  # 🔍 Test scripts
└── *.dockerfile               # 🗂️  Test environments

docs/archive/docker-experiments/
└── *.dockerfile               # 🗄️  Experimental/historical images
```

## 🚀 Quick Start

### Build JesterOS for Nook SimpleTouch

```bash
# 1. Build base Debian Lenny 5.0 (if not already built)
docker build -t debian:lenny -f build/docker/vanilla-debian-lenny.dockerfile .

# 2. Build JesterOS on Lenny (for actual Nook hardware)
docker build -t jesteros-lenny -f build/docker/jesteros-lenny.dockerfile .
```

### Deploy to SD Card

```bash
# 3. Export JesterOS for Nook deployment
docker create --name jesteros-export jesteros-lenny
docker export jesteros-export | gzip > jesteros-lenny-rootfs.tar.gz
docker rm jesteros-export

# 4. Deploy to SD card (see deployment guide)
# Use jesteros-lenny-rootfs.tar.gz with deployment scripts
```

### Run Tests
```bash
# Test the Lenny-based image
./tests/test-runner.sh jesteros-lenny simple-test.sh

# Interactive development
docker run -it jesteros-lenny bash
```

## 🎯 Docker Images Explained

### **Production Build Images:**

**`vanilla-debian-lenny.dockerfile`**
- Base Debian Lenny 5.0.10 from 2009
- Built from authentic archive.debian.org packages
- Required for Nook's 2.6.29 kernel compatibility
- Size: ~58MB

**`jesteros-lenny.dockerfile`**
- JesterOS runtime on Debian Lenny
- Complete 4-layer architecture
- USB keyboard support (GK61)
- Ready for Nook deployment
- Size: ~59MB

**`kernel-xda-proven.dockerfile`**
- Kernel compilation environment
- Android NDK for cross-compilation
- Builds 2.6.29 kernel for Nook

**`modern-packager.dockerfile`**
- SD card image creation tools
- Partition management utilities
- Deployment packaging

### **Directory Structure:**
```
/runtime/
├── 1-ui/          # User interface components
├── 2-application/ # JesterOS services
├── 3-system/      # System services (USB, etc.)
├── 4-hardware/    # Hardware interfaces (input, E-Ink)
└── configs/       # Configuration files

/var/jesteros/     # Runtime data and status files
/usr/local/bin/    # Service symlinks
```

## 🧪 Testing Framework

### **Test Scripts:**
- **`simple-test.sh`** - Quick validation (30 seconds)
- **`jesteros-integration-test.sh`** - Comprehensive suite (2-3 minutes)
- **Custom tests** - Add your own `.sh` scripts to `tests/`

### **Test Categories:**
1. **Structure** - Directory and file validation
2. **Scripts** - Executable and syntax checking
3. **Services** - Initialization and functionality
4. **Integration** - End-to-end system validation
5. **GK61 Keyboard** - USB keyboard functionality
6. **Memory** - Resource usage validation

### **Test Runner Commands:**
```bash
./tests/test-runner.sh build                    # Build base image
./tests/test-runner.sh list                     # List images/tests
./tests/test-runner.sh [image] [test-script]    # Run specific test
./tests/test-runner.sh help                     # Show help
```

## 🔧 Development Workflow

### **1. Development Cycle:**
```bash
# Make changes to runtime/ files
vim runtime/3-system/services/new-service.sh

# Test changes
./tests/test-runner.sh jesteros-base simple-test.sh

# Comprehensive validation
./tests/test-runner.sh jesteros-base jesteros-integration-test.sh
```

### **2. Creating New Tests:**
```bash
# Create test script
cat > tests/my-test.sh << 'EOF'
#!/bin/bash
echo "Testing my feature..."
# Add test logic here
EOF

chmod +x tests/my-test.sh

# Run your test
./tests/test-runner.sh jesteros-base my-test.sh
```

### **3. Image Customization:**
Extend the base image for specific use cases:
```dockerfile
FROM jesteros-base
# Add your customizations
RUN apt-get update && apt-get install -y my-tool
COPY my-configs/ /etc/my-configs/
```

## ⚠️ Critical: Why Debian Lenny?

**The Nook SimpleTouch requires Debian Lenny (5.0) from 2009:**
- Linux kernel 2.6.29 expects old glibc (2.7)
- Modern Debian 11 libraries are incompatible
- Binary compatibility with 2009-era software
- Matches the Nook's original Android 2.1 base

**Memory Profile (Lenny-based):**
- Base image: ~59MB (vs 224MB for Debian 11!)
- Runtime memory: <35MB
- Perfect for Nook's 233MB total RAM
- Leaves maximum space for writing

## 🚦 Status & Health Checks

### **Image Status:**
```bash
docker run --rm jesteros-base jesteros-status.sh
```

### **Component Health:**
```bash
# Check specific services
docker run --rm jesteros-base usb-keyboard-manager.sh status
docker run --rm jesteros-base button-handler.sh status

# Run health check
docker run --rm jesteros-base jesteros-service-init.sh health
```

## 🔄 Migration from Legacy

**Old Approach (Deprecated):**
```bash
# Monolithic test image with embedded tests
docker build -t jesteros-test -f tests/jesteros-integration-test.dockerfile .
docker run --rm jesteros-test
```

**New Modular Approach:**
```bash
# Separate base image + external test scripts
docker build -t jesteros-base -f build/docker/jesteros-base.dockerfile .
./tests/test-runner.sh jesteros-base jesteros-integration-test.sh
```

**Benefits:**
- 🎯 **Focused Images** - Base image only contains runtime, tests are external
- 🔄 **Reusable** - Same base image for development, testing, deployment
- 🧪 **Flexible Testing** - Add/modify tests without rebuilding images
- 📦 **Smaller Images** - No embedded test code in production images
- 🚀 **Faster Iteration** - Rebuild only what changed

## 🃏 Philosophy

> "By quill and candlelight, we build modular foundations!"

The modular approach follows JesterOS principles:
- **Simplicity** - Clean separation of concerns
- **Writer-First** - Fast iteration for writing-focused development  
- **Minimalism** - Only include what's needed in each layer
- **Medieval Theme** - Maintain the jester's whimsical character

---

**For deployment to actual Nook hardware, use the base image as foundation and layer on device-specific configurations.**