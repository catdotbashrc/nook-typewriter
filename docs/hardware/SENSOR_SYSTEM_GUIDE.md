# System Sensors & Environmental Awareness Guide

## Overview

The Nook Simple Touch features a **minimalist sensor suite** focused on temperature monitoring for device safety and optimal E-Ink performance. Unlike modern tablets, it intentionally lacks motion sensors, choosing simplicity and battery efficiency over features that don't enhance the writing experience.

## Available Sensors

### 🌡️ Temperature Sensors (4 total)

#### 1. E-Ink Display Temperature
- **Purpose**: Optimize refresh timing for temperature
- **Path**: `/sys/class/graphics/fb0/epd_temp`
- **Range**: -20°C to +50°C
- **Optimal**: 15-30°C for best refresh quality
- **Critical**: <5°C or >40°C affects display performance

#### 2. Battery Temperature (BQ27510)
- **Purpose**: Charging safety and thermal protection
- **Path**: `/sys/class/power_supply/battery/temp`
- **I2C Address**: `0x55`
- **Safe Charging**: 0-45°C
- **Critical**: >50°C triggers safety shutdown
- **Resolution**: 0.1°C

#### 3. CPU Temperature (OMAP3621)
- **Purpose**: Thermal throttling and protection
- **Path**: `/sys/class/thermal/thermal_zone0/temp`
- **Normal**: 40-50°C during writing
- **Throttle**: >65°C reduces CPU speed
- **Critical**: >85°C emergency shutdown
- **Units**: Millidegrees Celsius (divide by 1000)

#### 4. Power Management IC Temperature (TWL4030)
- **Purpose**: Power system protection
- **Path**: `/sys/class/hwmon/hwmon0/temp1_input` (if available)
- **Location**: Internal die temperature
- **Warning**: >70°C
- **Critical**: >85°C

## Absent Sensors (By Design)

### ❌ No Accelerometer
- **Impact**: No automatic screen rotation
- **Benefit**: Simpler, more reliable, better battery life
- **Alternative**: Manual rotation via settings if needed

### ❌ No Ambient Light Sensor
- **Impact**: No automatic brightness adjustment
- **Benefit**: E-Ink doesn't need backlighting
- **Note**: E-Ink is readable in any lighting condition

### ❌ No Proximity/Hall Effect Sensor
- **Impact**: No smart cover detection
- **Benefit**: One less thing to break
- **Alternative**: Power button for sleep/wake

### ❌ No GPS/Magnetometer
- **Impact**: No location services or compass
- **Benefit**: Privacy, simplicity, battery life
- **Philosophy**: A writing device doesn't need to know where you are

## Temperature Impact on Writing

### E-Ink Display Performance

| Temperature | Refresh Speed | Quality | Recommendations |
|------------|--------------|---------|-----------------|
| <5°C | Very Slow | Ghosting | Warm device before use |
| 5-15°C | Slow | Good | Allow extra refresh time |
| 15-30°C | **Optimal** | **Best** | **Ideal writing conditions** |
| 30-40°C | Fast | Good | Monitor for overheating |
| >40°C | Unstable | Poor | Move to cooler location |

### Cold Weather Writing (<10°C)
```bash
# Optimizations for cold conditions
/runtime/4-hardware/sensors/temperature-monitor.sh adjust

# Effects:
# - Stronger refresh voltage
# - Longer refresh duration
# - More complete pixel clearing
```

### Hot Weather Writing (>35°C)
```bash
# Optimizations for hot conditions
/runtime/4-hardware/power/power-optimizer.sh max-battery

# Effects:
# - CPU throttling to reduce heat
# - Gentler refresh cycles
# - Charging disabled if needed
```

## JesterOS Sensor Integration

### Temperature Monitoring Service
```bash
# Start temperature monitor
/runtime/4-hardware/sensors/temperature-monitor.sh monitor &

# Check current status
/runtime/4-hardware/sensors/temperature-monitor.sh status
```

### Sensor Data Interface
```
/var/jesteros/sensors/
├── eink_temp         # Display temperature (°C)
├── battery_temp      # Battery temperature (°C)
├── cpu_temp          # CPU temperature (°C)
├── condition         # Overall status (optimal/cold/hot/critical)
├── warnings          # Active warnings
├── eink_mode         # Current refresh mode
├── jester_mood       # Temperature-aware ASCII art
└── report            # Full sensor report
```

### Temperature-Aware Features

#### Automatic E-Ink Adjustment
The system automatically adjusts E-Ink refresh parameters based on temperature:
```c
if (temp < 10°C) {
    refresh_voltage = HIGH;
    refresh_duration = 500ms;
    waveform = COLD_WEATHER;
} else if (temp > 35°C) {
    refresh_voltage = LOW;
    refresh_duration = 100ms;
    waveform = HOT_WEATHER;
}
```

