# Nook Typewriter - Embedded Linux Distribution
# Transform a $20 e-reader into a distraction-free writing device
# Medieval-themed, writer-focused, E-Ink optimized

# Version and configuration
VERSION := 1.0.0
BUILD_DATE := $(shell date +%Y%m%d)
IMAGE_NAME := nook-typewriter-$(VERSION).img

# Directory configuration with validation
KERNEL_DIR := source/kernel
JESTEROS_DIR := source/kernel/jesteros
SCRIPTS_DIR := source/scripts
CONFIGS_DIR := source/configs
FIRMWARE_DIR := firmware
RELEASES_DIR := releases

# Build configuration
J_CORES := $(shell nproc 2>/dev/null || echo 4)
DOCKER_IMAGE := jesteros-unified
SD_DEVICE ?= auto
BUILD_LOG := build.log
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)

# Colors for output (E-Ink friendly)
RESET := \033[0m
BOLD := \033[1m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m

.PHONY: all clean distclean kernel rootfs firmware image release help test validate deps check-tools
.PHONY: quick-build quick-deploy sd-deploy detect-sd build-status

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
	@echo "  $(GREEN)make image$(RESET)       - Create bootable SD card image"
	@echo "  $(GREEN)make release$(RESET)     - Create release package with checksums"
	@echo ""
	@echo "$(BOLD)Testing & Validation:$(RESET)"
	@echo "  $(GREEN)make test$(RESET)        - Run all tests"
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
firmware: check-tools kernel rootfs boot
	@echo "$(GREEN)$(BOLD)✅ Firmware build complete!$(RESET)"
	@echo "  Kernel: $(shell ls -lh $(FIRMWARE_DIR)/boot/uImage 2>/dev/null | awk '{print $$5}')"
	@echo "  MLO: $(shell ls -lh $(FIRMWARE_DIR)/boot/MLO 2>/dev/null | awk '{print $$5}')"
	@echo "  U-Boot: $(shell ls -lh $(FIRMWARE_DIR)/boot/u-boot.bin 2>/dev/null | awk '{print $$5}')"
	@echo "  Modules: $(shell find $(FIRMWARE_DIR)/kernel -name '*.ko' 2>/dev/null | wc -l) modules"
	@echo "  Scripts: $(shell ls $(FIRMWARE_DIR)/rootfs/usr/local/bin/*.sh 2>/dev/null | wc -l) scripts"
	@echo "$(BOLD)═══════════════════════════════════════════════════════════════$(RESET)"

# Kernel build with Docker validation and logging
kernel: check-tools
	@echo "$(BOLD)🔨 Building kernel (JesterOS services in userspace)...$(RESET)"
	@echo "[$(TIMESTAMP)] Starting kernel build" >> $(BUILD_LOG)
	@if [ ! -f build/scripts/build_kernel.sh ]; then \
		echo "$(RED)Error: build/scripts/build_kernel.sh not found$(RESET)"; \
		echo "[$(TIMESTAMP)] ERROR: build/scripts/build_kernel.sh not found" >> $(BUILD_LOG); \
		exit 1; \
	fi
	@if ! docker images | grep -q $(DOCKER_IMAGE); then \
		echo "$(YELLOW)Building Docker image $(DOCKER_IMAGE)...$(RESET)"; \
		echo "[$(TIMESTAMP)] Building Docker image" >> $(BUILD_LOG); \
	fi
	@./build/scripts/build_kernel.sh 2>&1 | tee -a $(BUILD_LOG) || (echo "$(RED)Kernel build failed!$(RESET)" && exit 1)
	@echo "[$(TIMESTAMP)] Kernel build successful" >> $(BUILD_LOG)
	@echo "$(GREEN)✓ Kernel build successful$(RESET)"

# Root filesystem with medieval scripts
rootfs:
	@echo "$(BOLD)📦 Building root filesystem...$(RESET)"
	@mkdir -p $(FIRMWARE_DIR)/rootfs/usr/local/bin
	@mkdir -p $(FIRMWARE_DIR)/rootfs/etc/jesteros
	@# Copy scripts with validation
	@for dir in boot menu services lib; do \
		if [ -d $(SCRIPTS_DIR)/$$dir ]; then \
			echo "  Installing $$dir scripts..."; \
			cp -v $(SCRIPTS_DIR)/$$dir/*.sh $(FIRMWARE_DIR)/rootfs/usr/local/bin/ 2>/dev/null || true; \
		fi; \
	done
	@# Copy configurations
	@if [ -d $(CONFIGS_DIR) ]; then \
		cp -r $(CONFIGS_DIR)/ascii $(FIRMWARE_DIR)/rootfs/etc/jesteros/ 2>/dev/null || true; \
		cp -r $(CONFIGS_DIR)/vim $(FIRMWARE_DIR)/rootfs/etc/vim/ 2>/dev/null || true; \
	fi
	@# Set permissions
	@chmod +x $(FIRMWARE_DIR)/rootfs/usr/local/bin/*.sh 2>/dev/null || true
	@echo "$(GREEN)✓ Root filesystem prepared$(RESET)"

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
	@# Clean boot directory but PRESERVE critical bootloaders
	@find $(FIRMWARE_DIR)/boot -type f -not -name "MLO" -not -name "u-boot.bin" -delete 2>/dev/null || true
	@# Remove any temporary partition images
	@rm -f $(FIRMWARE_DIR)/boot/*.img 2>/dev/null || true
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
	@echo "Available SD card devices:"
	@$(MAKE) detect-sd
	@echo ""
	@echo "To flash the image, run:"
	@echo "  $(BOLD)sudo dd if=$(RELEASES_DIR)/$(IMAGE_NAME) of=/dev/sdX bs=4M status=progress$(RESET)"
	@echo ""
	@echo "Or use: $(BOLD)make sd-deploy SD_DEVICE=/dev/sdX$(RESET)"
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
	@test -f build/scripts/build_kernel.sh || (echo "$(RED)Error: build/scripts/build_kernel.sh not found$(RESET)" && exit 1)
	@echo "$(GREEN)✓ Environment validated$(RESET)"

# Run test suite (simple!)
test:
	@echo "$(BOLD)🧪 Running tests...$(RESET)"
	@cd tests && ./run-tests.sh

# Run just safety check
test-safety:
	@echo "$(BOLD)🛡️ Running safety check...$(RESET)"
	@cd tests && ./01-safety-check.sh

# Run old comprehensive tests (archived)
test-old:
	@echo "$(BOLD)📦 Running archived tests...$(RESET)"
	@echo "$(YELLOW)Note: These are overcomplicated. Use 'make test' instead!$(RESET)"
	@if [ -f tests/archive/run-all-tests.sh ]; then \
		cd tests/archive && ./run-all-tests.sh; \
	else \
		echo "$(YELLOW)Old tests not found (good!)$(RESET)"; \
	fi

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
	@lsblk -d -o NAME,SIZE,MODEL,TRAN | grep -E "(sd|mmcblk)" | grep -v -E "sda|sdb|sdc|sdd" || echo "No removable devices found"
	@echo ""
	@echo "Safe removable devices (likely SD cards):"
	@for dev in $$(ls /dev/sd[e-z] /dev/mmcblk[0-9] 2>/dev/null); do \
		if [ -b $$dev ]; then \
			size=$$(lsblk -b -d -o SIZE -n $$dev 2>/dev/null); \
			if [ "$$size" -lt "68719476736" ]; then \
				echo "  $$dev - $$(lsblk -d -o SIZE,MODEL -n $$dev 2>/dev/null)"; \
			fi; \
		fi; \
	done

# Auto-deploy to SD card (safe mode - excludes system and Docker drives)
sd-deploy: firmware
	@echo "$(BOLD)💾 Deploying to SD card$(RESET)"
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
		sudo dd if=images/2gb_clockwork-rc2.img of=$$SD_CARD bs=4M status=progress || exit 1; \
		sync; \
		echo "Mounting partitions..."; \
		sudo mkdir -p /mnt/nook-boot /mnt/nook-root; \
		sudo mount $${SD_CARD}1 /mnt/nook-boot || sudo mount $${SD_CARD}p1 /mnt/nook-boot || exit 1; \
		if [ -f $(KERNEL_DIR)/src/arch/arm/boot/uImage ]; then \
			echo "Copying kernel..."; \
			sudo cp $(KERNEL_DIR)/src/arch/arm/boot/uImage /mnt/nook-boot/; \
		fi; \
		if [ -f nook-mvp-rootfs.tar.gz ]; then \
			echo "Extracting rootfs (this may take a while)..."; \
			sudo mount $${SD_CARD}2 /mnt/nook-root || sudo mount $${SD_CARD}p2 /mnt/nook-root || exit 1; \
			sudo tar -xzf nook-mvp-rootfs.tar.gz -C /mnt/nook-root/; \
			sudo umount /mnt/nook-root; \
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

.DEFAULT_GOAL := help
