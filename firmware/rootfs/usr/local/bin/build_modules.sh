#!/bin/bash
# Standalone SquireOS module builder
# Builds kernel modules without kernel source tree integration
# "By quill and determination, we forge modules independently"

set -euo pipefail

echo "==============================================================="
echo "        Standalone SquireOS Module Builder"
echo "==============================================================="
echo ""

KERNEL_SRC="$(pwd)/source/kernel/src"
MODULE_SRC="$KERNEL_SRC/drivers/squireos"
OUTPUT_DIR="$(pwd)/platform/nook-touch/modules"
STANDALONE_DIR="$(pwd)/standalone_modules"
DOCKER_IMAGE="quillkernel-xda"

# Clean and create directories
rm -rf "$STANDALONE_DIR"
mkdir -p "$STANDALONE_DIR"
mkdir -p "$OUTPUT_DIR"

echo "-> Preparing standalone module directory..."

# Copy module sources
cp "$MODULE_SRC"/*.c "$STANDALONE_DIR/"

# Create a proper external module Makefile
cat > "$STANDALONE_DIR/Makefile" << 'EOF'
# Standalone SquireOS Module Build
# External module Makefile for out-of-tree build

# Module names - these will become .ko files
obj-m := squireos_core.o jester.o typewriter.o wisdom.o

# Kernel source directory
KERNELDIR ?= /kernel/src

# Cross compilation settings
ARCH ?= arm
CROSS_COMPILE ?= arm-linux-androideabi-

# Module build rules
all:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) modules

clean:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean

.PHONY: all clean
EOF

echo "-> Preparing kernel for external module build..."

# Prepare the kernel
docker run --rm \
    -v "$(pwd)/source/kernel:/kernel" \
    -w /kernel/src \
    $DOCKER_IMAGE bash -c "
    echo 'Setting up kernel configuration...'
    
    # Use default config
    make ARCH=arm omap3621_gossamer_evt1c_defconfig
    
    # Ensure modules are enabled
    ./scripts/config --enable MODULES
    ./scripts/config --enable MODULE_UNLOAD
    ./scripts/config --enable PROC_FS
    
    # Update config
    make ARCH=arm CROSS_COMPILE=arm-linux-androideabi- oldconfig < /dev/null
    
    # Prepare kernel
    echo 'Preparing kernel headers...'
    make ARCH=arm CROSS_COMPILE=arm-linux-androideabi- prepare
    make ARCH=arm CROSS_COMPILE=arm-linux-androideabi- scripts
    
    echo 'Kernel prepared for external module build'
"

echo ""
echo "-> Building standalone modules..."

# Build the modules
docker run --rm \
    -v "$(pwd)/source/kernel:/kernel" \
    -v "$STANDALONE_DIR:/modules" \
    -w /modules \
    $DOCKER_IMAGE bash -c "
    echo 'Building SquireOS modules as external modules...'
    
    # Set environment
    export ARCH=arm
    export CROSS_COMPILE=arm-linux-androideabi-
    export KERNELDIR=/kernel/src
    
    # Build modules
    make
    
    echo ''
    echo 'Checking build results:'
    ls -la *.ko 2>/dev/null || echo 'No .ko files found'
    ls -la *.o 2>/dev/null | head -10
    
    # If .ko files exist, they're ready
    if ls *.ko 2>/dev/null > /dev/null; then
        echo ''
        echo 'SUCCESS: Kernel modules built!'
        file *.ko
    else
        echo ''
        echo 'Modules built as .o files, attempting to link...'
        
        # Try to manually create .ko files
        for module in squireos_core jester typewriter wisdom; do
            if [ -f \${module}.o ]; then
                echo \"Processing \${module}...\"
                
                # Create a minimal mod.c file
                cat > \${module}.mod.c << MODEOF
#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

MODULE_INFO(vermagic, VERMAGIC_STRING);

struct module __this_module
__attribute__((section(\".gnu.linkonce.this_module\"))) = {
 .name = \"\${module}\",
 .init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
 .exit = cleanup_module,
#endif
 .arch = MODULE_ARCH_INIT,
};
MODEOF
                
                # Compile the mod.c
                arm-linux-androideabi-gcc -c -o \${module}.mod.o \${module}.mod.c \
                    -I/kernel/src/include \
                    -I/kernel/src/arch/arm/include \
                    -D__KERNEL__ -DMODULE \
                    2>/dev/null || true
                
                # Link into .ko
                arm-linux-androideabi-ld -r -o \${module}.ko \
                    \${module}.o \${module}.mod.o \
                    2>/dev/null || true
            fi
        done
        
        echo ''
        echo 'After manual linking:'
        ls -la *.ko 2>/dev/null || echo 'Still no .ko files'
    fi
"

echo ""
echo "-> Copying modules to output directory..."

# Copy the built modules
docker run --rm \
    -v "$STANDALONE_DIR:/modules" \
    -v "$OUTPUT_DIR:/output" \
    $DOCKER_IMAGE bash -c "
    if ls /modules/*.ko 2>/dev/null > /dev/null; then
        cp /modules/*.ko /output/
        echo 'Kernel modules copied!'
        ls -la /output/*.ko
    else
        echo 'No .ko files available, copying .o files...'
        cp /modules/*.o /output/ 2>/dev/null || true
        ls -la /output/*.o 2>/dev/null | head -10
    fi
"

# Create module loading script
cat > "$OUTPUT_DIR/load_modules.sh" << 'EOF'
#!/bin/sh
# Load SquireOS modules in correct order

MODULE_DIR="/lib/modules/2.6.29"

echo "Loading SquireOS modules..."

# Load core first
if [ -f "$MODULE_DIR/squireos_core.ko" ]; then
    insmod "$MODULE_DIR/squireos_core.ko"
    echo "Loaded squireos_core"
fi

# Load feature modules
for mod in jester typewriter wisdom; do
    if [ -f "$MODULE_DIR/${mod}.ko" ]; then
        insmod "$MODULE_DIR/${mod}.ko"
        echo "Loaded ${mod}"
    fi
done

# Check if modules loaded
if [ -d /proc/squireos ]; then
    echo "SquireOS modules loaded successfully!"
    ls /proc/squireos/
else
    echo "Failed to load SquireOS modules"
fi
EOF

chmod +x "$OUTPUT_DIR/load_modules.sh"

# Clean up
rm -rf "$STANDALONE_DIR"

echo ""
echo "==============================================================="
echo "           Standalone Build Summary"
echo "==============================================================="

if ls "$OUTPUT_DIR"/*.ko 2>/dev/null > /dev/null; then
    echo "[SUCCESS] Standalone kernel modules built!"
    echo ""
    echo "Modules ready for deployment:"
    ls -lh "$OUTPUT_DIR"/*.ko
    echo ""
    echo "To deploy:"
    echo "1. Copy platform/nook-touch/modules/*.ko to /lib/modules/2.6.29/ on Nook"
    echo "2. Run: sh /lib/modules/2.6.29/load_modules.sh"
else
    echo "[INFO] Object files built:"
    ls -lh "$OUTPUT_DIR"/*.o 2>/dev/null | head -10
    echo ""
    echo "Note: .o files need to be converted to .ko on the device"
fi

echo ""
echo "==============================================================="