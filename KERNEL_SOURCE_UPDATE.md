# Kernel Source Update - December 2024

## Summary
Updated the build system to use `catdotbashrc/nst-kernel` as the primary kernel source, replacing the potentially unreliable `felixhaedicke/nst-kernel` repository.

## Changes Made

### 1. New Kernel Source Setup Script
- **File**: `build/scripts/setup-kernel-source.sh`
- **Features**:
  - Automatically uses local kernel if available at `/home/jyeary/projects/personal/nook-kernel/nst-kernel`
  - Falls back to downloading from `catdotbashrc/nst-kernel` if no local copy exists
  - Validates kernel source integrity before use
  - Creates symlinks to save disk space when using local copy

### 2. Updated Docker Configuration
- **File**: `build/docker/kernel-xda-proven.dockerfile`
- **Changes**: Added environment variables for new kernel repository

### 3. New Configuration File
- **File**: `build/kernel-source.conf`
- **Purpose**: Centralized configuration for kernel source management
- **Settings**:
  - Primary repo: `https://github.com/catdotbashrc/nst-kernel.git`
  - Local path: `/home/jyeary/projects/personal/nook-kernel/nst-kernel`
  - Validation and caching options

### 4. Build Script Integration
- **File**: `build/scripts/build_kernel.sh`
- **Changes**: Now runs `setup-kernel-source.sh` before building

## Benefits

### Reliability
- ✅ Eliminates single point of failure (original repo going offline)
- ✅ Uses more reliable mirror maintained by `catdotbashrc`
- ✅ Supports local kernel copy for offline builds

### Performance
- ✅ Uses local kernel when available (no download needed)
- ✅ Symlinks save disk space (no duplication)
- ✅ Shallow clone (`--depth=1`) for faster downloads

### Flexibility
- ✅ Easy to switch between sources via configuration
- ✅ Automatic fallback if primary source fails
- ✅ Validates kernel source before use

## Usage

### Using Local Kernel (Fastest)
```bash
# Your local kernel at /home/jyeary/projects/personal/nook-kernel/nst-kernel
# will be used automatically if it exists
make kernel
```

### Force Download from catdotbashrc
```bash
# Remove local symlink to force fresh download
rm -rf source/kernel/src
make kernel
```

### Switch to Different Repository
```bash
# Edit build/kernel-source.conf
# Change KERNEL_REPO to desired repository
vim build/kernel-source.conf
make kernel
```

## Testing

The setup script includes validation to ensure:
- Kernel Makefile exists
- Kconfig is present
- ARM architecture support is available

Run the setup script directly to test:
```bash
./build/scripts/setup-kernel-source.sh
```

## Migration Notes

The change is backward compatible. Existing builds will continue to work, but will now:
1. First check for local kernel at the configured path
2. Use `catdotbashrc/nst-kernel` instead of `felixhaedicke/nst-kernel` for downloads
3. Validate the kernel source before building

## Troubleshooting

If kernel setup fails:
1. Check internet connection for downloads
2. Verify local kernel path exists and is valid
3. Check `build/kernel-source.conf` for correct settings
4. Review setup script output for specific errors

---

*"By quill and candlelight, we secure our kernel source!"* 🏰