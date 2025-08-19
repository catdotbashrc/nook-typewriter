# syntax=docker/dockerfile:1
# JesterOS Unified Debian Lenny Base - Shared Foundation for All Images
# Optimized with BuildKit for caching while maintaining Debian 5.0 compatibility
# "By quill and candlelight, we build upon ancient foundations!"

# This base image is used by ALL JesterOS Docker images to ensure:
# 1. Consistent Debian Lenny 5.0 base (REQUIRED for Nook hardware)
# 2. Shared layers across all images (reduces total size)
# 3. BuildKit cache optimizations (faster rebuilds)
# 4. Single source of truth for base configuration

FROM scratch AS lenny-base

# Add the authentic Debian Lenny 5.0 rootfs
# This is CRITICAL for Nook SimpleTouch hardware compatibility
ADD ./lenny-rootfs.tar.gz /

# Set up base environment variables used by all images
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=linux \
    LANG=C \
    LC_ALL=C \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Create base directory structure needed by all JesterOS components
# This is done once in the base and inherited by all child images
RUN mkdir -p \
    /usr/local/bin \
    /usr/local/lib \
    /var/log \
    /var/run \
    /var/lib \
    /tmp \
    /root

# Base system configuration that all images need
RUN echo "JesterOS on Debian Lenny 5.0" > /etc/jesteros-base && \
    echo "deb http://archive.debian.org/debian lenny main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security lenny/updates main" >> /etc/apt/sources.list

# Install minimal base packages with BuildKit cache mount
# These are common to ALL JesterOS images
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        busybox \
        coreutils \
        findutils \
        grep \
        sed \
        gawk \
        tar \
        gzip \
        ca-certificates || true

# Clean up apt lists to reduce image size
# But keep the cache mounts for faster rebuilds
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Mark this as a JesterOS base image
RUN echo "jesteros-lenny-base:1.0" > /etc/jesteros-base-version

# This is a base image, no CMD or ENTRYPOINT
# Child images will define their own startup behavior

# ============================================================================
# STAGE 2: Development Base (extends lenny-base with dev tools)
# ============================================================================
FROM lenny-base AS dev-base

# Additional development packages with cache mount
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        wget \
        vim \
        bash \
        perl \
        python || true && \
    rm -rf /var/lib/apt/lists/*

# Mark as development variant
RUN echo "jesteros-dev-base:1.0" > /etc/jesteros-base-version

# ============================================================================
# STAGE 3: Runtime Base (minimal for production)
# ============================================================================
FROM lenny-base AS runtime-base

# Only essential runtime packages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        vim \
        perl || true && \
    rm -rf /var/lib/apt/lists/*

# Remove unnecessary files for production
RUN rm -rf \
    /usr/share/doc/* \
    /usr/share/man/* \
    /usr/share/info/* \
    /usr/share/locale/* \
    /var/cache/apt/* \
    /usr/share/vim/vim*/doc/* \
    /usr/share/vim/vim*/tutor/* \
    /usr/share/vim/vim*/spell/*

# Mark as runtime variant
RUN echo "jesteros-runtime-base:1.0" > /etc/jesteros-base-version

# ============================================================================
# Build Instructions:
# ============================================================================
# Build all stages:
#   DOCKER_BUILDKIT=1 docker build --target lenny-base -t jesteros:lenny-base -f jesteros-lenny-base.dockerfile .
#   DOCKER_BUILDKIT=1 docker build --target dev-base -t jesteros:dev-base -f jesteros-lenny-base.dockerfile .
#   DOCKER_BUILDKIT=1 docker build --target runtime-base -t jesteros:runtime-base -f jesteros-lenny-base.dockerfile .
#
# Use in other Dockerfiles:
#   FROM jesteros:runtime-base AS production
#   FROM jesteros:dev-base AS builder
#
# Benefits:
# - All images share the same Debian Lenny base layers
# - BuildKit cache mounts speed up package installation
# - Three variants: base (minimal), dev (with tools), runtime (production)
# - Consistent environment across all JesterOS components