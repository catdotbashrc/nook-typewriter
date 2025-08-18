#!/bin/bash
# git-installer.sh - Install git and SSH binaries for JesterOS
# Layer 2: Application - Writing tools installer
set -euo pipefail

# Configuration
INSTALL_DIR="/data/local/bin"
DATA_DIR="/data/local"
SSH_DIR="/data/.ssh"
TEMP_DIR="/data/local/tmp"

# Binary URLs (ARM static builds)
GIT_URL="https://github.com/termux/termux-packages/releases/download/git-v2.39.0/git_2.39.0_arm.deb"
DROPBEAR_URL="https://github.com/mkj/dropbear/releases/download/2022.83/dropbear-2022.83-static-arm"

# Alternative lightweight git implementations
GITLITE_URL="https://github.com/benhoyt/gitlite/releases/download/v0.1.0/gitlite-arm"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Nook via ADB
check_environment() {
    log_info "Checking environment..."
    
    # Check architecture
    local arch=$(uname -m)
    if [[ ! "$arch" =~ arm ]]; then
        log_warn "Architecture is $arch, expecting ARM. Continuing anyway..."
    fi
    
    # Check available space
    local available=$(df /data | tail -1 | awk '{print $4}')
    if [ "$available" -lt 50000 ]; then
        log_error "Insufficient space in /data (need 50MB, have ${available}KB)"
        return 1
    fi
    
    # Check network connectivity
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log_warn "No network connectivity. Manual download required."
        return 2
    fi
    
    log_info "Environment check passed"
    return 0
}

# Create necessary directories
setup_directories() {
    log_info "Setting up directories..."
    
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$SSH_DIR"
    mkdir -p "$TEMP_DIR"
    mkdir -p "$DATA_DIR/lib"
    mkdir -p "/data/writings"
    
    # Set permissions
    chmod 755 "$INSTALL_DIR"
    chmod 700 "$SSH_DIR"
    
    log_info "Directories created"
}

# Install git binary
install_git() {
    log_info "Installing git..."
    
    local git_binary="$INSTALL_DIR/git"
    
    # Check if already installed
    if [ -f "$git_binary" ]; then
        log_info "Git already installed at $git_binary"
        $git_binary --version
        return 0
    fi
    
    # Try lightweight git first (smaller, fewer features)
    if command -v wget >/dev/null 2>&1; then
        log_info "Downloading lightweight git..."
        wget -q -O "$TEMP_DIR/gitlite" "$GITLITE_URL" || {
            log_warn "Failed to download gitlite, trying full git..."
            install_full_git
            return $?
        }
        
        mv "$TEMP_DIR/gitlite" "$git_binary"
        chmod +x "$git_binary"
        
        log_info "Lightweight git installed"
    else
        log_warn "wget not available, manual installation required"
        provide_manual_instructions "git"
        return 1
    fi
}

