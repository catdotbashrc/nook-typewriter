# Kernel Reference Documentation for AI Assistance

This directory contains curated Linux kernel 2.6.29 documentation optimized for AI consumption.

## Purpose
Provide AI assistants with quick, accurate reference material for kernel module development on the Nook Typewriter project, avoiding confusion with modern kernel APIs.

## Organization

### Core References (Priority 1)
- `proc-filesystem-2.6.md` - Creating /proc entries with create_proc_entry()
- `module-basics-2.6.md` - Kernel module structure and lifecycle
- `memory-management-arm.md` - ARM-specific memory constraints

### Platform Specific (Priority 2)
- `omap3-platform.md` - OMAP3621 specifics and board files
- `arm-memory-layout.md` - Memory organization on ARM Linux

### Development Tools (Priority 3)
- `kbuild-system.md` - Building modules with 2.6.29 Makefiles
- `debugging-techniques.md` - Kernel debugging without modern tools

## Version Warning
⚠️ **CRITICAL**: This documentation is for Linux kernel 2.6.29 (2009)
- Uses `create_proc_entry()` NOT `proc_create()`
- Uses board files NOT device trees
- Uses older APIs that have changed in modern kernels

## Quick Reference

### Creating a /proc entry (2.6.29 style)
```c
#include <linux/proc_fs.h>

static struct proc_dir_entry *proc_entry;

// In module init
proc_entry = create_proc_entry("squireos/jester", 0444, NULL);
if (proc_entry) {
    proc_entry->read_proc = jester_read_proc;
    proc_entry->owner = THIS_MODULE;
}

// In module exit
remove_proc_entry("squireos/jester", NULL);
```

### Memory Constraints
- Total RAM: 256MB
- Kernel + OS: Maximum 96MB
- User space (writing): 160MB reserved
- Module allocations: Use kmalloc() sparingly

## Sources
- Linux Kernel 2.6.29 source Documentation/
- LKMPG 2.6.x guide
- kernel.org historical archives
- OMAP platform documentation

## AI Usage Guidelines
1. Always check version compatibility
2. Prefer local project docs for implementation details
3. Use this for kernel API reference
4. Cross-reference with source/kernel/src/Documentation/