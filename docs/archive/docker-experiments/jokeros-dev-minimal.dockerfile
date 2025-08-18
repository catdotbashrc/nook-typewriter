# JokerOS Minimal Development Environment
# Built on authentic Debian Lenny 5.0 with essential development tools
# "By quill and candlelight, we develop with minimal distraction!"

FROM scratch

# Extract authentic Debian Lenny 5.0 (built from archive.debian.org packages)
ADD lenny-rootfs.tar.gz /

# Set period-correct environment variables (2009 era)
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=linux \
    SHELL=/bin/bash \
    EDITOR=vim \
    PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin \
    HOME=/root

# Create essential directories and fix permissions
RUN mkdir -p /proc /sys /dev /tmp /var/tmp && \
    chmod 1777 /tmp /var/tmp

# Configure authentic Lenny package sources
RUN echo "# Debian Lenny 5.0 - Archived (February 2009)" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian/ lenny main" >> /etc/apt/sources.list

# Configure APT for archive repositories
RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99-disable-check-valid-until && \
    echo 'APT::Get::AllowUnauthenticated "true";' >> /etc/apt/apt.conf.d/99-disable-check-valid-until

# Create apt directories and update package database
RUN mkdir -p /var/lib/apt/lists/partial /var/cache/apt/archives/partial && \
    apt-get update

# Install essential development tools only
# Note: In 2009, git version control was called git-core, not git
RUN apt-get install -y --no-install-recommends \
    make \
    git-core \
    vim \
    strace \
    wget \
    e2fsprogs \
    util-linux \
    procps \
    ; apt-get clean ; \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* || true

# Create JokerOS development structure
RUN mkdir -p \
    /workspace \
    /jokeros \
    /jokeros/runtime \
    /jokeros/build \
    /jokeros/tests \
    /var/jokeros \
    /var/lib/jester

# Set up basic Git configuration (if git-core was installed successfully)
RUN git config --global user.name "JokerOS Developer" 2>/dev/null || true && \
    git config --global user.email "dev@jokeros.local" 2>/dev/null || true

# Create simple development bashrc
RUN cat > /root/.bashrc << 'EOF'
# JokerOS Minimal Development Environment
export EDITOR=vim
export JOKEROS_BASE=/jokeros
export WORKSPACE=/workspace

# Basic aliases
alias ll='ls -la'
alias ..='cd ..'
alias jokeros-init='mkdir -p $JOKEROS_BASE/runtime/{1-ui,2-application,3-system,4-hardware} && echo "JokerOS structure created"'

# Medieval greeting
echo ""
echo "🏰 JOKEROS MINIMAL DEVELOPMENT REALM"
echo "   Authentic Debian Lenny 5.0 (2009)"
echo "   \"By quill and candlelight!\""
echo ""
echo "Type 'jokeros-init' to initialize project structure"
echo ""
EOF

# Working directory for development
WORKDIR /workspace

# Metadata
LABEL maintainer="JesterOS Project" \
      description="JokerOS minimal development environment on Debian Lenny 5.0" \
      version="1.0-minimal" \
      base="debian-lenny-5.0" \
      tools="make,git,vim,strace,wget"

# Default command starts bash with configuration
CMD ["/bin/bash", "-l"]