# SquireOS Medieval Writing System for Nook

## Package Contents

- `boot/uImage` - QuillKernel with SquireOS support
- `lib/modules/` - SquireOS kernel modules
- `etc/init.d/` - Boot scripts for automatic loading
- `usr/local/bin/` - Module loading utilities
- `install.sh` - Automated installation script

## Installation

1. Copy this package to your Nook device
2. Extract the package: `tar -xzf squireos-nook-*.tar.gz`
3. Run the installer: `sudo ./install.sh`

## Manual Module Loading

If modules don't load at boot:
```bash
/usr/local/bin/load-squireos-modules.sh
```

## Accessing SquireOS Features

Once loaded, access the medieval writing features:

- View the jester: `cat /proc/squireos/jester`
- Check writing stats: `cat /proc/squireos/typewriter/stats`
- Get wisdom: `cat /proc/squireos/wisdom`
- See version: `cat /proc/squireos/version`

## Troubleshooting

If modules fail to load:
1. Check kernel version: `uname -r` (should be 2.6.29)
2. Verify module files exist: `ls /lib/modules/2.6.29/`
3. Check kernel log: `dmesg | grep squireos`

## Medieval Philosophy

"By quill and candlelight, we write eternal words"

The SquireOS system transforms your Nook into a distraction-free
writing sanctuary with a medieval theme to inspire your creativity.

May your words flow like ink from a well-seasoned quill!
