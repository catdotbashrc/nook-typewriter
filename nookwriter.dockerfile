# Use Debian slim for everything - simpler and more compatible
FROM debian:bullseye-slim

# Install all packages from Debian repos
RUN apt-get update && apt-get install -y \
    # Editor and writing tools
    vim git tmux \
    # Sync and network tools
    rsync rclone openssh-client curl wget \
    # System utilities
    bash procps \
    # Filesystem tools for SD card management
    e2fsprogs f2fs-tools dosfstools \
    # Network tools for Nook WiFi
    wireless-tools wpasupplicant \
    # Build dependencies for FBInk only
    build-essential cmake \
    libfreetype6-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Build and install FBInk (E-Ink display driver)
RUN git clone --depth=1 https://github.com/NiLuJe/FBInk && \
    cd FBInk && \
    git submodule update --init --recursive && \
    make clean && \
    make MINIMAL=1 FONTS=1 LINUX=1 && \
    make install && \
    cd / && rm -rf /FBInk

# Install Vim plugins
RUN mkdir -p /root/.vim/pack/plugins/start && \
    cd /root/.vim/pack/plugins/start && \
    git clone --depth=1 https://github.com/reedes/vim-pencil && \
    git clone --depth=1 https://github.com/junegunn/goyo.vim && \
    git clone --depth=1 https://github.com/michal-h21/vim-zettel && \
    git clone --depth=1 https://github.com/itchyny/lightline.vim

# Add configurations
COPY config/vimrc /root/.vimrc
COPY config/vim/ /root/.vim/
COPY config/scripts/ /usr/local/bin/
COPY config/system/fstab /etc/fstab
COPY config/system/sysctl.conf /etc/sysctl.conf

# Add SquireOS branding
COPY config/system/os-release /etc/os-release
COPY config/system/lsb-release /etc/lsb-release
COPY config/system/issue /etc/issue
COPY config/system/issue.net /etc/issue.net
COPY config/system/motd /etc/motd
COPY config/system/squireos-version /etc/squireos-version

# Add splash screens and ASCII art
COPY config/splash/ /usr/share/squireos/splash/

# Create SquireOS directory structure
RUN mkdir -p /root/scrolls /root/drafts /root/.squireos && \
    mkdir -p /usr/share/squireos/{themes,fonts,docs}

# Set permissions
RUN chmod +x /usr/local/bin/*.sh && \
    chmod 644 /etc/os-release /etc/lsb-release /etc/issue /etc/issue.net /etc/motd

# Configure dynamic MOTD
RUN rm -f /etc/update-motd.d/* && \
    ln -s /usr/local/bin/dynamic-motd.sh /etc/update-motd.d/00-squireos

# Install boot sequence (only runs on actual hardware with systemd)
COPY config/system/squireos-boot.service /etc/systemd/system/
RUN if [ -d /etc/systemd/system ]; then \
        systemctl enable squireos-boot.service 2>/dev/null || true; \
    fi

WORKDIR /root

# Set environment
ENV TERM=xterm-256color
ENV EDITOR=vim
ENV SHELL=/bin/bash
ENV SQUIRE_OS_VERSION=1.0.0
ENV SQUIRE_OS_CODENAME=parchment
ENV SQUIRE_MOTTO="By quill and candlelight"

# Create initial stats file
RUN echo "WORDS_TODAY=0" > /root/.squireos/stats && \
    echo "WORDS_TOTAL=0" >> /root/.squireos/stats && \
    echo "STREAK_DAYS=0" >> /root/.squireos/stats

# Set SquireOS as default menu on boot (for actual Nook)
RUN echo '#!/bin/bash' > /etc/profile.d/squireos.sh && \
    echo 'if [ -z "$SSH_CONNECTION" ] && [ "$TERM" != "dumb" ]; then' >> /etc/profile.d/squireos.sh && \
    echo '    exec /usr/local/bin/squire-menu.sh' >> /etc/profile.d/squireos.sh && \
    echo 'fi' >> /etc/profile.d/squireos.sh && \
    chmod +x /etc/profile.d/squireos.sh

# Default command
CMD ["/bin/bash"]