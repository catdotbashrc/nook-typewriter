# Power Management & Battery Optimization Guide

## Hardware Overview

The Nook Simple Touch features sophisticated power management through:
- **OMAP3621 SoC**: ARM Cortex-A8 @ 300-800MHz with dynamic frequency scaling
- **TWL4030 PMIC**: Texas Instruments Power Management IC
- **BQ27510 Fuel Gauge**: Accurate battery monitoring
- **1530mAh Li-ion Battery**: ~15-18 hours writing with optimization

## Power Consumption Analysis

### Component Power Draw

| Component | Sleep | Idle | Active | Notes |
|-----------|-------|------|--------|-------|
| CPU @ 300MHz | 1mW | 50mW | 100mW | Minimum frequency |
| CPU @ 600MHz | 1mW | 100mW | 200mW | Balanced mode |
| CPU @ 800MHz | 1mW | 150mW | 400mW | Maximum performance |
| E-Ink Display | 0mW | 0mW | 50-100mW | Only during refresh |
| WiFi Module | 0mW | 20mW | 150-200mW | TI WL1271 |
| eMMC Storage | <1mW | 5mW | 50mW | With runtime PM |
| RAM | 10mW | 20mW | 30mW | LPDDR |

### Battery Life Estimates

| Profile | CPU Speed | WiFi | Est. Battery Life | Use Case |
|---------|-----------|------|-------------------|----------|
| Max Battery | 300MHz | Off | 15-18 hours | Long writing sessions |
| Balanced | 600MHz | Power Save | 10-12 hours | Normal use |
| Performance | 800MHz | On | 6-8 hours | Syncing, heavy use |
| Plugged In | 800MHz | On | Unlimited | AC powered |

## Power Management Interfaces

### Battery Monitoring (`/sys/class/power_supply/battery/`)
```bash
capacity         # Battery percentage (0-100)
voltage_now      # Current voltage in microvolts
current_now      # Current draw in microamps (negative = discharge)
temp            # Battery temperature (°C * 10)
health          # Battery health status
status          # Charging/Discharging/Full
charge_full     # Full capacity in µAh
charge_now      # Current charge in µAh
```

### CPU Frequency Scaling (`/sys/devices/system/cpu/cpu0/cpufreq/`)
```bash
scaling_governor       # Current governor (powersave/conservative/ondemand/performance)
scaling_cur_freq      # Current CPU frequency
scaling_min_freq      # Minimum frequency limit
scaling_max_freq      # Maximum frequency limit
scaling_available_frequencies  # Available frequencies (300000 600000 800000)
```

### Wake Locks (`/sys/power/`)
```bash
wake_lock         # Acquire wake lock (prevent sleep)
wake_unlock       # Release wake lock
state            # System power state (on/mem/standby)
pm_async         # Async suspend (1 = enabled)
```

## JesterOS Power Integration

### Installation
```bash
# Copy power management scripts to runtime
cp runtime/4-hardware/power/*.sh /runtime/4-hardware/power/
chmod +x /runtime/4-hardware/power/*.sh

# Start battery monitor service
/runtime/4-hardware/power/battery-monitor.sh monitor &

# Apply power profile
/runtime/4-hardware/power/power-optimizer.sh balanced
```

### Power Profiles

#### Maximum Battery Mode (15-18 hours)
Perfect for long writing sessions without power access:
```bash
/runtime/4-hardware/power/power-optimizer.sh max-battery
```
- CPU locked at 300MHz
- WiFi completely disabled
- Aggressive power management
- Minimal background services

#### Balanced Mode (10-12 hours)
Good balance of performance and battery:
```bash
/runtime/4-hardware/power/power-optimizer.sh balanced
```
- CPU max 600MHz with conservative governor
- WiFi in power-save mode
- Standard power management
- Normal services running

#### Performance Mode (6-8 hours)
When plugged in or need maximum responsiveness:
```bash
/runtime/4-hardware/power/power-optimizer.sh performance
```
- CPU up to 800MHz
- WiFi fully enabled
- Minimal power saving
- All features available

#### Auto Mode
Automatically adjusts based on battery level:
```bash
/runtime/4-hardware/power/power-optimizer.sh auto
```
- >50% battery: Performance mode
- 20-50% battery: Balanced mode
- <20% battery: Max battery mode
- When charging: Performance mode

### Battery Monitoring

The battery monitor provides real-time status via the JesterOS interface:

```bash
# Check battery status
cat /var/jesteros/power/status

# View time remaining
cat /var/jesteros/power/time_remaining

# See current power mode
cat /var/jesteros/power/mode

# Check for warnings
cat /var/jesteros/power/warning
```

### Integration with Menu System

Add to `/runtime/1-ui/menu/nook-menu.sh`:
```bash
[P] Power Settings
```

