# Physical Button Navigation Guide

## Hardware Overview

The Nook Simple Touch features 5 physical buttons with intelligent hardware partitioning:

### Button Layout
```
    [Power Button] (top center)
           |
    +--------------+
    |              |
    |   E-Ink      |
    |   Display    |
    |              |
    +--------------+
    [<]  [Home]  [>]
    Left  Home  Right
```

### Technical Specifications

| Button | GPIO | Controller | Event Device | Key Code | Wake Capable |
|--------|------|------------|--------------|----------|--------------|
| Power | GPIO_116 | OMAP3621 | /dev/input/event0 | KEY_POWER (116) | Yes (all states) |
| Home | GPIO_102 | OMAP3621 | /dev/input/event0 | KEY_HOME (102) | Yes (light sleep) |
| Left Page | TWL_GPIO_6 | TWL4030 | /dev/input/event1 | KEY_PAGEUP (104) | Yes (light sleep) |
| Right Page | TWL_GPIO_7 | TWL4030 | /dev/input/event1 | KEY_PAGEDOWN (109) | Yes (light sleep) |

## Button Functions

### Individual Buttons

#### Power Button
- **Short Press** (<500ms): Open power menu
- **Medium Press** (500-2000ms): Quick sleep
- **Long Press** (>2000ms): Deep sleep/wake toggle
- **Wake Function**: Wakes from any sleep state

#### Home Button
- **Press**: Return to main JesterOS menu
- **From Vim**: Saves and exits to menu
- **From Menu**: Refreshes current menu

#### Left Page Button
- **In Vim**: Page up (Ctrl+B)
- **In Menu**: Previous option
- **In Reader**: Previous page
- **Writing Mode**: Previous paragraph

#### Right Page Button
- **In Vim**: Page down (Ctrl+F)
- **In Menu**: Next option
- **In Reader**: Next page
- **Writing Mode**: Next paragraph

### Button Combinations

| Combination | Function | Use Case |
|-------------|----------|----------|
| Power + Home | Screenshot | Capture current screen to /sdcard/ |
| Left + Right | Toggle Writing Mode | Switch between focused writing and normal |
| Power + Left | Decrease brightness | Adjust E-Ink contrast |
| Power + Right | Increase brightness | Adjust E-Ink contrast |
| Home + Left | Previous document | Quick document switching |
| Home + Right | Next document | Quick document switching |

## Software Architecture

### Input Event Flow
```
Physical Button Press
        ↓
GPIO Interrupt (OMAP/TWL4030)
        ↓
Kernel Driver (gpio-keys/twl4030-keypad)
        ↓
Input Subsystem (/dev/input/eventX)
        ↓
Button Daemon (button-daemon)
        ↓
JesterOS Interface (/var/jesteros/buttons/)
        ↓
Application (Vim/Menu/Reader)
```

### JesterOS Button Interface

Status files in `/var/jesteros/buttons/`:
```
power          # Current power button state
home           # Current home button state  
page_left      # Current left page button state
page_right     # Current right page button state
last_event     # Timestamp of last button event
last_action    # Description of last action taken
writing_mode   # Writing mode on/off status
```

## Installation & Configuration

### 1. Install Button Handler
```bash
# Copy button handler scripts
cp runtime/4-hardware/input/button-handler.sh /runtime/4-hardware/input/
chmod +x /runtime/4-hardware/input/button-handler.sh

# Compile C daemon (optional, for better performance)
arm-linux-gnueabi-gcc -static -o button-daemon button-daemon.c
cp button-daemon /runtime/4-hardware/input/
```

### 2. Start Button Service
```bash
# Shell-based handler
/runtime/4-hardware/input/button-handler.sh monitor &

# OR C-based daemon (recommended)
/runtime/4-hardware/input/button-daemon
```

### 3. Configure Vim Integration
Add to `.vimrc`:
```vim
source /runtime/2-application/writing/vim-button-config.vim
```

### 4. Test Buttons
```bash
# Interactive test mode
/runtime/4-hardware/input/button-handler.sh test

# Check button status
/runtime/4-hardware/input/button-handler.sh status

# View button logs
tail -f /var/log/button-daemon.log
```

## Writing Mode Integration

### Navigation Modes

The page buttons can cycle through different navigation modes optimized for writing:

1. **Page Mode** (default)
   - Left: Full page up
   - Right: Full page down
   - Best for: Reading, reviewing

2. **Paragraph Mode**
   - Left: Previous paragraph
   - Right: Next paragraph
   - Best for: Writing, editing

3. **Section Mode**
   - Left: Previous markdown header
   - Right: Next markdown header
   - Best for: Documentation, notes

4. **Chapter Mode**
   - Left: Previous chapter marker
   - Right: Next chapter marker
   - Best for: Novel writing

