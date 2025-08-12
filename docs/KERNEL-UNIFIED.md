# Unified Kernel Architecture

## Overview

The Nook Typewriter kernel is now fully unified - QuillKernel modules are integrated directly into the Linux kernel source tree as native kernel drivers.

## Structure

```
source/kernel/nst-kernel-base/    # Git submodule
├── src/
│   └── drivers/
│       └── squireos/          # Our medieval modules (integrated)
│           ├── squireos_core.c   # Base module
│           ├── jester.c          # ASCII art jester
│           ├── typewriter.c      # Writing statistics
│           ├── wisdom.c          # Inspirational quotes
│           ├── Kconfig           # Kernel configuration
│           └── Makefile          # Build configuration
└── build/
    └── (build artifacts)
```

## Benefits

1. **Single Build Process**: One kernel build includes everything
2. **Native Integration**: Modules are part of the kernel tree
3. **Version Consistency**: No module/kernel version mismatches
4. **Simplified Development**: Standard kernel development workflow
5. **Better Performance**: Can build as built-in (CONFIG_SQUIREOS=y)

## Building

### Quick Build
```bash
# From project root
make kernel
```

### Manual Build
```bash
# From project root
./build/scripts/build-kernel.sh
```

### Configuration Options

The SquireOS modules can be configured through standard kernel configuration:

```
Device Drivers --->
  [*] SquireOS Medieval Writing Support
      [*] ASCII Jester Display
      [*] Typewriter Statistics Tracking
      [*] Writing Wisdom Quotes
      [ ] SquireOS Debug Messages
```

Or set in `.config`:
```
CONFIG_SQUIREOS=y          # Build into kernel
CONFIG_SQUIREOS_JESTER=y   # Enable jester
CONFIG_SQUIREOS_TYPEWRITER=y # Enable stats
CONFIG_SQUIREOS_WISDOM=y   # Enable quotes
```

## Runtime Usage

Once the kernel boots on the Nook:

```bash
# View the jester
cat /proc/squireos/jester

# Check writing statistics
cat /proc/squireos/typewriter/stats

# Get writing wisdom
cat /proc/squireos/wisdom

# View the motto
cat /proc/squireos/motto
```

## Development Workflow

1. **Make changes** to modules in `source/kernel/nst-kernel-base/src/drivers/squireos/`
2. **Build kernel**: `make kernel`
3. **Test in emulator** or on device
4. **Commit changes** - the kernel is a git submodule

## Git Submodule Management

The kernel is maintained as a git submodule:

```bash
# Update to latest kernel
cd source/kernel/nst-kernel-base
git pull origin master
cd ../../..
git add source/kernel/nst-kernel-base
git commit -m "Update kernel submodule"

# Make kernel changes
cd source/kernel/nst-kernel-base
# ... make changes ...
git add -A
git commit -m "Your changes"
git push origin master
cd ../../..
git add source/kernel/nst-kernel-base
git commit -m "Update kernel with changes"
```

## Migration from Separate QuillKernel

If you had the old separate QuillKernel structure:

1. The modules are now at: `source/kernel/nst-kernel-base/src/drivers/squireos/`
2. The build is unified: no separate module build needed
3. Old directory `quillkernel/` can be deleted
4. Use `make kernel` instead of separate build scripts

## Troubleshooting

### Module not loading
```bash
# Check if built into kernel
zcat /proc/config.gz | grep SQUIREOS

# If built as module, load it
modprobe squireos

# Check dmesg for errors
dmesg | grep squireos
```

### Build failures
```bash
# Clean and rebuild
cd source/kernel/nst-kernel-base/src
make ARCH=arm clean
cd ../../../..
make kernel
```

### /proc/squireos not appearing
- Ensure CONFIG_SQUIREOS=y or =m in kernel config
- Check that module is loaded (if built as module)
- Verify no errors in dmesg

## Architecture Benefits

The unified architecture provides:

- **Simpler maintenance**: One codebase, one build system
- **Better integration**: Direct kernel API access
- **Improved reliability**: No module version mismatches
- **Easier deployment**: Single kernel image contains everything
- **Standard workflow**: Uses normal kernel development practices

---

*"United in the kernel, the jester and scribe work as one"* 🏰⚔️