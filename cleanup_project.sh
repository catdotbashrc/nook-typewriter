#!/bin/bash
# Project Cleanup Script for Nook Kernel Feature
# "By quill and candlelight, we tidy the scriptorium"

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "==============================================================="
echo "           Nook Kernel Project Cleanup"
echo "==============================================================="
echo ""

# Track cleanup statistics
REMOVED_FILES=0
REMOVED_DIRS=0
FREED_SPACE=0

# Function to safely remove files
safe_remove() {
    local pattern="$1"
    local description="$2"
    
    echo -e "${YELLOW}Cleaning $description...${NC}"
    
    # Count files before removal
    local count=$(find . -type f -name "$pattern" 2>/dev/null | wc -l)
    
    if [ "$count" -gt 0 ]; then
        # Calculate space before removal
        local space=$(find . -type f -name "$pattern" -exec du -cb {} + 2>/dev/null | grep total$ | awk '{print $1}' | head -1)
        
        # Remove files
        find . -type f -name "$pattern" -exec rm -f {} \; 2>/dev/null
        
        REMOVED_FILES=$((REMOVED_FILES + count))
        FREED_SPACE=$((FREED_SPACE + ${space:-0}))
        
        echo -e "  ${GREEN}✓${NC} Removed $count files ($(numfmt --to=iec ${space:-0}))"
    else
        echo -e "  ${BLUE}○${NC} No $description found"
    fi
}

echo -e "${BLUE}=== Phase 1: Cleaning Build Artifacts ===${NC}"
echo ""

# Clean kernel build artifacts
safe_remove "*.o" "object files"
safe_remove "*.ko" "old kernel modules (keeping firmware/modules/*.ko)"
safe_remove "*.mod.c" "module source files"
safe_remove "*.mod.o" "module object files"
safe_remove ".*.cmd" "command files"
safe_remove "*.order" "module order files"
safe_remove "*.symvers" "symbol version files"
safe_remove "*.markers" "marker files"

# Keep the built modules in firmware/modules
echo -e "${YELLOW}Preserving built modules in firmware/modules...${NC}"
if [ -d "firmware/modules" ]; then
    echo -e "  ${GREEN}✓${NC} Keeping $(ls firmware/modules/*.ko 2>/dev/null | wc -l) .ko modules"
fi

echo ""
echo -e "${BLUE}=== Phase 2: Removing Temporary Directories ===${NC}"
echo ""

# Remove .tmp_versions directories
echo -e "${YELLOW}Removing .tmp_versions directories...${NC}"
TEMP_DIRS=$(find . -type d -name ".tmp_versions" 2>/dev/null | wc -l)
find . -type d -name ".tmp_versions" -exec rm -rf {} + 2>/dev/null || true
REMOVED_DIRS=$((REMOVED_DIRS + TEMP_DIRS))
echo -e "  ${GREEN}✓${NC} Removed $TEMP_DIRS temporary directories"

# Clean standalone_modules if it exists
if [ -d "standalone_modules" ]; then
    echo -e "${YELLOW}Removing standalone_modules directory...${NC}"
    rm -rf standalone_modules
    REMOVED_DIRS=$((REMOVED_DIRS + 1))
    echo -e "  ${GREEN}✓${NC} Removed standalone_modules directory"
fi

echo ""
echo -e "${BLUE}=== Phase 3: Consolidating Build Scripts ===${NC}"
echo ""

# Create organized build directory
mkdir -p build/scripts

# Identify redundant build scripts
echo -e "${YELLOW}Organizing build scripts...${NC}"

# Keep the best version of each script type
declare -A SCRIPTS_TO_KEEP=(
    ["build_modules_standalone.sh"]="build/scripts/build_modules.sh"
    ["build_kernel.sh"]="build/scripts/build_kernel.sh"
    ["create_deployment_package.sh"]="build/scripts/create_deployment.sh"
    ["create_cwm_package.sh"]="build/scripts/create_cwm.sh"
    ["deploy_to_nook_sd.sh"]="build/scripts/deploy_to_nook.sh"
)

# Move and rename scripts
for script in "${!SCRIPTS_TO_KEEP[@]}"; do
    if [ -f "$script" ]; then
        mv "$script" "${SCRIPTS_TO_KEEP[$script]}"
        echo -e "  ${GREEN}✓${NC} Moved $script → ${SCRIPTS_TO_KEEP[$script]}"
    fi
done

# Remove redundant scripts
REDUNDANT_SCRIPTS=(
    "build_external_modules.sh"
    "build_modules_proper.sh"
    "build_modules_xda.sh"
    "build_squireos_modules.sh"
    "compile_squireos_modules.sh"
    "test-kernel-build.sh"
    "test_squireos_modules.sh"
)

for script in "${REDUNDANT_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        rm -f "$script"
        REMOVED_FILES=$((REMOVED_FILES + 1))
        echo -e "  ${RED}✗${NC} Removed redundant $script"
    fi
