#!/bin/bash
# git-manager.sh - Git version control integration for JesterOS
# Layer 2: Application - Writing tools
set -euo pipefail

# Configuration
GIT_BIN="/data/local/bin/git"
DROPBEAR_BIN="/data/local/bin/dropbear"
SSH_KEY="/data/.ssh/id_rsa"
WRITING_DIR="${WRITING_DIR:-/data/writings}"
REMOTE_NAME="origin"
BRANCH_NAME="main"

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../3-system/common/common.sh" 2>/dev/null || true

# Initialize git repository if needed
init_git_repo() {
    if [ ! -d "${WRITING_DIR}/.git" ]; then
        echo "Initializing git repository..."
        cd "${WRITING_DIR}"
        ${GIT_BIN} init
        ${GIT_BIN} config user.name "Nook Writer"
        ${GIT_BIN} config user.email "writer@nook.local"
        ${GIT_BIN} config core.editor "vim"
        
        # Create initial .gitignore
        cat > "${WRITING_DIR}/.gitignore" << 'EOF'
*.swp
*.swo
*~
.DS_Store
.vim/
.viminfo
EOF
        
        echo "✓ Git repository initialized"
        return 0
    fi
    return 1
}

# Save current writing session
git_save() {
    local message="${1:-Writing session $(date +%Y-%m-%d_%H:%M)}"
    
    cd "${WRITING_DIR}"
    
    # Check if there are changes
    if ${GIT_BIN} diff --quiet && ${GIT_BIN} diff --cached --quiet; then
        echo "No changes to save"
        return 0
    fi
    
    # Add all changes
    ${GIT_BIN} add -A
    
    # Commit with message
    ${GIT_BIN} commit -m "${message}"
    
    # Show what was saved
    echo "✓ Saved: $(${GIT_BIN} log -1 --oneline)"
    
    # Update stats
    update_git_stats
}

# Quick save with auto-generated message
git_quicksave() {
    local files_changed=$(cd "${WRITING_DIR}" && ${GIT_BIN} status --porcelain | wc -l)
    local words_added=$(cd "${WRITING_DIR}" && ${GIT_BIN} diff --word-diff=porcelain | grep '^+' | wc -w)
    
    if [ ${files_changed} -gt 0 ]; then
        local message="Quick save: ${files_changed} files, ~${words_added} words added"
        git_save "${message}"
    else
        echo "No changes to save"
    fi
}

# Show writing history
git_history() {
    local count="${1:-20}"
    
    cd "${WRITING_DIR}"
    
    echo "=== Writing History ==="
    ${GIT_BIN} log --oneline --graph --decorate -${count} \
        --pretty=format:'%C(yellow)%h%C(reset) - %C(green)%ar%C(reset) - %s'
    echo ""
}

# Show what changed in a session
git_diff() {
    local commit="${1:-HEAD}"
    
    cd "${WRITING_DIR}"
    
    # Show summary
    echo "=== Changes in ${commit} ==="
    ${GIT_BIN} show --stat "${commit}"
    
    # Show word count changes
    echo ""
    echo "=== Word Count Changes ==="
    ${GIT_BIN} diff "${commit}^" "${commit}" --word-diff=porcelain | \
        awk '/^[+-][^+-]/ {if($0~/^\+/) a+=NF-1; else d+=NF-1} END {print "Added: "a" words\nDeleted: "d" words"}'
}

# Create a writing milestone/tag
git_milestone() {
    local name="${1}"
    local message="${2:-Milestone: ${name}}"
    
    if [ -z "${name}" ]; then
        echo "Usage: git_milestone <name> [message]"
        return 1
    fi
    
    cd "${WRITING_DIR}"
    
    # Create annotated tag
    ${GIT_BIN} tag -a "${name}" -m "${message}"
    
    echo "✓ Milestone created: ${name}"
    echo "  ${message}"
}

# List milestones
git_milestones() {
    cd "${WRITING_DIR}"
    
    echo "=== Writing Milestones ==="
    ${GIT_BIN} tag -l --format='%(tag) - %(subject)' | column -t -s '-'
}

