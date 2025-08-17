# Makefile for JesterOS SVG to E-Ink Splash Screen Generation
# Batch processes SVG files into optimized E-Ink formats

# Configuration
PYTHON := python3
SCRIPT := svg_to_eink.py
OUTPUT_DIR := ./output
BUILD_DIR := ./build

# E-Ink display parameters
WIDTH := 600
HEIGHT := 800
LEVELS := 16

# Source SVG files
SVG_FILES := jesteros_splash.svg \
             boot_animation_splash.svg \
             error_splash.svg \
             writing_mode_splash.svg

# Output formats
FORMATS := png raw c_header shell_script

# Quantization methods for different splash types
DITHER_SPLASHES := jesteros_splash boot_animation_splash writing_mode_splash
POSTERIZE_SPLASHES := error_splash

# Default target
.PHONY: all
all: check-deps directories splash-screens

# Check dependencies
.PHONY: check-deps
check-deps:
	@echo "Checking dependencies..."
	@which $(PYTHON) > /dev/null || (echo "Error: Python3 not found" && exit 1)
	@$(PYTHON) -c "import PIL" 2>/dev/null || (echo "Error: Pillow not installed. Run: pip install Pillow" && exit 1)
	@$(PYTHON) -c "import cairosvg" 2>/dev/null || (echo "Error: cairosvg not installed. Run: pip install cairosvg" && exit 1)
	@$(PYTHON) -c "import numpy" 2>/dev/null || (echo "Error: numpy not installed. Run: pip install numpy" && exit 1)
	@$(PYTHON) -c "import scipy" 2>/dev/null || (echo "Error: scipy not installed. Run: pip install scipy" && exit 1)
	@echo "✓ All dependencies satisfied"

# Create output directories
.PHONY: directories
directories:
	@mkdir -p $(OUTPUT_DIR)
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(OUTPUT_DIR)/png
	@mkdir -p $(OUTPUT_DIR)/raw
	@mkdir -p $(OUTPUT_DIR)/headers
	@mkdir -p $(OUTPUT_DIR)/scripts

# Generate all splash screens
.PHONY: splash-screens
splash-screens: $(SVG_FILES:.svg=.processed)

# Process individual SVG files with appropriate quantization
%.processed: %.svg
	@echo "Processing $<..."
	@if echo "$(DITHER_SPLASHES)" | grep -q "$(basename $<)"; then \
		echo "  Using dither method for $(basename $<)"; \
		$(PYTHON) $(SCRIPT) $< \
			--output $(OUTPUT_DIR) \
			--name $(basename $<) \
			--method dither \
			--width $(WIDTH) \
			--height $(HEIGHT) \
			--levels $(LEVELS) \
			--formats $(FORMATS); \
	elif echo "$(POSTERIZE_SPLASHES)" | grep -q "$(basename $<)"; then \
		echo "  Using posterize method for $(basename $<)"; \
		$(PYTHON) $(SCRIPT) $< \
			--output $(OUTPUT_DIR) \
			--name $(basename $<) \
			--method posterize \
			--width $(WIDTH) \
			--height $(HEIGHT) \
			--levels $(LEVELS) \
			--formats $(FORMATS); \
	else \
		echo "  Using error_diffusion method for $(basename $<)"; \
		$(PYTHON) $(SCRIPT) $< \
			--output $(OUTPUT_DIR) \
			--name $(basename $<) \
			--method error_diffusion \
			--width $(WIDTH) \
			--height $(HEIGHT) \
			--levels $(LEVELS) \
			--formats $(FORMATS); \
	fi
	@touch $(BUILD_DIR)/$@

# Generate boot animation sequence
.PHONY: boot-sequence
boot-sequence:
	@echo "Generating boot animation sequence..."
	@for i in 1 2 3 4 5; do \
		echo "Creating boot stage $$i..."; \
		cp boot_animation_splash.svg $(BUILD_DIR)/boot_stage_$$i.svg; \
		$(PYTHON) $(SCRIPT) $(BUILD_DIR)/boot_stage_$$i.svg \
			--output $(OUTPUT_DIR)/sequence \
			--name boot_stage_$$i \
			--method dither \
			--formats raw; \
	done
	@echo "✓ Boot sequence generated"

# Generate combined boot animation script
.PHONY: animation-script
animation-script: boot-sequence
	@echo "Creating boot animation script..."
	@cat > $(OUTPUT_DIR)/boot_animation.sh <<'EOF'
	#!/bin/bash
	# JesterOS Boot Animation Script
	FRAMEBUFFER="/dev/fb0"
	SEQUENCE_DIR="$$(dirname $$0)/sequence"
	DELAY=0.5
	
	for stage in $$(seq 1 5); do
	    if [ -f "$$SEQUENCE_DIR/boot_stage_$$stage.raw" ]; then
	        dd if="$$SEQUENCE_DIR/boot_stage_$$stage.raw" of="$$FRAMEBUFFER" bs=480000 count=1 2>/dev/null
	        sleep $$DELAY
	    fi
	done
	EOF
	@chmod +x $(OUTPUT_DIR)/boot_animation.sh
	@echo "✓ Animation script created"

# Generate all formats for a single splash
.PHONY: single
single:
	@if [ -z "$(SVG)" ]; then \
		echo "Usage: make single SVG=filename.svg"; \
		exit 1; \
	fi
	@$(PYTHON) $(SCRIPT) $(SVG) \
		--output $(OUTPUT_DIR) \
		--name $(basename $(SVG)) \
		--method dither \
		--formats $(FORMATS)

