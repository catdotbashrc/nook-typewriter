# Aggressive Cleanup Plan - DRY RUN

## ⚠️ DRY RUN MODE - NO CHANGES WILL BE MADE

This report shows what would be cleaned with `--aggressive` mode.

## 📊 Cleanup Statistics

- **Files to Remove**: 45 items
- **Directories to Remove**: 20 empty directories  
- **Code to Clean**: 151 commented lines, 28 unsafe functions
- **Estimated Space Saved**: ~35 MB
- **Risk Level**: MEDIUM-HIGH (aggressive mode)

## 🗑️ Files to Remove

### Duplicate/Obsolete Directories (31 MB)
```bash
# OLD QUILLKERNEL DIRECTORY - Now integrated into kernel
rm -rf quillkernel/                    # 31 MB - VERIFY INTEGRATION FIRST!
rm -rf source/kernel/quillkernel/      # Duplicate of above
```

### Build Artifacts (2 files)
```bash
rm quillkernel/build.log
rm source/kernel/quillkernel/build.log
```

### Empty Directories (20 directories)
```bash
# Project structure directories (may be intentional placeholders)
rmdir build/config
rmdir tools/debug
rmdir releases
rmdir .claude/templates

# Firmware structure (likely needed for deployment)
rmdir firmware/boot
rmdir firmware/rootfs/lib
rmdir firmware/rootfs/usr/local/bin
rmdir firmware/rootfs/usr/local/share/vim/colors
rmdir firmware/rootfs/usr/local/share/ascii
rmdir firmware/rootfs/usr/bin
rmdir firmware/rootfs/root
rmdir firmware/rootfs/bin
rmdir firmware/rootfs/etc/init.d
rmdir firmware/kernel/modules

# Git directories (leave alone)
# .git/modules/nst-kernel-base/objects/info
# .git/modules/nst-kernel-base/branches
# .git/modules/nst-kernel-base/refs/tags
# .git/objects/info
# .git/objects/pack
# .git/branches
```

## 🔧 Code Cleanup

### Shell Scripts - Consolidation Needed

#### Menu Scripts (4 variations → 1 unified)
```bash
# MERGE THESE INTO ONE:
config/scripts/nook-menu.sh         # Main menu (keep as base)
config/scripts/nook-menu-plugin.sh  # Plugin features (merge)
config/scripts/nook-menu-zk.sh      # Zettelkasten mode (merge)  
config/scripts/squire-menu.sh       # Old menu (remove)

# Suggested: Create unified nook-menu.sh with --mode flag
```

#### Jester Scripts (3 variations → 1 unified)
```bash
# MERGE THESE:
config/scripts/jester-daemon.sh     # Main daemon (keep)
config/scripts/jester-splash.sh     # Boot splash (merge into daemon)
config/scripts/jester-mischief.sh   # Random events (merge into daemon)
```

### C Code - Security Fixes

#### Replace Unsafe Functions (28 instances)
```c
// In nst-kernel-base/src/drivers/squireos/*.c
// BEFORE:
sprintf(buffer, "format", args);
// AFTER:
snprintf(buffer, sizeof(buffer), "format", args);
```

Files needing fixes:
- `squireos_core.c`: 4 sprintf calls
- `jester.c`: 6 sprintf calls  
- `typewriter.c`: 10 sprintf calls
- `wisdom.c`: 8 sprintf calls

### Shell Scripts - Add Error Handling

32 scripts missing proper error handling:
```bash
# Add to top of each script after shebang:
set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR
```

Priority scripts to fix:
- `install_to_sdcard.sh` - Critical deployment script
- `build_kernel.sh` - Build process
- `foundation-validation.sh` - Validation script

## 📝 Comments & Dead Code

### Commented Code Blocks to Remove
- **Shell scripts**: 151 comment lines (excluding headers)
- **TODO/FIXME**: 20 instances to review

High-density comment files:
- `test_modules.sh`: 28 comment lines
- `test-improvements.sh`: 21 comment lines
- `foundation-validation.sh`: 17 comment lines

## 🏗️ Structure Improvements

### Consolidate Build Scripts
```bash
# Merge these into unified build system:
build_kernel.sh              # Top-level (remove)
quillkernel/build.sh         # Old module build (remove)
nst-kernel-base/build/build.sh  # Keep as main build script
```

### Standardize Script Locations
```bash
# Move all operational scripts to:
config/scripts/         # User-facing scripts
nst-kernel-base/build/  # Build scripts
tests/                  # Test scripts
```

## ⚡ Performance Optimizations

### Remove Redundant Operations
1. Multiple menu scripts loading same libraries
2. Duplicate jester initialization code
3. Repeated display refresh calls

### Optimize Docker Images
```dockerfile
# Combine RUN commands to reduce layers
# Use multi-stage builds for smaller images
# Remove build dependencies after compilation
```

## 🚨 Risk Assessment

### High Risk Changes ⚠️
1. **Removing quillkernel/**: Verify kernel integration complete
2. **Merging menu scripts**: May break existing workflows
3. **Aggressive comment removal**: Might lose important notes

### Medium Risk Changes ⚡
1. **Empty directory removal**: Some may be deployment placeholders
2. **Script consolidation**: Need careful testing
3. **Error handling additions**: Could expose hidden issues

### Low Risk Changes ✅
1. **Build log removal**: Safe to delete
2. **sprintf → snprintf**: Improves security
3. **Comment cleanup**: Safe with review

## 📋 Execution Commands

If this were not a dry run, here's what would execute:

```bash
#!/bin/bash
# AGGRESSIVE CLEANUP SCRIPT - DO NOT RUN WITHOUT REVIEW!

# Create backup first
echo "Creating backup..."
tar -czf nook-backup-$(date +%Y%m%d-%H%M%S).tar.gz .

# Remove duplicate directories
echo "Removing duplicate QuillKernel directory..."
rm -rf quillkernel/
rm -rf source/kernel/quillkernel/

# Remove build artifacts
echo "Cleaning build artifacts..."
rm -f quillkernel/build.log
rm -f source/kernel/quillkernel/build.log

# Remove empty directories
echo "Removing empty directories..."
find . -type d -empty -delete

# Fix unsafe C functions
echo "Fixing unsafe C functions..."
for file in nst-kernel-base/src/drivers/squireos/*.c; do
    sed -i 's/sprintf(/snprintf(/g' "$file"
done

# Add error handling to scripts
echo "Adding error handling to scripts..."
for script in $(find . -name "*.sh" -type f); do
    if ! grep -q "set -e" "$script"; then
        sed -i '2i set -euo pipefail\ntrap "echo Error at line $LINENO" ERR' "$script"
    fi
done

echo "Cleanup complete!"
```

## 📊 Summary

### Space Savings
- **Immediate**: ~35 MB from duplicate directories
- **After consolidation**: ~5 MB from merged scripts
- **Total Potential**: ~40 MB

### Code Quality Improvements
- **Security**: 28 unsafe function calls fixed
- **Reliability**: 32 scripts with error handling
- **Maintainability**: 4 menu scripts → 1, 3 jester scripts → 1

### Time Savings
- **Build time**: Faster with single build script
- **Development**: Clearer structure, less confusion
- **Maintenance**: Fewer files to update

## ✅ Recommendations

Since this is a **DRY RUN**, review this plan and:

1. **Verify** QuillKernel integration is complete before removing old directory
2. **Test** menu script consolidation in development first
3. **Review** empty directories - some may be needed for deployment
4. **Backup** everything before running aggressive cleanup
5. **Consider** running `--safe` mode first, then `--aggressive`

---

*"Dry run complete - thy cleanup plan awaits approval!"* 🧹📜