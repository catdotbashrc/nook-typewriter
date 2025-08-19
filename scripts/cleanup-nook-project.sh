#!/bin/bash
# Nook Project Cleanup Script
# Removes duplicates, consolidates files, and cleans up the project structure

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
REMOVED_FILES=0
REMOVED_SIZE=0

echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}     Nook Project Cleanup - Safe Mode                  ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"

# Function to calculate size
get_size() {
    if [ -e "$1" ]; then
        du -sb "$1" 2>/dev/null | cut -f1 || echo 0
    else
        echo 0
    fi
}

# Function to safely remove files/directories
safe_remove() {
    local target="$1"
    local description="$2"
    
    if [ -e "$target" ]; then
        local size=$(get_size "$target")
        echo -e "${YELLOW}Removing:${NC} $description"
        echo "  Path: $target"
        echo "  Size: $(numfmt --to=iec-i --suffix=B $size)"
        
        if [ "$DRY_RUN" = true ]; then
            echo -e "  ${YELLOW}[DRY RUN] Would remove${NC}"
        else
            if rm -rf "$target" 2>/dev/null; then
                echo -e "  ${GREEN}✓ Removed${NC}"
                REMOVED_FILES=$((REMOVED_FILES + 1))
                REMOVED_SIZE=$((REMOVED_SIZE + size))
            else
                echo -e "  ${RED}✗ Permission denied (may need sudo)${NC}"
            fi
        fi
        echo
    fi
}

# Parse arguments
DRY_RUN=false
AGGRESSIVE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}\n"
            shift
            ;;
        --aggressive)
            AGGRESSIVE=true
            echo -e "${RED}AGGRESSIVE MODE - More thorough cleanup${NC}\n"
            shift
            ;;
        *)
            echo "Usage: $0 [--dry-run] [--aggressive]"
            exit 1
            ;;
    esac
done

# 1. Remove old kernel directory (379MB!)
echo -e "${GREEN}Step 1: Removing duplicate kernel directories${NC}"
echo "==============================================="
safe_remove "source/kernel-old" "Old kernel directory (duplicate, 379MB)"

# 2. Clean up backup and temporary files
echo -e "${GREEN}Step 2: Cleaning backup and temporary files${NC}"
echo "=============================================="
safe_remove "./lenny-rootfs/var/backups/infodir.bak" "Info directory backup"
safe_remove "./lenny-rootfs/etc/apt/trusted.gpg~" "APT trusted keys backup"
safe_remove "./source/kernel/src/.config.old" "Old kernel config"

# Find and remove all backup files
find . -type f \( -name "*.bak" -o -name "*.old" -o -name "*.orig" -o -name "*~" -o -name "*.swp" \) 2>/dev/null | while read -r file; do
    safe_remove "$file" "Backup/temp file"
done

# 3. Clean up build artifacts
echo -e "${GREEN}Step 3: Cleaning build artifacts${NC}"
echo "=================================="

# Clean kernel build artifacts
if [ -d "source/kernel/src" ]; then
    echo "Cleaning kernel build artifacts..."
    find source/kernel/src -type f \( \
        -name "*.o" -o \
        -name "*.ko" -o \
        -name "*.mod.c" -o \
        -name "*.mod" -o \
        -name "*.cmd" -o \
        -name ".*.cmd" -o \
        -name "*.order" -o \
        -name "*.symvers" -o \
        -name "*.markers" \
    \) 2>/dev/null | while read -r file; do
        safe_remove "$file" "Kernel build artifact"
    done
fi

# 4. Remove empty directories
echo -e "${GREEN}Step 4: Removing empty directories${NC}"
echo "===================================="
find . -type d -empty 2>/dev/null | while read -r dir; do
    # Skip .git directories
    if [[ "$dir" != *".git"* ]]; then
        safe_remove "$dir" "Empty directory"
    fi
done

# 5. Consolidate duplicate test scripts
echo -e "${GREEN}Step 5: Consolidating duplicate scripts${NC}"
echo "========================================="

