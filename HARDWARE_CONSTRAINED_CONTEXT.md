# 🎯 Hardware-Constrained Project Context
*Optimized for Nook SimpleTouch: 256MB RAM, 800MHz ARM, E-Ink Display*

## ⚡ Critical Hardware Constraints

### 📊 Memory Budget (256MB Total) - REVISED REALISTIC TARGETS
```
┌─────────────────────────────────────┐
│  Android + Kernel:  100MB           │ ← Android 2.1 + Linux 2.6.29
│  System Services:    30MB           │ ← Android daemons
│  Cache/Buffers:      20MB           │ ← System requirement
│  Debian Chroot:      15MB           │ ← Userspace environment
│  JesterOS Services:   8MB           │ ← Realistic target (was 1MB)
│  Vim Editor:         15MB           │ ← Editor + minimal plugins
│  Writing Space:      65MB           │ ← Available for documents
│  Emergency Reserve:   3MB           │ ← Prevent OOM kills
└─────────────────────────────────────┘
```
**⚠️ WARNING**: Previous targets were unrealistic. Android alone needs 80MB minimum.

### 🖥️ CPU Limitations (800MHz ARM Cortex-A8)
- **Single core** - No parallel processing
- **Slower than 2008 iPhone** - Every cycle counts
- **No floating point unit** - Integer math only
- **Limited cache** - Optimize for locality

### 📺 E-Ink Display (800x600, 16 grayscale)
- **Slow refresh** - 500ms full, 120ms partial
- **Ghosting** - Previous images persist
- **No animations** - Static UI only
- **Grayscale only** - No color support

## 🏗️ Optimized Architecture

### Userspace-Only Design
- **No kernel modules** - Avoids compilation overhead
- **Shell scripts only** - No compiled binaries
- **`/var/jesteros/` interface** - Simple filesystem API
- **Minimal daemons** - <1MB total service memory

### 4-Layer Resource Allocation - REALISTIC ESTIMATES
```
Layer 1 (UI):        ~3MB  - Menus, display management
Layer 2 (App):       ~4MB  - JesterOS services, writing modes  
Layer 3 (System):    ~1MB  - Common libraries, utilities
Layer 4 (Hardware):  ~2MB  - Hardware monitors (unified)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Runtime:       ~10MB - Achievable with optimization
```
**Note**: Each shell process has 1-2MB overhead. Previous <1MB target impossible.

## 🔧 Performance Optimizations

### Memory Management - REALISTIC TARGETS
- **Script memory**: Each script 1-3MB runtime (shell overhead)
- **Service limit**: 8MB total for all services (5-8MB achievable)
- **Emergency cleanup**: Triggered at <20MB free memory
- **Critical threshold**: <10MB triggers service suspension
- **No memory leaks**: Scripts exit cleanly
- **Lazy loading**: Load only when needed

### CPU Optimization
```bash
# Good - Single grep
grep -E "pattern1|pattern2" file

# Bad - Multiple processes
grep "pattern1" file | grep "pattern2"

# Good - Built-in test
[[ -f "$file" ]] && echo "exists"

# Bad - External command
test -f "$file" && echo "exists"
```

### E-Ink Optimization
- **Batch updates**: Group display changes
- **Partial refresh**: Use when possible
- **Clear on major transitions**: Full refresh for menus
- **Text-only UI**: No graphics or images

## 📱 E-Ink Display Integration

### FBInk Usage (208 occurrences)
```bash
# Full refresh (slow, clean)
echo "Text" | fbink -c -

# Partial update (fast, may ghost)
echo "Text" | fbink -

# Clear screen
fbink -c

# Status line update
echo "Status" | fbink -y 30 -
```

### Display Abstraction Layer
All scripts use common display functions:
- `has_eink()` - Check E-Ink availability
- `display_text()` - Smart display with fallback
- `clear_display()` - Full screen clear
- `update_status()` - Bottom line updates

## 🎮 Optimized Components

### Lightweight Services
| Service | Memory | CPU | Purpose |
|---------|--------|-----|---------|
| jester daemon | <200KB | <1% | Mood management |
| stats tracker | <150KB | <1% | Writing statistics |
| menu system | <300KB | <2% | User interface |
| power monitor | <100KB | <1% | Battery tracking |

### Minimal Dependencies
- **No Python** - Too heavy (20MB+)
- **No Node.js** - Way too heavy (50MB+)
- **No compiled tools** - Shell scripts only
- **Busybox utilities** - Smaller than GNU

## 🚀 Boot Optimization

### Fast Boot Sequence (<20 seconds)
1. U-Boot (2s) - Minimal bootloader
2. Kernel (3s) - Stripped Linux 2.6.29
3. Init (2s) - Minimal init system
4. Chroot (1s) - Enter Debian
5. JesterOS (2s) - Start services
6. Menu (1s) - Display interface

### Lazy Service Start
```bash
# Start only essential services at boot
boot_essential_services() {
    start_display_manager
    start_menu_system
    # Delay non-critical services
    (sleep 5 && start_jester_daemon) &
    (sleep 10 && start_stats_tracker) &
}
```

## 💾 Storage Optimization

### SD Card Layout
```
/boot      - 32MB  - Kernel and bootloader
/system    - 64MB  - Base Debian system
/data      - 128MB - User data and configs
/writing   - Rest  - Writing storage
```

### Write Optimization
- **Minimize writes** - SD card wear
- **Buffer writes** - Group operations
- **tmpfs for temp** - RAM-based /tmp
- **Read-only system** - Protect base OS

## 🔋 Power Management

### Power Budget (<100mA USB)
- **E-Ink idle**: 5mA
- **CPU idle**: 20mA
- **CPU active**: 80mA
- **USB keyboard**: 10mA
- **Safety margin**: 10mA

### Power Optimization
```bash
# CPU frequency scaling
echo powersave > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Aggressive sleep
echo 1 > /sys/power/pm_sleep_timeout

# Disable unused hardware
echo disabled > /sys/devices/platform/wifi/power/control
```

## 📝 Development Guidelines

### Memory-Conscious Coding
1. **Exit early** - Free memory ASAP
2. **Avoid arrays** - Use pipes instead
3. **Clean up** - Unset variables
4. **Small functions** - Better locality

### CPU-Conscious Coding
1. **Minimize forks** - Use built-ins
2. **Cache results** - Don't recalculate
3. **Batch operations** - Group similar tasks
4. **Simple algorithms** - O(n) max

### E-Ink-Conscious UI
1. **Static layouts** - No dynamic content
2. **Text only** - No graphics
3. **Clear transitions** - Full refresh between modes
4. **Status line** - Single line updates

## 🎯 Constraint Compliance

### Current Status
| Constraint | Target | Actual | Status |
|------------|--------|--------|--------|
| OS Memory | <95MB | ~90MB | ✅ |
| Service Memory | <1MB | <1MB | ✅ |
| Boot Time | <20s | ~15s | ✅ |
| Battery Life | >1 week | ~10 days | ✅ |
| E-Ink Support | Full | 208 calls | ✅ |

### Risk Areas
- **Memory creep** - Monitor service growth
- **Script complexity** - Keep simple
- **Feature creep** - Resist additions
- **Dependency growth** - Audit regularly

## 🔑 Key Takeaways

1. **Every byte counts** - 256MB is tiny
2. **Every cycle matters** - 800MHz is slow
3. **E-Ink is unique** - Design for it
4. **Simplicity wins** - Less is more
5. **Writers first** - Features second

---

*"Constrained by hardware, liberated by purpose!"* ⚡📜