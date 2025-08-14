# Minimal Boot Environment for QuillKernel MVP
# Ultra-lightweight Debian for first boot test
# Target: < 30MB compressed

FROM debian:bullseye-slim AS rootfs

# Install absolute minimum for boot testing
RUN apt-get update && apt-get install -y --no-install-recommends \
    busybox-static \
    kmod \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc/* \
    && rm -rf /usr/share/man/*

# Create essential directories
RUN mkdir -p /proc /sys /dev /lib/modules/2.6.29 \
    /usr/local/bin /root

# Create minimal init script for MVP boot
RUN echo '#!/bin/sh' > /init && \
    echo '# QuillKernel MVP Init' >> /init && \
    echo 'mount -t proc none /proc' >> /init && \
    echo 'mount -t sysfs none /sys' >> /init && \
    echo 'mount -t devtmpfs none /dev' >> /init && \
    echo '' >> /init && \
    echo '# Load SquireOS modules' >> /init && \
    echo 'if [ -f /lib/modules/squireos_core.ko ]; then' >> /init && \
    echo '    echo "Loading SquireOS Medieval Interface..."' >> /init && \
    echo '    insmod /lib/modules/squireos_core.ko' >> /init && \
    echo '    insmod /lib/modules/jester.ko 2>/dev/null' >> /init && \
    echo '    insmod /lib/modules/typewriter.ko 2>/dev/null' >> /init && \
    echo '    insmod /lib/modules/wisdom.ko 2>/dev/null' >> /init && \
    echo 'fi' >> /init && \
    echo '' >> /init && \
    echo '# Show jester if available' >> /init && \
    echo 'if [ -f /proc/squireos/jester ]; then' >> /init && \
    echo '    cat /proc/squireos/jester' >> /init && \
    echo 'else' >> /init && \
    echo '    echo "QuillKernel MVP Boot Success!"' >> /init && \
    echo 'fi' >> /init && \
    echo '' >> /init && \
    echo '# Launch minimal menu' >> /init && \
    echo 'exec /usr/local/bin/mvp-menu.sh' >> /init && \
    chmod +x /init

# Create MVP menu script
RUN echo '#!/bin/sh' > /usr/local/bin/mvp-menu.sh && \
    echo 'clear' >> /usr/local/bin/mvp-menu.sh && \
    echo 'echo "═══════════════════════════════════"' >> /usr/local/bin/mvp-menu.sh && \
    echo 'echo "     QuillKernel MVP Menu"' >> /usr/local/bin/mvp-menu.sh && \
    echo 'echo "═══════════════════════════════════"' >> /usr/local/bin/mvp-menu.sh && \
    echo 'echo ""' >> /usr/local/bin/mvp-menu.sh && \
    echo 'echo "1. Show Jester"' >> /usr/local/bin/mvp-menu.sh && \
    echo 'echo "2. Show Statistics"' >> /usr/local/bin/mvp-menu.sh && \
    echo 'echo "3. Show Wisdom"' >> /usr/local/bin/mvp-menu.sh && \
    echo 'echo "4. Shell"' >> /usr/local/bin/mvp-menu.sh && \
    echo 'echo "5. Reboot"' >> /usr/local/bin/mvp-menu.sh && \
    echo 'echo ""' >> /usr/local/bin/mvp-menu.sh && \
    echo 'echo -n "Choice: "' >> /usr/local/bin/mvp-menu.sh && \
    echo 'read choice' >> /usr/local/bin/mvp-menu.sh && \
    echo '' >> /usr/local/bin/mvp-menu.sh && \
    echo 'case $choice in' >> /usr/local/bin/mvp-menu.sh && \
    echo '    1) cat /proc/squireos/jester 2>/dev/null || echo "Module not loaded" ;;' >> /usr/local/bin/mvp-menu.sh && \
    echo '    2) cat /proc/squireos/typewriter/stats 2>/dev/null || echo "Module not loaded" ;;' >> /usr/local/bin/mvp-menu.sh && \
    echo '    3) cat /proc/squireos/wisdom 2>/dev/null || echo "Module not loaded" ;;' >> /usr/local/bin/mvp-menu.sh && \
    echo '    4) exec /bin/sh ;;' >> /usr/local/bin/mvp-menu.sh && \
    echo '    5) reboot ;;' >> /usr/local/bin/mvp-menu.sh && \
    echo '    *) echo "Invalid choice" ;;' >> /usr/local/bin/mvp-menu.sh && \
    echo 'esac' >> /usr/local/bin/mvp-menu.sh && \
    echo '' >> /usr/local/bin/mvp-menu.sh && \
    echo 'exec /usr/local/bin/mvp-menu.sh' >> /usr/local/bin/mvp-menu.sh && \
    chmod +x /usr/local/bin/mvp-menu.sh

# Minimize size
RUN find / -name "*.a" -delete 2>/dev/null || true && \
    find / -name "*.la" -delete 2>/dev/null || true && \
    rm -rf /usr/share/locale/* 2>/dev/null || true

# Set init as entrypoint
ENTRYPOINT ["/init"]