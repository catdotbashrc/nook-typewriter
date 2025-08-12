# Nook Typewriter - Embedded Linux Distribution
# Transform a $20 e-reader into a distraction-free writing device

VERSION := 1.0.0
IMAGE_NAME := nook-typewriter-$(VERSION).img
KERNEL_DIR := source/kernel/nst-kernel-base
QUILL_DIR := source/kernel/quillkernel

.PHONY: all clean kernel rootfs firmware image release help

help:
	@echo "Nook Typewriter Build System"
	@echo "============================"
	@echo "  make firmware    - Build complete firmware"
	@echo "  make kernel      - Build kernel with QuillKernel"
	@echo "  make rootfs      - Build root filesystem"
	@echo "  make image       - Create SD card image"
	@echo "  make release     - Create release package"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make install     - Flash to SD card (requires sudo)"

all: firmware

firmware: kernel rootfs boot
	@echo "✅ Firmware ready in firmware/"
	@ls -la firmware/kernel/ 2>/dev/null || true
	@ls -la firmware/rootfs/usr/local/bin/ 2>/dev/null || true

kernel:
	@echo "🔨 Building kernel with integrated QuillKernel..."
	@if [ -f build/scripts/build-kernel.sh ]; then \
		./build/scripts/build-kernel.sh; \
	else \
		echo "⚠️  Kernel build script not found"; \
		echo "   Run: ./scripts/setup-build-env.sh"; \
	fi

rootfs:
	@echo "📦 Building root filesystem..."
	@mkdir -p firmware/rootfs/usr/local/bin
	@# Copy scripts from source to firmware
	@for dir in boot menu services lib; do \
		if [ -d source/scripts/$$dir ]; then \
			cp -v source/scripts/$$dir/*.sh firmware/rootfs/usr/local/bin/ 2>/dev/null || true; \
		fi; \
	done
	@chmod +x firmware/rootfs/usr/local/bin/*.sh 2>/dev/null || true

boot: kernel
	@echo "🥾 Preparing boot partition..."
	@mkdir -p firmware/boot
	@if [ -f $(KERNEL_DIR)/src/arch/arm/boot/uImage ]; then \
		cp $(KERNEL_DIR)/src/arch/arm/boot/uImage firmware/boot/; \
		echo "   ✓ Kernel image copied"; \
	fi

image: firmware
	@echo "💾 Creating SD card image: $(IMAGE_NAME)"
	@if [ -f build/scripts/create-image.sh ]; then \
		./build/scripts/create-image.sh $(IMAGE_NAME); \
	else \
		echo "⚠️  Image creation script not found"; \
	fi

release: image
	@echo "📋 Creating release $(VERSION)..."
	@mkdir -p releases
	@if [ -f $(IMAGE_NAME) ]; then \
		mv $(IMAGE_NAME) releases/; \
		cd releases && sha256sum $(IMAGE_NAME) > $(IMAGE_NAME).sha256; \
		echo "✅ Release created: releases/$(IMAGE_NAME)"; \
	fi

clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf firmware/kernel/*.ko
	rm -rf firmware/rootfs/usr/local/bin/*
	rm -rf firmware/boot/*
	rm -f releases/*.img

install: image
	@echo "🎯 Ready to flash to SD card"
	@echo "Run: sudo dd if=releases/$(IMAGE_NAME) of=/dev/sdX bs=4M status=progress"
	@echo "Replace /dev/sdX with your SD card device"

.DEFAULT_GOAL := help
