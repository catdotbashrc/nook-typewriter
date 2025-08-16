#!/bin/bash
# Setup secure non-root writer user for JesterOS
# This script creates a dedicated user for writing operations

set -euo pipefail
trap 'echo "Error at line $LINENO: $BASH_COMMAND"' ERR

# Configuration
WRITER_USER="scribe"
WRITER_GROUP="scribes"
WRITER_HOME="/home/scribe"
WRITER_UID=1000
WRITER_GID=1000

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Create writer group
create_writer_group() {
    if getent group "$WRITER_GROUP" >/dev/null 2>&1; then
        log_warn "Group '$WRITER_GROUP' already exists"
    else
        log_info "Creating group '$WRITER_GROUP' with GID $WRITER_GID"
        groupadd -g "$WRITER_GID" "$WRITER_GROUP"
    fi
}

# Create writer user
create_writer_user() {
    if id "$WRITER_USER" >/dev/null 2>&1; then
        log_warn "User '$WRITER_USER' already exists"
    else
        log_info "Creating user '$WRITER_USER' with UID $WRITER_UID"
        useradd -m \
            -u "$WRITER_UID" \
            -g "$WRITER_GROUP" \
            -s /bin/bash \
            -c "JesterOS Writer" \
            -d "$WRITER_HOME" \
            "$WRITER_USER"
    fi
}

