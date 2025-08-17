#!/bin/bash
# git-menu.sh - Git version control menu for JesterOS
# Layer 1: UI - Git menu interface
set -euo pipefail

# Source common functions
COMMON_PATH="${COMMON_PATH:-/runtime/3-system/common/common.sh}"
if [[ -f "$COMMON_PATH" ]]; then
    source "$COMMON_PATH"
fi

# Git manager path
GIT_MANAGER="/runtime/2-application/writing/git-manager.sh"
GIT_INSTALLER="/runtime/2-application/writing/git-installer.sh"

# Check if git is installed
check_git_installed() {
    if [ ! -f "/data/local/bin/git" ] && [ ! -f "/data/local/bin/git-wrapper" ]; then
        return 1
    fi
    return 0
}

# Display git menu header
display_git_header() {
    clear
    cat << 'EOF'
    ═══════════════════════════════════════════════════════════════
                     📜 Git Version Control 📜
    ═══════════════════════════════════════════════════════════════
    
         .~"~.         "By quill and git,
        /  ^  \         thy words commit,
       |  ◡  <|         In history vast,
        \ ___ /         thy writing shall last!"
         |♦|♦|
        /|   |\        - The Jester's Git Wisdom
    
    ═══════════════════════════════════════════════════════════════
EOF
}

# Display git installation menu
display_install_menu() {
    display_git_header
    echo ""
    echo "    Git is not installed. Would you like to install it?"
    echo ""
    echo "    [I] Install Git & SSH"
    echo "    [M] Manual Installation Instructions"
    echo "    [B] Back to Main Menu"
    echo ""
    echo -n "    Choose: "
}

# Display main git menu
display_git_menu() {
    display_git_header
    
    # Show current status if available
    if [ -f "/var/jesteros/git/stats" ]; then
        echo ""
        echo "    Current Repository:"
        cat /var/jesteros/git/stats | sed 's/^/    /'
        echo ""
    fi
    
    echo ""
    echo "    === Writing Version Control ==="
    echo ""
    echo "    [S] Save Current Work (Commit)"
    echo "    [Q] Quick Save (Auto-message)"
    echo "    [H] View Writing History"
    echo "    [D] Show Changes (Diff)"
    echo "    [M] Create Milestone/Tag"
    echo "    [L] List Milestones"
    echo ""
    echo "    === Synchronization ==="
    echo ""
    echo "    [Y] Sync with Cloud"
    echo "    [R] Setup Remote Repository"
    echo "    [K] Backup to SD Card"
    echo ""
    echo "    === Information ==="
    echo ""
    echo "    [T] Repository Statistics"
    echo "    [I] Initialize Repository"
    echo "    [?] Help"
    echo "    [B] Back to Main Menu"
    echo ""
    echo -n "    Choose: "
}

# Show installation instructions
show_manual_install() {
    clear
    cat << 'EOF'
    ═══════════════════════════════════════════════════════════════
                   Manual Git Installation Guide
    ═══════════════════════════════════════════════════════════════
    
    On your computer:
    
    1. Download ARM binaries:
       
       # Lightweight git
       wget https://github.com/benhoyt/gitlite/releases/download/v0.1.0/gitlite-arm
       
       # SSH client
       wget https://github.com/mkj/dropbear/releases/download/2022.83/dropbear-2022.83-static-arm
    
    2. Push to Nook via ADB:
       
       adb push gitlite-arm /data/local/bin/git
       adb push dropbear-2022.83-static-arm /data/local/bin/dropbear
       
       adb shell chmod +x /data/local/bin/git
       adb shell chmod +x /data/local/bin/dropbear
       adb shell ln -s /data/local/bin/dropbear /data/local/bin/dbclient
    
    3. Generate SSH keys:
       
       adb shell /data/local/bin/dropbear -t rsa -f /data/.ssh/id_rsa
    
    Press any key to return...
EOF
    read -n 1
}

# Show git help
show_git_help() {
    clear
    cat << 'EOF'
    ═══════════════════════════════════════════════════════════════
                        Git for Writers - Help
    ═══════════════════════════════════════════════════════════════
    
    CONCEPTS:
    
    • Commit = Save a version of your writing
    • History = Timeline of all your saved versions
    • Diff = See what changed between versions
    • Milestone = Mark an important version (chapter done, etc)
    • Sync = Backup to cloud (GitHub, GitLab, etc)
    
    WORKFLOW:
    
    1. Write your document
    2. Save version with 'S' (describe what you wrote)
    3. View history with 'H' to see your progress
    4. Create milestone when you finish a chapter
    5. Sync to cloud for backup
    
    BENEFITS:
    
    • Never lose work - every save is permanent
    • See how your writing evolved over time
    • Try different versions without fear
    • Access your writing from any device
    • Professional backup solution
    
    Press any key to return...
EOF
    read -n 1
}

