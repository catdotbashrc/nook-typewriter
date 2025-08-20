#!/bin/bash
# ===============================================================
# 🩸 THE BLOOD PACT MIGRATION SCRIPT 🩸
# By the ancient rites of standardization, we heal this project!
# ===============================================================

set -e  # Exit on error - no half measures!

# Colors for our dramatic ritual
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}     🩸 THE BLOOD PACT MIGRATION RITUAL BEGINS! 🩸${NC}"
echo -e "${PURPLE}     From chaos to order, from old to standard!${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
echo

# Safety check
echo -e "${YELLOW}⚠️  This will restructure your entire project!${NC}"
echo -e "${YELLOW}   Current branch: $(git branch --show-current)${NC}"
read -p "Proceed with the blood pact? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "The pact is broken. Exiting..."
    exit 1
fi

# Create backup branch
echo -e "\n${BLUE}Creating safety backup branch...${NC}"
git checkout -b backup-before-blood-pact-$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
git checkout -

# ===============================================================
# PHASE 1: Create Standard Structure
# ===============================================================
echo -e "\n${PURPLE}PHASE 1: Preparing the sacred grounds...${NC}"

# Create all standard directories
mkdir -p src/{init,core,hal,services,apps}
mkdir -p src/services/{ui,menu,jester,tracker}
mkdir -p src/hal/{eink,buttons,power,sensors,usb}
mkdir -p src/apps/{vim,git}
mkdir -p platform/nook-touch/{bootloader,kernel,firmware,modules}
mkdir -p scripts/{build,deploy,test}
mkdir -p config/{kernel,system,user}
mkdir -p vendor/{images,kernel}
mkdir -p test/{unit,integration,system}

echo -e "${GREEN}✓ Standard structure created${NC}"

# ===============================================================
# PHASE 2: The Great Migration - runtime/ → src/
# ===============================================================
echo -e "\n${PURPLE}PHASE 2: Migrating the runtime realm...${NC}"