# Install full git from deb package
install_full_git() {
    log_info "Installing full git from deb package..."
    
    # Download git deb package
    if command -v wget >/dev/null 2>&1; then
        wget -O "$TEMP_DIR/git.deb" "$GIT_URL" || {
            log_error "Failed to download git"
            return 1
        }
    else
        log_error "wget not available"
        return 1
    fi
    
    # Extract deb package (using busybox if available)
    cd "$TEMP_DIR"
    
    if command -v ar >/dev/null 2>&1; then
        ar x git.deb
        tar -xf data.tar.xz
    elif command -v busybox >/dev/null 2>&1; then
        busybox ar x git.deb
        busybox tar -xf data.tar.xz
    else
        log_error "Cannot extract deb package (no ar or busybox)"
        return 1
    fi
    
    # Copy git binary and libraries
    cp -r data/data/com.termux/files/usr/bin/git* "$INSTALL_DIR/"
    cp -r data/data/com.termux/files/usr/lib/* "$DATA_DIR/lib/" 2>/dev/null || true
    
    # Make executable
    chmod +x "$INSTALL_DIR"/git*
    
    # Clean up
    rm -rf "$TEMP_DIR"/*
    
    log_info "Full git installed"
}

# Install dropbear SSH client
install_ssh() {
    log_info "Installing Dropbear SSH client..."
    
    local dropbear_binary="$INSTALL_DIR/dropbear"
    local dbclient_binary="$INSTALL_DIR/dbclient"
    local dropbearkey_binary="$INSTALL_DIR/dropbearkey"
    
    # Check if already installed
    if [ -f "$dbclient_binary" ]; then
        log_info "Dropbear already installed at $dbclient_binary"
        return 0
    fi
    
    # Download dropbear
    if command -v wget >/dev/null 2>&1; then
        log_info "Downloading Dropbear..."
        wget -q -O "$dropbear_binary" "$DROPBEAR_URL" || {
            log_error "Failed to download Dropbear"
            provide_manual_instructions "dropbear"
            return 1
        }
        
        chmod +x "$dropbear_binary"
        
        # Create symlinks for different functions
        ln -sf "$dropbear_binary" "$dbclient_binary"
        ln -sf "$dropbear_binary" "$dropbearkey_binary"
        
        log_info "Dropbear SSH installed"
    else
        log_warn "wget not available, manual installation required"
        provide_manual_instructions "dropbear"
        return 1
    fi
}

# Generate SSH keys
generate_ssh_keys() {
    log_info "Generating SSH keys..."
    
    local key_file="$SSH_DIR/id_rsa"
    
    # Check if key already exists
    if [ -f "$key_file" ]; then
        log_info "SSH key already exists at $key_file"
        return 0
    fi
    
    # Generate key using dropbearkey
    if [ -f "$INSTALL_DIR/dropbearkey" ]; then
        "$INSTALL_DIR/dropbearkey" -t rsa -f "$key_file" || {
            log_error "Failed to generate SSH key"
            return 1
        }
        
        # Convert to OpenSSH format for GitHub/GitLab
        "$INSTALL_DIR/dropbearkey" -y -f "$key_file" | grep "^ssh-rsa" > "${key_file}.pub"
        
        # Set permissions
        chmod 600 "$key_file"
        chmod 644 "${key_file}.pub"
        
        log_info "SSH keys generated"
        echo ""
        echo "Your public key for GitHub/GitLab:"
        echo "=================================="
        cat "${key_file}.pub"
        echo "=================================="
        echo ""
    else
        log_warn "dropbearkey not found, skipping key generation"
    fi
}

# Create wrapper scripts
create_wrapper_scripts() {
    log_info "Creating wrapper scripts..."
    
    # Git wrapper with environment setup
    cat > "$INSTALL_DIR/git-wrapper" << 'EOF'
#!/bin/sh
export PATH=/data/local/bin:$PATH
export LD_LIBRARY_PATH=/data/local/lib:$LD_LIBRARY_PATH
export GIT_SSH_COMMAND="/data/local/bin/dbclient -i /data/.ssh/id_rsa"
export HOME=/data
exec /data/local/bin/git "$@"
EOF
    chmod +x "$INSTALL_DIR/git-wrapper"
    
    # SSH wrapper
    cat > "$INSTALL_DIR/ssh-wrapper" << 'EOF'
#!/bin/sh
exec /data/local/bin/dbclient -i /data/.ssh/id_rsa "$@"
EOF
    chmod +x "$INSTALL_DIR/ssh-wrapper"
    
    log_info "Wrapper scripts created"
}

# Setup environment
setup_environment() {
    log_info "Setting up environment..."
    
    # Create profile script
    cat > "$DATA_DIR/.profile" << 'EOF'
# JesterOS Git Environment
export PATH=/data/local/bin:$PATH
export LD_LIBRARY_PATH=/data/local/lib:$LD_LIBRARY_PATH
export GIT_SSH_COMMAND="/data/local/bin/dbclient -i /data/.ssh/id_rsa"
export GIT_AUTHOR_NAME="Nook Writer"
export GIT_AUTHOR_EMAIL="writer@nook.local"
export GIT_COMMITTER_NAME="Nook Writer"
export GIT_COMMITTER_EMAIL="writer@nook.local"
export HOME=/data

# Aliases for convenience
alias git='/data/local/bin/git-wrapper'
alias ssh='/data/local/bin/ssh-wrapper'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
EOF
    
    # Source in bashrc if exists
    if [ -f "$DATA_DIR/.bashrc" ]; then
        grep -q ".profile" "$DATA_DIR/.bashrc" || \
            echo "[ -f $DATA_DIR/.profile ] && . $DATA_DIR/.profile" >> "$DATA_DIR/.bashrc"
    fi
    
    log_info "Environment configured"
}

# Provide manual installation instructions
provide_manual_instructions() {
    local component="$1"
    
    echo ""
    echo "=== Manual Installation Instructions for $component ==="
    echo ""
    echo "1. On your computer, download the ARM binary:"
    
    case "$component" in
        git)
            echo "   wget $GITLITE_URL -O gitlite-arm"
            echo "   # OR"
            echo "   wget $GIT_URL -O git.deb"
            echo ""
            echo "2. Push to Nook via ADB:"
            echo "   adb push gitlite-arm /data/local/bin/git"
            echo "   adb shell chmod +x /data/local/bin/git"
            ;;
        dropbear)
            echo "   wget $DROPBEAR_URL -O dropbear"
            echo ""
            echo "2. Push to Nook via ADB:"
            echo "   adb push dropbear /data/local/bin/"
            echo "   adb shell chmod +x /data/local/bin/dropbear"
            echo "   adb shell ln -s /data/local/bin/dropbear /data/local/bin/dbclient"
            echo "   adb shell ln -s /data/local/bin/dropbear /data/local/bin/dropbearkey"
            ;;
    esac
    
    echo ""
    echo "3. Run this script again to continue setup"
    echo ""
}

# Test installation
test_installation() {
    log_info "Testing installation..."
    
    local all_good=true
    
    # Test git
    if [ -f "$INSTALL_DIR/git" ] || [ -f "$INSTALL_DIR/git-wrapper" ]; then
        log_info "Git: ✓"
        $INSTALL_DIR/git --version 2>/dev/null || $INSTALL_DIR/git-wrapper --version 2>/dev/null || log_warn "Git version check failed"
    else
        log_warn "Git: ✗"
        all_good=false
    fi
    
    # Test SSH
    if [ -f "$INSTALL_DIR/dbclient" ]; then
        log_info "SSH: ✓"
    else
        log_warn "SSH: ✗"
        all_good=false
    fi
    
    # Test SSH keys
    if [ -f "$SSH_DIR/id_rsa" ]; then
        log_info "SSH Keys: ✓"
    else
        log_warn "SSH Keys: ✗"
        all_good=false
    fi
    
    # Test environment
    if [ -f "$DATA_DIR/.profile" ]; then
        log_info "Environment: ✓"
    else
        log_warn "Environment: ✗"
        all_good=false
    fi
    
    if $all_good; then
        log_info "All components installed successfully!"
        echo ""
        echo "=== Next Steps ==="
        echo "1. Add your SSH public key to GitHub/GitLab:"
        [ -f "$SSH_DIR/id_rsa.pub" ] && cat "$SSH_DIR/id_rsa.pub"
        echo ""
        echo "2. Initialize your writing repository:"
        echo "   cd /data/writings"
        echo "   /data/local/bin/git-wrapper init"
        echo "   /data/local/bin/git-wrapper remote add origin <your-repo-url>"
        echo ""
        echo "3. Start using git for version control!"
        echo ""
    else
        log_warn "Some components are missing. Run installer again or install manually."
    fi
}

# Main installation flow
main() {
    echo "===================================="
    echo "   JesterOS Git Installer v1.0     "
    echo "===================================="
    echo ""
    
    # Check environment
    check_environment
    local env_status=$?
    
    if [ $env_status -eq 1 ]; then
        log_error "Environment check failed"
        exit 1
    fi
    
    # Setup directories
    setup_directories
    
    # Install components
    if [ $env_status -eq 0 ]; then
        # Network available, try automatic installation
        install_git
        install_ssh
    else
        # No network, provide manual instructions
        log_warn "No network detected. Manual installation required."
        provide_manual_instructions "git"
        provide_manual_instructions "dropbear"
        exit 0
    fi
    
    # Generate SSH keys
    generate_ssh_keys
    
    # Create wrapper scripts
    create_wrapper_scripts
    
    # Setup environment
    setup_environment
    
    # Test installation
    test_installation
    
    log_info "Installation complete!"
}

# Run main function
main "$@"