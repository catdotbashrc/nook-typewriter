# Nook Typewriter - Embedded Linux Distribution
# Transform a $20 e-reader into a distraction-free writing device
# Medieval-themed, writer-focused, E-Ink optimized

# Version and configuration
VERSION := 1.0.0
BUILD_DATE := $(shell date +%Y%m%d)
IMAGE_NAME := nook-typewriter-$(VERSION).img

# Directory configuration with validation
KERNEL_DIR := source/kernel
JOKERNEL_DIR := source/kernel/jokernel
SCRIPTS_DIR := source/scripts
CONFIGS_DIR := source/configs
FIRMWARE_DIR := firmware
RELEASES_DIR := releases

# Build configuration
J_CORES := $(shell nproc 2>/dev/null || echo 4)
DOCKER_IMAGE := jokernel-unified

# Colors for output (E-Ink friendly)
RESET := \033[0m
BOLD := \033[1m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m

.PHONY: all clean distclean kernel rootfs firmware image release help test validate deps check-tools

help:
	@echo "$(BOLD)═══════════════════════════════════════════════════════════════$(RESET)"
	@echo "$(BOLD)           🏰 Nook Typewriter Build System 🏰$(RESET)"
	@echo "$(BOLD)═══════════════════════════════════════════════════════════════$(RESET)"
	@echo ""
	@echo "$(BOLD)Main Targets:$(RESET)"
	@echo "  $(GREEN)make firmware$(RESET)    - Build complete firmware (kernel + rootfs)"
	@echo "  $(GREEN)make kernel$(RESET)      - Build JoKernel with JokerOS modules"
	@echo "  $(GREEN)make rootfs$(RESET)      - Build root filesystem with scripts"
	@echo "  $(GREEN)make image$(RESET)       - Create bootable SD card image"
	@echo "  $(GREEN)make release$(RESET)     - Create release package with checksums"
	@echo ""
	@echo "$(BOLD)Testing & Validation:$(RESET)"
	@echo "  $(GREEN)make test$(RESET)        - Run all tests"
	@echo "  $(GREEN)make validate$(RESET)    - Validate build environment"
	@echo "  $(GREEN)make check-tools$(RESET) - Check required tools"
	@echo ""
	@echo "$(BOLD)Utility:$(RESET)"
	@echo "  $(GREEN)make clean$(RESET)       - Clean build artifacts"
	@echo "  $(GREEN)make distclean$(RESET)   - Deep clean (including Docker cache)"
	@echo "  $(GREEN)make install$(RESET)     - Flash to SD card (requires sudo)"
	@echo "  $(GREEN)make deps$(RESET)        - Show build dependencies"
	@echo ""
	@echo "$(BOLD)Configuration:$(RESET)"
	@echo "  Version: $(VERSION) | Build Date: $(BUILD_DATE)"
	@echo "  Kernel: $(KERNEL_DIR) | Scripts: $(SCRIPTS_DIR)"
	@echo "$(BOLD)═══════════════════════════════════════════════════════════════$(RESET)"

# Default target
all: validate firmware

# Complete firmware build with validation
firmware: check-tools kernel rootfs boot
	@echo "$(GREEN)$(BOLD)✅ Firmware build complete!$(RESET)"
	@echo "  Kernel: $(shell ls -lh $(FIRMWARE_DIR)/boot/uImage 2>/dev/null | awk '{print $$5}')"
	@echo "  Modules: $(shell find $(FIRMWARE_DIR)/kernel -name '*.ko' 2>/dev/null | wc -l) modules"
	@echo "  Scripts: $(shell ls $(FIRMWARE_DIR)/rootfs/usr/local/bin/*.sh 2>/dev/null | wc -l) scripts"
	@echo "$(BOLD)═══════════════════════════════════════════════════════════════$(RESET)"

# Kernel build with Docker validation
kernel: check-tools
	@echo "$(BOLD)🔨 Building JoKernel with JokerOS modules...$(RESET)"
	@if [ ! -f build_kernel.sh ]; then \
		echo "$(RED)Error: build_kernel.sh not found$(RESET)"; \
		exit 1; \
	fi
	@if ! docker images | grep -q $(DOCKER_IMAGE); then \
		echo "$(YELLOW)Building Docker image $(DOCKER_IMAGE)...$(RESET)"; \
	fi
	@./build_kernel.sh || (echo "$(RED)Kernel build failed!$(RESET)" && exit 1)
	@echo "$(GREEN)✓ Kernel build successful$(RESET)"

# Root filesystem with medieval scripts
rootfs:
	@echo "$(BOLD)📦 Building root filesystem...$(RESET)"
	@mkdir -p $(FIRMWARE_DIR)/rootfs/usr/local/bin
	@mkdir -p $(FIRMWARE_DIR)/rootfs/etc/squireos
	@# Copy scripts with validation
	@for dir in boot menu services lib; do \
		if [ -d $(SCRIPTS_DIR)/$$dir ]; then \
			echo "  Installing $$dir scripts..."; \
			cp -v $(SCRIPTS_DIR)/$$dir/*.sh $(FIRMWARE_DIR)/rootfs/usr/local/bin/ 2>/dev/null || true; \
		fi; \
	done
	@# Copy configurations
	@if [ -d $(CONFIGS_DIR) ]; then \
		cp -r $(CONFIGS_DIR)/ascii $(FIRMWARE_DIR)/rootfs/etc/jokeros/ 2>/dev/null || true; \
		cp -r $(CONFIGS_DIR)/vim $(FIRMWARE_DIR)/rootfs/etc/vim/ 2>/dev/null || true; \
	fi
	@# Set permissions
	@chmod +x $(FIRMWARE_DIR)/rootfs/usr/local/bin/*.sh 2>/dev/null || true
	@echo "$(GREEN)✓ Root filesystem prepared$(RESET)"

# Boot partition preparation
boot: kernel
	@echo "$(BOLD)🥾 Preparing boot partition...$(RESET)"
	@mkdir -p $(FIRMWARE_DIR)/boot
	@# Copy kernel image
	@if [ -f $(KERNEL_DIR)/src/arch/arm/boot/uImage ]; then \
		cp $(KERNEL_DIR)/src/arch/arm/boot/uImage $(FIRMWARE_DIR)/boot/; \
		echo "$(GREEN)   ✓ Kernel image copied$(RESET)"; \
	else \
		echo "$(YELLOW)   ⚠ Kernel image not found, skipping$(RESET)"; \
	fi
	@# Copy boot configuration
	@if [ -f boot/uEnv.txt ]; then \
		cp boot/uEnv.txt $(FIRMWARE_DIR)/boot/; \
		echo "$(GREEN)   ✓ Boot configuration copied$(RESET)"; \
	fi

# SD card image creation
image: firmware
	@echo "$(BOLD)💾 Creating SD card image: $(IMAGE_NAME)$(RESET)"
	@mkdir -p $(RELEASES_DIR)
	@if [ -f build/scripts/create-image.sh ]; then \
		./build/scripts/create-image.sh $(IMAGE_NAME) || exit 1; \
		echo "$(GREEN)✓ Image created successfully$(RESET)"; \
	else \
		echo "$(RED)Error: Image creation script not found$(RESET)"; \
		echo "Expected: build/scripts/create-image.sh"; \
		exit 1; \
	fi

# Release package with checksums and documentation
release: image
	@echo "$(BOLD)📋 Creating release $(VERSION)...$(RESET)"
	@mkdir -p $(RELEASES_DIR)
	@if [ -f $(IMAGE_NAME) ]; then \
		mv $(IMAGE_NAME) $(RELEASES_DIR)/; \
		cd $(RELEASES_DIR) && sha256sum $(IMAGE_NAME) > $(IMAGE_NAME).sha256; \
		echo "$(GREEN)✅ Release created: $(RELEASES_DIR)/$(IMAGE_NAME)$(RESET)"; \
		echo "   SHA256: $$(cat $(RELEASES_DIR)/$(IMAGE_NAME).sha256 | cut -d' ' -f1)"; \
	else \
		echo "$(RED)Error: Image file not found$(RESET)"; \
		exit 1; \
	fi
	@# Create release notes
	@echo "Nook Typewriter $(VERSION) - $(BUILD_DATE)" > $(RELEASES_DIR)/RELEASE_NOTES.txt
	@echo "Medieval-themed distraction-free writing device" >> $(RELEASES_DIR)/RELEASE_NOTES.txt

# Clean build artifacts
clean:
	@echo "$(BOLD)🧹 Cleaning build artifacts...$(RESET)"
	@# Firmware artifacts
	@rm -rf $(FIRMWARE_DIR)/kernel/*.ko
	@rm -rf $(FIRMWARE_DIR)/rootfs/usr/local/bin/*
	@rm -rf $(FIRMWARE_DIR)/boot/*
	@rm -f $(RELEASES_DIR)/*.img
	@rm -f $(RELEASES_DIR)/*.sha256
	@# Kernel build artifacts (comprehensive)
	@if [ -d $(KERNEL_DIR)/src ]; then \
		echo "  Cleaning kernel build artifacts..."; \
		cd $(KERNEL_DIR)/src && make clean ARCH=arm 2>/dev/null || true; \
		find $(KERNEL_DIR)/src -name "*.o" -type f -delete 2>/dev/null || true; \
		find $(KERNEL_DIR)/src -name "*.ko" -type f -delete 2>/dev/null || true; \
		rm -f $(KERNEL_DIR)/src/vmlinux $(KERNEL_DIR)/src/System.map 2>/dev/null || true; \
		rm -f $(KERNEL_DIR)/src/Module.symvers $(KERNEL_DIR)/src/modules.order 2>/dev/null || true; \
	fi
	@# Temporary files and build logs
	@find . -name "*.log" -type f -not -path "./.git/*" -delete 2>/dev/null || true
	@find . -name "*~" -o -name ".*.swp" -o -name ".*.swo" -type f -not -path "./.git/*" -delete 2>/dev/null || true
	@# Remove compressed artifacts (but preserve nook-mvp-rootfs.tar.gz if it exists)
	@rm -f *.tar.gz.tmp build.log kernel-build.log 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete$(RESET)"

# Deep clean including Docker cache and all artifacts
distclean: clean
	@echo "$(BOLD)🧹 Deep cleaning (including Docker)...$(RESET)"
	@# Remove Docker build cache
	@if command -v docker >/dev/null 2>&1; then \
		echo "  Cleaning Docker build cache..."; \
		docker builder prune -f 2>/dev/null || true; \
		docker system prune -f 2>/dev/null || true; \
	fi
	@# Remove all generated files
	@rm -f nook-mvp-rootfs.tar.gz 2>/dev/null || true
	@rm -rf $(FIRMWARE_DIR)/ 2>/dev/null || true
	@echo "$(GREEN)✓ Deep cleanup complete$(RESET)"

# Flash to SD card with safety checks
install: image
	@echo "$(BOLD)🎯 Ready to flash to SD card$(RESET)"
	@echo ""
	@echo "$(YELLOW)⚠️  WARNING: This will erase your SD card!$(RESET)"
	@echo ""
	@echo "To flash the image, run:"
	@echo "  $(BOLD)sudo dd if=$(RELEASES_DIR)/$(IMAGE_NAME) of=/dev/sdX bs=4M status=progress$(RESET)"
	@echo ""
	@echo "Replace /dev/sdX with your SD card device (use 'lsblk' to find it)"
	@echo "$(RED)Double-check the device to avoid data loss!$(RESET)"

# New targets for validation and testing

# Check required build tools
check-tools:
	@echo "$(BOLD)🔍 Checking build tools...$(RESET)"
	@which docker >/dev/null 2>&1 || (echo "$(RED)Error: Docker not found$(RESET)" && exit 1)
	@which bash >/dev/null 2>&1 || (echo "$(RED)Error: Bash not found$(RESET)" && exit 1)
	@echo "$(GREEN)✓ All required tools found$(RESET)"

# Validate build environment
validate: check-tools
	@echo "$(BOLD)✅ Validating build environment...$(RESET)"
	@test -d $(KERNEL_DIR) || (echo "$(RED)Error: Kernel directory not found$(RESET)" && exit 1)
	@test -d $(SCRIPTS_DIR) || (echo "$(RED)Error: Scripts directory not found$(RESET)" && exit 1)
	@test -f build_kernel.sh || (echo "$(RED)Error: build_kernel.sh not found$(RESET)" && exit 1)
	@echo "$(GREEN)✓ Environment validated$(RESET)"

# Run test suite
test:
	@echo "$(BOLD)🧪 Running test suite...$(RESET)"
	@if [ -f tests/run-all-tests.sh ]; then \
		./tests/run-all-tests.sh; \
	else \
		echo "$(YELLOW)Test suite not found$(RESET)"; \
	fi

# Show dependencies
deps:
	@echo "$(BOLD)📚 Build Dependencies:$(RESET)"
	@echo "  - Docker (for cross-compilation)"
	@echo "  - Android NDK r10e (in Docker image)"
	@echo "  - ARM cross-compiler (arm-linux-androideabi)"
	@echo "  - 4GB+ free disk space"
	@echo "  - Linux or WSL2 environment"

.DEFAULT_GOAL := help
