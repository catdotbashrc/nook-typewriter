# JesterOS Base Image
# Modular base environment for JesterOS development and deployment
# "By quill and candlelight, we build the foundation!"

FROM debian:bullseye-slim AS base

# Install essential packages (matching Nook environment)
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    busybox-static \
    perl \
    grep \
    gawk \
    procps \
    psmisc \
    findutils \
    coreutils \
    util-linux \
    udev \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc/* \
    && rm -rf /usr/share/man/*

# Create the complete JesterOS directory structure including GK61 keyboard support
RUN mkdir -p /runtime/1-ui/display \
    /runtime/1-ui/themes \
    /runtime/1-ui/menu \
    /runtime/1-ui/setup \
    /runtime/2-application/jesteros \
    /runtime/3-system/common \
    /runtime/3-system/services \
    /runtime/4-hardware/eink \
    /runtime/4-hardware/input \
    /runtime/4-hardware/usb \
    /runtime/configs/services \
    /runtime/configs/system \
    /runtime/init \
    /var/jesteros/typewriter \
    /var/jesteros/health \
    /var/jesteros/keyboard \
    /var/jesteros/usb \
    /var/jesteros/buttons \
    /var/run/jesteros \
    /var/log/jesteros \
    /var/lib/jester \
    /etc/jesteros/services \
    /usr/local/bin \
    /root/manuscripts \
    /root/notes \
    /root/drafts \
    /root/scrolls \
    /dev/input

# Copy the complete runtime system
COPY runtime/ /runtime/

# Make all scripts executable and create mock system files for testing
RUN find /runtime -name "*.sh" -type f -exec chmod +x {} \; && \
    chmod +x /usr/local/bin/* 2>/dev/null || true && \
    # Create mock input devices for testing \
    mkdir -p /dev/input && \
    touch /dev/input/event0 /dev/input/event1 /dev/input/event2 /dev/input/event3 && \
    # Create mock USB OTG controller interface in test location \
    mkdir -p /tmp/mock-sys/devices/platform/musb_hdrc && \
    echo "b_idle" > /tmp/mock-sys/devices/platform/musb_hdrc/mode && \
    # Create mock evtest command \
    echo '#!/bin/bash\necho "Mock evtest - device monitoring simulation"\nwhile true; do sleep 1; done' > /usr/bin/evtest && \
    chmod +x /usr/bin/evtest

# Create symbolic links for service executables (as they would be installed)
RUN ln -sf /runtime/2-application/jesteros/jester-daemon.sh /usr/local/bin/jester-daemon.sh && \
    ln -sf /runtime/2-application/jesteros/jesteros-tracker.sh /usr/local/bin/jesteros-tracker.sh && \
    ln -sf /runtime/2-application/jesteros/health-check.sh /usr/local/bin/health-check.sh && \
    ln -sf /runtime/2-application/jesteros/manager.sh /usr/local/bin/jesteros-manager.sh && \
    ln -sf /runtime/init/jesteros-service-init.sh /usr/local/bin/jesteros-service-init.sh && \
    ln -sf /runtime/3-system/services/usb-keyboard-manager.sh /usr/local/bin/usb-keyboard-manager.sh && \
    ln -sf /runtime/4-hardware/input/button-handler.sh /usr/local/bin/button-handler.sh && \
    ln -sf /runtime/1-ui/setup/usb-keyboard-setup.sh /usr/local/bin/usb-keyboard-setup.sh

# Set environment variables to match Nook deployment
ENV TERM=linux
ENV RUNTIME_BASE=/runtime
ENV JESTEROS_BASE=/var/jesteros
ENV COMMON_PATH=/runtime/3-system/common/common.sh

# Create a simple status script for the base image
RUN cat > /usr/local/bin/jesteros-status.sh << 'EOF'
#!/bin/bash
# JesterOS Base Image Status
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                     JESTEROS BASE IMAGE                       ║"
echo "║                                                                ║"
echo "║              \"The foundation of the digital court!\"            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Image Information:"
echo "  OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "  Architecture: $(uname -m)"
echo "  Memory: $(grep MemTotal /proc/meminfo | awk '{print $2 / 1024 "MB"}')"
echo ""
echo "JesterOS Components:"
echo "  Runtime Base: ${RUNTIME_BASE}"
echo "  Data Base: ${JESTEROS_BASE}"
echo "  Services: $(ls -1 /usr/local/bin/*jesteros* | wc -l) available"
echo "  USB Keyboard: $(test -x /usr/local/bin/usb-keyboard-manager.sh && echo 'Supported' || echo 'Not available')"
echo ""
echo "Available Services:"
for service in /usr/local/bin/*jesteros* /usr/local/bin/usb-keyboard* /usr/local/bin/button-handler*; do
    if [ -x "$service" ]; then
        basename "$service"
    fi
done
echo ""
echo "To run services:"
echo "  jesteros-service-init.sh init    # Initialize system"
echo "  usb-keyboard-setup.sh setup      # Setup GK61 keyboard"
echo "  button-handler.sh monitor        # Start input monitoring"
echo ""
EOF

RUN chmod +x /usr/local/bin/jesteros-status.sh

# Set working directory
WORKDIR /

# Default command shows status
CMD ["/usr/local/bin/jesteros-status.sh"]