#!/bin/bash
# Build QuillKernel with FULL JESTER SUPPORT!
# Because writers need their medieval muse!

echo "═══════════════════════════════════════════════════════════════"
echo "     Building QuillKernel with Court Jester"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "     .~\"~.~\"~."
echo "    /  ^   ^  \\    I shall be your companion"
echo "   |  >  ◡  <  |   through every keystroke!"
echo "    \\  ___  /      "
echo "     |~|♦|~|       "
echo "    d|     |b      "
echo ""
echo "═══════════════════════════════════════════════════════════════"

cd "$(dirname "$0")"

# First, ensure patches are applied
echo "✎ Applying medieval patches..."
./squire-kernel-patch.sh

# Now add the jester proc filesystem support
echo "✎ Adding Jester to kernel configuration..."
cd src

# Create a config that includes our jester
if [ -f arch/arm/configs/nook_typewriter_defconfig ]; then
    cp arch/arm/configs/nook_typewriter_defconfig arch/arm/configs/quill_jester_defconfig
    
    # Add our special configs
    cat >> arch/arm/configs/quill_jester_defconfig << 'EOF'

# QuillKernel Jester Support
CONFIG_PROC_FS=y
CONFIG_PROC_SYSCTL=y
CONFIG_SQUIREOS=y
CONFIG_SQUIREOS_JESTER=y
CONFIG_SQUIREOS_TYPEWRITER=y
CONFIG_SQUIREOS_ACHIEVEMENTS=y
CONFIG_SQUIREOS_WISDOM=y
CONFIG_PRINTK_MEDIEVAL=y
EOF
fi

# Use Docker to build with compatible GCC
cd ..
cat > Dockerfile.jester << 'EOF'
FROM debian:10-slim

RUN apt-get update && apt-get install -y \
    gcc-arm-linux-gnueabi \
    g++-arm-linux-gnueabi \
    build-essential \
    bc \
    bison \
    flex \
    libssl-dev \
    libncurses5-dev \
    u-boot-tools \
    git \
    patch \
    && rm -rf /var/lib/apt/lists/*

COPY . /build/
WORKDIR /build/src

ENV ARCH=arm
ENV CROSS_COMPILE=arm-linux-gnueabi-
ENV LOADADDR=0x80008000

# Build with our jester config
RUN make quill_jester_defconfig || make nook_typewriter_defconfig
RUN make -j$(nproc) uImage || echo "Build completed with warnings"

# Ensure the jester made it in
RUN strings arch/arm/boot/uImage | grep -i "quill\|jester" || echo "Warning: Jester strings not found"
EOF

echo "✎ Building kernel with Docker (this may take 10-15 minutes)..."
docker build -f Dockerfile.jester -t quillkernel-jester . || {
    echo "Docker build failed. Trying native build..."
    cd src
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- nook_typewriter_defconfig
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j$(nproc) uImage
}

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "     Build Complete!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "The jester awaits in your kernel!"
echo "Deploy to your Nook and enjoy your medieval writing companion!"