### Vim Commands
```vim
:WritingMode   " Toggle focused writing mode
:NavMode       " Cycle through navigation modes
:ButtonHelp    " Show button guide in Vim
```

## Power Management

### Button Power Consumption

| State | Power Draw | Notes |
|-------|------------|-------|
| Idle | <0.1mW | Interrupt-driven, no polling |
| Press | 1-2mW | Brief spike during event |
| Held | 0.5mW | Continuous state monitoring |

### Wake Behavior

- **Deep Sleep**: Only Power button wakes
- **Light Sleep**: All buttons wake
- **Screen Off**: All buttons wake and perform action
- **Active**: All buttons immediately responsive

### Optimization Tips

1. **Disable unused buttons** to save power:
   ```bash
   echo 0 > /sys/class/input/event1/device/enabled
   ```

2. **Adjust debounce timing** for responsiveness:
   ```bash
   echo 50 > /sys/devices/platform/gpio-keys/debounce_interval
   ```

3. **Configure wake sources** for battery life:
   ```bash
   echo disabled > /sys/devices/platform/gpio-keys/wakeup
   ```

## Troubleshooting

### Buttons Not Responding

1. **Check input devices**:
   ```bash
   ls -la /dev/input/event*
   cat /proc/bus/input/devices
   ```

2. **Test with evtest**:
   ```bash
   evtest /dev/input/event0  # GPIO buttons
   evtest /dev/input/event1  # TWL4030 buttons
   ```

3. **Check GPIO exports**:
   ```bash
   ls /sys/class/gpio/
   cat /sys/class/gpio/gpio116/value  # Power button
   ```

### Button Daemon Issues

1. **Check if daemon is running**:
   ```bash
   ps aux | grep button-daemon
   ```

2. **View daemon logs**:
   ```bash
   tail -f /var/log/button-daemon.log
   ```

3. **Restart daemon**:
   ```bash
   pkill button-daemon
   /runtime/4-hardware/input/button-daemon
   ```

### Wrong Button Mapping

1. **Check key layout**:
   ```bash
   cat /system/usr/keylayout/gpio-keys.kl
   cat /system/usr/keylayout/twl4030-keypad.kl
   ```

2. **Override with custom layout**:
   ```bash
   # Create custom layout
   cat > /data/gpio-keys-custom.kl <<EOF
   key 116 POWER
   key 102 HOME
   EOF
   ```

## Advanced Customization

### Custom Button Actions

Edit `/runtime/4-hardware/input/button-handler.sh`:
```bash
handle_custom_action() {
    case "$1" in
        power_double)
            # Your custom power double-tap action
            ;;
        home_long)
            # Your custom home long-press action
            ;;
    esac
}
```

### Button Timing Configuration

Adjust timing constants in `button-daemon.c`:
```c
#define LONG_PRESS_MS     2000  // Long press threshold
#define DOUBLE_TAP_MS     500   // Double tap window
#define DEBOUNCE_MS       50    // Debounce delay
```

### Creating Button Macros

Add to Vim configuration:
```vim
" Custom button macro for word count
function! ButtonWordCount()
    let words = system('wc -w ' . expand('%'))
    echo "Words: " . words
endfunction

" Map to button combination
autocmd User ButtonCombo1 call ButtonWordCount()
```

## Best Practices

1. **Preserve Battery**: Use interrupt-driven handling, not polling
2. **Respect Sleep**: Don't wake unnecessarily from deep sleep
3. **Visual Feedback**: Update E-Ink to confirm button press
4. **Consistent Behavior**: Same button = same action across contexts
5. **Recovery Options**: Always provide button combo for recovery

## Integration Examples

### Menu Integration
```bash
# In nook-menu.sh
case "$key" in
    $KEY_PAGEUP)
        menu_previous
        ;;
    $KEY_PAGEDOWN)
        menu_next
        ;;
    $KEY_HOME)
        menu_home
        ;;
esac
```

### Writing Statistics
```bash
# Track button usage for writing stats
echo $(($(cat /var/jesteros/stats/page_turns) + 1)) > \
    /var/jesteros/stats/page_turns
```

### Emergency Recovery
```bash
# Power + Home + Both Pages = Factory reset
if [ "$power" = "1" ] && [ "$home" = "1" ] && 
   [ "$left" = "1" ] && [ "$right" = "1" ]; then
    /runtime/recovery/factory-reset.sh
fi
```

## Summary

The Nook Simple Touch button system provides:
- **5 physical buttons** with distinct functions
- **Hardware-level efficiency** via GPIO interrupts
- **Flexible navigation modes** for different writing styles
- **Deep Vim integration** for seamless writing
- **Power-aware design** with wake control
- **Extensive customization** options

With proper configuration, the buttons transform the Nook into an efficient, distraction-free writing device where navigation becomes second nature.

---

*"Five buttons, infinite possibilities!"* - The Button Jester 🎭