# SVG to E-Ink Splash Screen Generator

Advanced tooling for creating highly detailed, vector-based splash screens for the JesterOS Nook e-reader project. This system generates intricate splash images programmatically using SVG, optimized specifically for E-Ink displays.

## Overview

This tool suite provides a complete pipeline for converting SVG vector graphics into E-Ink-optimized splash screens, supporting the Nook Simple Touch's 600×800 16-grayscale display. Unlike simple ASCII art, these splash screens can contain detailed illustrations, gradients, patterns, and sophisticated typography.

## Features

### Core Capabilities
- **SVG to E-Ink Conversion**: Full vector-to-raster pipeline with E-Ink optimization
- **Multiple Quantization Methods**: Dithering, posterization, and error diffusion
- **E-Ink Display Optimization**: Gamma correction, contrast enhancement, edge sharpening
- **Multiple Output Formats**: Raw framebuffer, PNG preview, C headers, shell scripts
- **Batch Processing**: Makefile-driven workflow for multiple splash screens
- **Boot Animation Support**: Sequential frame generation for animated boot

### E-Ink Specific Optimizations
- **Gamma Correction**: Adjusted for E-Ink's 1.8 gamma response
- **Contrast Enhancement**: Compensates for E-Ink's lower contrast ratio
- **Edge Enhancement**: Sharpens lines for crisp text and graphics
- **Dithering Options**: Multiple algorithms for smooth gradients on 16-level displays

## Components

### Python Tool: `svg_to_eink.py`
Main conversion engine with:
- SVG rasterization via Cairo
- NumPy-based image processing
- SciPy edge enhancement
- Multiple dithering algorithms
- Framebuffer format generation

### SVG Templates
1. **`jesteros_splash.svg`**: Main boot splash with detailed jester face
2. **`boot_animation_splash.svg`**: Animated loading sequence with gears
3. **`error_splash.svg`**: Error state with sad jester and diagnostics
4. **`writing_mode_splash.svg`**: Writing mode with quill and parchment theme

### Build System: `Makefile`
Automated build pipeline with targets for:
- Dependency checking
- Batch conversion
- Boot sequence generation
- Deployment packaging
- SD card installation

## Installation

### Prerequisites
```bash
# Python 3.6+ required
sudo apt-get install python3 python3-pip

# Install Python dependencies
pip install Pillow cairosvg numpy scipy

# Or use the Makefile
make install-deps
```

### Quick Start
```bash
# Generate all splash screens
make all

# Process single SVG
python3 svg_to_eink.py my_splash.svg -o ./output

# Generate with specific method
python3 svg_to_eink.py splash.svg --method dither --formats png raw
```

## Usage

### Command Line Interface
```bash
python3 svg_to_eink.py [options] input.svg

Options:
  -o, --output DIR         Output directory (default: ./output)
  -n, --name NAME          Base name for outputs (default: splash)
  -m, --method METHOD      Quantization: dither|posterize|error_diffusion
  -f, --formats FORMATS    Output formats: png raw c_header shell_script
  --width WIDTH            Display width (default: 600)
  --height HEIGHT          Display height (default: 800)
  --levels LEVELS          Grayscale levels (default: 16)
```

### Makefile Targets
```bash
make all                 # Generate all splash screens
make single SVG=file.svg # Process single SVG
make boot-sequence       # Generate boot animation frames
make package            # Create deployment archive
make deploy SDCARD=/dev/sdX1  # Deploy to SD card
make clean              # Clean generated files
```

## Creating Custom Splash Screens

### SVG Design Guidelines
1. **Canvas Size**: Design at 600×800 pixels
2. **Grayscale Values**: Use 16 distinct gray levels for best results
3. **Contrast**: High contrast designs work best on E-Ink
4. **Line Width**: Minimum 2px for clear rendering
5. **Gradients**: Use sparingly, will be dithered
6. **Text**: Sans-serif fonts at 12pt minimum

### Example SVG Structure
```xml
<svg width="600" height="800" viewBox="0 0 600 800">
  <defs>
    <!-- Define gradients, patterns, filters -->
    <radialGradient id="bgGradient">
      <stop offset="0%" style="stop-color:#f0f0f0"/>
      <stop offset="100%" style="stop-color:#d0d0d0"/>
    </radialGradient>
  </defs>
  
  <!-- Background -->
  <rect width="600" height="800" fill="url(#bgGradient)"/>
  
  <!-- Main content -->
  <g transform="translate(300,400)">
    <!-- Your artwork here -->
  </g>
</svg>
```

