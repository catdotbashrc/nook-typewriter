# JesterOS Source Code Index
*Comprehensive documentation of the /src directory structure*

## Overview

The `/src` directory contains the core JesterOS codebase, organized using industry-standard conventions after the BLOOD_PACT_MIGRATION from the original 4-layer runtime model.

**Migration Status**: ✅ COMPLETE (January 2025)
**Total Modules**: 7 top-level directories
**Total Scripts**: 31 shell scripts
**Architecture**: Modular, HAL-based, service-oriented

---

## Directory Structure

```
src/
├── apps/        # User applications
├── core/        # Core system libraries
├── hal/         # Hardware Abstraction Layer
├── init/        # Boot and initialization
├── services/    # System services
└── README.md    # Source documentation
```

---

## Module Documentation

### 📦 `/src/apps/` - User Applications
*User-facing applications and utilities*

| File | Purpose | Dependencies |
|------|---------|--------------|
| `git/git-installer.sh` | Git installation manager | core/common.sh |
| `git/git-manager.sh` | Git repository management | core/common.sh |

**Key Features**:
- Lightweight Git support for writing version control
- Memory-efficient implementation (<2MB footprint)
- Integration with JesterOS menu system

---

### 🔧 `/src/core/` - Core System Libraries
*Shared functions and system utilities*

| File | Purpose | Critical Functions |
|------|---------|-------------------|
| `common.sh` | Legacy common functions | Basic utilities |
| `consolidated-functions.sh` | **PRIMARY** - Unified function library | display_text(), validate_menu_choice(), update_jester_mood() |
| `memory-guardian.sh` | Memory limit enforcement | Enforces 92.8MB OS limit |
| `service-functions.sh` | Service management utilities | Service lifecycle management |

**Critical Component**: `consolidated-functions.sh`
- Eliminates code duplication across system
- Provides 30+ shared functions
- Central configuration management
- Path abstraction layer

---

### 🎛️ `/src/hal/` - Hardware Abstraction Layer
*Hardware interface and device drivers*

#### `/src/hal/buttons/`
| File | Purpose | Hardware Interface |
|------|---------|-------------------|
| `button-handler.sh` | Physical button event handling | GPIO interrupts |

#### `/src/hal/eink/`
| File | Purpose | Hardware Interface |
|------|---------|-------------------|
| `font-setup.sh` | E-Ink optimized font configuration | /dev/fb0, fbink |

#### `/src/hal/power/`
| File | Purpose | Hardware Interface |
|------|---------|-------------------|
| `battery-monitor.sh` | Battery status and alerts | /sys/class/power_supply/battery |
| `power-optimizer.sh` | CPU/WiFi power management | cpufreq, rfkill |

**Power Profiles**:
- `max-battery`: 15-18 hours (300MHz, WiFi off)
- `balanced`: 10-12 hours (600MHz, WiFi powersave)
- `performance`: 6-8 hours (800MHz, WiFi on)

#### `/src/hal/sensors/`
| File | Purpose | Hardware Interface |
|------|---------|-------------------|
| `temperature-monitor.sh` | Basic temperature monitoring | /sys/class/thermal |
| `temperature-monitor-optimized.sh` | Efficient temp monitoring | Reduced polling |

#### `/src/hal/usb/`
| File | Purpose | Hardware Interface |
|------|---------|-------------------|
| `usb-keyboard-manager.sh` | USB keyboard detection/config | /dev/input/event* |
| `usb-keyboard-ui-setup.sh` | Keyboard UI integration | Input event handling |

---

### 🚀 `/src/init/` - Boot and Initialization
*System startup and initialization scripts*

| File | Purpose | Boot Stage |
|------|---------|------------|
| `boot-jester.sh` | Jester personality initialization | Stage 3 |
| `jesteros-boot.sh` | Main JesterOS boot orchestrator | Stage 2 |
| `jesteros-init.sh` | System initialization | Stage 1 |
| `jesteros-service-init.sh` | Service startup manager | Stage 4 |

**Boot Sequence**:
1. Android init (hardware drivers)
2. `jesteros-init.sh` (system setup)
3. `jesteros-boot.sh` (JesterOS services)
4. `boot-jester.sh` (personality)
5. `jesteros-service-init.sh` (user services)

---

### 🔄 `/src/services/` - System Services
*Background services and daemons*

#### `/src/services/jester/`
| File | Purpose | Service Type |
|------|---------|--------------|
| `jester-daemon.sh` | Medieval writing assistant | Background daemon |
| `jesteros-tracker.sh` | Writing statistics tracker | Monitoring service |

