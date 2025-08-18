#!/bin/bash
# JesterOS Script & Tool Unification Implementation
# Combines /scripts/ and /tools/ into unified /utilities/ directory
# Created: January 2025

set -euo pipefail
trap 'error_handler $? $LINENO "$BASH_COMMAND"' ERR

# Configuration
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
BACKUP_DIR="backups/unification-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="unification.log"
DRY_RUN="${DRY_RUN:-false}"

# Colors for output
BOLD='\033[1m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
BLUE='\033[34m'
NC='\033[0m'

# Counters
SCRIPTS_MIGRATED=0
DUPLICATES_RESOLVED=0
TESTS_UNIFIED=0
ERRORS=0

# Initialize log
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo -e "${BOLD}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}          JesterOS Script & Tool Unification${NC}"
echo -e "${BOLD}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Starting at: $(date)"
echo "Project root: $PROJECT_ROOT"
echo "Dry run: $DRY_RUN"
echo ""

# Error handler
error_handler() {
    local exit_code=$1
    local line_no=$2
    local bash_command=$3
    echo -e "${RED}✗${NC} Error occurred at line $line_no: $bash_command (exit code: $exit_code)"
    ((ERRORS++))
    if [[ "$DRY_RUN" == "false" ]]; then
        echo -e "${YELLOW}⚠${NC} Rolling back changes..."
        rollback
    fi
    exit $exit_code
}

