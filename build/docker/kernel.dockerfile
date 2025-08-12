# QuillKernel Build Environment
# Provides Android NDK toolchain for building Nook Simple Touch kernel

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

# Download and install Android NDK r10e (compatible with 2.6.29 kernel)
# This version has GCC 4.8 which works well with older kernels
RUN mkdir -p /opt && \
    cd /opt && \
    wget -q https://dl.google.com/android/repository/android-ndk-r10e-linux-x86_64.zip && \
    unzip -q android-ndk-r10e-linux-x86_64.zip && \
    rm android-ndk-r10e-linux-x86_64.zip && \
    mv android-ndk-r10e android-ndk

# Set up environment variables
ENV NDK_PATH=/opt/android-ndk
ENV PATH=${NDK_PATH}/toolchains/arm-linux-androideabi-4.8/prebuilt/linux-x86_64/bin:${PATH}
ENV ARCH=arm
ENV CROSS_COMPILE=arm-linux-androideabi-

# Create working directory
WORKDIR /build

# Create build script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "═══════════════════════════════════════════════════════════════"\n\
echo "     QuillKernel Builder - Medieval Kernel for Nook"\n\
echo "═══════════════════════════════════════════════════════════════"\n\
echo ""\n\
echo "     .~\"~.~\"~."\n\
echo "    /  o   o  \\\\    Building thy kernel..."\n\
echo "   |  >  ◡  <  |   By quill and compiler"\n\
echo "    \\\\  ___  /      "\n\
echo "     |~|♦|~|       "\n\
echo ""\n\
echo "═══════════════════════════════════════════════════════════════"\n\
echo ""\n\
\n\
cd /build\n\
\n\
# Build kernel\n\
if [ -f "nst-kernel-base/build/uImage.config" ]; then\n\
    echo "→ Using existing kernel config..."\n\
    cp nst-kernel-base/build/uImage.config nst-kernel-base/src/.config\n\
else\n\
    echo "→ Using default config..."\n\
    cd nst-kernel-base/src\n\
    make ARCH=arm omap3621_gossamer_evt1c_defconfig\n\
    cd ../..\n\
fi\n\
\n\
echo "→ Building kernel..."\n\
cd nst-kernel-base/src\n\
make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-androideabi- uImage\n\
\n\
echo ""\n\
echo "═══════════════════════════════════════════════════════════════"\n\
echo "✓ Kernel built successfully!"\n\
echo "  Output: nst-kernel-base/src/arch/arm/boot/uImage"\n\
echo "═══════════════════════════════════════════════════════════════"\n\
\n\
# Build modules if they exist\n\
if [ -d "quillkernel/modules" ]; then\n\
    echo ""\n\
    echo "→ Building SquireOS modules..."\n\
    cd /build/quillkernel/modules\n\
    make KERNELDIR=/build/nst-kernel-base/src\n\
    echo "✓ Modules built successfully!"\n\
fi\n\
' > /usr/local/bin/build-quillkernel.sh && \
    chmod +x /usr/local/bin/build-quillkernel.sh

# Default command
CMD ["/usr/local/bin/build-quillkernel.sh"]