# Check if runtime exists
if [ -d "runtime" ]; then
    echo "Found runtime/ directory - beginning migration..."
    
    # Init scripts
    if [ -d "runtime/init" ]; then
        echo -e "  ${BLUE}Moving init scripts...${NC}"
        git mv runtime/init/*.sh src/init/ 2>/dev/null || cp runtime/init/*.sh src/init/ 2>/dev/null || true
    fi
    
    # System/Core scripts (Layer 3 → core)
    if [ -d "runtime/3-system" ]; then
        echo -e "  ${BLUE}Moving core system scripts...${NC}"
        find runtime/3-system -name "*.sh" -exec git mv {} src/core/ \; 2>/dev/null || \
        find runtime/3-system -name "*.sh" -exec cp {} src/core/ \; 2>/dev/null || true
    fi
    
    # Hardware scripts (Layer 4 → hal)
    if [ -d "runtime/4-hardware" ]; then
        echo -e "  ${BLUE}Moving hardware abstraction...${NC}"
        [ -d "runtime/4-hardware/input" ] && git mv runtime/4-hardware/input/*.sh src/hal/buttons/ 2>/dev/null || true
        [ -d "runtime/4-hardware/power" ] && git mv runtime/4-hardware/power/*.sh src/hal/power/ 2>/dev/null || true
        [ -d "runtime/4-hardware/sensors" ] && git mv runtime/4-hardware/sensors/*.sh src/hal/sensors/ 2>/dev/null || true
        [ -d "runtime/4-hardware/eink" ] && git mv runtime/4-hardware/eink/*.sh src/hal/eink/ 2>/dev/null || true
    fi
    
    # UI/Services (Layer 1 → services)
    if [ -d "runtime/1-ui" ]; then
        echo -e "  ${BLUE}Moving UI services...${NC}"
        find runtime/1-ui -name "*.sh" -exec git mv {} src/services/ui/ \; 2>/dev/null || \
        find runtime/1-ui -name "*.sh" -exec cp {} src/services/ui/ \; 2>/dev/null || true
    fi
    
    # Applications (Layer 2 → services/apps)
    if [ -d "runtime/2-application" ]; then
        echo -e "  ${BLUE}Moving applications...${NC}"
        [ -f "runtime/2-application/jesteros/jester-daemon.sh" ] && git mv runtime/2-application/jesteros/jester*.sh src/services/jester/ 2>/dev/null || true
        [ -f "runtime/2-application/jesteros/tracker.sh" ] && git mv runtime/2-application/jesteros/tracker.sh src/services/tracker/ 2>/dev/null || true
        [ -d "runtime/2-application/writing" ] && git mv runtime/2-application/writing/*.sh src/apps/git/ 2>/dev/null || true
    fi
    
    # Config files
    if [ -d "runtime/config" ] || [ -d "runtime/configs" ]; then
        echo -e "  ${BLUE}Moving configurations...${NC}"
        [ -d "runtime/config" ] && cp -r runtime/config/* config/system/ 2>/dev/null || true
        [ -d "runtime/configs" ] && cp -r runtime/configs/* config/ 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✓ Runtime migration complete${NC}"
else
    echo -e "${YELLOW}No runtime/ directory found - may already be migrated${NC}"
fi

# ===============================================================
# PHASE 3: Platform Migration - firmware/ → platform/nook-touch/
# ===============================================================
echo -e "\n${PURPLE}PHASE 3: Relocating platform artifacts...${NC}"

if [ -d "firmware" ]; then
    echo "Found firmware/ directory - migrating to platform/..."
    
    # Bootloader files
    if [ -d "firmware/boot" ]; then
        echo -e "  ${BLUE}Moving bootloader files...${NC}"
        [ -f "firmware/boot/MLO" ] && git mv firmware/boot/MLO platform/nook-touch/bootloader/ 2>/dev/null || true
        [ -f "firmware/boot/u-boot.bin" ] && git mv firmware/boot/u-boot.bin platform/nook-touch/bootloader/ 2>/dev/null || true
        [ -f "firmware/boot/uImage" ] && git mv firmware/boot/uImage platform/nook-touch/kernel/ 2>/dev/null || true
    fi
    
    # Android and DSP firmware
    [ -d "firmware/android" ] && git mv firmware/android/* platform/nook-touch/firmware/ 2>/dev/null || true
    [ -d "firmware/dsp" ] && git mv firmware/dsp/* platform/nook-touch/firmware/ 2>/dev/null || true
    
    # Kernel modules
    [ -d "firmware/modules" ] && git mv firmware/modules/* platform/nook-touch/modules/ 2>/dev/null || true
    
    echo -e "${GREEN}✓ Platform migration complete${NC}"
else
    echo -e "${YELLOW}No firmware/ directory found${NC}"
fi

# ===============================================================
# PHASE 4: Clean build/ directory
# ===============================================================
echo -e "\n${PURPLE}PHASE 4: Purifying the build realm...${NC}"

if [ -d "build/scripts" ]; then
    echo -e "  ${BLUE}Moving build scripts to scripts/...${NC}"
    git mv build/scripts/*.sh scripts/build/ 2>/dev/null || cp build/scripts/*.sh scripts/build/ 2>/dev/null || true
    echo -e "${GREEN}✓ Build scripts relocated${NC}"
fi

# ===============================================================
# PHASE 5: Relocate misc items
# ===============================================================
echo -e "\n${PURPLE}PHASE 5: Final relocations...${NC}"

# Move base images
if [ -d "images" ] && [ "$(ls -A images/)" ]; then
    echo -e "  ${BLUE}Moving base images...${NC}"
    git mv images/*.img vendor/images/ 2>/dev/null || mv images/*.img vendor/images/ 2>/dev/null || true
fi

# Move kernel source
if [ -d "source/kernel" ]; then
    echo -e "  ${BLUE}Moving kernel source...${NC}"
    git mv source/kernel vendor/ 2>/dev/null || mv source/kernel vendor/ 2>/dev/null || true
fi

echo -e "${GREEN}✓ Relocations complete${NC}"

# ===============================================================
# PHASE 6: Update all references
# ===============================================================
echo -e "\n${PURPLE}PHASE 6: Updating the ancient scrolls (configs)...${NC}"

# Update Makefile
if [ -f "Makefile" ]; then
    echo -e "  ${BLUE}Updating Makefile...${NC}"
    sed -i.bak \
        -e 's|runtime/|src/|g' \
        -e 's|firmware/|platform/nook-touch/|g' \
        -e 's|SCRIPTS_DIR := scripts|SCRIPTS_DIR := src|g' \
        -e 's|build/scripts/|scripts/build/|g' \
        Makefile
    echo -e "${GREEN}✓ Makefile updated${NC}"
fi

# Update Docker files
if [ -d "docker" ]; then
    echo -e "  ${BLUE}Updating Docker files...${NC}"
    find docker -name "*.dockerfile" -o -name "Dockerfile*" | while read dockerfile; do
        sed -i.bak \
            -e 's|runtime/|src/|g' \
            -e 's|firmware/|platform/nook-touch/|g' \
            -e 's|COPY runtime/|COPY src/|g' \
            -e 's|/runtime/|/src/|g' \
            "$dockerfile"
    done
    echo -e "${GREEN}✓ Docker files updated${NC}"
fi

# Update test scripts
if [ -d "tests" ]; then
    echo -e "  ${BLUE}Updating test scripts...${NC}"
    find tests -name "*.sh" | while read testfile; do
        sed -i.bak \
            -e 's|runtime/|src/|g' \
            -e 's|firmware/|platform/nook-touch/|g' \
            "$testfile"
    done
    echo -e "${GREEN}✓ Test scripts updated${NC}"
fi

# Update documentation
echo -e "  ${BLUE}Updating documentation...${NC}"
find docs -name "*.md" | while read doc; do
    sed -i.bak \
        -e 's|runtime/|src/|g' \
        -e 's|firmware/|platform/nook-touch/|g' \
        "$doc" 2>/dev/null || true
done

# Update CLAUDE.md if it exists
[ -f "CLAUDE.md" ] && sed -i.bak 's|runtime/|src/|g; s|firmware/|platform/nook-touch/|g' CLAUDE.md

echo -e "${GREEN}✓ References updated${NC}"

# ===============================================================
# PHASE 7: Cleanup
# ===============================================================
echo -e "\n${PURPLE}PHASE 7: Banishing the old ways...${NC}"

# Remove empty directories
echo -e "  ${BLUE}Removing empty directories...${NC}"
find . -type d -empty -delete 2>/dev/null || true

# Clean up backup files
find . -name "*.bak" -delete 2>/dev/null || true

# Remove old runtime directory if empty
[ -d "runtime" ] && [ -z "$(ls -A runtime/)" ] && rmdir runtime && echo -e "${GREEN}✓ Removed empty runtime/${NC}"
[ -d "firmware" ] && [ -z "$(ls -A firmware/)" ] && rmdir firmware && echo -e "${GREEN}✓ Removed empty firmware/${NC}"
[ -d "images" ] && [ -z "$(ls -A images/)" ] && rmdir images && echo -e "${GREEN}✓ Removed empty images/${NC}"

# ===============================================================
# PHASE 8: Validation
# ===============================================================
echo -e "\n${PURPLE}PHASE 8: Validating the transformation...${NC}"

# Check key directories exist
ERRORS=0

check_dir() {
    if [ -d "$1" ]; then
        echo -e "  ${GREEN}✓ $1 exists${NC}"
    else
        echo -e "  ${RED}✗ $1 missing!${NC}"
        ERRORS=$((ERRORS + 1))
    fi
}

check_dir "src/init"
check_dir "src/core"
check_dir "src/hal"
check_dir "src/services"
check_dir "platform/nook-touch"
check_dir "scripts/build"

if [ $ERRORS -eq 0 ]; then
    echo -e "\n${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}     🎉 THE BLOOD PACT IS COMPLETE! 🎉${NC}"
    echo -e "${GREEN}     Your project has been transformed!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    
    # Show new structure
    echo -e "\n${BLUE}New structure:${NC}"
    tree -L 2 -d --dirsfirst 2>/dev/null | head -20 || ls -d */
    
    echo -e "\n${YELLOW}Next steps:${NC}"
    echo "1. Review changes: git status"
    echo "2. Test build: make clean && make"
    echo "3. Run tests: make test"
    echo "4. Commit if satisfied: git add -A && git commit -m '🩸 Blood Pact: Migrated to standard structure'"
    echo ""
    echo "If something went wrong, restore from backup branch:"
    echo "  git reset --hard && git checkout backup-before-blood-pact-*"
else
    echo -e "\n${RED}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}     ⚠️  BLOOD PACT INCOMPLETE! ⚠️${NC}"
    echo -e "${RED}     Some issues were encountered.${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "To rollback: git reset --hard && git checkout backup-before-blood-pact-*"
fi

echo -e "\n${PURPLE}The ritual is complete. May your code compile swiftly!${NC} 🎭"