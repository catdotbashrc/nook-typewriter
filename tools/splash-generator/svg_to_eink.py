#!/usr/bin/env python3
"""
svg_to_eink.py - SVG to E-Ink Splash Screen Generator for JesterOS
Converts SVG vector graphics to optimized E-Ink display formats
Supports the Nook Simple Touch's 600x800 16-grayscale display
"""

import argparse
import numpy as np
from PIL import Image, ImageDraw, ImageFont
import cairosvg
import io
import struct
import os
from pathlib import Path

class EInkSplashGenerator:
    """Generate E-Ink optimized splash screens from SVG files"""
    
    def __init__(self, width=600, height=800, grayscale_levels=16):
        """
        Initialize generator for Nook Simple Touch display
        
        Args:
            width: Display width in pixels (600 for Nook)
            height: Display height in pixels (800 for Nook)
            grayscale_levels: Number of gray levels (16 for E-Ink Pearl)
        """
        self.width = width
        self.height = height
        self.grayscale_levels = grayscale_levels
        self.dither_matrix = self._create_bayer_matrix(4)
        
    def _create_bayer_matrix(self, n):
        """Create Bayer dithering matrix for smooth gradients"""
        if n == 1:
            return np.array([[0, 2], [3, 1]]) / 4.0
        else:
            smaller = self._create_bayer_matrix(n - 1)
            size = len(smaller)
            matrix = np.zeros((size * 2, size * 2))
            matrix[:size, :size] = 4 * smaller
            matrix[:size, size:] = 4 * smaller + 2
            matrix[size:, :size] = 4 * smaller + 3
            matrix[size:, size:] = 4 * smaller + 1
            return matrix / (4 ** n)
    
    def svg_to_image(self, svg_path):
        """
        Convert SVG to PIL Image at target resolution
        
        Args:
            svg_path: Path to SVG file
            
        Returns:
            PIL Image object
        """
        # Render SVG to PNG using cairosvg
        png_data = cairosvg.svg2png(
            url=svg_path,
            output_width=self.width,
            output_height=self.height
        )
        
        # Convert to PIL Image
        image = Image.open(io.BytesIO(png_data))
        
        # Convert to grayscale
        if image.mode != 'L':
            image = image.convert('L')
            
        return image
    
    def apply_eink_optimization(self, image):
        """
        Optimize image for E-Ink display characteristics
        
        Args:
            image: PIL Image object
            
        Returns:
            Optimized PIL Image
        """
        # Convert to numpy array for processing
        img_array = np.array(image, dtype=np.float32) / 255.0
        
        # Apply gamma correction for E-Ink
        # E-Ink displays have different gamma than LCD
        gamma = 1.8  # E-Ink typical gamma
        img_array = np.power(img_array, 1.0 / gamma)
        
        # Enhance contrast for better E-Ink visibility
        # E-Ink has lower contrast than LCD
        img_array = self._enhance_contrast(img_array, 1.2)
        
        # Apply edge enhancement for crisp lines
        img_array = self._enhance_edges(img_array)
        
        # Convert back to 8-bit
        img_array = (img_array * 255).clip(0, 255).astype(np.uint8)
        
        return Image.fromarray(img_array, mode='L')
    
    def _enhance_contrast(self, img_array, factor=1.2):
        """Enhance contrast for E-Ink display"""
        # Adjust contrast around middle gray
        mean = 0.5
        return ((img_array - mean) * factor + mean).clip(0, 1)
    
    def _enhance_edges(self, img_array):
        """Enhance edges for sharper E-Ink rendering"""
        from scipy import ndimage
        
        # Simple unsharp masking
        blurred = ndimage.gaussian_filter(img_array, sigma=1)
        sharpened = img_array + 0.3 * (img_array - blurred)
        
        return sharpened.clip(0, 1)
    
    def quantize_to_eink_levels(self, image, method='dither'):
        """
        Quantize image to E-Ink grayscale levels
        
        Args:
            image: PIL Image object
            method: 'dither', 'posterize', or 'error_diffusion'
            
        Returns:
            Quantized PIL Image
        """
        if method == 'dither':
            return self._ordered_dither(image)
        elif method == 'posterize':
            return self._posterize(image)
        elif method == 'error_diffusion':
            return self._floyd_steinberg_dither(image)
        else:
            raise ValueError(f"Unknown quantization method: {method}")
    
    def _ordered_dither(self, image):
        """Apply ordered (Bayer) dithering"""
        img_array = np.array(image, dtype=np.float32) / 255.0
        
        # Tile dither matrix to image size
        h, w = img_array.shape
        dither_h, dither_w = self.dither_matrix.shape
        tiled_dither = np.tile(self.dither_matrix, 
                               (h // dither_h + 1, w // dither_w + 1))[:h, :w]
        
        # Apply dithering
        levels = self.grayscale_levels - 1
        dithered = img_array * levels + tiled_dither - 0.5
        quantized = np.round(dithered.clip(0, levels)) / levels
        
        return Image.fromarray((quantized * 255).astype(np.uint8), mode='L')
    
    def _posterize(self, image):
        """Simple posterization to N levels"""
        levels = self.grayscale_levels
        img_array = np.array(image)
        
        # Quantize to N levels
        step = 256 / levels
        quantized = (img_array / step).astype(int) * step
        
        return Image.fromarray(quantized.astype(np.uint8), mode='L')
    
    def _floyd_steinberg_dither(self, image):
        """Floyd-Steinberg error diffusion dithering"""
        img = np.array(image, dtype=np.float32)
        h, w = img.shape
        
        # Process each pixel
        for y in range(h):
            for x in range(w):
                old_pixel = img[y, x]
                new_pixel = round(old_pixel * (self.grayscale_levels - 1) / 255) * 255 / (self.grayscale_levels - 1)
                img[y, x] = new_pixel
                error = old_pixel - new_pixel
                
                # Distribute error to neighbors
                if x + 1 < w:
                    img[y, x + 1] += error * 7 / 16
                if y + 1 < h:
                    if x > 0:
                        img[y + 1, x - 1] += error * 3 / 16
                    img[y + 1, x] += error * 5 / 16
                    if x + 1 < w:
                        img[y + 1, x + 1] += error * 1 / 16
        
        return Image.fromarray(img.clip(0, 255).astype(np.uint8), mode='L')
    
    def generate_raw_framebuffer(self, image):
        """
        Generate raw framebuffer data for direct E-Ink write
        
        Args:
            image: PIL Image object
            
        Returns:
            bytes: Raw framebuffer data
        """
        # Ensure correct size
        if image.size != (self.width, self.height):
            image = image.resize((self.width, self.height), Image.LANCZOS)
        
        # Convert to raw bytes
        return image.tobytes()
    
    def generate_c_header(self, image, name="splash_screen"):
        """
        Generate C header file with image data
        
        Args:
            image: PIL Image object
            name: Variable name for the array
            
        Returns:
            str: C header file content
        """
        raw_data = self.generate_raw_framebuffer(image)
        
        header = f"""#ifndef {name.upper()}_H
#define {name.upper()}_H

#include <stdint.h>

// E-Ink splash screen data
// Resolution: {self.width}x{self.height}
// Grayscale levels: {self.grayscale_levels}
// Size: {len(raw_data)} bytes

const uint8_t {name}_data[] = {{
"""
        
        # Add data in hex format
        for i in range(0, len(raw_data), 16):
            line_data = raw_data[i:i+16]
            hex_values = ', '.join(f'0x{b:02x}' for b in line_data)
            header += f"    {hex_values},\n"
        
        header = header.rstrip(',\n') + '\n'
        header += f"""
}};

const uint32_t {name}_width = {self.width};
const uint32_t {name}_height = {self.height};
const uint32_t {name}_size = sizeof({name}_data);

#endif // {name.upper()}_H
"""
        
        return header
    
    def generate_shell_script(self, image_path, name="splash"):
        """
        Generate shell script for displaying the splash screen
        
        Args:
            image_path: Path where the raw image will be saved
            name: Name for the script
            
        Returns:
            str: Shell script content
        """
        script = f"""#!/bin/bash
# {name}_display.sh - Display E-Ink splash screen on Nook
# Generated by svg_to_eink.py

SPLASH_IMAGE="{image_path}"
FRAMEBUFFER="/dev/fb0"
EINK_CONTROL="/sys/class/graphics/fb0"

# Function to display splash
display_splash() {{
    echo "Displaying {name} splash screen..."
    
    # Disable auto-refresh during update
    echo 1 > $EINK_CONTROL/epd_disable 2>/dev/null || true
    
    # Write image to framebuffer
    if [ -f "$SPLASH_IMAGE" ]; then
        dd if="$SPLASH_IMAGE" of="$FRAMEBUFFER" bs=480000 count=1 2>/dev/null
    else
        echo "Error: Splash image not found at $SPLASH_IMAGE"
        return 1
    fi
    
    # Re-enable refresh and trigger high-quality update
    echo 0 > $EINK_CONTROL/epd_disable 2>/dev/null || true
    
    # Use GL16 mode for best quality (mode 3)
    echo "0,0,600,800,3,500,0" > $EINK_CONTROL/epd_area 2>/dev/null || \\
        echo 1 > $EINK_CONTROL/pgflip_refresh 2>/dev/null || true
    
    echo "Splash screen displayed"
}}

# Function for animated reveal
animated_reveal() {{
    echo "Animating splash reveal..."
    
    # Write image first
    dd if="$SPLASH_IMAGE" of="$FRAMEBUFFER" bs=480000 count=1 2>/dev/null
    
    # Reveal in strips
    for y in $(seq 0 50 800); do
        echo "0,$y,600,50,1,50,0" > $EINK_CONTROL/epd_area 2>/dev/null || true
        sleep 0.1
    done
}}

# Main execution
case "${{1:-display}}" in
    display)
        display_splash
        ;;
    animate)
        animated_reveal
        ;;
    clear)
        echo 1 > $EINK_CONTROL/pgflip_refresh
        ;;
    *)
        echo "Usage: $0 {{display|animate|clear}}"
        exit 1
        ;;
esac
"""
        
        return script
    
    def process_svg(self, svg_path, output_dir, name="splash", 
                   method='dither', formats=None):
        """
        Process SVG file and generate all output formats
        
        Args:
            svg_path: Path to input SVG file
            output_dir: Directory for output files
            name: Base name for output files
            method: Quantization method
            formats: List of output formats (default: all)
        """
        if formats is None:
            formats = ['png', 'raw', 'c_header', 'shell_script']
        
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
        
        print(f"Processing {svg_path}...")
        
        # Load and convert SVG
        print("  Converting SVG to raster...")
        image = self.svg_to_image(svg_path)
        
        # Optimize for E-Ink
        print("  Optimizing for E-Ink display...")
        image = self.apply_eink_optimization(image)
        
        # Quantize to E-Ink levels
        print(f"  Quantizing using {method} method...")
        image = self.quantize_to_eink_levels(image, method)
        
        # Generate outputs
        if 'png' in formats:
            png_path = output_dir / f"{name}.png"
            image.save(png_path, 'PNG')
            print(f"  Saved PNG: {png_path}")
        
        if 'raw' in formats:
            raw_path = output_dir / f"{name}.raw"
            raw_data = self.generate_raw_framebuffer(image)
            with open(raw_path, 'wb') as f:
                f.write(raw_data)
            print(f"  Saved raw framebuffer: {raw_path}")
        
        if 'c_header' in formats:
            header_path = output_dir / f"{name}.h"
            header_content = self.generate_c_header(image, name)
            with open(header_path, 'w') as f:
                f.write(header_content)
            print(f"  Generated C header: {header_path}")
        
        if 'shell_script' in formats:
            script_path = output_dir / f"display_{name}.sh"
            script_content = self.generate_shell_script(f"{name}.raw", name)
            with open(script_path, 'w') as f:
                f.write(script_content)
            os.chmod(script_path, 0o755)
            print(f"  Generated shell script: {script_path}")
        
        print(f"✓ Successfully generated {name} splash screen")
        return image


def main():
    parser = argparse.ArgumentParser(
        description='Convert SVG to E-Ink optimized splash screens'
    )
    parser.add_argument('svg', help='Input SVG file')
    parser.add_argument('-o', '--output', default='./output',
                       help='Output directory (default: ./output)')
    parser.add_argument('-n', '--name', default='splash',
                       help='Base name for output files (default: splash)')
    parser.add_argument('-m', '--method', 
                       choices=['dither', 'posterize', 'error_diffusion'],
                       default='dither',
                       help='Quantization method (default: dither)')
    parser.add_argument('-f', '--formats', nargs='+',
                       choices=['png', 'raw', 'c_header', 'shell_script'],
                       help='Output formats (default: all)')
    parser.add_argument('--width', type=int, default=600,
                       help='Display width (default: 600)')
    parser.add_argument('--height', type=int, default=800,
                       help='Display height (default: 800)')
    parser.add_argument('--levels', type=int, default=16,
                       help='Grayscale levels (default: 16)')
    
    args = parser.parse_args()
    
    # Create generator
    generator = EInkSplashGenerator(
        width=args.width,
        height=args.height,
        grayscale_levels=args.levels
    )
    
    # Process SVG
    generator.process_svg(
        svg_path=args.svg,
        output_dir=args.output,
        name=args.name,
        method=args.method,
        formats=args.formats
    )


if __name__ == '__main__':
    main()