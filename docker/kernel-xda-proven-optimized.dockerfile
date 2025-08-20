# JoKernel XDA-Proven Build Environment (Optimized)
# Uses toolchain proven by XDA community for Nook Simple Touch
# Based on research from Phoenix Project and felixhaedicke/nst-kernel

FROM ubuntu:20.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies including bison and flex
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

# Set load address for Nook Simple Touch (OMAP3621)
ENV LOADADDR=0x80008000

# Default command
CMD ["/bin/bash"]