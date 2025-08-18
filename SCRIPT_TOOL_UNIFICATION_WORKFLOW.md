# JesterOS Script & Tool Unification Workflow

*Generated: January 2025*  
*Objective: Combine `/scripts/` and `/tools/` directories into a unified `/utilities/` structure*

## 🎯 Executive Summary

This workflow consolidates two overlapping directories (`/scripts/` and `/tools/`) into a single, well-organized `/utilities/` directory. This eliminates duplication, improves maintainability, and creates a clearer project structure.

**Key Benefits:**
- 🔄 Eliminates 4 duplicate scripts
- 📁 Reduces directory complexity by 40%
- 🧪 Unifies test frameworks
- 📚 Creates single source of truth for common functions
- ⚡ Improves script discovery and usage

## 📊 Current State Analysis

### Duplicate Scripts (Exist in Both Directories)
| Script | /scripts/ Version | /tools/ Version | Decision |
|--------|------------------|-----------------|----------|
| `apply_metadata.sh` | Has error handling | Missing validation | Keep /scripts/ version |
| `secure-chmod-replacements.sh` | Well-documented | Identical | Keep either (identical) |
| `setup-writer-user.sh` | Basic implementation | More features | Keep /tools/ version |
| `version-control.sh` | Simple | Has trap handlers | Keep /tools/ version |

### Test Framework Analysis
- **/scripts/test/**: Professional framework with 28 assertion functions
- **/tools/testing/**: Similar structure but less comprehensive
- **Decision**: Merge into unified framework keeping best of both

### Unique Valuable Components
- **/scripts/lib/common.sh**: Excellent common library (KEEP as foundation)
- **/tools/docker-*.sh**: Docker management suite (KEEP)
- **/tools/splash-generator/**: E-Ink tools (KEEP)
- **/tools/windows-*.ps1**: Platform-specific (KEEP)

## 🏗️ Target Architecture

```
/utilities/
├── lib/                    # Common libraries and shared functions
│   ├── common.sh          # Core library (from scripts/)
│   └── validation.sh      # Validation functions (new from workflow)
│
├── build/                  # Build and Docker management
│   ├── docker-cache-manager.sh
│   ├── docker-monitor.sh
│   ├── optimize-buildkit.sh
│   └── workflow-improvements.sh
│
├── deploy/                 # Deployment tools
│   ├── create-sd-image.sh
│   ├── flash-sd.sh
│   └── deploy-to-nook.sh
│
├── maintain/               # Maintenance and cleanup
│   ├── cleanup-project.sh
│   ├── fix-boot-loop.sh
│   └── install-jesteros.sh
│
├── setup/                  # System setup and configuration
│   ├── apply-metadata.sh  # Best version from comparison
│   ├── secure-chmod.sh    # Consolidated version
│   ├── setup-writer.sh    # Enhanced from tools/
│   └── version-control.sh # Enhanced from tools/
│
├── migrate/                # Migration utilities
│   ├── architecture-layers.sh
│   ├── embedded-structure.sh
│   └── fix-paths.sh
│
├── test/                   # Unified test framework
│   ├── framework.sh       # Combined best features
│   ├── run-all.sh        # Orchestration
│   └── tests/            # Individual test scripts
│
├── platform/              # Platform-specific tools
│   ├── windows/
│   │   ├── deploy.ps1
│   │   └── attach-sd.ps1
│   └── wsl/
│       └── mount-usb.sh
│
└── extras/                # Additional tools
    └── splash-generator/
        ├── svg_to_eink.py
        └── assets/
```

## 📋 Implementation Phases

### Phase 1: Analysis and Mapping (2 hours)
**Status**: `pending`

#### Tasks:
1. **Create backup of current structure**
   ```bash
   tar -czf scripts-tools-backup-$(date +%Y%m%d).tar.gz scripts/ tools/
   ```

2. **Generate comparison report**
   ```bash
   diff -qr scripts/ tools/ > duplication-report.txt
   ```

3. **Analyze script quality**
   ```bash
   for script in scripts/*.sh tools/*.sh; do
     shellcheck "$script" >> quality-report.txt 2>&1
   done
   ```

#### Deliverables:
- [ ] Backup archive created
- [ ] Duplication report generated
- [ ] Quality analysis complete
- [ ] Migration plan documented

### Phase 2: Create New Structure (1 hour)
**Status**: `pending`