# Setup writing directories
setup_writing_directories() {
    log_info "Setting up writing directories..."
    
    # Create writing directories
    local dirs=(
        "$WRITER_HOME/notes"
        "$WRITER_HOME/drafts"
        "$WRITER_HOME/scrolls"
        "$WRITER_HOME/.vim"
        "$WRITER_HOME/.vim/backup"
        "$WRITER_HOME/.vim/undo"
        "$WRITER_HOME/.config"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            install -d -m 0750 -o "$WRITER_USER" -g "$WRITER_GROUP" "$dir"
            log_info "Created directory: $dir"
        fi
    done
}

# Setup vim configuration
setup_vim_config() {
    log_info "Setting up vim configuration..."
    
    cat > "$WRITER_HOME/.vimrc" << 'EOF'
" JesterOS Writer Vim Configuration
" Optimized for distraction-free writing

" Basic settings
set nocompatible
set encoding=utf-8
set fileencoding=utf-8

" Writing-focused settings
set wrap
set linebreak
set spell spelllang=en_us
set textwidth=72
set formatoptions=tcqn

" Minimal UI
set nonumber
set norelativenumber
set laststatus=1
set noshowmode
set noshowcmd
set noruler

" Save and backup settings
set backup
set backupdir=~/.vim/backup//
set undofile
set undodir=~/.vim/undo//
set swapfile
set directory=~/.vim/swap//

" Auto-save
autocmd TextChanged,TextChangedI * silent! write

" Medieval theme
colorscheme desert
highlight SpellBad term=underline cterm=underline
highlight SpellCap term=underline cterm=underline

" Writing statistics function
function! WordCount()
    let s:old_status = v:statusmsg
    let position = getpos(".")
    exe ":silent normal g\<c-g>"
    let stat = v:statusmsg
    let s:word_count = 0
    if stat != '--No lines in buffer--'
        let s:word_count = str2nr(split(v:statusmsg)[11])
        let v:statusmsg = s:old_status
    endif
    call setpos('.', position)
    return s:word_count
endfunction

" Show word count in status line
set statusline=Words:\ %{WordCount()}

" Map F5 to show statistics
nnoremap <F5> :echo 'Words: ' . WordCount()<CR>
EOF
    
    # Set ownership
    chown "$WRITER_USER:$WRITER_GROUP" "$WRITER_HOME/.vimrc"
    chmod 0640 "$WRITER_HOME/.vimrc"
}

# Setup JesterOS access
setup_jesteros_access() {
    log_info "Setting up JesterOS service access..."
    
    # Create sudoers entry for specific commands
    cat > /etc/sudoers.d/jesteros-writer << EOF
# JesterOS Writer User Permissions
# Allow writer to interact with JesterOS services

# View statistics and jester
$WRITER_USER ALL=(root) NOPASSWD: /bin/cat /var/jesteros/jester
$WRITER_USER ALL=(root) NOPASSWD: /bin/cat /var/jesteros/typewriter/stats
$WRITER_USER ALL=(root) NOPASSWD: /bin/cat /var/jesteros/wisdom
$WRITER_USER ALL=(root) NOPASSWD: /bin/cat /var/jesteros/health/status

# Control writing-related services
$WRITER_USER ALL=(root) NOPASSWD: /usr/local/bin/jesteros-service-manager.sh status
$WRITER_USER ALL=(root) NOPASSWD: /usr/local/bin/jesteros-service-manager.sh restart tracker

# Launch menu
$WRITER_USER ALL=(root) NOPASSWD: /usr/local/bin/nook-menu.sh
EOF
    
    # Secure sudoers file
    chmod 0440 /etc/sudoers.d/jesteros-writer
}

# Create safe wrapper scripts
create_wrapper_scripts() {
    log_info "Creating safe wrapper scripts..."
    
    # Create wrapper for menu launch
    cat > "$WRITER_HOME/bin/writing-menu" << 'EOF'
#!/bin/bash
# Safe wrapper for writing menu
set -euo pipefail

# Launch menu with proper environment
export HOME=/home/scribe
export USER=scribe
exec sudo /usr/local/bin/nook-menu.sh "$@"
EOF
    
    # Create statistics viewer
    cat > "$WRITER_HOME/bin/writing-stats" << 'EOF'
#!/bin/bash
# Display writing statistics
set -euo pipefail

echo "═══════════════════════════════════════"
echo "        Writing Statistics"
echo "═══════════════════════════════════════"
echo ""

if [[ -f /var/jesteros/typewriter/stats ]]; then
    sudo cat /var/jesteros/typewriter/stats
else
    echo "Statistics not available"
fi

echo ""
echo "═══════════════════════════════════════"
EOF
    
    # Create jester viewer
    cat > "$WRITER_HOME/bin/view-jester" << 'EOF'
#!/bin/bash
# Display the court jester
set -euo pipefail

if [[ -f /var/jesteros/jester ]]; then
    sudo cat /var/jesteros/jester
else
    echo "The jester is away..."
fi
EOF
    
    # Set permissions for wrapper scripts
    install -d -m 0750 -o "$WRITER_USER" -g "$WRITER_GROUP" "$WRITER_HOME/bin"
    
    for script in writing-menu writing-stats view-jester; do
        install -m 0750 -o "$WRITER_USER" -g "$WRITER_GROUP" \
            "$WRITER_HOME/bin/$script" "$WRITER_HOME/bin/$script"
    done
}

# Update PATH for writer user
update_user_path() {
    log_info "Updating user PATH..."
    
    cat >> "$WRITER_HOME/.bashrc" << 'EOF'

# JesterOS Writer Environment
export PATH="$HOME/bin:$PATH"
export EDITOR=vim

# Aliases for writing
alias stats='writing-stats'
alias jester='view-jester'
alias write='vim'
alias menu='writing-menu'

# Writing prompt
PS1='[Scribe \W]$ '

# Welcome message
echo "════════════════════════════════════════"
echo "    Welcome, Noble Scribe!"
echo "    Thy writing chamber awaits..."
echo "════════════════════════════════════════"
echo ""
echo "Commands:"
echo "  write   - Start writing"
echo "  menu    - Open writing menu"
echo "  stats   - View statistics"
echo "  jester  - Visit the jester"
echo ""
EOF
    
    chown "$WRITER_USER:$WRITER_GROUP" "$WRITER_HOME/.bashrc"
}

# Main execution
main() {
    echo "════════════════════════════════════════"
    echo "    JesterOS Writer User Setup"
    echo "════════════════════════════════════════"
    echo ""
    
    check_root
    create_writer_group
    create_writer_user
    setup_writing_directories
    setup_vim_config
    setup_jesteros_access
    create_wrapper_scripts
    update_user_path
    
    echo ""
    echo "════════════════════════════════════════"
    log_info "Writer user setup complete!"
    echo ""
    echo "To switch to writer user:"
    echo "  su - $WRITER_USER"
    echo ""
    echo "Default directories:"
    echo "  Notes:  $WRITER_HOME/notes/"
    echo "  Drafts: $WRITER_HOME/drafts/"
    echo "  Final:  $WRITER_HOME/scrolls/"
    echo "════════════════════════════════════════"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi