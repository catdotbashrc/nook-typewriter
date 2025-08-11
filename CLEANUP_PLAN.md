# 🧹 Nook Typewriter Project Cleanup Plan

## Executive Summary
Safe cleanup plan to remove redundancy and improve project organization while preserving all functionality.

## 🔍 Analysis Results

### Current State
- **Total Project Size**: ~200MB (excluding kernel source)
- **Deprecated Scripts**: 6 scripts already moved to archive
- **Empty Files**: 1 (advanced-kernel-setup.md)
- **Temporary Files**: 1 (debian-build.log)
- **Missing Docker Files**: nookwriter.dockerfile and docker-compose.yml referenced but deleted
- **Documentation**: Well organized, minimal duplication

### ✅ Safe to Remove

#### 1. Empty Documentation File
- `docs/how-to/advanced-kernel-setup.md` - Empty file, no content
- **Risk**: None
- **Action**: Delete

#### 2. Build Log
- `debian-build.log` - Old build output
- **Risk**: None (can regenerate)
- **Action**: Delete or move to .gitignore

#### 3. Already Archived Scripts
- Scripts in `/archive/deprecated-scripts/` are documented as deprecated
- **Risk**: None (already archived)
- **Action**: Keep archived for reference

### ⚠️ Review Before Cleanup

#### 1. Duplicate Menu Scripts
- `config/scripts/nook-menu.sh` - Original menu
- `config/scripts/nook-menu-zk.sh` - Enhanced with zk
- `config/scripts/squire-menu.sh` - Medieval themed
- **Analysis**: Each serves different purpose
- **Recommendation**: Keep all, document differences in README

#### 2. Multiple Vim Configurations
- `config/vimrc` - Standard config
- `config/vimrc-minimal` - 2MB RAM
- `config/vimrc-writer` - 5MB RAM
- `config/vimrc-zk` - Zettelkasten
- **Analysis**: Each optimized for different use cases
- **Recommendation**: Keep all, they support the multi-mode strategy

### 🚫 Do NOT Remove

#### Critical Files
1. **Docker Configurations** - Both optimized versions are actively used
2. **Kernel Source** - Even if large, needed for builds
3. **Test Scripts** - Essential for validation
4. **Boot Configuration** - Critical for device operation

### 📋 Cleanup Actions (Safe Mode)

```bash
# 1. Remove empty documentation file
rm docs/how-to/advanced-kernel-setup.md

# 2. Remove or gitignore build log
rm debian-build.log
# OR add to .gitignore:
echo "*.log" >> .gitignore

# 3. Clean any vim swap files (if present)
find . -name "*.swp" -delete
find . -name "*~" -delete

# 4. Update .gitignore for common temporary files
cat >> .gitignore << 'EOF'
# Build artifacts
*.log
*.tmp
*.swp
*~
.DS_Store

# Docker artifacts  
*.tar.gz
nook-export/

# Vim temporary files
*.vim~
.*.sw?
EOF
```

### 🔄 Reorganization Suggestions

#### 1. Scripts Organization
```
scripts/
├── build/          # Build-related scripts
├── deploy/         # Deployment and verification
└── deprecated/     # Move archive here
```

#### 2. Configuration Consolidation
```
config/
├── vim/            # All vim configs together
│   ├── minimal.vim
│   ├── writer.vim
│   └── zk.vim
├── menus/          # All menu scripts
│   ├── standard.sh
│   ├── zk.sh
│   └── medieval.sh
└── system/         # System configs (current)
```

### 📊 Impact Assessment

#### Space Savings
- Empty file removal: ~0KB (negligible)
- Log file removal: ~1-5MB
- Total savings: < 5MB

#### Risk Assessment
- **Risk Level**: LOW
- **Functionality Impact**: None
- **Rollback Strategy**: Git history preserves everything

### 🎯 Recommended Execution Order

1. **Phase 1 - Immediate (No Risk)**
   - Remove empty `advanced-kernel-setup.md`
   - Remove/gitignore `debian-build.log`
   - Update `.gitignore`

2. **Phase 2 - Optional (Low Risk)**
   - Reorganize scripts into subdirectories
   - Consolidate vim configs into vim/ subdirectory

3. **Phase 3 - Documentation**
   - Update PROJECT_INDEX.md with new structure
   - Add clear descriptions for each menu variant

### ⚠️ Important Notes

1. **Git Safety**: All changes tracked in git, easy rollback
2. **No Functional Changes**: Only removing truly unused files
3. **Preserve Variants**: Multiple versions serve different RAM profiles
4. **Archive Value**: Deprecated scripts show project evolution

### 🚀 Execution Commands

For safe cleanup, run:
```bash
# Navigate to project root
cd /home/jyeary/projects/personal/nook

# Phase 1: Safe cleanup
rm -f docs/how-to/advanced-kernel-setup.md
rm -f debian-build.log

# Update gitignore
echo -e "\n# Temporary files\n*.log\n*.swp\n*~\n.DS_Store" >> .gitignore

# Verify changes
git status

# Commit if satisfied
git add -A
git commit -m "chore: Clean up empty files and update .gitignore

- Remove empty advanced-kernel-setup.md
- Remove old build log
- Update .gitignore for common temporary files"
```

## Summary

The project is already well-organized with minimal redundancy. The main cleanup opportunities are:
- Removing one empty file
- Removing/ignoring build logs
- Updating .gitignore for better hygiene

The multiple Docker configs, vim configs, and menu scripts should be **preserved** as they serve the important goal of supporting different RAM profiles and user preferences.