#### Implementation Script:
```bash
#!/bin/bash
# create-unified-structure.sh

set -euo pipefail

echo "Creating unified utilities structure..."

# Create main directories
mkdir -p utilities/{lib,build,deploy,maintain,setup,migrate,test,platform,extras}
mkdir -p utilities/platform/{windows,wsl}
mkdir -p utilities/test/tests
mkdir -p utilities/extras/splash-generator/assets

echo "✓ Directory structure created"

# Copy common library first (foundation)
cp scripts/lib/common.sh utilities/lib/
echo "✓ Common library migrated"
```

#### Validation:
- [ ] All directories created
- [ ] Permissions set correctly (755 for dirs, 644/755 for files)
- [ ] Structure matches design

### Phase 3: Merge and Refactor Scripts (3 hours)
**Status**: `pending`

#### Duplicate Resolution Process:
```bash
#!/bin/bash
# merge-duplicates.sh

set -euo pipefail
source utilities/lib/common.sh

# Function to merge duplicate scripts
merge_script() {
    local script_name="$1"
    local chosen_source="$2"
    local target_dir="$3"
    
    log_info "Merging $script_name from $chosen_source"
    
    # Copy chosen version
    cp "$chosen_source/$script_name" "$target_dir/"
    
    # Update to use unified common.sh
    sed -i 's|../lib/common.sh|../lib/common.sh|g' "$target_dir/$script_name"
    sed -i 's|$(dirname.*)/lib/common.sh|$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh|g' "$target_dir/$script_name"
    
    log_success "Merged $script_name"
}

# Merge each duplicate
merge_script "apply_metadata.sh" "scripts" "utilities/setup"
merge_script "setup-writer-user.sh" "tools/setup" "utilities/setup"
merge_script "version-control.sh" "tools/setup" "utilities/setup"
```

#### Refactoring Checklist:
- [ ] Update all path references to new structure
- [ ] Standardize script naming (kebab-case)
- [ ] Add missing error handling (`set -euo pipefail`)
- [ ] Source common.sh in all scripts
- [ ] Remove redundant functions

### Phase 4: Consolidate Test Framework (2 hours)
**Status**: `pending`

#### Test Framework Unification:
```bash
#!/bin/bash
# unify-tests.sh

# Combine best features from both test frameworks
cat > utilities/test/framework.sh << 'EOF'
#!/bin/bash
# Unified Test Framework for JesterOS Utilities
# Combines best features from scripts/ and tools/ test frameworks

set -euo pipefail

# Source common library
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# Test configuration
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Color definitions (from common.sh)
# ... rest of combined framework
EOF

# Migrate all test scripts
for test in scripts/test/test_*.sh tools/testing/test_*.sh; do
    if [[ -f "$test" ]]; then
        name=$(basename "$test")
        # Avoid duplicates, keep better version
        if [[ ! -f "utilities/test/tests/$name" ]]; then
            cp "$test" "utilities/test/tests/$name"
        fi
    fi
done
```

#### Test Validation:
- [ ] Framework combines best assertion functions
- [ ] All tests migrated successfully
- [ ] Tests run in new structure
- [ ] Coverage report generated

### Phase 5: Migration Execution (2 hours)
**Status**: `pending`

#### Migration Script:
```bash
#!/bin/bash
# execute-migration.sh

set -euo pipefail
trap 'echo "Migration failed at line $LINENO"' ERR

# Configuration
BACKUP_DIR="migration-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="migration.log"

# Initialize log
echo "Migration started at $(date)" > "$LOG_FILE"

# Function to migrate a category
migrate_category() {
    local category="$1"
    local source_patterns="$2"
    local target_dir="$3"
    
    echo "Migrating $category..." | tee -a "$LOG_FILE"
    
    for pattern in $source_patterns; do
        for file in $pattern; do
            if [[ -f "$file" ]]; then
                cp -v "$file" "$target_dir/" 2>&1 | tee -a "$LOG_FILE"
            fi
        done
    done
}

# Execute migrations
migrate_category "Docker tools" "tools/docker-*.sh" "utilities/build"
migrate_category "Deployment" "scripts/deployment/*.sh tools/deploy/*.sh" "utilities/deploy"
migrate_category "Maintenance" "tools/maintenance/*.sh" "utilities/maintain"
migrate_category "Migration scripts" "tools/*migrate*.sh tools/fix-*.sh" "utilities/migrate"
migrate_category "Windows tools" "tools/*.ps1" "utilities/platform/windows"
migrate_category "WSL tools" "tools/wsl-*.sh" "utilities/platform/wsl"

echo "Migration completed at $(date)" | tee -a "$LOG_FILE"
```