# Sync with remote repository
git_sync() {
    cd "${WRITING_DIR}"
    
    # Check if remote is configured
    if ! ${GIT_BIN} remote get-url ${REMOTE_NAME} >/dev/null 2>&1; then
        echo "No remote repository configured"
        echo "Run: git_setup_remote <url>"
        return 1
    fi
    
    echo "Syncing with remote repository..."
    
    # Set up SSH for git
    export GIT_SSH_COMMAND="${DROPBEAR_BIN} -i ${SSH_KEY}"
    
    # Pull changes (rebase to keep history clean)
    echo "Pulling remote changes..."
    ${GIT_BIN} pull --rebase ${REMOTE_NAME} ${BRANCH_NAME} || {
        echo "Pull failed. You may have conflicts to resolve."
        return 1
    }
    
    # Push changes
    echo "Pushing local changes..."
    ${GIT_BIN} push ${REMOTE_NAME} ${BRANCH_NAME} || {
        echo "Push failed. Remote may have been updated."
        return 1
    }
    
    echo "✓ Sync complete!"
    
    # Update sync timestamp
    date > "${WRITING_DIR}/.last_sync"
}

# Setup remote repository
git_setup_remote() {
    local url="${1}"
    
    if [ -z "${url}" ]; then
        echo "Usage: git_setup_remote <repository-url>"
        echo "Example: git_setup_remote git@github.com:username/nook-writings.git"
        return 1
    fi
    
    cd "${WRITING_DIR}"
    
    # Remove existing remote if present
    ${GIT_BIN} remote remove ${REMOTE_NAME} 2>/dev/null || true
    
    # Add new remote
    ${GIT_BIN} remote add ${REMOTE_NAME} "${url}"
    
    echo "✓ Remote repository configured: ${url}"
    echo "Run 'git_sync' to synchronize"
}

# Show git statistics
git_stats() {
    cd "${WRITING_DIR}"
    
    echo "=== Git Repository Statistics ==="
    echo "Total commits: $(${GIT_BIN} rev-list --count HEAD)"
    echo "Files tracked: $(${GIT_BIN} ls-files | wc -l)"
    echo "Repository size: $(du -sh .git | cut -f1)"
    
    if [ -f ".last_sync" ]; then
        echo "Last sync: $(cat .last_sync)"
    fi
    
    echo ""
    echo "=== Recent Activity ==="
    ${GIT_BIN} log --since="1 week ago" --oneline | wc -l | xargs echo "Commits this week:"
    ${GIT_BIN} log --since="1 month ago" --oneline | wc -l | xargs echo "Commits this month:"
}

# Update git statistics for JesterOS
update_git_stats() {
    local stats_file="/var/jesteros/git/stats"
    mkdir -p "$(dirname "${stats_file}")"
    
    cd "${WRITING_DIR}"
    
    cat > "${stats_file}" << EOF
Commits: $(${GIT_BIN} rev-list --count HEAD 2>/dev/null || echo 0)
Files: $(${GIT_BIN} ls-files 2>/dev/null | wc -l || echo 0)
Last Save: $(${GIT_BIN} log -1 --format=%ar 2>/dev/null || echo "never")
EOF
}

# Backup to alternate location
git_backup() {
    local backup_dir="${1:-/sdcard/writing-backup}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="writings_${timestamp}.tar.gz"
    
    echo "Creating backup..."
    
    cd "${WRITING_DIR}"
    
    # Create compressed archive
    tar -czf "${backup_dir}/${backup_name}" \
        --exclude=".git/objects" \
        --exclude="*.swp" \
        .
    
    echo "✓ Backup created: ${backup_dir}/${backup_name}"
    echo "  Size: $(du -h ${backup_dir}/${backup_name} | cut -f1)"
}

# Main command dispatcher
case "${1:-help}" in
    init)
        init_git_repo
        ;;
    save)
        shift
        git_save "$@"
        ;;
    quicksave|qs)
        git_quicksave
        ;;
    history|log)
        shift
        git_history "$@"
        ;;
    diff|changes)
        shift
        git_diff "$@"
        ;;
    milestone|tag)
        shift
        git_milestone "$@"
        ;;
    milestones|tags)
        git_milestones
        ;;
    sync)
        git_sync
        ;;
    remote)
        shift
        git_setup_remote "$@"
        ;;
    stats)
        git_stats
        ;;
    backup)
        shift
        git_backup "$@"
        ;;
    help|*)
        cat << 'EOF'
Git Manager for JesterOS Writing Environment

Commands:
  init          Initialize git repository
  save [msg]    Save current writing session
  quicksave     Quick save with auto message
  history [n]   Show last n commits (default: 20)
  diff [commit] Show changes in commit
  milestone     Create a writing milestone
  milestones    List all milestones
  sync          Sync with remote repository
  remote <url>  Setup remote repository
  stats         Show repository statistics
  backup [dir]  Create backup archive
  help          Show this help message

Examples:
  git-manager.sh save "Chapter 3 complete"
  git-manager.sh milestone "v1.0" "First draft complete"
  git-manager.sh sync
EOF
        ;;
esac