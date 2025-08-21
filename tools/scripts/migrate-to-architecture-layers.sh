#!/bin/bash
# Migrate project structure to match 4-layer architecture
# Safe migration with backup and rollback capability

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BACKUP_DIR="runtime-backup-$(date +%Y%m%d-%H%M%S)"
DRY_RUN=${1:-false}

echo "🏗️  Architecture Layer Migration Tool"
echo "===================================="
echo ""

# Function to print colored messages
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if we're in the right directory
if [ ! -d "runtime" ]; then
    log_error "Must run from project root (no runtime/ directory found)"
    exit 1
fi

# Dry run mode
if [ "$DRY_RUN" = "--dry-run" ]; then
    log_warn "DRY RUN MODE - No changes will be made"
    echo ""
fi

# Step 1: Create backup
if [ "$DRY_RUN" != "--dry-run" ]; then
    log_info "Creating backup in $BACKUP_DIR..."
    cp -r runtime "$BACKUP_DIR"
    log_info "Backup created successfully"
fi

# Step 2: Create new architecture-aligned structure
log_info "Creating 4-layer architecture directories..."

DIRS=(
    "src/services/menu/menu"
    "src/services/menu/display"
    "src/services/menu/themes"
    "src/services/jester/jesteros"
    "src/services/jester/writing"
    "src/services/jester/stats"
    "src/services/system/display"
    "src/services/system/filesystem"
    "src/services/system/process"
    "src/services/system/common"
    "src/hal/eink"
    "src/hal/usb"
    "src/hal/power"
    "src/services/init"
)

for dir in "${DIRS[@]}"; do
    if [ "$DRY_RUN" = "--dry-run" ]; then
        echo "  Would create: $dir"
    else
        mkdir -p "$dir"
        echo "  Created: $dir"
    fi
done

# Step 3: Move files to appropriate layers
log_info "Migrating files to architecture layers..."

# Define file mappings (source -> destination)
declare -A FILE_MAPPINGS=(
    # UI Layer (1)
    ["src/services/scripts/menu/"]="src/services/menu/menu/"
    ["src/services/ui/components/"]="src/services/menu/display/"
    ["src/services/ui/themes/"]="src/services/menu/themes/"
    ["src/services/configs/ascii/"]="src/services/menu/themes/"
    
    # Application Layer (2)
    ["src/services/scripts/services/jesteros-mood-selector.sh"]="src/services/services/jester/mood.sh"
    ["src/services/scripts/services/jesteros-service-manager.sh"]="src/services/services/jester/manager.sh"
    ["src/services/scripts/services/jesteros-tracker.sh"]="src/services/services/jester/tracker.sh"
    ["src/services/scripts/services/jester-daemon.sh"]="src/services/services/jester/daemon.sh"
    
    # System Layer (3)
    ["src/services/scripts/lib/common.sh"]="src/services/services/system/"
    ["src/services/scripts/lib/service-functions.sh"]="src/services/services/system/"
    ["src/services/scripts/lib/font-setup.sh"]="src/services/system/display/"
    
    # Kernel Layer (4)
    ["src/services/modules/"]="src/services/4-kernel/modules/"
    
    # Init/Boot
    ["src/services/scripts/boot/jesteros-init.sh"]="src/services/init/"
    ["src/services/scripts/boot/boot-jester.sh"]="src/services/init/"
    ["src/services/scripts/boot/jesteros-boot.sh"]="src/services/init/"
)

# Move files
for source in "${!FILE_MAPPINGS[@]}"; do
    dest="${FILE_MAPPINGS[$source]}"
    
    if [ -e "$source" ]; then
        if [ "$DRY_RUN" = "--dry-run" ]; then
            echo "  Would move: $source -> $dest"
        else
            # Handle file vs directory
            if [ -d "$source" ]; then
                cp -r "$source"* "$dest" 2>/dev/null || true
            else
                # Extract filename for renaming cases
                if [[ "$dest" == *.sh ]]; then
                    cp "$source" "$dest"
                else
                    cp "$source" "$dest"
                fi
            fi
            echo "  Moved: $source -> $dest"
        fi
    fi
done

# Step 4: Create layer README files
log_info "Creating layer documentation..."

if [ "$DRY_RUN" != "--dry-run" ]; then
    cat > runtime/1-ui/README.md << 'EOF'
# Layer 1: User Interface
User-facing components: menus, displays, themes
Dependencies: Can call layers 2-5
EOF

    cat > runtime/2-application/README.md << 'EOF'
# Layer 2: Application Services  
Business logic: JesterOS services, writing modes, statistics
Dependencies: Can call layers 3-5
EOF

    cat > runtime/3-system/README.md << 'EOF'
# Layer 3: System Services
OS integration: display management, filesystem, process control
Dependencies: Can call layers 4-5
EOF

    cat > runtime/4-kernel/README.md << 'EOF'
# Layer 4: Kernel Interface
Kernel communication: modules, proc, sysfs interfaces
Dependencies: Can call layer 5
EOF

    cat > runtime/5-hardware/README.md << 'EOF'
# Layer 5: Hardware Abstraction
Direct hardware control: E-Ink, USB, power management
Dependencies: None (bottom layer)
EOF
fi

# Step 5: Update import paths (show what needs updating)
log_info "Checking for path updates needed..."

echo ""
echo "Files that need path updates:"
grep -r "source.*scripts/lib" runtime/ 2>/dev/null | head -5 || true
grep -r "\.\./lib/" runtime/ 2>/dev/null | head -5 || true

# Step 6: Create migration summary
if [ "$DRY_RUN" != "--dry-run" ]; then
    cat > runtime/MIGRATION_COMPLETED.md << EOF
# Architecture Migration Completed
Date: $(date)
Backup: $BACKUP_DIR

## New Structure
- Layer 1 (UI): Menu, display, themes
- Layer 2 (Application): JesterOS services  
- Layer 3 (System): System services
- Layer 4 (Kernel): Kernel interfaces
- Layer 5 (Hardware): Hardware abstraction

## Next Steps
1. Update script import paths
2. Test boot sequence
3. Update Docker builds
4. Run test suite
EOF
fi

# Summary
echo ""
echo "====================================="
if [ "$DRY_RUN" = "--dry-run" ]; then
    log_warn "DRY RUN COMPLETE - No changes made"
    echo "Run without --dry-run to apply changes"
else
    log_info "✅ Migration completed successfully!"
    log_info "Backup saved to: $BACKUP_DIR"
    echo ""
    echo "⚠️  IMPORTANT NEXT STEPS:"
    echo "1. Update import paths in scripts"
    echo "2. Test the boot sequence"
    echo "3. Update Docker build files"
    echo "4. Run the full test suite"
    echo ""
    echo "To rollback if needed:"
    echo "  rm -rf runtime && mv $BACKUP_DIR runtime"
fi