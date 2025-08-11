# Makefile for SquireOS kernel modules
# Builds medieval-themed kernel modules for QuillKernel

obj-m += squireos.o
squireos-objs := squireos_core.o jester.o typewriter.o wisdom.o

# Kernel source directory (will be set by build script)
KERNELDIR ?= ../../nst-kernel-base/src

# Cross-compilation settings for ARM
ARCH := arm
CROSS_COMPILE := arm-linux-androideabi-

# Android NDK path (can be overridden)
NDK_PATH ?= /opt/android-ndk
TOOLCHAIN := $(NDK_PATH)/toolchains/arm-linux-androideabi-4.7/prebuilt/linux-x86_64/bin

# Make sure we use the right compiler
export PATH := $(TOOLCHAIN):$(PATH)

# Module build flags
ccflags-y := -DMODULE -D__KERNEL__ -DLINUX
ccflags-y += -I$(KERNELDIR)/include
ccflags-y += -I$(KERNELDIR)/arch/arm/include

all: modules

modules:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) modules

clean:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean
	rm -f *.o *.ko *.mod.c *.mod.o .*.cmd

install: modules
	@echo "Installing SquireOS modules..."
	@echo "Copy squireos.ko to your Nook's /lib/modules/"

.PHONY: all modules clean install

help:
	@echo "SquireOS Kernel Modules Build System"
	@echo "====================================="
	@echo "Targets:"
	@echo "  all      - Build all modules"
	@echo "  modules  - Build kernel modules"
	@echo "  clean    - Clean build files"
	@echo "  install  - Show installation instructions"
	@echo ""
	@echo "Variables:"
	@echo "  KERNELDIR - Kernel source directory (default: ../../nst-kernel-base/src)"
	@echo "  NDK_PATH  - Android NDK path (default: /opt/android-ndk)"