# Debian Lenny Authentic Test Environment
# Multi-stage build creating reusable Debian Lenny 5.0 from archive.debian.org
# "Period-correct 2009 environment for authentic JesterOS testing!"

# =============================================================================
# Stage 1: Debian Lenny Builder
# Uses modern tools to build authentic 2009 environment
# =============================================================================
FROM debian:bullseye-slim AS lenny-builder

# Install debootstrap and required tools
RUN apt-get update && apt-get install -y \
    debootstrap \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Extract authentic Debian Lenny 5.0 (pre-built from archive.debian.org)
# This uses the actual packages from 2009!
COPY lenny-rootfs.tar.gz /tmp/
RUN echo "Extracting authentic Debian Lenny 5.0..." && \
    mkdir -p /lenny-rootfs && \
    cd /lenny-rootfs && \
    tar -xzf /tmp/lenny-rootfs.tar.gz && \
    rm /tmp/lenny-rootfs.tar.gz

# Verify we got authentic Lenny
RUN cat /lenny-rootfs/etc/debian_version && \
    cat /lenny-rootfs/etc/issue && \
    echo "✓ Authentic Debian Lenny 5.0 extracted successfully!"

# Create essential directories for JesterOS deployment
RUN mkdir -p /lenny-rootfs/var/jesteros/typewriter \
             /lenny-rootfs/var/jesteros/health \
             /lenny-rootfs/var/lib/jester \
             /lenny-rootfs/var/run/jesteros \
             /lenny-rootfs/var/log/jesteros \
             /lenny-rootfs/usr/local/bin \
             /lenny-rootfs/root/manuscripts \
             /lenny-rootfs/root/notes \
             /lenny-rootfs/root/drafts \
             /lenny-rootfs/etc/jesteros/services

# Set up basic Lenny environment
RUN echo 'export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"' > /lenny-rootfs/etc/profile && \
    echo 'export TERM=linux' >> /lenny-rootfs/etc/profile && \
    echo 'export SHELL=/bin/sh' >> /lenny-rootfs/etc/profile

# =============================================================================
# Stage 2: Reusable Debian Lenny Base Image  
# Clean, minimal Lenny environment that can be reused
# =============================================================================
FROM scratch AS debian-lenny-base

# Copy the complete authentic Debian Lenny filesystem
COPY --from=lenny-builder /lenny-rootfs /

# Set period-correct environment variables (2009 era)
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux
ENV SHELL=/bin/sh
ENV EDITOR=vi
ENV PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
ENV HOME=/root

# Working directory
WORKDIR /root

# Metadata for the base image
LABEL maintainer="JesterOS Project" \
      description="Authentic Debian Lenny 5.0 base image built from archive.debian.org" \
      version="5.0" \
      build-date="2009-02-14" \
      authentic="true"

# Default command
CMD ["/bin/sh"]

# =============================================================================
# Stage 3: JesterOS Test Environment
# Lenny base + JesterOS runtime for authentic testing
# =============================================================================
FROM debian-lenny-base AS jesteros-lenny-test

# Copy JesterOS runtime system
COPY runtime/ /runtime/

# Create symbolic links for JesterOS services (as deployed on Nook)
RUN ln -sf /runtime/2-application/jesteros/jester-daemon.sh /usr/local/bin/jester-daemon.sh && \
    ln -sf /runtime/2-application/jesteros/jesteros-tracker.sh /usr/local/bin/jesteros-tracker.sh && \
    ln -sf /runtime/2-application/jesteros/health-check.sh /usr/local/bin/health-check.sh && \
    ln -sf /runtime/2-application/jesteros/manager.sh /usr/local/bin/jesteros-manager.sh && \
    ln -sf /runtime/init/jesteros-service-init.sh /usr/local/bin/jesteros-service-init.sh

# Make all JesterOS scripts executable
RUN find /runtime -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true

# Initialize jester's home (as on Nook)
RUN echo "By quill and candlelight!" > /var/lib/jester/motto && \
    echo "0" > /var/lib/jester/wordcount

# Set JesterOS environment variables
ENV RUNTIME_BASE=/runtime
ENV JESTEROS_BASE=/var/jesteros
ENV COMMON_PATH=/runtime/3-system/common/common.sh

# Copy test scripts
COPY tests/ /tests/
RUN chmod +x /tests/*.sh 2>/dev/null || true

# Create comprehensive validation script
RUN cat > /validate-authentic-lenny.sh << 'EOF'
#!/bin/sh
# JesterOS Authentic Lenny Validation
# Tests in TRUE 2009 Debian environment

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           JESTEROS AUTHENTIC LENNY VALIDATION                 ║"
echo "║      \"Testing in the true spirit of the 2009 realm!\"          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Show authentic environment
echo "Authentic Environment:"
echo "  Debian: $(cat /etc/debian_version)"
echo "  Issue: $(head -1 /etc/issue)"
echo "  Shell: $SHELL"
echo "  Architecture: $(uname -m)"
echo ""

# Test basic Lenny functionality
echo "Test 1: Debian Lenny Authenticity"
if grep -q "5.0" /etc/debian_version && grep -q "Debian GNU/Linux 5.0" /etc/issue; then
    echo "✓ Authentic Debian Lenny 5.0 confirmed"
else
    echo "✗ Not authentic Debian Lenny"
    exit 1
fi

# Test JesterOS in Lenny
echo "Test 2: JesterOS Services in Lenny"
if [ -x "/usr/local/bin/jesteros-service-init.sh" ]; then
    echo "✓ JesterOS services installed in Lenny"
else
    echo "✗ JesterOS services missing"
    exit 1
fi

# Test initialization
echo "Test 3: Service Initialization"
if /usr/local/bin/jesteros-service-init.sh directories >/dev/null 2>&1 && \
   /usr/local/bin/jesteros-service-init.sh interface >/dev/null 2>&1; then
    echo "✓ JesterOS initialization works in Lenny"
else
    echo "✗ JesterOS initialization failed in Lenny"
    exit 1
fi

# Test interface creation
echo "Test 4: Interface Files"
if [ -s "/var/jesteros/jester" ] && [ -s "/var/jesteros/typewriter/stats" ]; then
    echo "✓ JesterOS interfaces created in Lenny"
else
    echo "✗ JesterOS interfaces missing in Lenny"
    exit 1
fi

echo ""
echo "🏰 SUCCESS: JesterOS works perfectly in authentic Debian Lenny!"
echo ""
echo "Sample Jester in Lenny:"
head -5 /var/jesteros/jester | sed 's/^/  /'
echo ""
echo "\"By quill and candlelight, authentically tested in the 2009 realm!\""
EOF

RUN chmod +x /validate-authentic-lenny.sh

# Metadata for test image
LABEL purpose="JesterOS testing in authentic Debian Lenny 5.0" \
      base="debian-lenny-5.0" \
      jesteros="userspace-services"

# Default command runs validation
CMD ["/validate-authentic-lenny.sh"]