#### `/src/services/menu/`
| File | Purpose | Menu Type |
|------|---------|-----------|
| `display.sh` | E-Ink display manager | System service |
| `menu.sh` | Base menu framework | Core UI |
| `jester-menu.sh` | Jester-themed main menu | Primary interface |
| `nook-menu.sh` | Hardware-specific menu | Device menu |
| `nook-menu-plugin.sh` | Menu plugin system | Extension framework |
| `nook-menu-zk.sh` | Zettelkasten menu | Writing tool |
| `git-menu.sh` | Git operations menu | Version control UI |
| `power-menu.sh` | Power management menu | System control |

#### `/src/services/tracker/`
| File | Purpose | Tracking Type |
|------|---------|---------------|
| `tracker.sh` | Writing session tracker | Statistics collection |

---

## Key Design Patterns

### 1. **Function Consolidation**
All shared functions centralized in `core/consolidated-functions.sh`:
- Display functions (E-Ink aware)
- Menu validation
- Jester mood management
- Path configuration
- System monitoring

### 2. **Hardware Abstraction**
Clean separation between hardware interfaces and services:
- HAL layer handles all hardware-specific code
- Services use HAL APIs, not direct hardware access
- Fallback mechanisms for testing/development

### 3. **Memory Management**
Strict 92.8MB OS limit enforcement:
- `memory-guardian.sh` monitors continuously
- All scripts optimized for minimal footprint
- Writing space (160MB) remains sacred

### 4. **Service Architecture**
Modular service design:
- Independent service scripts
- Shared state via `/var/jesteros/`
- Event-driven communication

---

## Dependencies Map

```
init/jesteros-boot.sh
    ├── core/consolidated-functions.sh
    ├── core/memory-guardian.sh
    ├── hal/power/power-optimizer.sh
    ├── services/jester/jester-daemon.sh
    └── services/menu/jester-menu.sh
            ├── core/consolidated-functions.sh
            ├── hal/eink/font-setup.sh
            └── services/tracker/tracker.sh
```

---

## Configuration Files

| Location | Purpose |
|----------|---------|
| `/etc/jesteros/` | System configuration |
| `/var/jesteros/` | Runtime state |
| `/var/log/jesteros/` | System logs |

---

## Memory Footprint

| Component | Memory Usage | Priority |
|-----------|--------------|----------|
| Core libraries | ~2MB | Critical |
| HAL drivers | ~3MB | Critical |
| Init scripts | ~1MB | Boot only |
| Services | ~8MB | Variable |
| **Total OS** | **<92.8MB** | **ENFORCED** |

---

## Integration Points

### 1. **E-Ink Display**
- Primary: `hal/eink/font-setup.sh`
- Display: `services/menu/display.sh`
- Refresh: Via fbink library

### 2. **Power Management**
- Monitor: `hal/power/battery-monitor.sh`
- Optimize: `hal/power/power-optimizer.sh`
- UI: `services/menu/power-menu.sh`

### 3. **User Input**
- Touch: `/dev/input/event2` (hardware)
- Buttons: `hal/buttons/button-handler.sh`
- USB: `hal/usb/usb-keyboard-manager.sh`

### 4. **Writing Tools**
- Vim: Configured via `/etc/vim/`
- Tracker: `services/tracker/tracker.sh`
- Jester: `services/jester/jester-daemon.sh`

---

## Development Guidelines

### Adding New Features
1. Determine appropriate module (apps/core/hal/services)
2. Use functions from `consolidated-functions.sh`
3. Follow memory constraints (<1MB per feature)
4. Test on actual hardware or Docker environment

### Code Style
- Bash strict mode: `set -euo pipefail`
- Function names: `snake_case`
- Variables: `UPPER_CASE` for globals, `lower_case` for locals
- Always quote variables: `"$var"`
- Use `|| true` for non-critical failures

### Testing
```bash
# Unit test example
source /src/core/consolidated-functions.sh
validate_menu_choice "1" "1" "9" && echo "PASS" || echo "FAIL"
```

---

## Recent Updates

**January 2025 - Post-Migration**:
- Migrated from 4-layer runtime model to standard /src structure
- Consolidated duplicate functions into single library
- Implemented HAL pattern for hardware abstraction
- Reduced memory footprint by 12MB through deduplication

**Phoenix Project Integration**:
- Adjusted memory limit to 92.8MB (hardware reality)
- Added touch recovery mechanism (Issue #36)
- Implemented 1.5% daily drain target (Issue #32)
- E-Ink refresh optimization (Issue #34)

---

## Future Roadmap

### High Priority
- [ ] Implement touch screen recovery (Issue #36)
- [ ] Optimize power management (Issue #32)
- [ ] Add logging module (Issue #35)
- [ ] E-Ink refresh optimization (Issue #34)

### Medium Priority
- [ ] Expand Git integration
- [ ] Add markdown preview
- [ ] Implement backup system

### Low Priority
- [ ] Plugin system expansion
- [ ] Network sync capabilities
- [ ] Theme customization

---

*SRC_INDEX.md - Generated January 2025*
*Part of JesterOS Documentation Suite*