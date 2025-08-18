#!/bin/bash
# Font configuration for E-Ink readability
# Optimized for Nook's 800x600 display

set -euo pipefail
trap 'echo "Error configuring font at line $LINENO"' ERR

# Font priority for E-Ink readability
# Terminus is designed for long terminal sessions
FONT_PRIORITY=(
    "ter-v22n"      # Terminus 22pt - best for E-Ink
    "ter-v20n"      # Terminus 20pt - good alternative
    "ter-v16n"      # Terminus 16pt - more text visible
    "lat9w-16"      # Latin wide 16pt - fallback
    "lat2-16"       # Latin2 16pt - basic fallback
    "default8x16"   # Kernel default - last resort
)

# Display abstraction for compatibility
display_message() {
    local msg="$1"
    if command -v fbink >/dev/null 2>&1 && [ -e /dev/fb0 ]; then
        # E-Ink available
        fbink -q -y -30 "$msg" 2>/dev/null || echo "$msg"
    else
        # Fallback to terminal
        echo "$msg"
    fi
}

# Find best available font
find_best_font() {
    local font_dir="/usr/share/consolefonts"
    
    for font in "${FONT_PRIORITY[@]}"; do
        # Check with .psf.gz extension first
        if [ -f "${font_dir}/${font}.psf.gz" ]; then
            echo "${font}.psf.gz"
            return 0
        fi
        # Check without extension
        if [ -f "${font_dir}/${font}.psf" ]; then
            echo "${font}.psf"
            return 0
        fi
        # Check other variations
        if ls "${font_dir}/${font}"* >/dev/null 2>&1; then
            basename "$(ls "${font_dir}/${font}"* | head -1)"
            return 0
        fi
    done
    
    # No preferred font found
    return 1
}

# Apply font configuration
configure_font() {
    local font_dir="/usr/share/consolefonts"
    local selected_font=""
    
    # Ensure font directory exists
    if [ ! -d "$font_dir" ]; then
        display_message "Font directory missing, using kernel defaults"
        return 1
    fi
    
    # Find best available font
    if selected_font=$(find_best_font); then
        display_message "Setting font: ${selected_font}"
        
        # Try different font setting methods for compatibility
        if command -v setfont >/dev/null 2>&1; then
            setfont "${font_dir}/${selected_font}" 2>/dev/null || {
                display_message "setfont failed, trying consolechars..."
                if command -v consolechars >/dev/null 2>&1; then
                    consolechars -f "${selected_font%.psf.gz}" 2>/dev/null || {
                        display_message "Font setting failed, using defaults"
                        return 1
                    }
                fi
            }
        elif command -v consolechars >/dev/null 2>&1; then
            consolechars -f "${selected_font%.psf.gz}" 2>/dev/null || {
                display_message "consolechars failed, using defaults"
                return 1
            }
        else
            display_message "No font tools available, using kernel defaults"
            return 1
        fi
        
        # Save configuration for persistence
        if [ -w /etc/default/console-setup ]; then
            echo "FONT='${selected_font}'" > /etc/default/console-setup
            echo "FONTFACE='Terminus'" >> /etc/default/console-setup
            echo "FONTSIZE='11x22'" >> /etc/default/console-setup
        fi
        
        display_message "Font configured for optimal E-Ink readability"
        return 0
    else
        display_message "No Terminus fonts found, using kernel defaults"
        return 1
    fi
}

# Optimize console for E-Ink
optimize_console() {
    # Disable cursor blinking (saves E-Ink refreshes)
    echo 0 > /sys/class/graphics/fbcon/cursor_blink 2>/dev/null || true
    
    # Set console blank timeout (0 = never blank)
    setterm -blank 0 2>/dev/null || true
    
    # Disable console beep (for peaceful writing)
    setterm -blength 0 2>/dev/null || true
    
    # Set dark-on-light for E-Ink (if supported)
    setterm -inversescreen on 2>/dev/null || true
}

# Main execution
main() {
    display_message "Configuring fonts for E-Ink display..."
    
    # Configure font
    configure_font
    
    # Optimize console settings
    optimize_console
    
    display_message "Font setup complete!"
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi