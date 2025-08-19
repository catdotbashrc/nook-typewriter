# USB Keyboard Setup Guide - JesterOS

*Transform your Nook into a professional writing station with external keyboard support!*

## 🎯 Quick Start

### What You Need
1. **USB OTG Cable** - Micro-B to USB-A adapter (~$5)
2. **Powered USB Hub** - 5V external power (~$15)
3. **USB Keyboard** - Any HID-compliant keyboard (~$15-80)
   - Recommended: Skyloong GK61 mechanical keyboard
   - Budget: Any generic USB keyboard

### Total Investment: $35-100

---

## 📋 Step-by-Step Setup

### Step 1: Hardware Connection

```
Nook → OTG Cable → Powered Hub → Keyboard
        ↓
    [External 5V Power]
```

1. Connect OTG cable to Nook's micro-USB port
2. Connect powered hub to OTG cable
3. Plug in hub's power adapter
4. Connect keyboard to hub

### Step 2: Enable USB Host Mode

```bash
# On your Nook (via ADB or terminal)
cd /usr/local/bin
./usb-keyboard-setup.sh
```

The setup script will:
- Switch USB to host mode
- Detect connected keyboards
- Configure input handling
- Show connection status

### Step 3: Verify Connection

```bash
# Check keyboard status
cat /var/jesteros/keyboard/status

# Test keyboard input
cat /dev/input/event3  # Press keys to see events
```

---

## ⚙️ Configuration Options

### Manual Mode Switching

```bash
# Switch to host mode (keyboard)
echo "host" > /sys/devices/platform/musb_hdrc/mode

# Switch back to device mode (ADB)
echo "b_idle" > /sys/devices/platform/musb_hdrc/mode
```

### Keyboard Detection

```bash
# List connected USB devices
ls /sys/devices/platform/musb_hdrc/usb1/

# Check for keyboard
dmesg | grep -i "input.*keyboard"
```

---

## 🎨 Supported Keyboards

### Tested & Optimized
- **Skyloong GK61** - Full support with custom mappings
- **Generic USB Keyboards** - Basic HID support
- **Logitech K120** - Budget option, works well
- **Dell/HP USB Keyboards** - Standard office keyboards

### Special Features (GK61)
- RGB lighting disabled to save power
- Function keys mapped to JesterOS commands
- Mechanical switches for better typing feel
- Compact 60% layout saves desk space

---

## 🔧 Troubleshooting

### Keyboard Not Detected

1. **Check Power**
   ```bash
   # Verify hub is powered
   ls /sys/devices/platform/musb_hdrc/usb1/
   ```

2. **Reset USB Mode**
   ```bash
   ./usb-keyboard-manager.sh reset
   ```

3. **Check Connections**
   - Ensure OTG cable is properly connected
   - Verify hub power LED is on
   - Try different USB port on hub

### ADB Connection Lost

```bash
# Restore ADB mode
echo "b_idle" > /sys/devices/platform/musb_hdrc/mode

# Or use recovery script
./usb-keyboard-manager.sh restore-adb
```

### Power Issues

- **Symptom**: Keyboard connects but doesn't work
- **Solution**: Use powered hub (required for most keyboards)
- **Alternative**: Try low-power keyboard (<100mA)

---

## 📊 Writing Mode Integration

### Vim Configuration

JesterOS automatically configures Vim for external keyboards:

```vim
" Function key mappings
F1  - Help
F2  - Save file
F3  - Word count
F4  - Toggle spell check
F5  - Insert timestamp
F6  - Show writing stats
```

### Menu Navigation

```
Arrow Keys - Navigate menus
Enter      - Select option
Esc        - Go back
Tab        - Next field
```

---

## 🎯 Advanced Configuration

### Custom Key Mappings

Edit `/etc/jesteros/keyboard.conf`:

```bash
# Map F12 to writing stats
KEY_F12="cat /var/jesteros/typewriter/stats"

# Map PrintScreen to screenshot
KEY_PRINT="fbink -g"
```

### Auto-Detection on Boot

Enable automatic keyboard detection:

```bash
# Add to /etc/init.d/jesteros
/usr/local/bin/usb-keyboard-manager.sh auto &
```

---

## 🚀 Future Enhancements

### Planned Features
- Bluetooth keyboard support (via WiFi chip)
- Hot-swap between USB and Bluetooth
- Custom keyboard profiles
- Typing statistics per keyboard

### WiFi Keyboard (Coming Soon)
- No cables required
- Preserves ADB connectivity
- Multiple device support
- Better battery life

---

## 📝 Tips for Writers

1. **Mechanical Keyboards**: Better tactile feedback for long writing sessions
2. **60% Layouts**: Compact size perfect for portable writing setup
3. **Keyboard Shortcuts**: Learn JesterOS shortcuts for faster writing
4. **Power Management**: Unplug keyboard when not in use to save battery

---

## 🔗 Related Documentation

- [USB Keyboard Technical Analysis](../hardware/USB_KEYBOARD_WIFI_ANALYSIS.md)
- [Hardware Integration Guide](../04-kernel/kernel-integration-guide.md)
- [Testing USB Keyboards](../../tests/test-gk61-integration.sh)

---

*"By quill and keyboard, the modern scribe conquers words!"* 🃏⌨️📜