# Preview PNG outputs
.PHONY: preview
preview:
	@echo "Generated PNG previews:"
	@ls -la $(OUTPUT_DIR)/*.png 2>/dev/null || echo "No PNG files generated yet"

# Package for deployment
.PHONY: package
package: all
	@echo "Packaging splash screens for deployment..."
	@tar -czf jesteros_splashes.tar.gz \
		-C $(OUTPUT_DIR) \
		--exclude='*.png' \
		.
	@echo "✓ Package created: jesteros_splashes.tar.gz"

# Deploy to SD card (requires root)
.PHONY: deploy
deploy: package
	@if [ -z "$(SDCARD)" ]; then \
		echo "Usage: make deploy SDCARD=/dev/sdX1"; \
		exit 1; \
	fi
	@echo "Deploying to SD card $(SDCARD)..."
	@sudo mkdir -p /mnt/nook_tmp
	@sudo mount $(SDCARD) /mnt/nook_tmp
	@sudo mkdir -p /mnt/nook_tmp/boot/splash
	@sudo tar -xzf jesteros_splashes.tar.gz -C /mnt/nook_tmp/boot/splash/
	@sudo umount /mnt/nook_tmp
	@sudo rmdir /mnt/nook_tmp
	@echo "✓ Deployed to $(SDCARD)"

# Test splash display (Docker environment)
.PHONY: test
test:
	@echo "Testing splash display in console..."
	@for svg in $(SVG_FILES); do \
		echo ""; \
		echo "=== $${svg%.svg} ==="; \
		if [ -f "$(OUTPUT_DIR)/$${svg%.svg}.png" ]; then \
			echo "Generated: $(OUTPUT_DIR)/$${svg%.svg}.png"; \
		fi; \
	done

# Generate C header library
.PHONY: headers
headers: splash-screens
	@echo "Creating combined header file..."
	@cat $(OUTPUT_DIR)/*.h > $(OUTPUT_DIR)/all_splashes.h 2>/dev/null || true
	@echo "✓ Combined header: $(OUTPUT_DIR)/all_splashes.h"

# Clean generated files
.PHONY: clean
clean:
	@echo "Cleaning generated files..."
	@rm -rf $(OUTPUT_DIR)
	@rm -rf $(BUILD_DIR)
	@rm -f jesteros_splashes.tar.gz
	@echo "✓ Cleaned"

# Clean and regenerate
.PHONY: rebuild
rebuild: clean all

# Generate documentation
.PHONY: docs
docs:
	@echo "Generating splash screen documentation..."
	@cat > $(OUTPUT_DIR)/README.md <<'EOF'
	# JesterOS E-Ink Splash Screens
	
	## Generated Files
	
	### Main Splash Screens
	- `jesteros_splash.*` - Main JesterOS boot splash with jester logo
	- `boot_animation_splash.*` - Animated boot sequence with progress
	- `error_splash.*` - Error state with sad jester
	- `writing_mode_splash.*` - Writing mode with quill theme
	
	### Output Formats
	- `.png` - Preview images for testing
	- `.raw` - Raw framebuffer data for direct E-Ink write
	- `.h` - C header files for kernel integration
	- `.sh` - Shell scripts for displaying splashes
	
	## Display Instructions
	
	### On Nook Device
	```bash
	# Display main splash
	./display_jesteros_splash.sh
	
	# Run boot animation
	./boot_animation.sh
	
	# Show error screen
	./display_error_splash.sh
	```
	
	### Testing in Docker
	View PNG previews in output directory since E-Ink display not available.
	
	## Integration
	
	1. Copy raw files to `/boot/splash/` on SD card
	2. Add display scripts to boot sequence
	3. Include C headers in kernel module if needed
	
	## Customization
	
	Edit SVG files and regenerate with:
	```bash
	make single SVG=custom_splash.svg
	```
	EOF
	@echo "✓ Documentation created: $(OUTPUT_DIR)/README.md"

# Help target
.PHONY: help
help:
	@echo "JesterOS Splash Screen Generator"
	@echo "================================"
	@echo ""
	@echo "Targets:"
	@echo "  all            - Generate all splash screens (default)"
	@echo "  single         - Process single SVG (use: make single SVG=file.svg)"
	@echo "  boot-sequence  - Generate boot animation frames"
	@echo "  animation-script - Create boot animation script"
	@echo "  preview        - List generated PNG files"
	@echo "  package        - Create deployment package"
	@echo "  deploy         - Deploy to SD card (use: make deploy SDCARD=/dev/sdX1)"
	@echo "  test           - Test display in console"
	@echo "  headers        - Generate combined C header"
	@echo "  docs           - Generate documentation"
	@echo "  clean          - Remove generated files"
	@echo "  rebuild        - Clean and regenerate everything"
	@echo "  help           - Show this help message"
	@echo ""
	@echo "Configuration:"
	@echo "  WIDTH=$(WIDTH), HEIGHT=$(HEIGHT), LEVELS=$(LEVELS)"
	@echo "  OUTPUT_DIR=$(OUTPUT_DIR)"
	@echo ""
	@echo "Examples:"
	@echo "  make                    # Generate all splash screens"
	@echo "  make single SVG=my.svg  # Process single SVG file"
	@echo "  make deploy SDCARD=/dev/sdb1  # Deploy to SD card"

# Install Python dependencies
.PHONY: install-deps
install-deps:
	@echo "Installing Python dependencies..."
	@pip install Pillow cairosvg numpy scipy
	@echo "✓ Dependencies installed"

.DEFAULT_GOAL := all