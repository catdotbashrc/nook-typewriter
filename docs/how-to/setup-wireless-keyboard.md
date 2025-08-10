# How to Set Up a Wireless Keyboard

Using a wireless keyboard with your Nook requires extra power management but offers more flexibility.

## The Power Challenge

The Nook's USB port provides limited power:
- **Available**: ~100mA at 5V (0.5W)
- **Wired keyboard**: 50-100mA ✅
- **Wireless receiver**: 100-250mA ❌

Most wireless receivers exceed the Nook's power budget.

## Solution: Powered USB Hub

### What You Need

1. **Powered USB hub** (with AC adapter)
2. **USB OTG cable** (micro-USB to USB-A)
3. **Wireless keyboard** with USB receiver
4. **Power source** near your writing spot

### Recommended Hubs

Tested and working:
- Anker 4-Port USB 3.0 Hub
- AmazonBasics 4-Port Hub
- Belkin F4U041 (older but reliable)

Requirements:
- External power adapter
- At least 2A total output
- USB 2.0 is sufficient

## Setup Steps

### Step 1: Connect Hardware

```
[Nook] ← [OTG Cable] ← [Powered Hub] ← [AC Power]
                              ↑
                     [Wireless Receiver]
```

1. Plug hub into wall power
2. Connect OTG cable to Nook
3. Connect OTG cable to hub
4. Insert wireless receiver into hub

### Step 2: Verify Detection

```bash
# From terminal (menu option 7)
lsusb

# Should show something like:
# Bus 001 Device 003: ID 046d:c534 Logitech, Inc. Receiver
```

### Step 3: Test Keyboard

1. Type in terminal
2. If working, test in Vim
3. Check all keys function

## Keyboard Recommendations

### Best for Battery Life

**Logitech K380**
- Bluetooth version available
- 2-year battery life
- Compact size

**Microsoft Wireless Desktop 850**
- Reliable 2.4GHz
- Decent battery life
- Full-size layout

### Best for Typing

**Logitech MX Keys**
- Excellent key feel
- Backlit (but drains battery)
- Multi-device support

**Keychron K2/K6**
- Mechanical switches
- Long battery life
- Compact layouts

## Alternative: Bluetooth Setup

Some users report success with Bluetooth:

### Requirements
- Kernel with Bluetooth support
- Additional power draw
- More complex setup

### Basic Steps
```bash
# Install Bluetooth tools
apt-get update
apt-get install bluetooth bluez

# Enable Bluetooth
systemctl start bluetooth
bluetoothctl

# In bluetoothctl:
power on
agent on
scan on
# Find your keyboard
pair XX:XX:XX:XX:XX:XX
trust XX:XX:XX:XX:XX:XX
connect XX:XX:XX:XX:XX:XX
```

⚠️ **Warning**: Bluetooth significantly reduces battery life.

## Power Management Tips

### Hub Power Saving

1. **Use a hub with individual port switches**
   - Turn off unused ports
   - Reduces interference

2. **Smart Power Strips**
   - Auto-off when Nook sleeps
   - Saves standby power

3. **Battery Pack Option**
   ```
   [Nook] ← [OTG] ← [Hub] ← [USB Battery Pack]
   ```
   - Portable solution
   - 10,000mAh = weeks of typing

### Keyboard Power Saving

- Remove keyboard batteries when not in use
- Use keyboards with power switches
- Choose 2.4GHz over Bluetooth
- Disable keyboard backlighting

## Troubleshooting

### Keyboard Not Detected

1. **Check power**
   - Hub LED should be on
   - Try different outlet

2. **Check connections**
   - Reseat all cables
   - Try different USB port on hub

3. **Check receiver**
   ```bash
   dmesg | tail -20
   ```
   Look for USB connection messages

### Intermittent Connection

Common causes:
- Insufficient hub power
- Interference from other devices
- Failing keyboard batteries
- Bad USB cable

Solutions:
- Use powered hub with higher amperage
- Move away from WiFi routers
- Replace keyboard batteries
- Use shorter, quality cables

### Keys Repeating/Lag

E-Ink refresh can cause apparent lag:
```bash
# Adjust key repeat rate
xset r rate 200 30
```

Or in Vim:
```vim
set ttimeoutlen=50
set timeoutlen=1000
```

## Mobile Setup

For writing in cafés:

### Compact Solution
```
Nook + OTG Y-Cable + Keyboard Receiver + Power Bank
```

The Y-cable provides power while connecting devices.

### Ultra-Portable
- Foldable Bluetooth keyboard
- Accept higher battery drain
- Charge Nook more frequently

## Wired Alternatives

If wireless proves troublesome:

### Recommended Wired Keyboards
- **Apple Keyboard A1243** (excellent key feel)
- **Dell KB216** (reliable, cheap)
- **Mechanical TKL keyboards** (avoid RGB)

### Cable Management
- Coiled cables reduce clutter
- Right-angle adapters prevent strain
- Velcro strips for organization

## Success Stories

### User Setup Examples

**"Coffee Shop Writer"**
- Microsoft folding keyboard
- Small 4-port powered hub
- 20,000mAh power bank
- Total weight: <2 lbs

**"Home Office"**
- Mechanical keyboard (Keychron K2)
- Anker 7-port hub mounted under desk
- Permanent setup, no portability needed

**"Minimalist"**
- Switched to quality wired keyboard
- No hub or extra power needed
- Maximum reliability

## Decision Matrix

| If you... | Then use... |
|-----------|-------------|
| Write at home | Powered hub + favorite keyboard |
| Travel often | Wired compact keyboard |
| Need flexibility | Hub + battery pack |
| Value simplicity | Wired keyboard only |

---

⚡ **Bottom line**: Wireless is possible with a powered hub, but wired keyboards remain the most reliable option for the Nook typewriter.