Handler:
```bash
p|P)
    /runtime/4-hardware/power/power-menu.sh
    ;;
```

## Writing Session Optimization

### Before Starting
1. Check battery level: `cat /sys/class/power_supply/battery/capacity`
2. Select appropriate profile:
   - Full battery: Use balanced mode
   - Limited time: Use performance mode
   - Long session: Use max-battery mode

### During Writing
- Monitor battery via Jester mood indicator
- Save work when warnings appear
- Consider switching to max-battery mode if running low

### Power-Aware Features
- **Auto-save**: Trigger more frequently when battery < 20%
- **Sync**: Disable automatic sync when battery < 30%
- **Display**: Reduce refresh frequency in low battery
- **CPU**: Automatically throttle when thermal limits reached

## Advanced Power Tuning

### Kernel Parameters
```bash
# Enable deep sleep states
echo 1 > /sys/module/pm_debug/parameters/enable_off_mode

# Laptop mode for reduced disk writes
echo 5 > /proc/sys/vm/laptop_mode

# Increase dirty page writeback time
echo 1500 > /proc/sys/vm/dirty_writeback_centisecs

# Reduce swappiness
echo 10 > /proc/sys/vm/swappiness
```

### Display Optimization
```bash
# Reduce E-Ink refresh for power saving
echo 2 > /sys/class/graphics/fb0/epd_refresh  # Partial refresh mode

# Disable auto-refresh
echo 0 > /sys/class/graphics/fb0/epd_auto_refresh
```

### Storage Power Management
```bash
# Enable runtime PM for MMC
echo auto > /sys/block/mmcblk0/device/power/control

# Set I/O scheduler to noop (best for flash)
echo noop > /sys/block/mmcblk0/queue/scheduler
```

## Troubleshooting

### Battery Not Detected
```bash
# Check battery sysfs
ls -la /sys/class/power_supply/

# Verify TWL4030 driver
dmesg | grep -i twl4030

# Check fuel gauge
dmesg | grep -i bq27
```

### High Power Consumption
```bash
# Check wake locks
cat /sys/power/wake_lock

# Monitor CPU frequency
watch -n 1 cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq

# Check running processes
top -b -n 1 | head -20
```

### Power Profile Not Applying
```bash
# Check permissions
ls -la /sys/devices/system/cpu/cpu0/cpufreq/

# Verify governor availability
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

# Test with manual setting
echo conservative > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

## Battery Replacement

The Nook Simple Touch uses a standard 3.7V Li-ion battery (Barnes & Noble BNRV300).

### Specifications
- Voltage: 3.7V nominal, 4.2V full charge
- Capacity: 1530mAh
- Dimensions: 54mm x 34mm x 5mm
- Connector: 3-pin JST

### Health Monitoring
```bash
# Check battery health
cat /sys/class/power_supply/battery/health

# View cycle count (if available)
cat /sys/class/power_supply/battery/cycle_count

# Monitor voltage for degradation
cat /sys/class/power_supply/battery/voltage_now
```

Healthy voltage range: 3.6V - 4.2V
Replace if voltage drops below 3.5V at full charge.

## Best Practices

1. **Charge Management**
   - Avoid deep discharge below 10%
   - Unplug when fully charged
   - Store at 40-60% charge if not using

2. **Temperature**
   - Avoid charging in extreme temperatures
   - Monitor temperature during heavy use
   - Let device cool if overheating

3. **Power Profiles**
   - Use auto mode for worry-free operation
   - Switch to max-battery for travel
   - Performance mode only when plugged in

4. **Writing Habits**
   - Save frequently when battery < 30%
   - Use local storage, sync when charged
   - Disable WiFi when not needed

## Integration Example

### Power-Aware Writing Script
```bash
#!/bin/bash
# power-aware-writing.sh

# Check battery before starting
battery=$(cat /sys/class/power_supply/battery/capacity)

if [ "$battery" -lt 20 ]; then
    echo "Low battery! Charge before writing session."
    exit 1
fi

# Set appropriate power mode
if [ "$battery" -gt 80 ]; then
    /runtime/4-hardware/power/power-optimizer.sh balanced
else
    /runtime/4-hardware/power/power-optimizer.sh max-battery
fi

# Start battery monitor
/runtime/4-hardware/power/battery-monitor.sh monitor &
MONITOR_PID=$!

# Launch writing environment
vim "$@"

# Cleanup
kill $MONITOR_PID 2>/dev/null
```

## Summary

The Nook Simple Touch's power management system offers excellent battery life for writing:
- **Hardware**: OMAP3621 + TWL4030 provide comprehensive power control
- **Software**: Multiple governors and power states for optimization
- **JesterOS**: Integrated monitoring and profile management
- **Real-world**: 15-18 hours achievable with proper configuration

With these power management tools, writers can focus on their craft without battery anxiety!