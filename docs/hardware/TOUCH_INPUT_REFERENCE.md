# Touch Input System Reference
*Nook Simple Touch - zForce Infrared Touchscreen Documentation*

## 📋 Quick Reference

| Component | Specification | JesterOS Impact |
|-----------|---------------|-----------------|
| **Technology** | Infrared (IR) optical | Works with gloves/stylus |
| **Touch Points** | Single-touch only | Simple, focused interaction |
| **Resolution** | 600×800 pixels | 1:1 display mapping |
| **Response Time** | <30ms latency | Responsive menus |
| **Device Node** | `/dev/input/event2` | Standard Linux input |
| **Power Draw** | <1mA idle, 5mA active | Excellent battery life |

---

## 🎯 Hardware Architecture

### zForce Touch Controller
```yaml
Controller: Neonode zForce
Technology: Infrared optical touch frame
Interface: I2C bus (address 0x50)
IRQ Pin: GPIO 273
Driver: zforce.ko kernel module
Firmware: Embedded in controller
```

### How Infrared Touch Works
```
┌─────────────────────────────────────┐
│         IR LED Emitters (Top)        │
│  ●  ●  ●  ●  ●  ●  ●  ●  ●  ●  ●   │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│◆│     Display Area (600×800)     │◆│ ← IR Detectors
│ │                                 │ │    (Sides)
│ │     [Touch breaks IR beams]    │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│  ●  ●  ●  ●  ●  ●  ●  ●  ●  ●  ●   │
│        IR LED Emitters (Bottom)      │
└─────────────────────────────────────┘

When touched, finger breaks X and Y IR beams
Controller calculates intersection point
```

### Advantages of IR Touch
- ✅ Works with any object (finger, stylus, glove)
- ✅ No pressure required (hover detection possible)
- ✅ Doesn't affect display clarity
- ✅ Extremely low power consumption
- ✅ No calibration drift over time

---

## 🔌 System Integration

### Input Device Hierarchy
```bash
/sys/class/input/input2/
├── capabilities/
│   ├── abs         # Absolute positioning
│   ├── ev          # Event types (0x0b = ABS + KEY)
│   └── key         # Button support (0x400 = BTN_TOUCH)
├── device/
│   ├── name        # "zForce Touchscreen"
│   ├── phys        # Physical location
│   └── poll        # Polling rate (20ms)
├── id/
│   ├── bustype     # 0x0018 (I2C)
│   ├── product     # Product ID
│   ├── vendor      # Vendor ID
│   └── version     # Driver version
└── properties      # Device properties
```

### Device Node Details
```bash
# Primary touch input device
/dev/input/event2
├── Type: Character Device
├── Major: 13 (input subsystem)
├── Minor: 66 (event2)
├── Permissions: crw-rw---- root input
└── Protocol: Linux Input Event Interface
```

---

## 📊 Input Event Protocol

### Event Structure (16 bytes)
```c
struct input_event {
    struct timeval time;  // 8 bytes: timestamp
    __u16 type;          // 2 bytes: event type
    __u16 code;          // 2 bytes: event code
    __s32 value;         // 4 bytes: event value
};
```

### Event Types & Codes
```c
// Event Types
#define EV_SYN    0x00  // Synchronization events
#define EV_KEY    0x01  // Button/key state changes
#define EV_ABS    0x03  // Absolute axis values

// Event Codes for EV_ABS
#define ABS_X     0x00  // X coordinate
#define ABS_Y     0x01  // Y coordinate

// Event Codes for EV_KEY
#define BTN_TOUCH 0x14a // Touch down/up

// Event Codes for EV_SYN
#define SYN_REPORT 0x00 // End of event group
```

### Typical Touch Sequence
```
1. Touch Down:
   EV_ABS    ABS_X    300     // X coordinate
   EV_ABS    ABS_Y    400     // Y coordinate
   EV_KEY    BTN_TOUCH  1     // Touch pressed
   EV_SYN    SYN_REPORT 0     // End of events

2. Touch Move:
   EV_ABS    ABS_X    305     // New X
   EV_ABS    ABS_Y    402     // New Y
   EV_SYN    SYN_REPORT 0     // End of events

3. Touch Up:
   EV_KEY    BTN_TOUCH  0     // Touch released
   EV_SYN    SYN_REPORT 0     // End of events
```

---

## 🎮 Touch Handling Implementation

