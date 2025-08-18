#!/bin/bash
# cleanup-project.sh - JesterOS Project Cleanup Script
# Purpose: Organize project structure while preserving production files
# Usage: bash cleanup-project.sh [--dry-run|--force]
# Author: JesterOS Team
# Date: 2025-01-18

set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

# Configuration
ARG=${1:-}
DRY_RUN=""
FORCE=""
EXEC_CMD=""

# Parse arguments
if [[ "$ARG" == "--dry-run" ]]; then
    DRY_RUN="true"
elif [[ "$ARG" == "--force" ]]; then
    FORCE="true"
fi
CLEANUP_LOG="cleanup-$(date +%Y%m%d-%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log() {
    echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $1" | tee -a "$CLEANUP_LOG"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$CLEANUP_LOG"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$CLEANUP_LOG"
    exit 1
}

# Check if in correct directory
if [[ ! -f "CLAUDE.md" || ! -d "runtime" ]]; then
    error "Not in JesterOS root directory. Please run from project root."
fi

if [[ "$DRY_RUN" == "true" ]]; then
    log "🔍 DRY RUN MODE - No changes will be made"
    EXEC_CMD="echo [DRY-RUN]"
elif [[ "$FORCE" == "true" ]]; then
    log "🚀 FORCE MODE - Changes will be made without confirmation"
else
    log "🚀 LIVE MODE - Changes will be made"
    # Check if we're in an interactive terminal
    if [[ -t 0 ]]; then
        read -p "Are you sure you want to proceed? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "Cleanup cancelled by user"
            exit 0
        fi
    else
        warn "Non-interactive mode detected, skipping confirmation"
        warn "Use --dry-run first if unsure about changes"
    fi
fi

log "🧹 JesterOS Cleanup Script Starting..."
log "📝 Logging to: $CLEANUP_LOG"

# Track what we're doing
MOVED_FILES=0
ARCHIVED_DIRS=0
CLEANED_DIRS=0

# 1. Create archive structure
log "📁 Creating archive directories..."
$EXEC_CMD mkdir -p .archives/{backups,docker,docs,rootfs,tests,scripts}

# 2. Move backup tar.gz files (keeping production ones)
log "📦 Archiving backup files..."
for file in docker-backup-*.tar.gz docs-backup-*.tar.gz lenny-rootfs.tar.gz nook-mvp-rootfs.tar.gz; do
    if [[ -f "$file" ]]; then
        log "  Moving $file to .archives/rootfs/"
        $EXEC_CMD mv -v "$file" .archives/rootfs/ 2>/dev/null && ((MOVED_FILES++)) || true
    fi
done

log "✅ Keeping production rootfs files in place:"
for file in jesteros-lenny-rootfs-*.tar.gz jesteros-rootfs-with-gk61-*.tar.gz nook-mvp-rootfs-updated.tar.gz; do
    if [[ -f "$file" ]]; then
        log "  ✓ $file ($(du -h "$file" | cut -f1))"
    fi
done

