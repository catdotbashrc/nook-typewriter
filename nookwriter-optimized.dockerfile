# Optimized Nook Writer - RAM-conscious configuration
# Two build targets: minimal (2MB RAM) or writer (5MB RAM)
# Default: writer mode with essential plugins only

ARG BUILD_MODE=writer

FROM debian:bullseye-slim AS base

# Install only essential packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core editor
    vim \
    # Shell utilities
    busybox \
    perl \
    # Required for some scripts
    grep \
    gawk \
    # Sync capability
    rsync \
    # Required for FBInk
    libfreetype6 \
    ca-certificates \
    # Required for downloading FBInk
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Download FBInk directly from GitHub releases (ARM version)
# This eliminates circular dependency on nook-system:latest
RUN wget -q -O /usr/local/bin/fbink \
    https://github.com/NiLuJe/FBInk/releases/download/v1.25.0/fbink-v1.25.0-armv7-linux-gnueabihf.tar.xz \
    && tar -xJf /usr/local/bin/fbink -C /usr/local/bin/ \
    && rm /usr/local/bin/fbink \
    && mv /usr/local/bin/FBInk-v1.25.0-armv7-linux-gnueabihf/fbink /usr/local/bin/ \
    && rm -rf /usr/local/bin/FBInk-v1.25.0-armv7-linux-gnueabihf \
    && chmod +x /usr/local/bin/fbink \
    || echo "Warning: FBInk download failed, E-Ink display won't work"

# === MINIMAL BUILD (No plugins, 2MB RAM) ===
FROM base AS minimal

# Copy minimal config
COPY config/vimrc-minimal /root/.vimrc
COPY config/colors/eink.vim /root/.vim/colors/eink.vim

# No plugins for minimal build
RUN echo "colorscheme eink" >> /root/.vimrc

# === WRITER BUILD (Goyo + Pencil, 5MB RAM) ===
FROM base AS writer

# Install only essential vim plugins
RUN mkdir -p /root/.vim/pack/plugins/start && \
    cd /root/.vim/pack/plugins/start && \
    # Goyo - distraction free (essential)
    git clone --depth=1 https://github.com/junegunn/goyo.vim && \
    # Pencil - soft wrap for prose (essential)
    git clone --depth=1 https://github.com/preservim/vim-pencil && \
    # Litecorrect - autocorrect common typos (small, useful)
    git clone --depth=1 https://github.com/preservim/vim-litecorrect && \
    # Clean up git files to save space
    find . -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true

# Copy writer config
COPY config/vimrc-writer /root/.vimrc
COPY config/colors/eink.vim /root/.vim/colors/eink.vim

RUN echo "colorscheme eink" >> /root/.vimrc

# === FINAL STAGE ===
FROM ${BUILD_MODE} AS final

# Copy all scripts and configs
COPY config/scripts/ /usr/local/bin/
COPY config/system/fstab /etc/fstab
COPY config/system/sysctl.conf /etc/sysctl.conf

# SquireOS branding
COPY config/system/os-release /etc/os-release
COPY config/system/lsb-release /etc/lsb-release
COPY config/system/issue /etc/issue
COPY config/system/issue.net /etc/issue.net
COPY config/system/motd /etc/motd

# Create writing directories
RUN mkdir -p /root/notes /root/drafts /root/scrolls && \
    mkdir -p /root/.vim/backup /root/.vim/swap

# Make scripts executable
RUN chmod +x /usr/local/bin/*.sh 2>/dev/null || true

# Set permissions
RUN chmod 644 /etc/os-release /etc/lsb-release /etc/issue /etc/issue.net /etc/motd

# Clean up to save RAM
RUN rm -rf /usr/share/doc/* \
    /usr/share/man/* \
    /usr/share/info/* \
    /usr/share/locale/* \
    /var/cache/apt/* \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
    /usr/share/vim/vim*/doc/* \
    /usr/share/vim/vim*/tutor/* \
    /usr/share/vim/vim*/spell/* \
    /usr/share/vim/vim*/lang/*

# Optimize vim for minimal RAM
RUN echo "set viminfo='10,<50,s10,h" >> /root/.vimrc && \
    echo "set directory=/tmp" >> /root/.vimrc && \
    echo "set backupdir=/tmp" >> /root/.vimrc

# Environment
ENV TERM=linux
ENV EDITOR=vim
ENV SHELL=/bin/sh
ENV SQUIRE_OS_VERSION=1.0.1
ENV SQUIRE_MOTTO="By quill and candlelight"

WORKDIR /root

# Add startup script that detects mode
RUN cat > /usr/local/bin/startup.sh << 'EOF'
#!/bin/sh
if [ -d /root/.vim/pack/plugins/start/goyo.vim ]; then
  echo "SquireOS Writer Mode - Goyo & Pencil enabled"
  echo "RAM usage: ~5MB | F5=Focus Mode"
else
  echo "SquireOS Minimal Mode - No plugins"
  echo "RAM usage: ~2MB | Maximum writing space"
fi
echo "Ready to write. F3=Save F4=Quit F6=WordCount"
exec /bin/sh
EOF

RUN chmod +x /usr/local/bin/startup.sh

CMD ["/usr/local/bin/startup.sh"]