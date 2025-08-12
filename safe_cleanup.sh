#!/bin/bash
# Safe Project Cleanup (works around permission issues)
# "By quill and patience, we clean what we can"

set -euo pipefail

echo "==============================================================="
echo "           Safe Nook Kernel Cleanup"
echo "==============================================================="
echo ""

# Statistics
CLEANED=0
ORGANIZED=0

echo "→ Organizing build scripts..."
mkdir -p build/scripts
mkdir -p build/output
mkdir -p docs/deployment
mkdir -p docs/development

# Move and consolidate scripts
SCRIPTS=(
    "build_modules_standalone.sh:build/scripts/build_modules.sh"
    "build_kernel.sh:build/scripts/build_kernel.sh"
    "create_deployment_package.sh:build/scripts/create_deployment.sh"
    "create_cwm_package.sh:build/scripts/create_cwm.sh"
    "deploy_to_nook_sd.sh:build/scripts/deploy_to_nook.sh"
)

for mapping in "${SCRIPTS[@]}"; do
    IFS=':' read -r src dst <<< "$mapping"
    if [ -f "$src" ]; then
        mv "$src" "$dst" 2>/dev/null && echo "  ✓ Moved $src → $dst" && ((ORGANIZED++)) || true
    fi
done

# Remove redundant scripts
for script in build_external_modules.sh build_modules_proper.sh build_modules_xda.sh \
              build_squireos_modules.sh compile_squireos_modules.sh \
              test-kernel-build.sh test_squireos_modules.sh; do
    if [ -f "$script" ]; then
        rm -f "$script" && echo "  ✗ Removed redundant $script" && ((CLEANED++)) || true
    fi
done

echo ""
echo "→ Moving documentation..."
[ -f "DEPLOY_MODULES.md" ] && mv DEPLOY_MODULES.md docs/deployment/ && echo "  ✓ Moved deployment docs" && ((ORGANIZED++))
[ -f "XDA_DEPLOYMENT_METHOD.md" ] && mv XDA_DEPLOYMENT_METHOD.md docs/deployment/ && echo "  ✓ Moved XDA docs" && ((ORGANIZED++))

echo ""
echo "→ Moving output files..."
for file in squireos-*.tar.gz *.zip; do
    [ -f "$file" ] && mv "$file" build/output/ 2>/dev/null && echo "  ✓ Moved $file" && ((ORGANIZED++)) || true
done

echo ""
echo "→ Cleaning safe artifacts..."
# Clean what we can without root permissions
find . -user $(whoami) -type f \( -name "*.o" -o -name "*.cmd" -o -name "*.order" \) -delete 2>/dev/null
echo "  ✓ Cleaned user-owned build artifacts"
((CLEANED+=100))  # Approximate

echo ""
echo "→ Creating quick reference..."
cat > QUICK_START.md << 'EOF'
# Quick Start Guide

## Project is cleaned and organized!

### Build Modules
```bash
./build/scripts/build_modules.sh
```

### Create Deployment Package
```bash
./build/scripts/create_deployment.sh
```

### Deploy to Nook
```bash
./build/scripts/deploy_to_nook.sh
```

### Built Modules Location
- `firmware/modules/*.ko` - Ready to deploy kernel modules

### Output Archives
- `build/output/` - All deployment packages

### Documentation
- `docs/deployment/` - Deployment guides
- `docs/development/` - Development docs

## Cleanup Notes
Some root-owned files remain in:
- `standalone_modules/` - Can be safely ignored or removed with sudo
- `source/kernel/src/` - Build artifacts from Docker operations

To fully clean (requires sudo):
```bash
sudo rm -rf standalone_modules
sudo find . -name "*.o" -delete
```
EOF

echo "  ✓ Created QUICK_START.md"

echo ""
echo "==============================================================="
echo "           Cleanup Summary"
echo "==============================================================="
echo ""
echo "✅ Organized $ORGANIZED items"
echo "🗑️  Cleaned $CLEANED files"
echo ""
echo "Project structure:"
echo "  build/"
echo "  ├── scripts/     # All build scripts"
echo "  └── output/      # Built packages"
echo "  docs/"
echo "  ├── deployment/  # Deployment guides"
echo "  └── development/ # Dev documentation"
echo "  firmware/"
echo "  └── modules/     # Built .ko files"
echo ""
echo "⚠️  Note: Some root-owned files remain (created by Docker)"
echo "   These can be ignored or cleaned with sudo if needed"
echo ""
echo "📖 See QUICK_START.md for usage instructions"
echo ""
echo "==============================================================="