# 3. Consolidate Docker files
log "🐳 Organizing Docker files..."
if [[ -d "build/docker" ]]; then
    $EXEC_CMD mkdir -p build/docker/archive/{test,experiments,tests,optimized,base}
    
    # Move test dockerfiles
    if [[ -d "build/docker/test" ]]; then
        for file in build/docker/test/*.dockerfile; do
            if [[ -f "$file" ]]; then
                log "  Archiving $(basename "$file")"
                $EXEC_CMD mv -v "$file" build/docker/archive/test/ && ((ARCHIVED_DIRS++)) || true
            fi
        done
    fi
    
    # Move optimized dockerfiles
    for file in build/docker/*-optimized.dockerfile; do
        if [[ -f "$file" ]]; then
            log "  Archiving $(basename "$file")"
            $EXEC_CMD mv -v "$file" build/docker/archive/optimized/ && ((ARCHIVED_DIRS++)) || true
        fi
    done
    
    # Move vanilla dockerfiles
    for file in build/docker/vanilla-*.dockerfile; do
        if [[ -f "$file" ]]; then
            log "  Archiving $(basename "$file")"
            $EXEC_CMD mv -v "$file" build/docker/archive/base/ && ((ARCHIVED_DIRS++)) || true
        fi
    done
fi

# Move docker experiments
if [[ -d "docs/archive/docker-experiments" ]]; then
    log "  Moving docker experiments to archive..."
    $EXEC_CMD mv -v docs/archive/docker-experiments/* build/docker/archive/experiments/ 2>/dev/null || true
fi

# Move test archive dockerfiles
if [[ -d "tests/archive" ]]; then
    for file in tests/archive/*.dockerfile; do
        if [[ -f "$file" ]]; then
            log "  Archiving test dockerfile: $(basename "$file")"
            $EXEC_CMD mv -v "$file" build/docker/archive/tests/ && ((ARCHIVED_DIRS++)) || true
        fi
    done
fi

# 4. Consolidate test directories
log "🧪 Consolidating test directories..."
$EXEC_CMD mkdir -p tests/{docker,tools,scripts,integration,utilities}

# Move test directories carefully
if [[ -d "tools/test" && -d "tools/test" ]]; then
    log "  Moving tools/test contents..."
    $EXEC_CMD cp -r tools/test/* tests/tools/ 2>/dev/null || true
    $EXEC_CMD rm -rf tools/test
fi

if [[ -d "development/test" ]]; then
    log "  Moving development/test contents..."
    $EXEC_CMD cp -r development/test/* tests/integration/ 2>/dev/null || true
    $EXEC_CMD rm -rf development/test
fi

if [[ -d "utilities/test" ]]; then
    log "  Moving utilities/test contents..."
    $EXEC_CMD cp -r utilities/test/* tests/utilities/ 2>/dev/null || true
    $EXEC_CMD rm -rf utilities/test
fi

# 5. Move existing backups
log "💾 Moving existing backups..."
if [[ -d "backups" ]]; then
    for dir in backups/*; do
        if [[ -d "$dir" ]]; then
            log "  Moving $(basename "$dir")"
            $EXEC_CMD mv -v "$dir" .archives/backups/ 2>/dev/null && ((MOVED_FILES++)) || true
        fi
    done
    $EXEC_CMD rmdir backups 2>/dev/null || warn "Could not remove backups directory (may not be empty)"
fi

# 6. Move script duplicates
log "📜 Consolidating scripts..."
if [[ -d "scripts" && -d "tools" ]]; then
    log "  Merging scripts/ into tools/"
    $EXEC_CMD mkdir -p tools/legacy-scripts
    $EXEC_CMD mv -v scripts/* tools/legacy-scripts/ 2>/dev/null || true
    $EXEC_CMD rmdir scripts 2>/dev/null || warn "Could not remove scripts directory"
fi

# 7. Clean up empty directories
log "🗑️ Removing empty directories..."
if [[ "$DRY_RUN" != "true" ]]; then
    find . -type d -empty -not -path "./.git/*" -not -path "./.archives/*" -not -path "./runtime/1-ui/setup" -delete 2>/dev/null && ((CLEANED_DIRS++)) || true
fi

# 8. Update .gitignore
log "📝 Updating .gitignore..."
if [[ "$DRY_RUN" != "true" ]]; then
    if ! grep -q "^\.archives/" .gitignore 2>/dev/null; then
        cat >> .gitignore << 'EOF'

# Archives and backups (cleanup 2025-01-18)
.archives/
*.tar.gz.backup
cleanup-*.log
EOF
        log "  Added .archives/ to .gitignore"
    fi
fi

# 9. Generate cleanup report
log "📊 Generating cleanup report..."

# Calculate space saved
if [[ -d ".archives" ]]; then
    ARCHIVE_SIZE=$(du -sh .archives 2>/dev/null | cut -f1 || echo "N/A")
else
    ARCHIVE_SIZE="N/A"
fi

# Count remaining dockerfiles
ACTIVE_DOCKERFILES=$(find build/docker -maxdepth 1 -name "*.dockerfile" 2>/dev/null | wc -l || echo 0)

cat << EOF | tee -a "$CLEANUP_LOG"

╔════════════════════════════════════════════════════════════╗
║               CLEANUP COMPLETE SUMMARY                      ║
╚════════════════════════════════════════════════════════════╝

📊 Statistics:
   Files Moved:        $MOVED_FILES
   Dirs Archived:      $ARCHIVED_DIRS  
   Empty Dirs Removed: $CLEANED_DIRS
   Archive Size:       $ARCHIVE_SIZE

✅ Production Files Preserved:
$(for file in jesteros-lenny-rootfs-*.tar.gz jesteros-rootfs-with-gk61-*.tar.gz nook-mvp-rootfs-updated.tar.gz; do
    [[ -f "$file" ]] && echo "   - $file ($(du -h "$file" 2>/dev/null | cut -f1))"
done)

🐳 Active Docker Files ($ACTIVE_DOCKERFILES):
$(find build/docker -maxdepth 1 -name "*.dockerfile" 2>/dev/null | xargs -I {} basename {} | sed 's/^/   - /')

📁 New Structure:
   .archives/
   ├── backups/     (historical backups)
   ├── docker/      (archived dockerfiles)
   ├── rootfs/      (old rootfs archives)
   └── tests/       (archived tests)

🎯 Next Steps:
   1. Review: ls -la .archives/
   2. Test:   make test-quick
   3. Build:  docker build -f build/docker/jesteros-production-multistage.dockerfile .
   4. Commit: git add -A && git commit -m "chore: organize project structure"

⚠️  Important:
   - Log saved to: $CLEANUP_LOG
   - To rollback: mv .archives/* . && rm -rf .archives
   - Production files remain in root for deployment

EOF

if [[ "$DRY_RUN" == "--dry-run" ]]; then
    echo
    warn "This was a DRY RUN. To execute changes, run without --dry-run flag"
    warn "Command: bash cleanup-project.sh"
fi

log "✨ Cleanup script completed successfully!"