# Logging functions
log_phase() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Phase $1: $2${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

log_info() {
    echo -e "  $1"
}

# Rollback function
rollback() {
    if [[ -d "$BACKUP_DIR" ]]; then
        echo "Restoring from backup..."
        
        # Remove new structure
        [[ -d utilities ]] && rm -rf utilities
        
        # Restore old structure
        if [[ -f "$BACKUP_DIR/scripts.tar.gz" ]]; then
            tar -xzf "$BACKUP_DIR/scripts.tar.gz"
        fi
        if [[ -f "$BACKUP_DIR/tools.tar.gz" ]]; then
            tar -xzf "$BACKUP_DIR/tools.tar.gz"
        fi
        
        log_success "Rollback complete"
    else
        log_error "No backup found for rollback"
    fi
}

# Phase 1: Backup and Analysis
phase1_backup_analysis() {
    log_phase "1" "Backup and Analysis"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        # Create backup directory
        mkdir -p "$BACKUP_DIR"
        
        # Backup existing directories
        if [[ -d scripts ]]; then
            tar -czf "$BACKUP_DIR/scripts.tar.gz" scripts/
            log_success "Backed up scripts/ directory"
        fi
        
        if [[ -d tools ]]; then
            tar -czf "$BACKUP_DIR/tools.tar.gz" tools/
            log_success "Backed up tools/ directory"
        fi
    else
        log_info "[DRY RUN] Would backup scripts/ and tools/ directories"
    fi
    
    # Analyze duplicates
    echo ""
    echo "Analyzing duplicate scripts..."
    
    local duplicates=("apply_metadata.sh" "secure-chmod-replacements.sh" "setup-writer-user.sh" "version-control.sh")
    
    for script in "${duplicates[@]}"; do
        local scripts_version="scripts/$script"
        local tools_version="tools/setup/$script"
        
        if [[ -f "$scripts_version" ]] && [[ -f "$tools_version" ]]; then
            echo -n "  Found duplicate: $script"
            
            # Quick quality check
            local scripts_lines=$(wc -l < "$scripts_version" 2>/dev/null || echo 0)
            local tools_lines=$(wc -l < "$tools_version" 2>/dev/null || echo 0)
            
            if [[ $tools_lines -gt $scripts_lines ]]; then
                echo " (will use tools/ version - more comprehensive)"
            elif [[ $scripts_lines -gt $tools_lines ]]; then
                echo " (will use scripts/ version - more comprehensive)"
            else
                echo " (versions are similar)"
            fi
            
            ((DUPLICATES_RESOLVED++))
        fi
    done
    
    log_success "Analysis complete: $DUPLICATES_RESOLVED duplicates found"
}

# Phase 2: Create New Structure
phase2_create_structure() {
    log_phase "2" "Create New Structure"
    
    local directories=(
        "utilities/lib"
        "utilities/build"
        "utilities/deploy"
        "utilities/maintain"
        "utilities/setup"
        "utilities/migrate"
        "utilities/test/tests"
        "utilities/platform/windows"
        "utilities/platform/wsl"
        "utilities/extras/splash-generator/assets"
    )
    
    for dir in "${directories[@]}"; do
        if [[ "$DRY_RUN" == "false" ]]; then
            mkdir -p "$dir"
            log_success "Created $dir"
        else
            log_info "[DRY RUN] Would create $dir"
        fi
    done
}

# Phase 3: Migrate Core Libraries
phase3_migrate_libraries() {
    log_phase "3" "Migrate Core Libraries"
    
    # Migrate common.sh from scripts
    if [[ -f "scripts/lib/common.sh" ]]; then
        if [[ "$DRY_RUN" == "false" ]]; then
            cp "scripts/lib/common.sh" "utilities/lib/common.sh"
            log_success "Migrated common.sh library"
        else
            log_info "[DRY RUN] Would migrate scripts/lib/common.sh"
        fi
    fi
    
    # Copy validation library from build/scripts if it exists
    if [[ -f "build/scripts/lib/validation.sh" ]]; then
        if [[ "$DRY_RUN" == "false" ]]; then
            cp "build/scripts/lib/validation.sh" "utilities/lib/validation.sh"
            log_success "Migrated validation.sh library"
        else
            log_info "[DRY RUN] Would migrate build/scripts/lib/validation.sh"
        fi
    fi
}

# Phase 4: Resolve Duplicates
phase4_resolve_duplicates() {
    log_phase "4" "Resolve Duplicates and Migrate Scripts"
    
    # Define migration mappings
    declare -A migrations=(
        # From scripts/
        ["scripts/apply_metadata.sh"]="utilities/setup/apply-metadata.sh"
        ["scripts/deployment/create-sd-image.sh"]="utilities/deploy/create-sd-image.sh"
        
        # From tools/setup/ (better versions)
        ["tools/setup/secure-chmod-replacements.sh"]="utilities/setup/secure-chmod.sh"
        ["tools/setup/setup-writer-user.sh"]="utilities/setup/setup-writer.sh"
        ["tools/setup/version-control.sh"]="utilities/setup/version-control.sh"
        
        # Docker management
        ["tools/docker-cache-manager.sh"]="utilities/build/docker-cache-manager.sh"
        ["tools/docker-monitor.sh"]="utilities/build/docker-monitor.sh"
        ["tools/optimize-buildkit.sh"]="utilities/build/optimize-buildkit.sh"
        ["tools/build-workflow-improvements.sh"]="utilities/build/workflow-improvements.sh"
        
        # Deployment
        ["tools/deploy/flash-sd.sh"]="utilities/deploy/flash-sd.sh"
        
        # Maintenance
        ["tools/maintenance/cleanup_nook_project.sh"]="utilities/maintain/cleanup-project.sh"
        ["tools/maintenance/fix-boot-loop.sh"]="utilities/maintain/fix-boot-loop.sh"
        ["tools/maintenance/install-jesteros-userspace.sh"]="utilities/maintain/install-jesteros.sh"
        
        # Migration scripts
        ["tools/migrate-to-architecture-layers.sh"]="utilities/migrate/architecture-layers.sh"
        ["tools/migrate-to-embedded-structure.sh"]="utilities/migrate/embedded-structure.sh"
        ["tools/fix-architecture-paths.sh"]="utilities/migrate/fix-paths.sh"
        ["tools/phase2-migrate-paths.sh"]="utilities/migrate/phase2-paths.sh"
        
        # Platform specific
        ["tools/windows-deploy-nook.ps1"]="utilities/platform/windows/deploy.ps1"
        ["tools/windows-attach-sd.ps1"]="utilities/platform/windows/attach-sd.ps1"
        ["tools/wsl-mount-usb.sh"]="utilities/platform/wsl/mount-usb.sh"
    )
    
    for source in "${!migrations[@]}"; do
        local target="${migrations[$source]}"
        
        if [[ -f "$source" ]]; then
            if [[ "$DRY_RUN" == "false" ]]; then
                cp "$source" "$target"
                
                # Update path references if it's a shell script
                if [[ "$target" == *.sh ]]; then
                    # Update common.sh references
                    sed -i 's|"\$(dirname.*)/\.\./lib/common\.sh"|"$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"|g' "$target"
                    sed -i 's|source.*lib/common\.sh|source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"|g' "$target"
                fi
                
                log_success "Migrated $(basename "$source") → $(basename "$target")"
                ((SCRIPTS_MIGRATED++))
            else
                log_info "[DRY RUN] Would migrate $source → $target"
            fi
        fi
    done
}

# Phase 5: Unify Test Framework
phase5_unify_tests() {
    log_phase "5" "Unify Test Framework"
    
    # Create unified test framework
    if [[ "$DRY_RUN" == "false" ]]; then
        # Use the better test framework from scripts/
        if [[ -f "scripts/test/test_framework.sh" ]]; then
            cp "scripts/test/test_framework.sh" "utilities/test/framework.sh"
            log_success "Migrated test framework"
        elif [[ -f "tools/testing/test_framework.sh" ]]; then
            cp "tools/testing/test_framework.sh" "utilities/test/framework.sh"
            log_success "Migrated test framework from tools"
        fi
        
        # Migrate test runner
        if [[ -f "scripts/test/run_all_tests.sh" ]]; then
            cp "scripts/test/run_all_tests.sh" "utilities/test/run-all.sh"
        elif [[ -f "tools/testing/run_all_tests.sh" ]]; then
            cp "tools/testing/run_all_tests.sh" "utilities/test/run-all.sh"
        fi
        
        # Migrate individual tests
        for test in scripts/test/test_*.sh tools/testing/test_*.sh; do
            if [[ -f "$test" ]]; then
                local name=$(basename "$test")
                if [[ ! -f "utilities/test/tests/$name" ]]; then
                    cp "$test" "utilities/test/tests/$name"
                    ((TESTS_UNIFIED++))
                fi
            fi
        done
        
        log_success "Unified $TESTS_UNIFIED test scripts"
    else
        log_info "[DRY RUN] Would unify test frameworks and migrate tests"
    fi
}

# Phase 6: Migrate Splash Generator
phase6_migrate_extras() {
    log_phase "6" "Migrate Extra Tools"
    
    # Migrate splash generator
    if [[ -d "tools/splash-generator" ]]; then
        if [[ "$DRY_RUN" == "false" ]]; then
            cp -r tools/splash-generator/* utilities/extras/splash-generator/
            log_success "Migrated splash generator tools"
        else
            log_info "[DRY RUN] Would migrate splash-generator"
        fi
    fi
}

# Phase 7: Update References and Documentation
phase7_update_references() {
    log_phase "7" "Update References and Documentation"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        # Create README for utilities
        cat > utilities/README.md << 'EOF'
# JesterOS Utilities Directory

*Unified collection of scripts and tools for JesterOS/Nook project*

## Directory Structure

### `/lib/` - Common Libraries
- `common.sh` - Core library with logging, error handling, and utilities
- `validation.sh` - Input validation and safety checks

### `/build/` - Build and Docker Management
- Docker cache management and optimization tools
- Build workflow improvements

### `/deploy/` - Deployment Tools
- SD card creation and flashing utilities
- Deployment scripts for Nook devices

### `/maintain/` - Maintenance Scripts
- Project cleanup and maintenance
- Boot loop fixes and troubleshooting
- JesterOS installation utilities

### `/setup/` - Configuration and Setup
- System setup scripts
- Metadata application
- Version control utilities

### `/migrate/` - Migration Tools
- Architecture migration scripts
- Path fixing utilities

### `/test/` - Testing Framework
- Unified test framework with assertions
- Test runner and individual test scripts

### `/platform/` - Platform-Specific Tools
- Windows PowerShell scripts
- WSL utilities

### `/extras/` - Additional Tools
- Splash screen generator for E-Ink displays
- SVG to E-Ink conversion utilities

## Usage

All scripts should be run from the project root:
```bash
./utilities/build/docker-cache-manager.sh
./utilities/test/run-all.sh
```

## Common Library

Most scripts source the common library for consistent functionality:
```bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
```

This provides:
- Unified logging functions
- Error handling
- Path resolution
- Color output support

## Migration from scripts/ and tools/

This directory consolidates the former `/scripts/` and `/tools/` directories.
All references have been updated to use the new `/utilities/` path.

---
*Last updated: $(date)*
EOF
        
        log_success "Created utilities/README.md"
        
        # Update project references
        echo "Updating project file references..."
        local updated=0
        
        for file in $(find . -type f \( -name "*.md" -o -name "*.sh" -o -name "Makefile" \) \
                      -not -path "./utilities/*" -not -path "./backups/*" \
                      -not -path "./.git/*" 2>/dev/null); do
            if grep -q "scripts/\|tools/" "$file" 2>/dev/null; then
                # Create backup
                cp "$file" "$file.unify-bak"
                
                # Update references
                sed -i 's|scripts/|utilities/|g; s|tools/|utilities/|g' "$file"
                ((updated++))
            fi
        done
        
        log_success "Updated $updated files with new paths"
    else
        log_info "[DRY RUN] Would create README and update references"
    fi
}

# Final Report
generate_report() {
    echo ""
    echo -e "${BOLD}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}                    Migration Report${NC}"
    echo -e "${BOLD}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Scripts migrated:      $SCRIPTS_MIGRATED"
    echo "Duplicates resolved:   $DUPLICATES_RESOLVED"
    echo "Tests unified:         $TESTS_UNIFIED"
    echo "Errors encountered:    $ERRORS"
    echo ""
    
    if [[ "$ERRORS" -eq 0 ]]; then
        echo -e "${GREEN}✓ Migration completed successfully!${NC}"
        
        if [[ "$DRY_RUN" == "false" ]]; then
            echo ""
            echo "Next steps:"
            echo "  1. Review the new structure in utilities/"
            echo "  2. Run tests: ./utilities/test/run-all.sh"
            echo "  3. Update any remaining references"
            echo "  4. Remove old directories when ready:"
            echo "     rm -rf scripts/ tools/"
        fi
    else
        echo -e "${RED}✗ Migration completed with errors${NC}"
        echo "Please review the log file: $LOG_FILE"
    fi
    
    echo ""
    echo "Completed at: $(date)"
}

# Main execution
main() {
    # Check prerequisites
    if [[ ! -d "scripts" ]] && [[ ! -d "tools" ]]; then
        log_error "Neither scripts/ nor tools/ directories found"
        exit 1
    fi
    
    # Execute phases
    phase1_backup_analysis
    phase2_create_structure
    phase3_migrate_libraries
    phase4_resolve_duplicates
    phase5_unify_tests
    phase6_migrate_extras
    phase7_update_references
    
    # Generate final report
    generate_report
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [--dry-run]"
        echo ""
        echo "Unifies scripts/ and tools/ directories into utilities/"
        echo ""
        echo "Options:"
        echo "  --dry-run    Show what would be done without making changes"
        echo "  --help       Show this help message"
        exit 0
        ;;
    --dry-run)
        DRY_RUN=true
        ;;
esac

# Run main function
main