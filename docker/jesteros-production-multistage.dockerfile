# syntax=docker/dockerfile:1
# JesterOS Production Environment - Multi-Stage Optimized
# Uses unified Debian Lenny base with multi-stage validation
# "By quill and candlelight, we optimize the realm!"

# Stage 1: Validation (uses Debian Lenny for consistency)
FROM jesteros:dev-base AS validator

# Copy runtime scripts for validation
COPY runtime/ /validate/runtime/

# Validate all shell scripts at build time
RUN echo "→ Validating JesterOS scripts..." && \
    find /validate/runtime -name "*.sh" -type f | while read script; do \
        echo "  Checking: $(basename $script)"; \
        bash -n "$script" || exit 1; \
    done && \
    echo "✓ All scripts validated successfully"

# Count scripts for verification
RUN script_count=$(find /validate/runtime -name "*.sh" -type f | wc -l) && \
    echo "✓ Validated $script_count JesterOS scripts"

# Stage 2: Production (uses unified Debian Lenny runtime base)
FROM jesteros:runtime-base AS production

# This inherits Debian Lenny 5.0 from our unified base
# Maintains CRITICAL Nook hardware compatibility

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

# Copy the validated JesterOS runtime system from validator stage
# Scripts have been pre-validated, so we know they're syntactically correct
COPY --from=validator /validate/runtime/ /runtime/

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
ENV EDITOR=vi
ENV SHELL=/bin/sh
ENV RUNTIME_BASE=/runtime
ENV JESTEROS_BASE=/var/jesteros
ENV COMMON_PATH=/runtime/3-system/common/common.sh
ENV DEBIAN_FRONTEND=noninteractive

# Working directory (as on Nook)
WORKDIR /root

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
echo "║           JESTEROS PRODUCTION ENVIRONMENT (OPTIMIZED)          ║"
echo "║           \"The digital court is ready for writing!\"            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Show authentic environment
echo -e "${BLUE}Authentic Nook Environment:${NC}"
echo "  OS: $(cat /etc/issue | head -1)"
echo "  Kernel: $(uname -r 2>/dev/null || echo 'Container kernel')"
echo "  Architecture: $(uname -m)"
echo "  Shell: $SHELL"
echo "  Editor: $EDITOR"
echo "  Debian Release: $(cat /etc/debian_version 2>/dev/null || echo 'Lenny 5.0')"
echo ""

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
echo "✅ All scripts pre-validated at build time"
echo "✅ Ready for deployment to Nook hardware"
echo ""
echo -e "${YELLOW}Service Status:${NC}"
echo "========================="
echo -e "${BLUE}Jester Interface:${NC}"
head -5 /var/jesteros/jester 2>/dev/null | sed "s/^/  /" || echo "  [Starting...]"
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