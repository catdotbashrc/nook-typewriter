# syntax=docker/dockerfile:1
# JoKernel XDA-Proven Build Environment - OPTIMIZED
# Uses BuildKit cache mounts to avoid re-downloading 500MB NDK every build
# Based on research from Phoenix Project and felixhaedicke/nst-kernel

FROM ubuntu:20.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies with cache mount for apt
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
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

# NDK configuration
ENV NDK_VERSION=r12b
ENV NDK_SHA256="eafae2d614e5475a3bcfd7c5f201db5b963cc1290ee3e8ae791ff0c66757781e"
ENV NDK_URL="https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux-x86_64.zip"

# Download and extract NDK with persistent cache mount
# This saves 500MB download and 5-10 minutes per build!
RUN --mount=type=cache,target=/opt/ndk-cache,sharing=locked \
    mkdir -p /opt && \
    cd /opt && \
    if [ ! -f /opt/ndk-cache/android-ndk-${NDK_VERSION}.zip ]; then \
        echo "→ Downloading Android NDK ${NDK_VERSION} (first time only)..."; \
        wget -q -O /opt/ndk-cache/android-ndk-${NDK_VERSION}.zip ${NDK_URL}; \
        echo "${NDK_SHA256}  /opt/ndk-cache/android-ndk-${NDK_VERSION}.zip" | sha256sum -c -; \
    else \
        echo "→ Using cached Android NDK ${NDK_VERSION}..."; \
    fi && \
    unzip -q /opt/ndk-cache/android-ndk-${NDK_VERSION}.zip && \
    mv android-ndk-${NDK_VERSION} android-ndk

# Kernel source configuration
ENV KERNEL_REPO="https://github.com/catdotbashrc/nst-kernel.git"
ENV KERNEL_BRANCH="master"

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
echo "     QuillKernel XDA-Proven Builder (Optimized)"\n\
echo "     Using cached NDK toolchain for NST"\n\
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