### Basic Event Reader (C)
```c
#include <linux/input.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

int main() {
    int fd;
    struct input_event ev;
    int x = 0, y = 0;
    
    fd = open("/dev/input/event2", O_RDONLY);
    if (fd < 0) {
        perror("Cannot open touch device");
        return 1;
    }
    
    while (1) {
        if (read(fd, &ev, sizeof(ev)) == sizeof(ev)) {
            switch (ev.type) {
                case EV_ABS:
                    if (ev.code == ABS_X) x = ev.value;
                    if (ev.code == ABS_Y) y = ev.value;
                    break;
                    
                case EV_KEY:
                    if (ev.code == BTN_TOUCH) {
                        if (ev.value == 1) {
                            printf("Touch DOWN at (%d, %d)\n", x, y);
                        } else {
                            printf("Touch UP at (%d, %d)\n", x, y);
                        }
                    }
                    break;
                    
                case EV_SYN:
                    // End of event group
                    break;
            }
        }
    }
    
    close(fd);
    return 0;
}
```

### Shell Script Handler
```bash
#!/bin/bash
# /usr/local/jesteros/input/touch-monitor.sh

TOUCH_DEV="/dev/input/event2"
FIFO="/tmp/touch_events"

# Create named pipe for touch events
[ -p "$FIFO" ] || mkfifo "$FIFO"

# Background process to read touch events
read_touch_events() {
    # Use evtest or custom binary to parse events
    evtest "$TOUCH_DEV" | while read line; do
        if echo "$line" | grep -q "ABS_X"; then
            X=$(echo "$line" | awk '{print $NF}')
        elif echo "$line" | grep -q "ABS_Y"; then
            Y=$(echo "$line" | awk '{print $NF}')
        elif echo "$line" | grep -q "BTN_TOUCH.*value 1"; then
            echo "DOWN $X $Y" > "$FIFO"
        elif echo "$line" | grep -q "BTN_TOUCH.*value 0"; then
            echo "UP $X $Y" > "$FIFO"
        fi
    done
}

# Process touch events
process_touch_events() {
    while read event x y < "$FIFO"; do
        case "$event" in
            DOWN)
                handle_touch_down "$x" "$y"
                ;;
            UP)
                handle_touch_up "$x" "$y"
                ;;
        esac
    done
}

# Touch zone detection
handle_touch_down() {
    local x=$1 y=$2
    
    # Define menu zones (example)
    if [ "$y" -ge 50 ] && [ "$y" -lt 150 ]; then
        echo "Menu Item 1 selected"
        /usr/local/jesteros/ui/menu/action1.sh
    elif [ "$y" -ge 150 ] && [ "$y" -lt 250 ]; then
        echo "Menu Item 2 selected"
        /usr/local/jesteros/ui/menu/action2.sh
    fi
}

# Start monitoring
read_touch_events &
process_touch_events
```

---

## 📐 Touch Zone Design Guidelines

### Optimal Touch Target Sizes
```
Minimum Recommended Sizes:
├── Button Height: 80px (12mm)
├── Button Width: 100px (15mm)
├── Spacing: 20px (3mm) minimum
├── Edge Padding: 10px (1.5mm)
└── Corner Targets: 100×100px

Human Finger Statistics:
├── Average Touch Area: 8-10mm diameter
├── Index Finger: 15-20mm wide
├── Thumb: 20-25mm wide
└── Stylus: 1-2mm precision
```

### JesterOS Menu Layout
```
Portrait Mode (600×800):
┌──────────────────────────────────┐
│ Status Bar (non-touch)    50px   │
├──────────────────────────────────┤
│                                  │
│  ┌──────────────────────────┐   │
│  │ Menu Item 1      100px   │   │ ← Large touch targets
│  └──────────────────────────┘   │
│         20px spacing             │
│  ┌──────────────────────────┐   │
│  │ Menu Item 2      100px   │   │
│  └──────────────────────────┘   │
│         20px spacing             │
│  ┌──────────────────────────┐   │
│  │ Menu Item 3      100px   │   │
│  └──────────────────────────┘   │
│                                  │
├──────────────────────────────────┤
│ Navigation Bar           100px   │
│  [Back] [Home] [Settings]        │
└──────────────────────────────────┘
```

---

## ⚡ Performance Optimization

