# Nook Typewriter - Embedded Linux Distribution
# Transform a $20 e-reader into a distraction-free writing device
# Medieval-themed, writer-focused, E-Ink optimized

# Version and configuration
VERSION := 1.0.0
BUILD_DATE := $(shell date +%Y%m%d)
IMAGE_NAME := nook-typewriter-$(VERSION).img

# Directory configuration with validation
KERNEL_DIR := platform/nook-touch/kernel
SCRIPTS_DIR := scripts
DOCKER_DIR := docker
FIRMWARE_DIR := firmware
BUILD_DIR := build
BUILD_ROOTFS_DIR := $(BUILD_DIR)/rootfs
BUILD_IMAGES_DIR := $(BUILD_DIR)/images
TESTS_DIR := tests
RELEASES_DIR := releases

# Build configuration
J_CORES := $(shell nproc 2>/dev/null || echo 4)
DOCKER_IMAGE_LENNY := jesteros-lenny
DOCKER_IMAGE_PRODUCTION := jesteros-production
DOCKER_IMAGE_KERNEL := kernel-xda-proven
DOCKER_KERNEL_IMAGE := kernel-xda-proven
BASE_IMAGE ?= images/2gb_clockwork-rc2.img
SD_DEVICE ?= auto
BUILD_LOG := $(BUILD_DIR)/logs/build.log
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)

# Phoenix Project validated configurations
FIRMWARE_VERSION := 1.2.2  # Most stable per XDA community
BATTERY_DRAIN_TARGET := 1.5  # % per day idle target
SD_CARD_BRAND := SanDisk  # Proven reliable per Phoenix Project
SD_CARD_CLASS := 10  # Required for reliable boot
CWM_IMAGE_SIZE := 128MB  # Smaller CWM for installation

# Enable BuildKit by default for all Docker builds
export DOCKER_BUILDKIT=1
# Alternative: use docker buildx if available (with --load flag for local use)
DOCKER_BUILD_CMD := $(shell if docker buildx version >/dev/null 2>&1; then echo "docker buildx build --load"; else echo "docker build"; fi)

