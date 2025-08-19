# JesterOS Production Environment
# Uses ACTUAL Debian Lenny 5.0 (period-correct from 2009)
# This is the PRODUCTION deployment environment for Nook hardware
# "By quill and candlelight, we deploy to the realm!"

FROM scratch

# Copy the authentic Debian Lenny 5.0 rootfs
# This is the EXACT same environment that runs on Nook hardware
ADD ./lenny-rootfs.tar.gz /

# Install essential packages for production (from Lenny repositories)
# CRITICAL: Install vim for core writing functionality
RUN echo "Setting up authentic Debian Lenny 5.0 production environment..." && \
    # Create necessary apt directories (minimal rootfs doesn't have them)
    mkdir -p /var/lib/apt/lists/partial && \
    mkdir -p /var/cache/apt/archives/partial && \
    # Configure Lenny repositories (archived)
    echo "deb http://archive.debian.org/debian/ lenny main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security/ lenny/updates main" >> /etc/apt/sources.list && \
    # Update package lists with archived keyring workaround
    apt-get update -o Acquire::Check-Valid-Until=false || true && \
    # Install regular vim (standard package for ARM)
    apt-get install -y --force-yes vim && \
    # Clean up to minimize image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    # Remove Docker contamination markers
    rm -f /.dockerenv /.dockerinit

# Create the complete JesterOS directory structure (as it would be deployed)
RUN mkdir -p /runtime/1-ui/display \
    /runtime/1-ui/themes \
    /runtime/2-application/jesteros \
    /runtime/3-system/common \
    /runtime/3-system/services \
    /runtime/4-hardware/eink \
    /runtime/configs/services \
    /runtime/configs/system \
    /runtime/init \
    /var/jesteros/typewriter \
    /var/jesteros/health \
    /var/run/jesteros \
    /var/log/jesteros \
    /var/lib/jester \
    /etc/jesteros/services \
    /usr/local/bin \
    /root/manuscripts \
    /root/notes \
    /root/drafts \
    /root/scrolls

# Copy the JesterOS runtime system (exactly as deployed)
COPY runtime/ /runtime/

# Setup JesterOS: make scripts executable, create symlinks, and initialize
RUN find /runtime -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true && \
    ln -sf /runtime/2-application/jesteros/jester-daemon.sh /usr/local/bin/jester-daemon.sh && \
    ln -sf /runtime/2-application/jesteros/jesteros-tracker.sh /usr/local/bin/jesteros-tracker.sh && \
    ln -sf /runtime/2-application/jesteros/health-check.sh /usr/local/bin/health-check.sh && \
    ln -sf /runtime/2-application/jesteros/manager.sh /usr/local/bin/jesteros-manager.sh && \
    ln -sf /runtime/init/jesteros-service-init.sh /usr/local/bin/jesteros-service-init.sh && \
    echo "By quill and candlelight!" > /var/lib/jester/motto && \
    echo "0" > /var/lib/jester/wordcount

# Set environment variables to match authentic Nook deployment
ENV TERM=linux
ENV EDITOR=vim
ENV SHELL=/bin/sh
ENV RUNTIME_BASE=/runtime
ENV JESTEROS_BASE=/var/jesteros
ENV COMMON_PATH=/runtime/3-system/common/common.sh
ENV DEBIAN_FRONTEND=noninteractive

# Working directory (as on Nook)
WORKDIR /root

# Production image - no test scripts included
# Tests are added in the test-specific docker images

# Create and configure production startup script
RUN cat > /start-jesteros.sh << 'EOF'
#!/bin/bash
# JesterOS Production Startup
# Initialize services for production deployment on Nook hardware
# "By quill and candlelight, the digital court awakens!"

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                  JESTEROS PRODUCTION ENVIRONMENT               ║"
echo "║           \"The digital court is ready for writing!\"            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Show authentic environment
echo -e "${BLUE}Authentic Nook Environment:${NC}"
echo "  OS: $(cat /etc/issue | head -1)"
echo "  Kernel: $(uname -r 2>/dev/null || echo 'Container kernel')"
echo "  Architecture: $(uname -m)"
echo "  Shell: $SHELL"
echo "  Editor: $EDITOR ($(which vim >/dev/null 2>&1 && echo 'installed' || echo 'MISSING!'))"
echo "  Debian Release: $(cat /etc/debian_version 2>/dev/null || echo 'Lenny 5.0')"
echo ""

# Verify vim is installed (critical for writing functionality)
if ! which vim >/dev/null 2>&1; then
    echo -e "${RED}CRITICAL: vim is not installed! Writing functionality unavailable.${NC}"
    echo "Please rebuild the image with vim-tiny package."
    exit 1
fi

# Initialize JesterOS services
echo -e "${BLUE}Initializing JesterOS services...${NC}"

# Initialize directories
if /usr/local/bin/jesteros-service-init.sh directories >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Directories initialized${NC}"
else
    echo -e "${RED}✗ Directory initialization failed${NC}"
    exit 1
fi

# Initialize interfaces
if /usr/local/bin/jesteros-service-init.sh interface >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Interfaces created${NC}"
else
    echo -e "${RED}✗ Interface creation failed${NC}"
    exit 1
fi

# Start service manager
if /runtime/2-application/jesteros/manager.sh init >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Service manager started${NC}"
else
    echo -e "${RED}✗ Service manager failed${NC}"
    exit 1
fi

# Health check
if /runtime/2-application/jesteros/health-check.sh check >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Health monitoring active${NC}"
else
    echo -e "${RED}✗ Health monitoring failed${NC}"
    exit 1
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    JESTEROS READY FOR PRODUCTION              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}🏰 SUCCESS: JesterOS services initialized!${NC}"
echo ""
echo "✅ Running in Debian Lenny 5.0 (2009)"
echo "✅ All services started successfully"
echo "✅ Ready for deployment to Nook hardware"
    echo ""
echo ""
echo -e "${YELLOW}Service Status:${NC}"
echo "========================="
echo -e "${BLUE}Jester Interface:${NC}"
head -5 /var/jesteros/jester | sed "s/^/  /"
echo ""
echo -e "${BLUE}System Info:${NC}"
echo "  Debian Version: $(cat /etc/debian_version)"
echo "  Available Memory: $(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2/1024 "MB"}' || echo 'N/A (container)')"
echo ""
echo -e "${GREEN}Ready for production deployment!${NC}"
echo -e "${YELLOW}\"By quill and candlelight, the digital court is ready!\"${NC}"
EOF

# Make startup script executable
RUN chmod +x /start-jesteros.sh

# Default command starts JesterOS services
CMD ["/start-jesteros.sh"]