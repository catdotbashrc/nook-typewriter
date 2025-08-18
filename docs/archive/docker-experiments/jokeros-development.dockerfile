# JokerOS Development Environment
# Built on authentic Debian Lenny 5.0 with modern development workflow
#
# This image provides a complete development environment for JokerOS/JesterOS,
# combining period-correct 2009 base system with essential development tools.
#
# Build: docker build -f jokeros-development.dockerfile -t jokeros:dev .
# Usage: docker run -it --rm -v $(pwd):/workspace jokeros:dev
#
# GitHub: https://github.com/bogdanscarwash/nook-typewriter
# Project: JesterOS - Distraction-free writing on e-readers

# =============================================================================
# Stage 1: Vanilla Debian Lenny Base
# =============================================================================
FROM scratch AS lenny-base

# Extract authentic Debian Lenny 5.0 (built from archive.debian.org packages)
ADD lenny-rootfs.tar.gz /

# Set period-correct environment variables (2009 era)
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=linux \
    SHELL=/bin/bash \
    EDITOR=vi \
    PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin \
    HOME=/root

# Create essential directories and fix permissions
RUN mkdir -p /proc /sys /dev /tmp /var/tmp && \
    chmod 1777 /tmp /var/tmp

# Set up basic system identity
RUN echo "jokeros-dev" > /etc/hostname 2>/dev/null || true && \
    echo "127.0.0.1 localhost jokeros-dev" > /etc/hosts 2>/dev/null || true

# =============================================================================
# Stage 2: JokerOS Development Environment
# =============================================================================
FROM lenny-base AS jokeros-dev

# Configure authentic Lenny package sources
RUN echo "# Debian Lenny 5.0 - Archived (February 2009)" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian/ lenny main" >> /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security/ lenny/updates main" >> /etc/apt/sources.list

# Configure APT for archive repositories (no Release.gpg validation for old repos)
RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99-disable-check-valid-until && \
    echo 'APT::Get::AllowUnauthenticated "true";' >> /etc/apt/apt.conf.d/99-disable-check-valid-until

# Create apt directories and update package database
RUN mkdir -p /var/lib/apt/lists/partial /var/cache/apt/archives/partial && \
    apt-get update

# Install essential development tools (period-appropriate for 2009)
# Split into multiple RUN commands to handle package availability issues
RUN apt-get install -y --no-install-recommends \
    make \
    git \
    vim \
    strace \
    gdb \
    file \
    wget \
    rsync \
    screen \
    less \
    gcc \
    libc6-dev \
    tar \
    gzip \
    unzip \
    && apt-get clean

# Install packages that might not be available (with fallback)
RUN apt-get install -y --no-install-recommends \
    curl || true && \
    apt-get install -y --no-install-recommends \
    lsof || true && \
    apt-get install -y --no-install-recommends \
    man-db || true && \
    apt-get install -y --no-install-recommends \
    groff-base || true && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Install writer-focused tools for testing (with fallbacks for packages that might not exist)
RUN apt-get update && \
    apt-get install -y --no-install-recommends aspell || true && \
    apt-get install -y --no-install-recommends aspell-en || true && \
    apt-get install -y --no-install-recommends wamerican || true && \
    apt-get install -y --no-install-recommends figlet || true && \
    apt-get install -y --no-install-recommends fortune-mod || true && \
    apt-get install -y --no-install-recommends cowsay || true && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Create JokerOS development structure
RUN mkdir -p \
    /workspace \
    /jokeros \
    /jokeros/runtime \
    /jokeros/build \
    /jokeros/tests \
    /jokeros/docs \
    /var/jokeros \
    /var/lib/jester \
    /root/.vim/syntax

# Set up Git configuration for development
RUN git config --global user.name "JokerOS Developer" && \
    git config --global user.email "dev@jokeros.local" && \
    git config --global init.defaultBranch main && \
    git config --global core.editor vim

# Configure Vim for shell development
RUN cat > /root/.vimrc << 'EOF'
" JokerOS Development Vim Configuration (2009-style)
syntax on
set number
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set hlsearch
set incsearch
set showmatch
set ruler
set laststatus=2

" Shell script highlighting
au BufNewFile,BufRead *.sh set filetype=sh
au BufNewFile,BufRead *.bash set filetype=sh

" JokerOS specific files
au BufNewFile,BufRead jester* set filetype=sh
au BufNewFile,BufRead *jokeros* set filetype=sh

" Medieval commenting style
abbrev medieval " By quill and candlelight! 
EOF

# Create development aliases and functions
RUN cat > /root/.bashrc << 'EOF'
# JokerOS Development Environment (.bashrc)
# "By quill and candlelight, we develop!"

# Environment
export EDITOR=vim
export PAGER=less
export JOKEROS_BASE=/jokeros
export WORKSPACE=/workspace

# Development aliases
alias ll='ls -la'
alias la='ls -la'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias tree='tree -C'
alias jester='cat /var/jokeros/jester 2>/dev/null || echo "Jester not initialized"'

# JokerOS specific aliases
alias build-jokeros='cd $JOKEROS_BASE && make'
alias test-jokeros='cd $JOKEROS_BASE && ./tests/run-tests.sh'
alias deploy-nook='rsync -av $JOKEROS_BASE/runtime/ /media/nook/'
alias jokeros-status='echo "=== JokerOS Development Status ===" && git status 2>/dev/null || echo "Not a git repository"'

# Medieval development greeting
alias medieval='figlet "JokerOS Dev" 2>/dev/null && fortune 2>/dev/null || echo "By quill and candlelight, code awaits!"'

# Development functions
jokeros-init() {
    echo "Initializing JokerOS development environment..."
    cd $JOKEROS_BASE
    if [ ! -d .git ]; then
        git init
        echo "Git repository initialized"
    fi
    mkdir -p runtime/{1-ui,2-application,3-system,4-hardware}
    mkdir -p build/{scripts,docker}
    mkdir -p tests
    mkdir -p docs
    echo "JokerOS structure created in $JOKEROS_BASE"
}

jokeros-help() {
    echo "=== JokerOS Development Commands ==="
    echo ""
    echo "📁 Project Management:"
    echo "  jokeros-init      - Initialize development structure"
    echo "  jokeros-status    - Show git status"
    echo "  build-jokeros     - Build the project"
    echo "  test-jokeros      - Run test suite"
    echo ""
    echo "🚀 Deployment:"
    echo "  deploy-nook       - Deploy to Nook hardware"
    echo ""
    echo "🎭 Medieval Vibes:"
    echo "  medieval          - Show medieval greeting"
    echo "  jester            - Display current jester"
    echo ""
    echo "📝 Development Tools:"
    echo "  vim               - Editor with syntax highlighting"
    echo "  git               - Version control"
    echo "  make              - Build automation"
    echo "  strace            - Debug system calls"
    echo "  htop              - Monitor resources"
    echo ""
}

# Show medieval greeting on login
if [ -t 1 ]; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                    JOKEROS DEVELOPMENT REALM                        ║"
    echo "║                                                                      ║"
    echo "║       🏰 Authentic Debian Lenny 5.0 Development Environment        ║"
    echo "║          \"By quill and candlelight, we shape digital destiny!\"      ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📜 Type 'jokeros-help' for development commands"
    echo "🎭 Type 'medieval' for inspiration"
    echo ""
fi
EOF

# Set up workspace permissions and structure
RUN chown -R root:root /workspace /jokeros && \
    chmod -R 755 /workspace /jokeros

# Working directory for development
WORKDIR /workspace

# Metadata for GitHub publishing
LABEL maintainer="Persephone Raskova" \
      source="https://github.com/bogdanscarwash/nook-typewriter" \
      project="JesterOS - Distraction-free writing on e-readers" \
      description="JokerOS development environment based on authentic Debian Lenny 5.0" \
      version="1.0-dev" \
      base="debian-lenny-5.0.10" \
      build-date="2024-08-17" \
      purpose="JokerOS/JesterOS development and testing" \
      tools="git,vim,make,strace,gdb,htop,screen" \
      arch="armel" \
      authentic="true" \
      development="true" \
      github.package="jokeros-dev" \
      github.source="https://github.com/bogdanscarwash/nook-typewriter"

# Expose common development ports (if needed)
EXPOSE 8080 3000 4000

# Default command starts an interactive development session
CMD ["/bin/bash", "-l"]