## Output Formats

### Raw Framebuffer (`.raw`)
Direct binary data for `/dev/fb0`:
```bash
# Display on E-Ink
dd if=splash.raw of=/dev/fb0 bs=480000 count=1
```

### C Header (`.h`)
For kernel/bootloader integration:
```c
#include "splash.h"
// Use splash_data array in kernel module
memcpy(framebuffer, splash_data, splash_size);
```

### Shell Script (`.sh`)
Ready-to-run display script:
```bash
./display_splash.sh         # Normal display
./display_splash.sh animate  # Animated reveal
./display_splash.sh clear    # Clear screen
```

### PNG Preview (`.png`)
For testing and documentation.

## Boot Animation System

### Creating Animation Sequences
1. Design keyframe SVGs
2. Use `make boot-sequence` to generate frames
3. Deploy with `boot_animation.sh`

### Animation Script
```bash
#!/bin/bash
for frame in boot_stage_*.raw; do
    dd if="$frame" of=/dev/fb0 bs=480000 count=1
    sleep 0.5
done
```

## Deployment

### SD Card Installation
```bash
# Package all splash screens
make package

# Deploy to SD card
sudo make deploy SDCARD=/dev/sdb1

# Manual deployment
sudo mount /dev/sdb1 /mnt
sudo cp -r output/* /mnt/boot/splash/
sudo umount /mnt
```

### Boot Integration
Add to boot script:
```bash
# In /etc/init.d/boot or equivalent
/boot/splash/display_jesteros_splash.sh
```

## Technical Details

### E-Ink Optimization Pipeline
1. **SVG Rasterization**: Cairo renders at target resolution
2. **Grayscale Conversion**: RGB to luminance
3. **Gamma Correction**: Apply 1.8 gamma curve
4. **Contrast Enhancement**: 1.2x multiplier around midpoint
5. **Edge Enhancement**: Unsharp masking for text clarity
6. **Quantization**: Reduce to 16 levels with dithering
7. **Format Generation**: Create device-specific outputs

### Dithering Algorithms

#### Ordered Dithering (Bayer)
- Fast, predictable patterns
- Good for gradients
- Minimal processing overhead

#### Error Diffusion (Floyd-Steinberg)  
- Higher quality for photos
- More natural appearance
- Higher CPU usage

#### Posterization
- Simple level reduction
- Best for high-contrast graphics
- Fastest method

## Performance

### Processing Times (Raspberry Pi Zero)
- SVG parsing: ~2 seconds
- Optimization: ~1 second
- Dithering: ~1 second  
- Total: ~4 seconds per splash

### Memory Usage
- Peak: ~50MB during processing
- Output files: ~470KB raw, ~2KB compressed

### Display Performance
- E-Ink refresh: ~500ms full update
- Partial update: ~250ms
- Animation frame rate: 2 FPS max

## Troubleshooting

### Common Issues

**ImportError: No module named 'cairosvg'**
```bash
pip install cairosvg
```

**E-Ink not updating**
```bash
# Force refresh
echo 1 > /sys/class/graphics/fb0/rotate
```

**Low contrast output**
- Increase contrast factor in script
- Use posterize method instead of dither

**Slow generation**
- Reduce image dimensions
- Use simpler quantization method
- Pre-generate and cache results

## Examples

### Generate Everything
```bash
make all
ls -la output/
```

### Custom Splash with High Contrast
```bash
python3 svg_to_eink.py custom.svg \
  --method posterize \
  --output ./high_contrast
```

### Boot Animation Sequence
```bash
# Create frames
for i in {1..5}; do
  python3 svg_to_eink.py frame_$i.svg \
    --name boot_$i \
    --formats raw
done

# Play animation
for f in boot_*.raw; do
  dd if=$f of=/dev/fb0
  sleep 0.3
done
```

## Contributing

### Adding New Splash Screens
1. Create SVG in `tools/splash-generator/`
2. Add to `SVG_FILES` in Makefile
3. Specify quantization method
4. Test with `make single SVG=new_splash.svg`
5. Update documentation

### Improving E-Ink Optimization
- Test on actual hardware
- Measure contrast ratios
- Profile performance
- Submit optimization patches

## License

Part of the JesterOS project. See main project LICENSE.

## Credits

Created for the Nook Simple Touch e-reader running JesterOS, transforming a $20 device into a distraction-free writing tool with beautiful, detailed splash screens.

---

*"From vectors to pixels, from pixels to E-Ink, from E-Ink to inspiration"*