#### Battery Protection
Charging is automatically disabled when battery temperature exceeds safe limits:
```bash
if [ "$battery_temp" -gt 45 ]; then
    echo 0 > /sys/class/power_supply/battery/charge_enabled
fi
```

#### CPU Thermal Management
Dynamic frequency scaling based on temperature:
```bash
if [ "$cpu_temp" -gt 65000 ]; then
    echo 300000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
fi
```

## Practical Usage

### Writing Session Optimization

1. **Before Starting**:
   ```bash
   # Check environmental conditions
   /runtime/4-hardware/sensors/temperature-monitor.sh status
   ```

2. **During Writing**:
   - Monitor `/var/jesteros/sensors/warnings` for alerts
   - Jester mood indicates temperature status
   - Auto-adjustments happen transparently

3. **Temperature Warnings**:
   - **Blue Jester** (❄️): Device too cold
   - **Sweating Jester** (🔥): Device too hot
   - **Panicked Jester** (‼️): Critical temperature

### Manual Temperature Reading
```bash
# Read all temperatures
cat /sys/class/power_supply/battery/temp | awk '{print $1/10 "°C"}'
cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000 "°C"}'

# Or use the helper script
/runtime/4-hardware/sensors/temperature-monitor.sh test
```

## Sensor Specifications

### I2C Bus Layout
```
I2C Bus 1 (100kHz):
├── 0x48-0x4B: TWL4030 PMIC (includes temp sensor)
├── 0x55: BQ27510 Battery Fuel Gauge (temp sensor)
└── 0x68: TPS65180 E-Ink Controller (temp feedback)
```

### Temperature Sensor Accuracy
- **Battery**: ±1°C
- **CPU**: ±2°C  
- **E-Ink**: ±2°C
- **PMIC**: ±3°C

### Polling Intervals
- **Normal**: Every 30 seconds
- **Warning**: Every 10 seconds
- **Critical**: Every 5 seconds

## Troubleshooting

### No Temperature Readings
```bash
# Check if sensors are available
ls -la /sys/class/thermal/
ls -la /sys/class/power_supply/battery/
ls -la /sys/class/hwmon/

# Test I2C communication
i2cdetect -y 1
```

### Incorrect Temperature Values
```bash
# Validate sensor readings
# Battery temp should be in decidegrees
cat /sys/class/power_supply/battery/temp

# CPU temp should be in millidegrees  
cat /sys/class/thermal/thermal_zone0/temp

# Convert to Celsius
echo "scale=1; $(cat /sys/class/power_supply/battery/temp) / 10" | bc
```

### E-Ink Not Adjusting for Temperature
```bash
# Check if adjustment is enabled
cat /sys/class/graphics/fb0/epd_refresh_mode

# Force adjustment
echo 2 > /sys/class/graphics/fb0/epd_refresh_mode  # Cold mode
echo 0 > /sys/class/graphics/fb0/epd_refresh_mode  # Normal mode
echo 1 > /sys/class/graphics/fb0/epd_refresh_mode  # Hot mode
```

## Best Practices

### For Writers
1. **Room Temperature is Best**: 20-25°C optimal for all components
2. **Avoid Direct Sunlight**: Can cause rapid temperature rise
3. **Cold Start**: Let device warm to room temperature before writing
4. **Hot Weather**: Take breaks to prevent overheating
5. **Monitor Warnings**: Heed temperature alerts to protect device

### For Developers
1. **Poll Sparingly**: Temperature changes slowly, don't over-poll
2. **Cache Readings**: Reuse recent values when possible
3. **Fail Gracefully**: Use safe defaults if sensors unavailable
4. **Log Anomalies**: Track unusual temperature patterns
5. **Test Extremes**: Verify behavior at temperature limits

## Environmental Specifications

### Operating Conditions
- **Temperature**: 0°C to 40°C
- **Storage**: -20°C to 60°C
- **Humidity**: 20% to 80% non-condensing
- **Altitude**: Sea level to 3,000m

### Optimal Writing Environment
- **Temperature**: 20-25°C
- **Humidity**: 40-60%
- **Lighting**: Any (E-Ink advantage)
- **Vibration**: Minimal (no accelerometer to detect)

## Summary

The Nook Simple Touch sensor system embodies the device's philosophy: **focus on what matters for writing**. By monitoring only temperature - the one environmental factor that actually affects E-Ink performance and device safety - it avoids the complexity and battery drain of unnecessary sensors while ensuring optimal operation across various conditions.

The temperature monitoring system provides:
- **Automatic E-Ink optimization** for any temperature
- **Battery safety** with thermal protection
- **CPU management** to prevent overheating
- **Writer-friendly alerts** via Jester moods
- **Transparent operation** with no user intervention needed

This minimalist approach results in a device that **just works** for writing, regardless of environmental conditions, without the distractions of auto-rotation, ambient light adjustments, or location tracking.

---

*"The best sensor is the one you don't notice - it just keeps you writing!"* - The Temperature Jester 🌡️