# Colors for output (E-Ink friendly)
RESET := \033[0m
BOLD := \033[1m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m

.PHONY: all clean distclean kernel rootfs firmware image release help test validate deps check-tools
.PHONY: quick-build quick-deploy sd-deploy detect-sd build-status bootloader-status
.PHONY: test-pre-build test-post-build test-runtime test-legacy docker-build docker-lenny docker-kernel
.PHONY: test-init test-report test-parallel test-safety test-quick test-writing test-experience
.PHONY: test-docker test-consistency test-memory test-coverage test-clean lenny-rootfs
.PHONY: docker-production docker-test docker-test-bullseye docker-test-gk61 docker-test-all
.PHONY: docker-base-all docker-base-lenny docker-base-dev docker-base-runtime docker-cache-info docker-cache-clean

help:
	@echo "$(BOLD)═══════════════════════════════════════════════════════════════$(RESET)"
	@echo "$(BOLD)           🏰 Nook Typewriter Build System 🏰$(RESET)"
	@echo "$(BOLD)═══════════════════════════════════════════════════════════════$(RESET)"
	@echo ""
	@echo "$(BOLD)Quick Start:$(RESET)"
	@echo "  $(GREEN)make quick-build$(RESET) - Fast build (kernel only if unchanged)"
	@echo "  $(GREEN)make sd-deploy$(RESET)   - Build and deploy to SD card (auto-detect)"
	@echo "  $(GREEN)make sd-deploy SD_DEVICE=/dev/sde$(RESET) - Deploy to specific device"
	@echo ""
	@echo "$(BOLD)Main Targets:$(RESET)"
	@echo "  $(GREEN)make firmware$(RESET)    - Build complete firmware (kernel + rootfs)"
	@echo "  $(GREEN)make kernel$(RESET)      - Build kernel (JesterOS now in userspace)"
	@echo "  $(GREEN)make rootfs$(RESET)      - Build root filesystem with scripts"
	@echo "  $(GREEN)make lenny-rootfs$(RESET)- Build Debian Lenny rootfs for Nook"
	@echo "  $(GREEN)make image$(RESET)       - Create bootable SD card image"
	@echo "  $(GREEN)make release$(RESET)     - Create release package with checksums"
	@echo "  $(GREEN)make installer$(RESET)  - Create CWM-compatible installer (Phoenix-style)"
	@echo "  $(GREEN)make battery-check$(RESET) - Check battery optimization settings"
	@echo ""
	@echo "$(BOLD)Testing & Validation:$(RESET)"
	@echo "  $(GREEN)make test$(RESET)        - Run complete test pipeline (all stages)"
	@echo "  $(GREEN)make test-quick$(RESET)  - Run show stoppers only (must pass)"
	@echo "  $(GREEN)make test-safety$(RESET) - Run critical safety check only"
	@echo "  $(GREEN)make test-parallel$(RESET) - Run tests in parallel (experimental)"
	@echo "  $(GREEN)make test-report$(RESET) - Show test results summary"
	@echo "  $(GREEN)make test-coverage$(RESET) - Check test coverage"
	@echo "  $(GREEN)make test-clean$(RESET)  - Clean test results"
	@echo ""
	@echo "  Test Stages:"
	@echo "  $(GREEN)make test-pre-build$(RESET) - Test build tools (before Docker)"
	@echo "  $(GREEN)make test-post-build$(RESET) - Test Docker output (after build)"
	@echo "  $(GREEN)make test-runtime$(RESET) - Test execution in container"
	@echo ""
	@echo "  $(GREEN)make validate$(RESET)    - Validate build environment"
	@echo "  $(GREEN)make check-tools$(RESET) - Check required tools"
	@echo "  $(GREEN)make detect-sd$(RESET)   - Detect SD card devices"
	@echo ""
	@echo "$(BOLD)Utility:$(RESET)"
	@echo "  $(GREEN)make clean$(RESET)       - Clean build artifacts"
	@echo "  $(GREEN)make distclean$(RESET)   - Deep clean (including Docker cache)"
	@echo "  $(GREEN)make build-status$(RESET)- Show build status and logs"
	@echo "  $(GREEN)make deps$(RESET)        - Show build dependencies"
	@echo ""
	@echo "$(BOLD)Configuration:$(RESET)"
	@echo "  Version: $(VERSION) | Build Date: $(BUILD_DATE)"
	@echo "  Kernel: $(KERNEL_DIR) | Scripts: $(SCRIPTS_DIR)"
	@echo "$(BOLD)═══════════════════════════════════════════════════════════════$(RESET)"

# Default target
all: validate firmware

# Complete firmware build with validation
firmware: check-tools kernel rootfs boot ramdisk
	@echo "$(GREEN)$(BOLD)✅ Firmware build complete!$(RESET)"
	@echo "  Kernel: $(shell ls -lh $(FIRMWARE_DIR)/boot/uImage 2>/dev/null | awk '{print $$5}')"
	@echo "  MLO: $(shell ls -lh $(FIRMWARE_DIR)/boot/MLO 2>/dev/null | awk '{print $$5}')"
	@echo "  U-Boot: $(shell ls -lh $(FIRMWARE_DIR)/boot/u-boot.bin 2>/dev/null | awk '{print $$5}')"
	@echo "  Modules: $(shell find $(FIRMWARE_DIR)/kernel -name '*.ko' 2>/dev/null | wc -l) modules"
	@echo "  Scripts: $(shell ls $(FIRMWARE_DIR)/rootfs/usr/local/bin/*.sh 2>/dev/null | wc -l) scripts"
	@echo "$(BOLD)═══════════════════════════════════════════════════════════════$(RESET)"

# Docker build targets - Production
docker-build: docker-lenny docker-production docker-kernel
	@echo "$(GREEN)✓ All production Docker images built$(RESET)"

# Build Debian Lenny base image
docker-lenny:
	@echo "$(BOLD)🏛️ Building Debian Lenny base image...$(RESET)"
	@if ! docker images | grep -q "debian.*lenny"; then \
		echo "  Building base Debian Lenny 5.0..."; \
		$(DOCKER_BUILD_CMD) -t debian:lenny -f build/docker/vanilla-debian-lenny.dockerfile .; \
	else \
		echo "  $(GREEN)✓ Debian Lenny base already exists$(RESET)"; \
	fi

# Build unified Lenny base images (Phase 3 optimization)
docker-base-all: docker-base-lenny docker-base-dev docker-base-runtime
	@echo "$(GREEN)✓ All unified base images built$(RESET)"

# Build minimal Lenny base
docker-base-lenny:
	@echo "$(BOLD)🏛️ Building unified Lenny base...$(RESET)"
	@$(DOCKER_BUILD_CMD) --target lenny-base -t jesteros:lenny-base -f build/docker/jesteros-lenny-base.dockerfile .
	@echo "$(GREEN)✓ Unified Lenny base ready$(RESET)"

# Build development base (extends lenny-base)
docker-base-dev: docker-base-lenny
	@echo "$(BOLD)🔧 Building development base...$(RESET)"
	@$(DOCKER_BUILD_CMD) --target dev-base -t jesteros:dev-base -f build/docker/jesteros-lenny-base.dockerfile .
	@echo "$(GREEN)✓ Development base ready$(RESET)"

# Build runtime base (minimal for production)
docker-base-runtime: docker-base-lenny
	@echo "$(BOLD)📦 Building runtime base...$(RESET)"
	@$(DOCKER_BUILD_CMD) --target runtime-base -t jesteros:runtime-base -f build/docker/jesteros-lenny-base.dockerfile .
	@echo "$(GREEN)✓ Runtime base ready$(RESET)"

# Build JesterOS production image (now uses unified base)
docker-production:
	@echo "$(BOLD)🏰 Building JesterOS production image...$(RESET)"
	@# First ensure we have the Lenny base rootfs
	@if [ ! -f lenny-rootfs.tar.gz ]; then \
		cp .archives/rootfs/lenny-rootfs.tar.gz . 2>/dev/null || \
		echo "$(YELLOW)Warning: lenny-rootfs.tar.gz not found$(RESET)"; \
	fi
	@$(DOCKER_BUILD_CMD) -t $(DOCKER_IMAGE_PRODUCTION) -f build/docker/jesteros-production.dockerfile .
	@echo "$(GREEN)✓ JesterOS production image ready$(RESET)"

# Build kernel compilation environment (now with BuildKit)
docker-kernel:
	@echo "$(BOLD)🔧 Building kernel build environment...$(RESET)"
	@$(DOCKER_BUILD_CMD) -t $(DOCKER_KERNEL_IMAGE)-optimized -f build/docker/kernel-xda-proven-optimized.dockerfile .
	@echo "$(GREEN)✓ Kernel build environment ready (with BuildKit cache)$(RESET)"

# Docker build targets - Testing
docker-test: docker-production
	@echo "$(BOLD)🧪 Building JesterOS test image...$(RESET)"
	@docker build -t jesteros-test -f build/docker/test/jesteros-test.dockerfile .
	@echo "$(GREEN)✓ JesterOS test image ready$(RESET)"

docker-test-bullseye:
	@echo "$(BOLD)🧪 Building Bullseye test image...$(RESET)"
	@docker build -t jesteros-bullseye-test -f build/docker/test/production-bullseye.dockerfile .
	@echo "$(GREEN)✓ Bullseye test image ready$(RESET)"

docker-test-gk61:
	@echo "$(BOLD)⌨️ Building GK61 keyboard test image...$(RESET)"
	@docker build -t gk61-test -f build/docker/test/gk61-keyboard.dockerfile .
	@echo "$(GREEN)✓ GK61 test image ready$(RESET)"

# Build all test images
docker-test-all: docker-test docker-test-bullseye docker-test-gk61
	@echo "$(GREEN)✓ All test images built$(RESET)"

# Docker cache management (Phase 3 optimization)
docker-cache-info:
	@echo "$(BOLD)📊 Docker BuildKit Cache Information$(RESET)"
	@echo "═══════════════════════════════════════════"
	@docker system df -v 2>/dev/null | grep -A5 "Build Cache" || docker system df
	@echo ""
	@echo "$(BOLD)Shared base images:$(RESET)"
	@docker images | grep "jesteros.*base" || echo "  No unified base images built yet"
	@echo ""
	@echo "$(BOLD)To build all optimized images:$(RESET)"
	@echo "  $(GREEN)make docker-base-all$(RESET) - Build unified base images"
	@echo "  $(GREEN)make docker-build$(RESET)    - Build production images"

docker-cache-clean:
	@echo "$(BOLD)🧹 Cleaning Docker BuildKit cache...$(RESET)"
	@docker builder prune -f
	@echo "$(GREEN)✓ BuildKit cache cleaned$(RESET)"

# Kernel build with Docker validation and logging
kernel: check-tools
	@echo "$(BOLD)🔨 Building kernel (JesterOS services in userspace)...$(RESET)"
	@echo "  Using kernel source: catdotbashrc/nst-kernel (reliable mirror)"
	@echo "[$(TIMESTAMP)] Starting kernel build" >> $(BUILD_LOG)
	@if [ ! -f build/scripts/build_kernel.sh ]; then \
		echo "$(RED)Error: build/scripts/build_kernel.sh not found$(RESET)"; \
		echo "[$(TIMESTAMP)] ERROR: build/scripts/build_kernel.sh not found" >> $(BUILD_LOG); \
		exit 1; \
	fi
	@if ! docker images | grep -q $(DOCKER_IMAGE_KERNEL); then \
		echo "$(YELLOW)Building Docker image $(DOCKER_IMAGE_KERNEL)...$(RESET)"; \
		echo "[$(TIMESTAMP)] Building Docker image" >> $(BUILD_LOG); \
		$(MAKE) docker-kernel; \
	fi
	@J_CORES=$(J_CORES) ./build/scripts/build_kernel.sh 2>&1 | tee -a $(BUILD_LOG) || (echo "$(RED)Kernel build failed!$(RESET)" && exit 1)
	@echo "[$(TIMESTAMP)] Kernel build successful" >> $(BUILD_LOG)
	@echo "$(GREEN)✓ Kernel build successful$(RESET)"

# Create Lenny-based rootfs for deployment
lenny-rootfs: docker-production
	@echo "$(BOLD)📦 Creating Debian Lenny rootfs for Nook...$(RESET)"
	@docker create --name jesteros-export $(DOCKER_IMAGE_PRODUCTION)
	@# Export and clean Docker contamination in one pipeline
	@docker export jesteros-export | tar --delete .dockerenv 2>/dev/null | gzip > jesteros-production-rootfs-$(BUILD_DATE).tar.gz || \
		(docker export jesteros-export | gzip > jesteros-production-rootfs-$(BUILD_DATE).tar.gz)
	@docker rm jesteros-export
	@echo "$(GREEN)✓ Created jesteros-production-rootfs-$(BUILD_DATE).tar.gz$(RESET)"
	@echo "$(GREEN)✓ Removed Docker contamination markers$(RESET)"
	@ls -lh jesteros-production-rootfs-*.tar.gz

# Root filesystem with JesterOS 4-layer architecture
rootfs:
	@echo "$(BOLD)📦 Building root filesystem with JesterOS services...$(RESET)"
	@mkdir -p $(FIRMWARE_DIR)/rootfs/usr/local/bin
	@mkdir -p $(FIRMWARE_DIR)/rootfs/etc/jesteros
	@mkdir -p $(FIRMWARE_DIR)/rootfs/var/jesteros
	@mkdir -p $(FIRMWARE_DIR)/rootfs/var/run/jesteros
	@mkdir -p $(FIRMWARE_DIR)/rootfs/var/lib/jester
	@# Copy 4-layer architecture scripts
	@echo "  Installing JesterOS 4-layer scripts..."
	@find $(SCRIPTS_DIR) -name "*.sh" -type f | while read script; do \
		relative_path=$$(echo "$$script" | sed 's|$(SCRIPTS_DIR)/||'); \
		echo "    Installing: $$relative_path"; \
		cp "$$script" $(FIRMWARE_DIR)/rootfs/usr/local/bin/; \
	done
	@# Copy JesterOS init scripts
	@if [ -d $(SCRIPTS_DIR)/init ]; then \
		echo "  Installing init scripts..."; \
		cp $(SCRIPTS_DIR)/init/*.sh $(FIRMWARE_DIR)/rootfs/usr/local/bin/ 2>/dev/null || true; \
	fi
	@# Copy configurations
	@if [ -d $(CONFIGS_DIR) ]; then \
		echo "  Installing configurations..."; \
		mkdir -p $(FIRMWARE_DIR)/rootfs/etc/jesteros/ascii/jester; \
		cp src/1-ui/themes/jester/*.txt $(FIRMWARE_DIR)/rootfs/etc/jesteros/ascii/jester/ 2>/dev/null || true; \
		cp src/1-ui/themes/ascii-art-library.txt $(FIRMWARE_DIR)/rootfs/etc/jesteros/ascii/ 2>/dev/null || true; \
		cp -r $(CONFIGS_DIR)/vim $(FIRMWARE_DIR)/rootfs/etc/vim/ 2>/dev/null || true; \
		cp -r $(CONFIGS_DIR)/system $(FIRMWARE_DIR)/rootfs/etc/jesteros/ 2>/dev/null || true; \
	fi
	@# Set permissions
	@chmod +x $(FIRMWARE_DIR)/rootfs/usr/local/bin/*.sh 2>/dev/null || true
	@# Create JesterOS service symlinks for /var/jesteros interface
	@echo "  Setting up JesterOS userspace interface..."
	@ln -sf /usr/local/bin/daemon.sh $(FIRMWARE_DIR)/rootfs/var/jesteros/jester 2>/dev/null || true
	@mkdir -p $(FIRMWARE_DIR)/rootfs/var/jesteros/typewriter
	@echo "0" > $(FIRMWARE_DIR)/rootfs/var/jesteros/typewriter/stats
	@echo "$(GREEN)✓ Root filesystem prepared with JesterOS services$(RESET)"

# Bootloader extraction from ClockworkMod image
# IMPORTANT: MLO and u-boot.bin are preserved during 'make clean'
# These files are critical for boot and should only be removed with 'make distclean'
bootloaders:
	@mkdir -p $(FIRMWARE_DIR)/boot
	@echo "$(BOLD)🔧 Checking bootloader files...$(RESET)"
	@if [ ! -f $(FIRMWARE_DIR)/boot/MLO ] || [ ! -f $(FIRMWARE_DIR)/boot/u-boot.bin ]; then \
		echo "$(YELLOW)   ⚠ Bootloaders missing - attempting extraction$(RESET)"; \
		if [ -f build/scripts/extract-bootloaders-dd.sh ]; then \
			./build/scripts/extract-bootloaders-dd.sh; \
		elif [ -f build/scripts/extract-bootloaders.sh ]; then \
			echo "   Note: This requires sudo for mounting"; \
			./build/scripts/extract-bootloaders.sh || true; \
		else \
			echo "$(RED)   ✗ No extraction scripts found!$(RESET)"; \
			exit 1; \
		fi; \
		if [ ! -f $(FIRMWARE_DIR)/boot/MLO ] || [ ! -f $(FIRMWARE_DIR)/boot/u-boot.bin ]; then \
			echo "$(YELLOW)   ⚠ Automatic extraction failed$(RESET)"; \
			echo "   Please extract manually:"; \
			echo "   1. Run: sudo ./build/scripts/extract-bootloaders.sh"; \
			echo "   2. Or follow instructions from extract-bootloaders-dd.sh"; \
			exit 1; \
		fi; \
	else \
		echo "$(GREEN)   ✓ Bootloaders present$(RESET)"; \
		ls -lh $(FIRMWARE_DIR)/boot/MLO $(FIRMWARE_DIR)/boot/u-boot.bin; \
	fi

# Boot script generation
boot-script:
	@mkdir -p $(FIRMWARE_DIR)/boot
	@echo "$(BOLD)📝 Creating boot script...$(RESET)"
	@echo 'setenv bootargs console=ttyS0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rw' > $(FIRMWARE_DIR)/boot/boot.cmd
	@echo 'fatload mmc 0 0x81c00000 uImage' >> $(FIRMWARE_DIR)/boot/boot.cmd
	@echo 'bootm 0x81c00000' >> $(FIRMWARE_DIR)/boot/boot.cmd
	@if command -v mkimage >/dev/null 2>&1; then \
		mkimage -A arm -O linux -T script -C none -n "Boot Script" \
			-d $(FIRMWARE_DIR)/boot/boot.cmd $(FIRMWARE_DIR)/boot/boot.scr; \
		cp $(FIRMWARE_DIR)/boot/boot.scr $(FIRMWARE_DIR)/boot/u-boot.scr; \
		cp $(FIRMWARE_DIR)/boot/boot.scr $(FIRMWARE_DIR)/boot/boot.scr.uimg; \
		echo "$(GREEN)   ✓ Boot scripts created$(RESET)"; \
	else \
		echo "$(YELLOW)   ⚠ mkimage not found - boot script not compiled$(RESET)"; \
		echo "   Install u-boot-tools for boot script compilation"; \
	fi

# Boot partition preparation
boot: kernel bootloaders boot-script
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
	@echo "$(GREEN)✓ Boot partition ready with all components$(RESET)"

# Build ramdisk for hybrid Android/JesterOS boot
ramdisk: check-tools
	@echo "$(BOLD)📦 Building uRamdisk for JesterOS...$(RESET)"
	@if [ ! -f scripts/build-ramdisk.sh ]; then \
		echo "$(RED)Error: scripts/build-ramdisk.sh not found$(RESET)"; \
		exit 1; \
	fi
	@scripts/build-ramdisk.sh
	@if [ -f build/boot/uRamdisk ]; then \
		echo "$(GREEN)✓ uRamdisk built successfully$(RESET)"; \
		echo "  Size: $$(ls -lh build/boot/uRamdisk | awk '{print $$5}')"; \
	else \
		echo "$(RED)✗ Failed to build uRamdisk$(RESET)"; \
		exit 1; \
	fi

# Generate boot script from boot.cmd
boot-script: check-tools
	@echo "$(BOLD)📜 Generating boot script...$(RESET)"
	@if [ ! -f scripts/generate-boot-script.sh ]; then \
		echo "$(RED)Error: scripts/generate-boot-script.sh not found$(RESET)"; \
		exit 1; \
	fi
	@scripts/generate-boot-script.sh
	@if [ -f platform/nook-touch/boot/boot.scr ]; then \
		echo "$(GREEN)✓ boot.scr generated successfully$(RESET)"; \
	else \
		echo "$(RED)✗ Failed to generate boot.scr$(RESET)"; \
		exit 1; \
	fi

# SD card image creation (target for complete bootable image)
sd-image: firmware ramdisk boot-script
	@echo "$(BOLD)💾 Creating complete SD card image with JesterOS...$(RESET)"
	@mkdir -p $(BUILD_DIR)/sd-image
	@# Prepare boot partition files
	@cp platform/nook-touch/boot/MLO $(BUILD_DIR)/sd-image/
	@cp platform/nook-touch/boot/u-boot.bin $(BUILD_DIR)/sd-image/
	@cp platform/nook-touch/boot/uImage $(BUILD_DIR)/sd-image/ 2>/dev/null || true
	@cp build/boot/uRamdisk $(BUILD_DIR)/sd-image/
	@cp platform/nook-touch/boot/boot.scr $(BUILD_DIR)/sd-image/
	@cp platform/nook-touch/boot/uEnv.txt $(BUILD_DIR)/sd-image/
	@echo "$(GREEN)✓ SD card image files prepared in $(BUILD_DIR)/sd-image/$(RESET)"
	@echo "  Next step: Use 'make sd-deploy' to write to SD card"

# SD card image creation
image: firmware lenny-rootfs
	@echo "$(BOLD)💾 Creating SD card image: $(IMAGE_NAME)$(RESET)"
	@mkdir -p $(RELEASES_DIR)
	@# Find the latest rootfs from Docker build
	@ROOTFS_FILE=$$(ls -t jesteros-production-rootfs-*.tar.gz 2>/dev/null | head -1); \
	if [ -z "$$ROOTFS_FILE" ]; then \
		echo "$(RED)Error: No rootfs found. Run 'make lenny-rootfs' first$(RESET)"; \
		exit 1; \
	fi; \
	echo "  Using rootfs: $$ROOTFS_FILE"; \
	if [ -f build/scripts/create-image.sh ]; then \
		ROOTFS_ARCHIVE=$$ROOTFS_FILE ./build/scripts/create-image.sh $(IMAGE_NAME) || exit 1; \
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
	@# Clean boot directory but PRESERVE critical bootloaders
	@find $(FIRMWARE_DIR)/boot -type f -not -name "MLO" -not -name "u-boot.bin" -delete 2>/dev/null || true
	@# Remove any temporary partition images
	@rm -f $(FIRMWARE_DIR)/boot/*.img 2>/dev/null || true
	@rm -f $(RELEASES_DIR)/*.img
	@rm -f $(RELEASES_DIR)/*.sha256
	@# Kernel build artifacts (comprehensive)
	@if [ -d $(KERNEL_DIR)/src ]; then \
		echo "  Cleaning kernel build artifacts..."; \
		cd $(KERNEL_DIR)/src && make -j$(J_CORES) clean ARCH=arm 2>/dev/null || true; \
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
	@echo "Available SD card devices:"
	@$(MAKE) detect-sd
	@echo ""
	@echo "To flash the image, run:"
	@echo "  $(BOLD)sudo dd if=$(RELEASES_DIR)/$(IMAGE_NAME) of=/dev/sdX bs=4M status=progress$(RESET)"
	@echo ""
	@echo "Or use: $(BOLD)make sd-deploy SD_DEVICE=/dev/sdX$(RESET)"
	@echo "$(RED)Double-check the device to avoid data loss!$(RESET)"

# New targets for validation and testing

# Test configuration
TEST_DIR := tests
TEST_RESULTS := $(TEST_DIR)/results
TEST_LOG := $(CURDIR)/$(TEST_RESULTS)/test-$(TIMESTAMP).log
TEST_TIMEOUT := 300  # 5 minutes default timeout per test

# Check required build tools
check-tools:
	@echo "$(BOLD)🔍 Checking build tools...$(RESET)"
	@which docker >/dev/null 2>&1 || (echo "$(RED)Error: Docker not found$(RESET)" && exit 1)
	@which bash >/dev/null 2>&1 || (echo "$(RED)Error: Bash not found$(RESET)" && exit 1)
	@echo "$(GREEN)✓ All required tools found$(RESET)"

# Validate build environment
validate: check-tools
	@echo "$(BOLD)✅ Validating build environment...$(RESET)"
	@test -d $(KERNEL_DIR) || (echo "$(RED)Error: Kernel directory not found$(RESET)" && echo "  Run: git submodule init && git submodule update" && exit 1)
	@test -d $(SCRIPTS_DIR) || (echo "$(RED)Error: Scripts directory not found$(RESET)" && echo "  Expected: $(SCRIPTS_DIR)" && exit 1)
	@test -f build/scripts/build_kernel.sh || (echo "$(RED)Error: build/scripts/build_kernel.sh not found$(RESET)" && exit 1)
	@test -f $(SCRIPTS_DIR)/3-system/common/common.sh || (echo "$(RED)Error: Common library not found$(RESET)" && echo "  Expected: $(SCRIPTS_DIR)/3-system/common/common.sh" && exit 1)
	@echo "$(GREEN)✓ Environment validated$(RESET)"
	@echo "  - Kernel source: Available ($(shell find $(KERNEL_DIR) -name "*.c" | wc -l) files)"
	@echo "  - Runtime scripts: Available ($(shell find $(SCRIPTS_DIR) -name "*.sh" | wc -l) scripts)"
	@echo "  - JesterOS services: Available (4-layer architecture)"

# Initialize test environment
test-init:
	@mkdir -p $(TEST_RESULTS)
	@echo "Test run started at $$(date)" > $(TEST_LOG)
	@echo "═══════════════════════════════════════════" >> $(TEST_LOG)

# Run complete test pipeline - all three stages with proper error handling
test: test-init test-pre-build docker-build test-post-build test-runtime test-report
	@echo "$(GREEN)$(BOLD)✅ Complete test pipeline passed!$(RESET)"
	@echo "  Results: $(TEST_LOG)"

# Stage 1: Test build tools before Docker build
test-pre-build: test-init
	@echo "$(BOLD)🔨 Testing build tools (pre-build stage)...$(RESET)"
	@echo "[PRE-BUILD] Started at $$(date)" >> $(TEST_LOG)
	@if cd $(TEST_DIR) && timeout $(TEST_TIMEOUT) bash -c 'TEST_STAGE=pre-build ./run-tests.sh' 2>&1; then \
		echo "$(GREEN)✓ Pre-build tests passed$(RESET)" | tee -a $(TEST_LOG); \
	else \
		echo "$(RED)✗ Pre-build tests failed$(RESET)" | tee -a $(TEST_LOG); \
		exit 1; \
	fi

# Stage 2: Test Docker-generated scripts after build
test-post-build: test-init
	@echo "$(BOLD)📦 Testing Docker output (post-build stage)...$(RESET)"
	@echo "[POST-BUILD] Started at $$(date)" >> $(TEST_LOG)
	@if cd $(TEST_DIR) && timeout $(TEST_TIMEOUT) bash -c 'TEST_STAGE=post-build ./run-tests.sh'; then \
		echo "$(GREEN)✓ Post-build tests passed$(RESET)" | tee -a $(TEST_LOG); \
	else \
		echo "$(RED)✗ Post-build tests failed$(RESET)" | tee -a $(TEST_LOG); \
		exit 1; \
	fi

# Stage 3: Test runtime execution in container
test-runtime: test-init docker-test
	@echo "$(BOLD)🚀 Testing runtime execution in container...$(RESET)"
	@echo "[RUNTIME] Started at $$(date)" >> $(TEST_LOG)
	@if docker run --rm -v $(TEST_DIR):/tests jesteros-test bash -c 'cd /tests && TEST_STAGE=runtime ./run-tests.sh' 2>&1 | tee -a $(TEST_LOG); then \
		echo "$(GREEN)✓ Runtime tests passed$(RESET)" | tee -a $(TEST_LOG); \
	else \
		echo "$(RED)✗ Runtime tests failed$(RESET)" | tee -a $(TEST_LOG); \
		exit 1; \
	fi

# Legacy test target for backward compatibility
test-legacy:
	@echo "$(BOLD)🧪 Running Nook Typewriter Test Suite (legacy mode)$(RESET)"
	@cd tests && TEST_STAGE=post-build ./run-tests.sh

# Run just critical safety checks
test-safety: test-init
	@echo "$(BOLD)🛡️ Running critical safety checks...$(RESET)"
	@if [ ! -f $(TEST_DIR)/01-safety-check.sh ]; then \
		echo "$(RED)Error: Safety check script not found$(RESET)"; \
		exit 1; \
	fi
	@if cd $(TEST_DIR) && timeout 60 ./01-safety-check.sh 2>&1 | tee -a $(TEST_LOG); then \
		echo "$(GREEN)✓ Safety checks passed$(RESET)"; \
	else \
		echo "$(RED)✗ Safety checks failed - DO NOT DEPLOY$(RESET)"; \
		exit 1; \
	fi

# Run show stoppers only (must pass before deploy)
test-quick: test-init test-safety
	@echo "$(BOLD)⚡ Running show stopper tests only...$(RESET)"
	@if cd $(TEST_DIR) && timeout 120 ./02-boot-test.sh 2>&1 | tee -a $(TEST_LOG); then \
		echo "$(GREEN)✓ Boot test passed$(RESET)"; \
	else \
		echo "$(RED)✗ Boot test failed$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✓ All show stopper tests passed$(RESET)"

# Test result reporting
test-report:
	@echo ""
	@echo "$(BOLD)📊 Test Results Summary$(RESET)"
	@echo "═══════════════════════════════════════════"
	@LATEST_LOG=$$(ls -t $(TEST_RESULTS)/*.log 2>/dev/null | head -1); \
	if [ -n "$$LATEST_LOG" ] && [ -f "$$LATEST_LOG" ]; then \
		passed=$$(grep "✓" "$$LATEST_LOG" 2>/dev/null | wc -l); \
		failed=$$(grep "✗" "$$LATEST_LOG" 2>/dev/null | wc -l); \
		echo "  Passed: $(GREEN)$$passed$(RESET)"; \
		echo "  Failed: $(RED)$$failed$(RESET)"; \
		if [ "$$failed" -gt "0" ]; then \
			echo ""; \
			echo "Failed tests:"; \
			grep "✗" "$$LATEST_LOG" | sed 's/^/  /'; \
		fi; \
		echo "═══════════════════════════════════════════"; \
		echo "  Log: $$LATEST_LOG"; \
		echo "  Time: $$(stat -c %y "$$LATEST_LOG" | cut -d' ' -f1,2)"; \
	else \
		echo "  No test results found"; \
		echo "═══════════════════════════════════════════"; \
	fi

# Run tests in parallel (experimental)
test-parallel: test-init
	@echo "$(BOLD)⚡ Running tests in parallel...$(RESET)"
	@echo "[PARALLEL] Starting parallel test execution" >> $(TEST_LOG)
	@$(MAKE) -j3 test-safety test-consistency test-memory > $(TEST_RESULTS)/parallel.tmp 2>&1 || true
	@cat $(TEST_RESULTS)/parallel.tmp >> $(TEST_LOG)
	@rm -f $(TEST_RESULTS)/parallel.tmp
	@$(MAKE) test-report

# Run writing blocker tests
test-writing: test-init
	@echo "$(BOLD)✍️ Running writing blocker tests...$(RESET)"
	@cd $(TEST_DIR) && \
	for test in 04-docker-smoke.sh 05-consistency-check.sh 06-memory-guard.sh; do \
		echo "Running $$test..." | tee -a $(TEST_LOG); \
		if timeout $(TEST_TIMEOUT) ./$$test 2>&1 | tee -a $(TEST_LOG); then \
			echo "$(GREEN)✓ $$test passed$(RESET)" | tee -a $(TEST_LOG); \
		else \
			echo "$(RED)✗ $$test failed$(RESET)" | tee -a $(TEST_LOG); \
			exit 1; \
		fi; \
	done

# Run experience tests
test-experience:
	@echo "$(BOLD)✨ Running writer experience tests...$(RESET)"
	@cd tests && bash -c './03-functionality.sh && ./07-writer-experience.sh'

# Run individual test categories
test-docker: test-init docker-test
	@echo "$(BOLD)🐳 Running Docker smoke test with test image...$(RESET)"
	@if docker run --rm jesteros-test /validate-jesteros.sh 2>&1 | tee -a $(TEST_LOG); then \
		echo "$(GREEN)✓ Docker test passed$(RESET)"; \
	else \
		echo "$(RED)✗ Docker test failed$(RESET)"; \
		exit 1; \
	fi

test-consistency: test-init
	@echo "$(BOLD)🔍 Running consistency check...$(RESET)"
	@cd $(TEST_DIR) && timeout $(TEST_TIMEOUT) ./05-consistency-check.sh 2>&1 | tee -a $(TEST_LOG)

test-memory: test-init
	@echo "$(BOLD)💾 Running memory guard test...$(RESET)"
	@cd $(TEST_DIR) && timeout $(TEST_TIMEOUT) ./06-memory-guard.sh 2>&1 | tee -a $(TEST_LOG)

# Test GK61 keyboard support
test-gk61: test-init docker-test-gk61
	@echo "$(BOLD)⌨️ Testing GK61 keyboard support...$(RESET)"
	@if docker run --rm gk61-test bash -c 'ls /src/3-system/services/usb-keyboard-manager.sh && ls /src/4-hardware/input/button-handler.sh' 2>&1 | tee -a $(TEST_LOG); then \
		echo "$(GREEN)✓ GK61 keyboard test passed$(RESET)"; \
	else \
		echo "$(RED)✗ GK61 keyboard test failed$(RESET)"; \
		exit 1; \
	fi

# Test coverage analysis
test-coverage: test-init
	@echo "$(BOLD)📈 Analyzing test coverage...$(RESET)"
	@echo "═══════════════════════════════════════════"
	@total_scripts=$$(find $(SCRIPTS_DIR) -name "*.sh" -type f | wc -l); \
	total_tests=$$(find $(TEST_DIR) -name "*.sh" -type f | wc -l); \
	tested_files=$$(grep -h "Testing.*\.sh" $(TEST_DIR)/*.sh 2>/dev/null | sort -u | wc -l || echo 0); \
	coverage=$$(echo "scale=1; $$tested_files * 100 / $$total_scripts" | bc 2>/dev/null || echo "0"); \
	echo "  Total scripts: $$total_scripts"; \
	echo "  Test scripts: $$total_tests"; \
	echo "  Files tested: $$tested_files"; \
	echo "  Coverage: $$coverage%"; \
	if [ $$(echo "$$coverage < 50" | bc) -eq 1 ]; then \
		echo "  $(RED)⚠ Low test coverage$(RESET)"; \
	elif [ $$(echo "$$coverage < 80" | bc) -eq 1 ]; then \
		echo "  $(YELLOW)⚠ Moderate test coverage$(RESET)"; \
	else \
		echo "  $(GREEN)✓ Good test coverage$(RESET)"; \
	fi
	@echo "═══════════════════════════════════════════"

# Clean test results and logs
test-clean:
	@echo "$(BOLD)🧹 Cleaning test results...$(RESET)"
	@rm -rf $(TEST_RESULTS)
	@find $(TEST_DIR) -name "*.log" -o -name "*.tmp" -o -name "*.out" | xargs rm -f 2>/dev/null || true
	@echo "$(GREEN)✓ Test artifacts cleaned$(RESET)"

# Show dependencies
deps:
	@echo "$(BOLD)📚 Build Dependencies:$(RESET)"
	@echo "  - Docker (for cross-compilation)"
	@echo "  - Android NDK r10e (in Docker image)"
	@echo "  - ARM cross-compiler (arm-linux-androideabi)"
	@echo "  - 4GB+ free disk space"
	@echo "  - Linux or WSL2 environment"

# Quick build target - skips unchanged components
quick-build:
	@echo "$(BOLD)⚡ Quick build mode$(RESET)"
	@if [ -f $(FIRMWARE_DIR)/boot/uImage ] && [ build/scripts/build_kernel.sh -ot $(FIRMWARE_DIR)/boot/uImage ]; then \
		echo "$(YELLOW)Kernel unchanged, skipping rebuild$(RESET)"; \
	else \
		$(MAKE) kernel; \
	fi
	@$(MAKE) rootfs
	@echo "$(GREEN)✓ Quick build complete$(RESET)"

# Detect SD card devices (excluding system and Docker drives)
detect-sd:
	@echo "$(BOLD)🔍 Detecting SD card devices...$(RESET)"
	@echo "$(YELLOW)⚠️  Excluding sda-sdd (system/Docker drives)$(RESET)"
	@echo "$(YELLOW)📌 Phoenix Project recommends: $(SD_CARD_BRAND) Class $(SD_CARD_CLASS) cards$(RESET)"
	@lsblk -d -o NAME,SIZE,MODEL,TRAN | grep -E "(sd|mmcblk)" | grep -v -E "sda|sdb|sdc|sdd" || echo "No removable devices found"
	@echo ""
	@echo "Safe removable devices (likely SD cards):"
	@for dev in $$(ls /dev/sd[e-z] /dev/mmcblk[0-9] 2>/dev/null); do \
		if [ -b $$dev ]; then \
			size=$$(lsblk -b -d -o SIZE -n $$dev 2>/dev/null); \
			if [ "$$size" -lt "68719476736" ]; then \
				model=$$(lsblk -d -o MODEL -n $$dev 2>/dev/null); \
				if echo "$$model" | grep -qi "sandisk"; then \
					echo "  $$dev - $$(lsblk -d -o SIZE,MODEL -n $$dev 2>/dev/null) $(GREEN)[RECOMMENDED]$(RESET)"; \
				else \
					echo "  $$dev - $$(lsblk -d -o SIZE,MODEL -n $$dev 2>/dev/null)"; \
				fi; \
			fi; \
		fi; \
	done
	@echo ""
	@echo "$(YELLOW)⚠️  Non-SanDisk cards may have boot issues (per XDA community)$(RESET)"

# Auto-deploy to SD card (safe mode - excludes system and Docker drives)
sd-deploy: firmware test-quick battery-check
	@echo "$(BOLD)💾 Deploying to SD card (Phoenix Project Method)$(RESET)"
	@echo "$(GREEN)✓ Show stopper tests passed - safe to deploy$(RESET)"
	@echo "$(YELLOW)📋 Using FW $(FIRMWARE_VERSION) configuration (most stable)$(RESET)"
	@if [ "$(SD_DEVICE)" = "auto" ]; then \
		echo "Auto-detecting SD card (excluding system/Docker drives)..."; \
		SD_CARD=$$(ls /dev/sd[e-z] /dev/mmcblk[0-9] 2>/dev/null | head -1); \
		if [ -z "$$SD_CARD" ]; then \
			echo "$(RED)No safe SD card detected!$(RESET)"; \
			echo "Detected devices (excluded sda-sdd for safety):"; \
			@$(MAKE) detect-sd; \
			echo "Please specify: make sd-deploy SD_DEVICE=/dev/sdX"; \
			exit 1; \
		fi; \
	else \
		SD_CARD="$(SD_DEVICE)"; \
		if echo "$$SD_CARD" | grep -qE "/dev/sd[a-d]"; then \
			echo "$(RED)ERROR: Cannot deploy to system/Docker drives (sda-sdd)!$(RESET)"; \
			echo "These are protected system/Windows/Docker drives."; \
			exit 1; \
		fi; \
	fi; \
	echo "$(YELLOW)Target device: $$SD_CARD$(RESET)"; \
	echo "$(RED)⚠️  This will ERASE $$SD_CARD!$(RESET)"; \
	read -p "Continue? (yes/NO): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		echo "Writing base image..."; \
		sudo dd if=$(BASE_IMAGE) of=$$SD_CARD bs=4M status=progress || exit 1; \
		sync; \
		echo "Mounting partitions..."; \
		sudo mkdir -p /mnt/nook-boot /mnt/nook-root; \
		sudo mount $${SD_CARD}1 /mnt/nook-boot || sudo mount $${SD_CARD}p1 /mnt/nook-boot || exit 1; \
		if [ -f $(KERNEL_DIR)/src/arch/arm/boot/uImage ]; then \
			echo "Copying kernel..."; \
			sudo cp $(KERNEL_DIR)/src/arch/arm/boot/uImage /mnt/nook-boot/; \
		fi; \
		ROOTFS_FILE=$$(ls -t jesteros-lenny-rootfs-*.tar.gz 2>/dev/null | head -1); \
		if [ -z "$$ROOTFS_FILE" ] && [ -f nook-mvp-rootfs.tar.gz ]; then \
			echo "$(YELLOW)Warning: Using fallback rootfs (not Lenny-based)$(RESET)"; \
			ROOTFS_FILE="nook-mvp-rootfs.tar.gz"; \
		fi; \
		if [ -n "$$ROOTFS_FILE" ] && [ -f "$$ROOTFS_FILE" ]; then \
			echo "Extracting rootfs from $$ROOTFS_FILE..."; \
			sudo mount $${SD_CARD}2 /mnt/nook-root || sudo mount $${SD_CARD}p2 /mnt/nook-root || exit 1; \
			sudo tar -xzf "$$ROOTFS_FILE" -C /mnt/nook-root/; \
			sudo umount /mnt/nook-root; \
		else \
			echo "$(YELLOW)Warning: No rootfs found, skipping rootfs extraction$(RESET)"; \
		fi; \
		sudo umount /mnt/nook-boot; \
		sync; \
		echo "$(GREEN)✅ SD card ready! You can now boot your Nook$(RESET)"; \
	else \
		echo "Deployment cancelled"; \
	fi

# Quick deploy - just kernel to existing SD card (safe mode)
quick-deploy:
	@echo "$(BOLD)⚡ Quick deploy (kernel only)$(RESET)"
	@if [ "$(SD_DEVICE)" = "auto" ]; then \
		SD_CARD=$$(ls /dev/sd[e-z] /dev/mmcblk[0-9] 2>/dev/null | head -1); \
	else \
		SD_CARD="$(SD_DEVICE)"; \
		if echo "$$SD_CARD" | grep -qE "/dev/sd[a-d]"; then \
			echo "$(RED)ERROR: Cannot deploy to system/Docker drives (sda-sdd)!$(RESET)"; \
			exit 1; \
		fi; \
	fi; \
	if [ -z "$$SD_CARD" ]; then \
		echo "$(RED)No SD card specified!$(RESET)"; \
		exit 1; \
	fi; \
	echo "Deploying to $$SD_CARD..."; \
	sudo mkdir -p /mnt/nook-boot; \
	sudo mount $${SD_CARD}1 /mnt/nook-boot || sudo mount $${SD_CARD}p1 /mnt/nook-boot || exit 1; \
	if [ -f $(KERNEL_DIR)/src/arch/arm/boot/uImage ]; then \
		sudo cp $(KERNEL_DIR)/src/arch/arm/boot/uImage /mnt/nook-boot/; \
		echo "$(GREEN)✓ Kernel updated$(RESET)"; \
	else \
		echo "$(RED)Kernel not found! Run 'make kernel' first$(RESET)"; \
	fi; \
	sudo umount /mnt/nook-boot; \
	sync

# Show build status and recent logs
build-status:
	@echo "$(BOLD)📊 Build Status$(RESET)"
	@echo "═══════════════════════════════════════════"
	@if [ -f $(FIRMWARE_DIR)/boot/uImage ]; then \
		echo "Kernel: $(GREEN)✓$(RESET) Built $$(stat -c %y $(FIRMWARE_DIR)/boot/uImage | cut -d' ' -f1,2)"; \
	else \
		echo "Kernel: $(RED)✗$(RESET) Not built"; \
	fi
	@if [ -d $(FIRMWARE_DIR)/rootfs/usr/local/bin ] && [ "$$(ls -A $(FIRMWARE_DIR)/rootfs/usr/local/bin 2>/dev/null)" ]; then \
		echo "Rootfs: $(GREEN)✓$(RESET) $$(ls $(FIRMWARE_DIR)/rootfs/usr/local/bin/*.sh 2>/dev/null | wc -l) scripts installed"; \
	else \
		echo "Rootfs: $(RED)✗$(RESET) Not built"; \
	fi
	@if [ -f $(BUILD_LOG) ]; then \
		echo ""; \
		echo "Recent build log:"; \
		tail -5 $(BUILD_LOG); \
	fi

# Show protected files status
bootloader-status:
	@echo "$(BOLD)🛡️  Protected Bootloader Files Status$(RESET)"
	@echo "═══════════════════════════════════════════"
	@if [ -f $(FIRMWARE_DIR)/boot/MLO ]; then \
		echo "$(GREEN)✓ MLO present$(RESET)"; \
		ls -lh $(FIRMWARE_DIR)/boot/MLO; \
	else \
		echo "$(RED)✗ MLO missing$(RESET)"; \
	fi
	@if [ -f $(FIRMWARE_DIR)/boot/u-boot.bin ]; then \
		echo "$(GREEN)✓ u-boot.bin present$(RESET)"; \
		ls -lh $(FIRMWARE_DIR)/boot/u-boot.bin; \
	else \
		echo "$(RED)✗ u-boot.bin missing$(RESET)"; \
	fi
	@echo ""
	@echo "$(YELLOW)Note: These files are preserved during 'make clean'$(RESET)"
	@echo "      Only 'make distclean' will remove them"

# Battery optimization check (Phoenix Project findings)
battery-check:
	@echo "$(BOLD)🔋 Checking battery optimization settings...$(RESET)"
	@echo "═══════════════════════════════════════════"
	@echo "Phoenix Project battery drain targets:"
	@echo "  - Registered device: 1-2% overnight"
	@echo "  - Unregistered: 14%+ daily (CRITICAL ISSUE)"
	@echo "  - Target: $(BATTERY_DRAIN_TARGET)% daily idle"
	@echo ""
	@echo "$(YELLOW)⚠️  Critical battery drain causes:$(RESET)"
	@echo "  ❌ Unregistered B&N system polling"
	@echo "  ❌ WiFi radio left on (hidden)"
	@echo "  ❌ Weather widget active"
	@echo "  ❌ EBookDroid in landscape mode"
	@echo ""
	@echo "$(GREEN)✓ JesterOS solution:$(RESET)"
	@echo "  - B&N system completely removed"
	@echo "  - No network services enabled"
	@echo "  - No background polling"
	@echo "  - Expected drain: <$(BATTERY_DRAIN_TARGET)% daily"
	@echo "═══════════════════════════════════════════"

# Create CWM-compatible installer (Phoenix Project method)
installer: firmware
	@echo "$(BOLD)📦 Creating CWM-compatible installer...$(RESET)"
	@echo "  Using Phoenix Project installation method"
	@mkdir -p $(RELEASES_DIR)/installer
	@# Create installation script
	@echo '#!/sbin/sh' > $(RELEASES_DIR)/installer/install.sh
	@echo '# JesterOS CWM Installer (Phoenix Project compatible)' >> $(RELEASES_DIR)/installer/install.sh
	@echo 'echo "Installing JesterOS..."' >> $(RELEASES_DIR)/installer/install.sh
	@echo '# Backup critical files' >> $(RELEASES_DIR)/installer/install.sh
	@echo 'mount /dev/block/mmcblk0p5 /system' >> $(RELEASES_DIR)/installer/install.sh
	@echo 'cp /system/build.prop /sdcard/backup.prop' >> $(RELEASES_DIR)/installer/install.sh
	@echo '# Wipe system (keep /rom untouched!)' >> $(RELEASES_DIR)/installer/install.sh
	@echo 'rm -rf /system/*' >> $(RELEASES_DIR)/installer/install.sh
	@echo 'rm -rf /data/*' >> $(RELEASES_DIR)/installer/install.sh
	@echo 'rm -rf /cache/*' >> $(RELEASES_DIR)/installer/install.sh
	@echo '# Extract JesterOS' >> $(RELEASES_DIR)/installer/install.sh
	@echo 'tar xzf /sdcard/jesteros-system.tar.gz -C /system/' >> $(RELEASES_DIR)/installer/install.sh
	@echo '# Add touch recovery gesture' >> $(RELEASES_DIR)/installer/install.sh
	@echo 'echo "# Two-finger swipe recovery" >> /system/etc/init.d/99-touch-recovery' >> $(RELEASES_DIR)/installer/install.sh
	@echo 'sync' >> $(RELEASES_DIR)/installer/install.sh
	@echo 'echo "Installation complete!"' >> $(RELEASES_DIR)/installer/install.sh
	@chmod +x $(RELEASES_DIR)/installer/install.sh
	@echo "$(GREEN)✓ CWM installer created$(RESET)"
	@echo "  Follows Phoenix Project standards"
	@echo "  Preserves /rom partition (safe)"
	@echo "  Includes touch recovery gesture"

# Touch screen recovery documentation
touch-recovery-doc:
	@echo "$(BOLD)👆 Touch Screen Lock-up Recovery$(RESET)"
	@echo "═══════════════════════════════════════════"
	@echo "$(YELLOW)Known hardware issue affecting ALL Nook devices$(RESET)"
	@echo ""
	@echo "Symptoms:"
	@echo "  - Touch frozen after wake from screensaver"
	@echo "  - Home button works but touch doesn't"
	@echo "  - Random occurrence (3 hours to 3 days)"
	@echo ""
	@echo "$(GREEN)Recovery methods:$(RESET)"
	@echo "  1. Two-finger horizontal swipe gesture"
	@echo "  2. Clean screen gutters with cotton swab"
	@echo "  3. Adjust screen timeout values"
	@echo "  4. Test with/without slide-to-unlock"
	@echo ""
	@echo "JesterOS implements automatic recovery gesture"
	@echo "═══════════════════════════════════════════"

.DEFAULT_GOAL := help