# Remove test scripts from kernel directories (keep only in tests/)
safe_remove "source/kernel-old/test/test_modules.sh" "Duplicate test script"
safe_remove "source/kernel/test/test_modules.sh" "Duplicate test script (use tests/ version)"

# 6. Clean up lenny-rootfs if aggressive mode
if [ "$AGGRESSIVE" = true ]; then
    echo -e "${GREEN}Step 6: Aggressive cleanup - old rootfs${NC}"
    echo "=========================================="
    safe_remove "lenny-rootfs" "Old Lenny rootfs (can be regenerated)"
    safe_remove "lenny-rootfs.tar.gz" "Lenny rootfs archive"
fi

# 7. Clean up old Docker images and caches
echo -e "${GREEN}Step 7: Cleaning Docker artifacts${NC}"
echo "==================================="
safe_remove "docker-cache" "Docker build cache"

# 8. Clean up test reports and logs (keep structure)
echo -e "${GREEN}Step 8: Cleaning test artifacts${NC}"
echo "================================="
find tests -type f \( -name "*.log" -o -name "test_report_*.md" -o -name "test_log_*.txt" \) 2>/dev/null | while read -r file; do
    # Keep the most recent report/log
    if [[ ! "$file" =~ (20250814_211827|20250813_164550) ]]; then
        safe_remove "$file" "Old test artifact"
    fi
done

# 9. Remove redundant documentation
echo -e "${GREEN}Step 9: Consolidating documentation${NC}"
echo "====================================="

# List of docs that might be redundant (manual review recommended)
REDUNDANT_DOCS=(
    "PROJECT_INDEX.md"           # Duplicate of PROJECT_INDEX_COMPLETE.md
    "BOOT_DOCUMENTATION_INDEX.md" # Covered in BOOT_GUIDE_CONSOLIDATED.md
    "COMPLETE_BOOT_GUIDE.md"     # Duplicate of BOOT_GUIDE_CONSOLIDATED.md
)

if [ "$AGGRESSIVE" = true ]; then
    for doc in "${REDUNDANT_DOCS[@]}"; do
        if [ -f "$doc" ]; then
            echo -e "${YELLOW}Consider removing redundant doc: $doc${NC}"
            # safe_remove "$doc" "Redundant documentation"
        fi
    done
fi

# 10. Clean up .zk directories (Zettelkasten notes)
echo -e "${GREEN}Step 10: Cleaning personal notes${NC}"
echo "=================================="
find . -type d -name ".zk" 2>/dev/null | while read -r dir; do
    safe_remove "$dir" "Zettelkasten notes directory"
done

# Summary
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}                    Cleanup Summary                     ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN COMPLETE - No changes were made${NC}"
    echo "Run without --dry-run to apply changes"
else
    echo -e "Files/directories removed: ${GREEN}$REMOVED_FILES${NC}"
    echo -e "Space reclaimed: ${GREEN}$(numfmt --to=iec-i --suffix=B $REMOVED_SIZE)${NC}"
    
    # Git status
    if command -v git &> /dev/null && [ -d .git ]; then
        echo
        echo "Git status:"
        git status --short | head -10
        
        echo
        echo -e "${YELLOW}Remember to review changes and commit:${NC}"
        echo "  git add -A"
        echo "  git commit -m 'chore: project cleanup - remove duplicates and old files'"
    fi
fi

# Recommendations
echo
echo -e "${GREEN}Additional Recommendations:${NC}"
echo "1. Run 'git gc --aggressive' to optimize git repository"
echo "2. Consider using Git LFS for large binary files"
echo "3. Review and consolidate duplicate documentation"
echo "4. Set up .gitignore to prevent future accumulation"

if [ "$AGGRESSIVE" = false ]; then
    echo
    echo -e "${YELLOW}Run with --aggressive flag for more thorough cleanup${NC}"
fi

echo
echo -e "${GREEN}Cleanup complete! 🧹${NC}"