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

# Set permissions
RUN chmod +x /usr/local/bin/*.sh

# Create directories for notes
RUN mkdir -p /root/notes /root/drafts

WORKDIR /root

# Set environment
ENV TERM=xterm-256color
ENV EDITOR=vim
ENV SHELL=/bin/bash

# Default command
CMD ["/bin/bash"]