### Touch Responsiveness
```bash
# Optimize touch sampling rate
echo 20 > /sys/class/input/input2/poll  # 50Hz sampling

# Reduce input latency
echo 1 > /proc/sys/kernel/sched_rt_runtime_us

# Priority for touch handler
nice -n -10 /usr/local/jesteros/input/touch-handler.sh
```

### Power Management
```bash
# Touch controller power states
echo auto > /sys/class/input/input2/device/power/control

# Wake on touch
echo enabled > /sys/class/input/input2/device/power/wakeup

# Idle timeout (seconds)
echo 30 > /sys/class/input/input2/device/power/autosuspend_delay_ms
```

---

## 🎯 JesterOS Integration Strategy

### Menu System Integration
```bash
# /etc/jesteros/touch.conf
# Touch configuration for JesterOS menus

# Touch zones (x,y,width,height,action)
ZONES="
0,50,600,100,menu_write
0,150,600,100,menu_read
0,250,600,100,menu_settings
0,700,200,100,nav_back
200,700,200,100,nav_home
400,700,200,100,nav_settings
"

# Touch behavior
TOUCH_TIMEOUT=2000      # Long press threshold (ms)
DOUBLE_TAP_TIME=500     # Double tap window (ms)
DEAD_ZONE=5            # Ignore movement < 5 pixels
DEBOUNCE=50           # Debounce time (ms)
```

### Gesture Emulation
```bash
# Emulate gestures using single touch
detect_gesture() {
    local start_x=$1 start_y=$2
    local end_x=$3 end_y=$4
    local duration=$5
    
    local dx=$((end_x - start_x))
    local dy=$((end_y - start_y))
    
    # Long press detection
    if [ $dx -lt 10 ] && [ $dy -lt 10 ] && [ $duration -gt 1000 ]; then
        echo "LONG_PRESS"
        return
    fi
    
    # Swipe detection (>100px movement)
    if [ ${dx#-} -gt 100 ]; then
        [ $dx -gt 0 ] && echo "SWIPE_RIGHT" || echo "SWIPE_LEFT"
    elif [ ${dy#-} -gt 100 ]; then
        [ $dy -gt 0 ] && echo "SWIPE_DOWN" || echo "SWIPE_UP"
    else
        echo "TAP"
    fi
}
```

---

## 🔧 Calibration & Testing

### Touch Calibration
```bash
# Check current calibration
cat /sys/class/input/input2/device/calibration

# Test touch accuracy
evtest /dev/input/event2

# Visual touch test
cat /dev/input/event2 | hexdump -C
```

### Debug Touch Events
```bash
# Monitor raw events
cat /proc/bus/input/devices | grep -A 5 "zForce"

# Watch event stream
evtest /dev/input/event2 | grep -E "ABS_X|ABS_Y|BTN_TOUCH"

# Log touch coordinates
while true; do
    evtest /dev/input/event2 | \
    awk '/ABS_X/{x=$NF} /ABS_Y/{y=$NF} /BTN_TOUCH.*value 1/{print x,y}'
done
```

---

## ⚠️ Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| **No touch response** | Device suspended | Check `/sys/power/state` |
| **Incorrect coordinates** | Screen rotation | Adjust coordinate mapping |
| **Ghost touches** | IR interference | Clean bezel, check for obstructions |
| **Delayed response** | CPU throttling | Increase touch handler priority |
| **Missing events** | Buffer overflow | Increase event buffer size |

---

## 🎭 The Jester Says

```
    .-.
   (o o)  "Touch so light, precise and true,
   | O |   Infrared beams see all you do,
    '-'    No pressure needed, just intent,
           Perfect for the writer bent!"
```

---

## Summary

The zForce infrared touch system provides reliable, low-power touch input ideal for JesterOS:

1. **Simple single-touch** interface perfect for focused writing
2. **Standard Linux input events** simplify integration  
3. **Infrared technology** works with any pointing device
4. **Excellent battery efficiency** with interrupt-driven design
5. **Direct coordinate mapping** (600×800) matches display

The system's simplicity is its strength - no complex multi-touch gestures to implement or debug, just reliable touch detection for menu navigation and text selection.

**Key Integration Points**:
- `/dev/input/event2` for touch events
- 80-100px minimum touch targets
- GPIO 273 IRQ for wake from sleep
- Simple event structure (X, Y, TOUCH)

---

*Touch Input System Reference v1.0*  
*Based on hardware investigation via ADB*  
*JesterOS Hardware Documentation Series*