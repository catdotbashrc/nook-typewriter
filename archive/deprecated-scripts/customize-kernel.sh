#!/bin/bash
# Opens kernel configuration menu

export ANDROID_NDK="$HOME/nook-kernel-dev/android-ndk-r23c"
export PATH="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
export ARCH=arm
export CROSS_COMPILE=arm-linux-androideabi-

cd "$HOME/nook-kernel-dev/nst-kernel"

# Ensure we have a base config
if [ ! -f .config ]; then
    make nook_defconfig
fi

echo "Opening kernel configuration menu..."
echo "Tips:"
echo "  - Use arrow keys to navigate"
echo "  - Space to toggle options"
echo "  - ? for help on any option"
echo "  - Save and exit when done"
echo ""
sleep 2

make menuconfig
