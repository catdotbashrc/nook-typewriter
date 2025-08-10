FROM alpine:3.17 AS builder

# Build environment
RUN apk add --no-cache \
    build-base git cmake \
    linux-headers ncurses-dev

# Build FBInk
RUN git clone --depth=1 https://github.com/NiLuJe/FBInk && \
    cd FBInk && \
    make MINIMAL=1 FONTS=1 STANDALONE=1 && \
    make install MINIMAL=1 FONTS=1 STANDALONE=1

# Build Vim with full features
RUN git clone --depth=1 https://github.com/vim/vim.git && \
    cd vim && \
    ./configure --with-features=normal \
                --enable-multibyte \
                --disable-gui \
                --disable-netbeans && \
    make && make install

# Final image
FROM alpine:3.17

# Install packages
RUN apk add --no-cache \
    vim rsync rclone openssh-client \
    git tmux ncurses bash curl wget \
    e2fsprogs f2fs-tools dosfstools \
    wireless-tools wpa_supplicant

# Copy built binaries
COPY --from=builder /usr/local/bin/fbink /usr/local/bin/
COPY --from=builder /usr/local/bin/vim /usr/local/bin/

# Add configurations
COPY config/vimrc /root/.vimrc
COPY config/vim/ /root/.vim/
COPY config/scripts/ /usr/local/bin/
COPY config/system/fstab /etc/fstab
COPY config/system/sysctl.conf /etc/sysctl.conf

# Install Vim plugins
RUN mkdir -p /root/.vim/pack/plugins/start && \
    cd /root/.vim/pack/plugins/start && \
    git clone --depth=1 https://github.com/reedes/vim-pencil && \
    git clone --depth=1 https://github.com/junegunn/goyo.vim && \
    git clone --depth=1 https://github.com/michal-h21/vim-zettel && \
    git clone --depth=1 https://github.com/itchyny/lightline.vim

# Set permissions
RUN chmod +x /usr/local/bin/*.sh

# Configure boot
RUN rc-update add localmount boot && \
    rc-update del networking boot && \
    rc-update del chronyd default

WORKDIR /root