# Handle save operation
handle_save() {
    echo ""
    echo -n "    Enter commit message (or press Enter for auto): "
    read -r message
    
    if [ -z "$message" ]; then
        $GIT_MANAGER quicksave
    else
        $GIT_MANAGER save "$message"
    fi
    
    echo ""
    echo "    Press any key to continue..."
    read -n 1
}

# Handle milestone creation
handle_milestone() {
    echo ""
    echo -n "    Enter milestone name (e.g., 'chapter-1'): "
    read -r name
    
    if [ -z "$name" ]; then
        echo "    Milestone name required!"
    else
        echo -n "    Enter description: "
        read -r desc
        $GIT_MANAGER milestone "$name" "$desc"
    fi
    
    echo ""
    echo "    Press any key to continue..."
    read -n 1
}

# Handle remote setup
handle_remote_setup() {
    clear
    echo "    ═══════════════════════════════════════════════════════════════"
    echo "                    Setup Remote Repository"
    echo "    ═══════════════════════════════════════════════════════════════"
    echo ""
    echo "    Examples:"
    echo "    • GitHub:  git@github.com:username/nook-writings.git"
    echo "    • GitLab:  git@gitlab.com:username/nook-writings.git"
    echo "    • Private: ssh://yourserver.com/writings.git"
    echo ""
    echo -n "    Enter repository URL: "
    read -r url
    
    if [ -n "$url" ]; then
        $GIT_MANAGER remote "$url"
    fi
    
    echo ""
    echo "    Press any key to continue..."
    read -n 1
}

# Main git menu loop
git_menu_loop() {
    while true; do
        if ! check_git_installed; then
            # Git not installed - show installation menu
            display_install_menu
            read -r choice
            
            case "${choice,,}" in
                i)
                    echo ""
                    echo "    Starting installation..."
                    $GIT_INSTALLER
                    echo "    Press any key to continue..."
                    read -n 1
                    ;;
                m)
                    show_manual_install
                    ;;
                b)
                    return 0
                    ;;
                *)
                    ;;
            esac
        else
            # Git installed - show main menu
            display_git_menu
            read -r choice
            
            case "${choice,,}" in
                s)
                    handle_save
                    ;;
                q)
                    $GIT_MANAGER quicksave
                    echo "    Press any key to continue..."
                    read -n 1
                    ;;
                h)
                    $GIT_MANAGER history
                    echo ""
                    echo "    Press any key to continue..."
                    read -n 1
                    ;;
                d)
                    $GIT_MANAGER diff
                    echo ""
                    echo "    Press any key to continue..."
                    read -n 1
                    ;;
                m)
                    handle_milestone
                    ;;
                l)
                    $GIT_MANAGER milestones
                    echo ""
                    echo "    Press any key to continue..."
                    read -n 1
                    ;;
                y)
                    echo ""
                    echo "    Syncing with remote repository..."
                    $GIT_MANAGER sync
                    echo ""
                    echo "    Press any key to continue..."
                    read -n 1
                    ;;
                r)
                    handle_remote_setup
                    ;;
                k)
                    echo ""
                    echo "    Creating backup to SD card..."
                    $GIT_MANAGER backup /sdcard/writing-backup
                    echo ""
                    echo "    Press any key to continue..."
                    read -n 1
                    ;;
                t)
                    $GIT_MANAGER stats
                    echo ""
                    echo "    Press any key to continue..."
                    read -n 1
                    ;;
                i)
                    echo ""
                    echo "    Initializing git repository..."
                    $GIT_MANAGER init
                    echo ""
                    echo "    Press any key to continue..."
                    read -n 1
                    ;;
                '?')
                    show_git_help
                    ;;
                b)
                    return 0
                    ;;
                *)
                    ;;
            esac
        fi
    done
}

# Main entry point
if [ "${1:-}" = "standalone" ]; then
    # Running standalone
    git_menu_loop
else
    # Called from main menu - just show once
    if ! check_git_installed; then
        display_install_menu
        read -r choice
        case "${choice,,}" in
            i)
                $GIT_INSTALLER
                ;;
            m)
                show_manual_install
                ;;
            *)
                ;;
        esac
    else
        display_git_menu
        read -r choice
        # Process single choice and return
        case "${choice,,}" in
            s) handle_save ;;
            q) $GIT_MANAGER quicksave ;;
            # ... handle other options ...
            *) ;;
        esac
    fi
fi