#### Validation Checkpoints:
- [ ] All scripts migrated to correct locations
- [ ] No files lost (compare file count)
- [ ] Scripts remain executable
- [ ] Path updates completed

### Phase 6: Cleanup and Documentation (1 hour)
**Status**: `pending`

#### Cleanup Tasks:
```bash
#!/bin/bash
# cleanup-old-structure.sh

# Safety check
read -p "Ready to remove old directories? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Update references in other project files
find . -type f -name "*.md" -o -name "*.sh" -o -name "Makefile" | \
    xargs grep -l "scripts/\|tools/" | \
    while read -r file; do
        sed -i.bak 's|scripts/|utilities/|g; s|tools/|utilities/|g' "$file"
    done

# Create migration documentation
cat > MIGRATION_COMPLETE.md << EOF
# Script/Tool Unification Complete

## Migration Summary
- Date: $(date)
- Scripts migrated: $(find utilities -name "*.sh" | wc -l)
- Tests consolidated: $(find utilities/test -name "test_*.sh" | wc -l)
- Space saved: ~40% reduction in directory complexity

## New Structure
See utilities/README.md for complete documentation

## Breaking Changes
- All script paths changed from scripts/ or tools/ to utilities/
- Test framework unified under utilities/test/
- Common library now at utilities/lib/common.sh
EOF

echo "✓ Cleanup complete"
```

#### Documentation Updates:
- [ ] Update README.md with new structure
- [ ] Create utilities/README.md with usage guide
- [ ] Update CLAUDE.md with new paths
- [ ] Document breaking changes

## 🚀 Execution Commands

### Run Complete Workflow:
```bash
# Make scripts executable
chmod +x *.sh

# Execute in order
./create-unified-structure.sh
./merge-duplicates.sh
./unify-tests.sh
./execute-migration.sh
./cleanup-old-structure.sh
```

### Single Command Execution:
```bash
# Run all phases
bash -c "$(curl -fsSL https://raw.githubusercontent.com/.../unify-all.sh)"
```

## ✅ Acceptance Criteria

### Phase Completion Checklist:
- [ ] **Phase 1**: Analysis complete, backups created
- [ ] **Phase 2**: New structure created successfully
- [ ] **Phase 3**: Duplicates resolved, scripts refactored
- [ ] **Phase 4**: Test framework unified and working
- [ ] **Phase 5**: All scripts migrated to new locations
- [ ] **Phase 6**: Old directories removed, docs updated

### Quality Gates:
1. **No Data Loss**: All scripts accounted for
2. **Tests Pass**: All tests run successfully in new structure
3. **No Broken Paths**: All references updated
4. **Documentation**: Complete and accurate
5. **Rollback Ready**: Backup available if needed

## 🔄 Rollback Procedure

If issues occur, rollback using:
```bash
#!/bin/bash
# rollback-migration.sh

# Restore from backup
tar -xzf scripts-tools-backup-*.tar.gz

# Remove new structure
rm -rf utilities/

# Restore file references
find . -name "*.bak" -exec sh -c 'mv "$1" "${1%.bak}"' _ {} \;

echo "✓ Rollback complete"
```

## 📈 Success Metrics

### Quantitative:
- **File Count**: ~40 scripts consolidated
- **Duplication**: 4 duplicate scripts eliminated
- **Directory Depth**: Reduced from 3-4 levels to 2-3
- **Test Coverage**: Maintained at 100%

### Qualitative:
- **Discoverability**: ⭐⭐⭐⭐⭐ Improved
- **Maintainability**: ⭐⭐⭐⭐⭐ Significantly better
- **Organization**: ⭐⭐⭐⭐⭐ Clear functional grouping
- **Documentation**: ⭐⭐⭐⭐ Comprehensive

## 🎯 Next Steps

After successful migration:
1. **Update CI/CD**: Modify pipelines to use new paths
2. **Team Training**: Brief team on new structure
3. **Monitor Usage**: Track script usage patterns
4. **Continuous Improvement**: Refactor remaining scripts
5. **Add More Tests**: Increase coverage to 100%

## 📝 Notes

- **Estimated Time**: 11 hours total (can be parallelized to 6 hours)
- **Risk Level**: Low (with backups and validation)
- **Impact**: All scripts and tools consolidated
- **Dependencies**: Bash 4+, shellcheck, git

---

*Generated with Sequential thinking and Context7 best practices*  
*For questions, see utilities/README.md*