done

echo ""
echo -e "${BLUE}=== Phase 4: Fixing Permissions ===${NC}"
echo ""

# Fix permissions on files owned by root (from Docker operations)
echo -e "${YELLOW}Fixing file permissions...${NC}"
find . -user root -type f 2>/dev/null | while read -r file; do
    if [ -f "$file" ]; then
        # Use sudo if available, otherwise try to change what we can
        if command -v sudo >/dev/null 2>&1; then
            sudo chown $(whoami):$(whoami) "$file" 2>/dev/null || true
        else
            chown $(whoami):$(whoami) "$file" 2>/dev/null || true
        fi
    fi
done
echo -e "  ${GREEN}✓${NC} Permission fixes attempted"

echo ""
echo -e "${BLUE}=== Phase 5: Organizing Project Structure ===${NC}"
echo ""

# Create proper directory structure
echo -e "${YELLOW}Creating organized structure...${NC}"
mkdir -p docs/deployment
mkdir -p docs/development
mkdir -p build/output

# Move documentation to proper locations
if [ -f "DEPLOY_MODULES.md" ]; then
    mv DEPLOY_MODULES.md docs/deployment/
    echo -e "  ${GREEN}✓${NC} Moved deployment docs"
fi

if [ -f "XDA_DEPLOYMENT_METHOD.md" ]; then
    mv XDA_DEPLOYMENT_METHOD.md docs/deployment/
    echo -e "  ${GREEN}✓${NC} Moved XDA deployment docs"
fi

# Move output files
if ls squireos-*.tar.gz 2>/dev/null; then
    mv squireos-*.tar.gz build/output/
    echo -e "  ${GREEN}✓${NC} Moved output archives to build/output/"
fi

if ls *.zip 2>/dev/null; then
    mv *.zip build/output/
    echo -e "  ${GREEN}✓${NC} Moved zip files to build/output/"
fi

echo ""
echo -e "${BLUE}=== Phase 6: Creating Project Index ===${NC}"
echo ""

# Create a project structure index
cat > PROJECT_STRUCTURE.md << 'EOF'
# Project Structure

## Directory Layout

```
nook-kernel-feature/
├── build/                  # Build system and outputs
│   ├── docker/            # Docker build environments
│   ├── scripts/           # Consolidated build scripts
│   └── output/            # Built packages and archives
├── source/                # Source code
│   ├── kernel/            # Linux kernel source
│   │   └── src/
│   │       └── drivers/
│   │           └── squireos/  # SquireOS kernel modules
│   ├── configs/           # System configurations
│   └── scripts/           # Runtime scripts
├── firmware/              # Built firmware components
│   └── modules/           # Compiled kernel modules (.ko files)
├── deployment_package/    # Ready-to-deploy package structure
├── docs/                  # Documentation
│   ├── deployment/        # Deployment guides
│   └── development/       # Development documentation
└── tests/                 # Test suites
```

## Key Files

### Build Scripts (build/scripts/)
- `build_kernel.sh` - Main kernel build script
- `build_modules.sh` - SquireOS module builder
- `create_deployment.sh` - Package creator
- `deploy_to_nook.sh` - Deployment script

### Kernel Modules (firmware/modules/)
- `squireos_core.ko` - Core module
- `jester.ko` - ASCII art companion
- `typewriter.ko` - Writing statistics
- `wisdom.ko` - Writing quotes

### Documentation (docs/)
- Deployment guides
- Development notes
- API documentation

## Quick Commands

Build modules:
```bash
./build/scripts/build_modules.sh
```

Create deployment package:
```bash
./build/scripts/create_deployment.sh
```

Deploy to Nook:
```bash
./build/scripts/deploy_to_nook.sh
```
EOF

echo -e "  ${GREEN}✓${NC} Created PROJECT_STRUCTURE.md"

echo ""
echo "==============================================================="
echo "           Cleanup Summary"
echo "==============================================================="
echo ""

# Calculate freed space in human-readable format
FREED_MB=$((FREED_SPACE / 1048576))

echo -e "${GREEN}Cleanup Complete!${NC}"
echo ""
echo "Statistics:"
echo "  • Files removed: $REMOVED_FILES"
echo "  • Directories removed: $REMOVED_DIRS"
echo "  • Space freed: ${FREED_MB}MB"
echo ""
echo "Preserved:"
echo "  • Built kernel modules in firmware/modules/"
echo "  • Deployment packages in build/output/"
echo "  • Essential build scripts in build/scripts/"
echo "  • Source code and configurations"
echo ""
echo "Next steps:"
echo "  1. Review PROJECT_STRUCTURE.md for new layout"
echo "  2. Use scripts in build/scripts/ for operations"
echo "  3. Find outputs in build/output/"
echo ""
echo "==============================================================="
echo "'By quill and order, the scriptorium is cleansed!'"
echo "==============================================================="