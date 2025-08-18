# JesterOS Development Build - Optimized
# Minimal development environment with build optimizations
# Target: <35MB runtime with development tools

FROM debian:bullseye-slim AS builder

# Build arguments for optimization
ARG DEBIAN_FRONTEND=noninteractive
ARG OPTIMIZE=1
ARG DEV_MODE=1

# Install minimal build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    make \
    libc6-dev \
    busybox-static \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create directory structure
RUN mkdir -p /build/runtime /build/bin /build/etc

# Copy runtime scripts with build-time validation
COPY runtime/ /build/runtime/
RUN find /build/runtime -name "*.sh" -exec chmod +x {} \; && \
    find /build/runtime -name "*.sh" -exec bash -n {} \;

# Optimization stage
FROM debian:bullseye-slim AS optimizer

# Copy from builder
COPY --from=builder /build /opt/jesteros

# Install only runtime essentials
RUN apt-get update && apt-get install -y --no-install-recommends \
    busybox-static \
    vim-tiny \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    /usr/share/doc/* \
    /usr/share/man/* \
    /usr/share/locale/* \
    /usr/share/info/*

# Aggressive space optimization
RUN find /usr -name "*.pyc" -delete 2>/dev/null || true && \
    find /usr -name "*.pyo" -delete 2>/dev/null || true && \
    find /usr -name "__pycache__" -type d -delete 2>/dev/null || true && \
    rm -rf /usr/share/zoneinfo/* && \
    rm -rf /usr/share/misc/* 2>/dev/null || true && \
    strip /usr/bin/* 2>/dev/null || true

# Final stage - Development Runtime
FROM scratch AS final

# Copy minimal system from optimizer
COPY --from=optimizer /lib/x86_64-linux-gnu/ /lib/x86_64-linux-gnu/
COPY --from=optimizer /lib64/ /lib64/
COPY --from=optimizer /bin/ /bin/
COPY --from=optimizer /usr/bin/vim.tiny /usr/bin/vim
COPY --from=optimizer /bin/busybox /bin/busybox
COPY --from=optimizer /opt/jesteros/runtime/ /runtime/

# Create essential directories
COPY --from=optimizer /etc/passwd /etc/passwd
COPY --from=optimizer /etc/group /etc/group

# Setup working directories
WORKDIR /root

# Create writer directories
RUN ["/bin/busybox", "mkdir", "-p", "/root/notes", "/root/drafts", "/root/scrolls"]
RUN ["/bin/busybox", "mkdir", "-p", "/var/jesteros", "/var/log", "/tmp"]

# Development mode environment
ENV DEV_MODE=1
ENV JESTEROS_HOME=/runtime
ENV PATH=/runtime/init:/runtime/1-ui/menu:/bin:/usr/bin

# Health check for development
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
    CMD ["/bin/busybox", "test", "-f", "/runtime/init/jesteros-init.sh"]

# Entry point for development
ENTRYPOINT ["/bin/busybox", "sh", "-c"]
CMD ["echo 'JesterOS Dev Build - Optimized'; /bin/busybox sh"]

# Labels
LABEL version="1.0.0-dev-optimized" \
      description="JesterOS Development Build - Optimized" \
      maintainer="JesterOS Project" \
      build.date="2025-01-18" \
      build.type="development" \
      build.optimized="true"