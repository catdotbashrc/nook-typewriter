# JoKernel XDA-Proven Build Environment
# Uses toolchain proven by XDA community for Nook Simple Touch
# Based on research from Phoenix Project and felixhaedicke/nst-kernel

FROM ubuntu:20.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    bc \
    bison \
    flex \
    libssl-dev \
    libncurses5-dev \
    git \
    wget \
    unzip \
    python2 \
    ccache \
    u-boot-tools \
    device-tree-compiler \
    && rm -rf /var/lib/apt/lists/*

# Download Android NDK r12b (XDA-proven for NST)
# Alternative to CodeSourcery that community has verified works
# SHA256 checksum for Android NDK r12b to prevent supply chain attacks
ENV NDK_SHA256="eafae2d614e5475a3bcfd7c5f201db5b963cc1290ee3e8ae791ff0c66757781e"

# Kernel source configuration - using catdotbashrc/nst-kernel as primary source
# This provides a more reliable mirror than felixhaedicke/nst-kernel
ENV KERNEL_REPO="https://github.com/catdotbashrc/nst-kernel.git"
ENV KERNEL_BRANCH="master"
RUN mkdir -p /opt && \
    cd /opt && \
    wget -q https://dl.google.com/android/repository/android-ndk-r12b-linux-x86_64.zip && \
    echo "${NDK_SHA256}  android-ndk-r12b-linux-x86_64.zip" | sha256sum -c - && \
    unzip -q android-ndk-r12b-linux-x86_64.zip && \
    rm android-ndk-r12b-linux-x86_64.zip && \
    mv android-ndk-r12b android-ndk

# Set up environment variables for XDA-proven toolchain
ENV NDK_PATH=/opt/android-ndk
ENV PATH=${NDK_PATH}/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:${PATH}
ENV ARCH=arm
ENV CROSS_COMPILE=arm-linux-androideabi-
ENV XDA_TOOLCHAIN=true

# Create working directory
WORKDIR /build

# Create XDA-compatible build script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "═══════════════════════════════════════════════════════════════"\n\
echo "     QuillKernel XDA-Proven Builder"\n\
echo "     Using community-verified toolchain for NST"\n\
echo "═══════════════════════════════════════════════════════════════"\n\
echo ""\n\
echo "     .~\"~.~\"~."\n\
echo "    /  o   o  \\\\    XDA community approved..."\n\
echo "   |  >  ◡  <  |   No boot loops here!"\n\
echo "    \\\\  ___  /      "\n\
echo "     |~|♦|~|       "\n\
echo ""\n\
echo "Toolchain: NDK r12b with arm-linux-androideabi-4.9"\n\
echo "Based on: Phoenix Project + felixhaedicke/nst-kernel"\n\
echo "═══════════════════════════════════════════════════════════════"\n\
echo ""\n\
\n\
cd /build\n\
\n\
# Verify toolchain\n\
echo "→ Verifying XDA-proven toolchain..."\n\
${CROSS_COMPILE}gcc --version | head -1\n\
echo ""\n\
\n\
# Build kernel using proven method\n\
if [ -f "nst-kernel-base/build/uImage.config" ]; then\n\
    echo "→ Using existing kernel config..."\n\
    cp nst-kernel-base/build/uImage.config nst-kernel-base/src/.config\n\
else\n\
    echo "→ Using Nook default config..."\n\
    cd nst-kernel-base/src\n\
    make ARCH=arm omap3621_gossamer_evt1c_defconfig\n\
    cd ../..\n\
fi\n\
\n\
echo "→ Building kernel with XDA-proven toolchain..."\n\
cd nst-kernel-base/src\n\
\n\
# Use exact build commands from felixhaedicke/nst-kernel\n\
make ARCH=arm oldconfig\n\
make -j$(nproc) ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} uImage\n\
\n\
echo ""\n\
echo "═══════════════════════════════════════════════════════════════"\n\
if [ -f arch/arm/boot/uImage ]; then\n\
    echo "✓ XDA-proven kernel built successfully!"\n\
    echo "  Output: arch/arm/boot/uImage"\n\
    ls -lh arch/arm/boot/uImage\n\
    echo "  This kernel should boot without loops on NST"\n\
else\n\
    echo "✗ Build failed - uImage not found"\n\
    exit 1\n\
fi\n\
echo "═══════════════════════════════════════════════════════════════"\n\
\n\
# Build SquireOS modules with compatible toolchain\n\
if [ -d "/build/quillkernel/modules" ]; then\n\
    echo ""\n\
    echo "→ Building SquireOS modules with XDA toolchain..."\n\
    cd /build/quillkernel/modules\n\
    make KERNELDIR=/build/nst-kernel-base/src ARCH=arm CROSS_COMPILE=${CROSS_COMPILE}\n\
    echo "✓ Medieval modules built with proven toolchain!"\n\
fi\n\
' > /usr/local/bin/build-quillkernel-xda.sh && \
    chmod +x /usr/local/bin/build-quillkernel-xda.sh

# Default command
CMD ["/usr/local/bin/build-quillkernel-xda.sh"]