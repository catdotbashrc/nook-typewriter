# 🏗️ Architecture Migration Guide

## Quick Migration Process

This guide helps migrate the project to match the 5-layer architecture. It's a simple 3-step process that takes about 5 minutes.

## Step 1: Preview Changes (30 seconds)
See what will change without making any modifications:

```bash
# See what directories will be created and files moved
./tools/migrate-to-architecture-layers.sh --dry-run
```

## Step 2: Run Migration (2 minutes)
Apply the restructuring with automatic backup:

```bash
# Creates backup and reorganizes into 5 layers
./tools/migrate-to-architecture-layers.sh
```

This will:
- ✅ Create backup in `runtime-backup-[timestamp]/`
- ✅ Create numbered layer directories (1-ui, 2-application, etc.)
- ✅ Move files to appropriate layers
- ✅ Keep configs centralized
- ✅ Preserve all functionality

## Step 3: Fix Import Paths (1 minute)
Update all script imports to match new structure:

```bash
# Preview what needs fixing
./tools/fix-architecture-paths.sh --dry-run

# Apply the fixes
./tools/fix-architecture-paths.sh
```

## Result: Clean 5-Layer Structure

```
runtime/
├── 1-ui/           # 👤 User Interface (menus, display, themes)
├── 2-application/  # 📱 Application Services (JesterOS)  
├── 3-system/       # ⚙️ System Services (common libs, display)
├── 4-kernel/       # 🐧 Kernel Interface (modules, proc, sysfs)
├── 5-hardware/     # 🔌 Hardware Control (E-Ink, USB, power)
├── configs/        # 📝 All configuration files
└── init/           # 🚀 Boot sequence scripts
```

## Benefits

1. **Self-Documenting**: Directory number = layer in architecture
2. **Clear Dependencies**: Higher layers call lower (1→2→3→4→5)
3. **Easy Navigation**: Know exactly where things belong
4. **Better Testing**: Test each layer independently

## Rollback (if needed)

If something goes wrong:

```bash
# Find your backup directory
ls -la | grep runtime-backup

# Restore from backup
rm -rf runtime
mv runtime-backup-[timestamp] runtime
```

## Testing After Migration

Quick smoke test:

```bash
# Check structure
tree -L 2 runtime/

# Test a script still works
bash runtime/1-ui/menu/nook-menu.sh --help

# Run safety check
./tests/01-safety-check.sh
```

## FAQ

**Q: Will this break my boot sequence?**
A: No, the migration updates all paths. But always test on SD card first!

**Q: What about Docker builds?**
A: The path fixer updates Dockerfile references too.

**Q: Why numbered directories?**
A: Makes the layer hierarchy instantly obvious - no documentation needed!

**Q: Is this reversible?**
A: Yes! Automatic backup is created before any changes.

---

*Total time: ~5 minutes for a much cleaner, architecture-aligned structure!*