# SuperClaude Configuration for Nook Typewriter

This directory contains SuperClaude-specific configuration to ensure accurate analysis of the Nook Typewriter project.

## Why This Exists

The Nook Typewriter project includes the entire Linux 2.6.29 kernel source (11,773 C files) which is **not our code**. Without this configuration, SuperClaude would incorrectly:
- Report 2,986 "unsafe C functions" that are actually in the vanilla kernel
- Calculate incorrect security scores based on upstream code
- Suggest fixing kernel code we shouldn't touch
- Waste analysis time on 914MB of vendor code

## Configuration Files

### `analysis-config.yaml`
Defines what SuperClaude should and shouldn't analyze:
- **EXCLUDES**: `source/kernel/src/` (vanilla Linux kernel)
- **INCLUDES**: Our actual code in `source/scripts/`, `build/`, `tools/`, etc.
- **FOCUSES**: Security analysis on shell scripts we wrote
- **ACCEPTS**: Known risks like legacy kernel (mitigated by air-gap)

## Project Reality

### Our Code (analyze this):
```
source/scripts/     # 24 shell scripts (boot, menu, services)
source/configs/     # Configuration files
build/              # 3 Dockerfiles, build scripts
tools/              # Maintenance scripts
tests/              # 52 test scripts
docs/               # 57 documentation files
```

### NOT Our Code (skip this):
```
source/kernel/src/  # 11,773 C files from Linux 2.6.29
lenny-rootfs/       # Debian Lenny base system
```

## Correct Metrics

When properly configured, analysis should show:
- **~300 shell scripts** to analyze (not 11,773 C files)
- **Security issues in OUR scripts** (not kernel code)
- **15% shell safety compliance** (our actual problem to fix)
- **0 unsafe C functions** (we don't write C code)

## Usage

SuperClaude commands will automatically use this configuration when run from the project root:

```bash
# These commands now exclude kernel code automatically
/sc:analyze --focus security
/sc:analyze --depth deep --metrics json
/sc:improve --focus quality
```

## Accepted Risks

The following are **documented and accepted** risks that should not be "fixed":
1. Linux 2.6.29 kernel with 1,247 CVEs → Mitigated by air-gap
2. Unsafe C functions in kernel → Not our code, don't modify
3. Legacy dependencies → Required for hardware compatibility

## Philosophy

> "Analyze what we control, accept what we cannot change"

The vanilla kernel is like the foundation of an old house - we work with it, not against it. Our code (the userspace services) is where we focus our quality and security efforts.