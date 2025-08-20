# System Information Reference

## Overview
System diagnostics and information gathering for Barnes & Noble Nook Simple Touch running JesterOS/JoKernel.

## Kernel Information

### Current Kernel
```
Linux version 2.6.29-omap1 (build@dhabuildimage04) 
GCC version 4.3.2 (Sourcery G++ Lite 2008q3-72)
Built: #1 PREEMPT Fri Dec 7 14:35:04 PST 2012
```

### JesterOS Kernel Build
```
Linux version 2.6.29-jester
Architecture: ARM OMAP3621
Cross-compiler: arm-linux-androideabi-4.9
```

## System Diagnostics Commands

### Memory Information
```bash
# Total memory
cat /proc/meminfo | grep MemTotal

# Available memory
cat /proc/meminfo | grep MemAvailable

# Memory usage by process
ps aux | head -10

# JesterOS memory guardian status
cat /var/jesteros/memory_status
```

### CPU Information
```bash
# CPU info
cat /proc/cpuinfo

# CPU frequency
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq

# Load average
cat /proc/loadavg
```

### Storage Information
```bash
# Disk usage
df -h

# Partition layout
cat /proc/mtd

# SD card status
mount | grep mmcblk
```

### Hardware Identification
```bash
# Hardware platform
cat /proc/cpuinfo | grep Hardware

# Serial number
cat /proc/cpuinfo | grep Serial

# Board version
cat /sys/board_properties/board_version
```

## JesterOS Service Status

### Check Running Services
```bash
# JesterOS daemon status
ps | grep jester-daemon

# Memory guardian status
ps | grep memory-guardian

# Display service
ps | grep display.sh

# USB keyboard manager
ps | grep usb-keyboard
```

### Service Logs
```bash
# System log
cat /var/log/jesteros.log

# Boot log
dmesg | tail -50

# Service errors
grep ERROR /var/log/jesteros.log
```

## /proc Filesystem Interfaces

### JesterOS Proc Entries
- `/proc/jesteros/version` - JesterOS version
- `/proc/jesteros/memory_limit` - Current memory limit (95MB)
- `/proc/jesteros/services` - Running services list
- `/proc/jesteros/stats` - Writing statistics

### Hardware Proc Entries
- `/proc/epd_hwconfig` - E-Ink display configuration
- `/proc/epd_waveform` - Waveform data info
- `/proc/zforce` - Touch controller status
- `/proc/battery` - Battery status and voltage

## Performance Monitoring

### Resource Usage
```bash
# Real-time process monitoring
top -n 1

# Memory usage over time
vmstat 1 5

# I/O statistics
iostat -x 1 5
```

### Battery Monitoring
```bash
# Battery voltage
cat /sys/class/power_supply/bq27510-0/voltage_now

# Battery percentage
cat /sys/class/power_supply/bq27510-0/capacity

# Power consumption
cat /sys/class/power_supply/bq27510-0/current_now
```

## Network Information

### USB Network (when connected)
```bash
# Interface status
ifconfig usb0

# Routing table
route -n

# Connection test
ping -c 3 192.168.1.1
```

## Troubleshooting

### Common Diagnostics
```bash
# Check for kernel panics
dmesg | grep -i panic

# Check for OOM killer
dmesg | grep -i "killed process"

# Check service failures
grep -i fail /var/log/jesteros.log

# Verify boot sequence
cat /var/log/boot.log
```

### Debug Mode
```bash
# Enable debug logging
export DEBUG=1

# Verbose boot
setprop ro.debuggable 1

# Service trace
sh -x /runtime/init/jesteros-init.sh
```

## File System Health

### Check File Systems
```bash
# Root filesystem
df -h /

# Check for errors
dmesg | grep -i "ext4-fs error"

# Inode usage
df -i

# Find large files
find / -size +10M -type f 2>/dev/null
```

## Quick Health Check Script

```bash
#!/bin/bash
# JesterOS System Health Check

echo "=== JesterOS System Health ==="
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime)"
echo "Memory: $(free -m | grep Mem | awk '{print $3"/"$2" MB"}')"
echo "Storage: $(df -h / | tail -1 | awk '{print $3"/"$2}')"
echo "Battery: $(cat /sys/class/power_supply/bq27510-0/capacity)%"
echo "Services: $(ps | grep -c jester)"
echo "Temperature: $(cat /sys/class/hwmon/hwmon0/device/temp1_input)mC"
echo "=============================="
```

## See Also
- [Hardware Reference](./NOOK_HARDWARE_REFERENCE.md)
- [Power Management Guide](./POWER_MANAGEMENT_GUIDE.md)
- [Boot Infrastructure](../BOOT-INFRASTRUCTURE-COMPLETE.md)
- [JesterOS Boot Process](../JESTEROS_BOOT_PROCESS.md)

---

*"By quill and candlelight, we monitor the realm"* 🕯️📊