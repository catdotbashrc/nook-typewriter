# 🏛️ Runtime Architecture Index
*Complete guide to the 4-layer runtime architecture*

## 📐 Architecture Overview

The runtime system implements a **clean 4-layer architecture** with strict dependency rules and clear separation of concerns.

```
┌────────────────────────────────────────┐
│         Layer 1: User Interface         │  7 components
├────────────────────────────────────────┤
│      Layer 2: Application Services      │  9 components
├────────────────────────────────────────┤
│        Layer 3: System Services         │  3 libraries
├────────────────────────────────────────┤
│      Layer 4: Hardware Abstraction      │  6 interfaces
└────────────────────────────────────────┘
```

**Dependency Rule**: Higher layers can call lower layers, but never the reverse.

## 📁 Layer 1: User Interface (1-ui/)

### Purpose
Everything the user sees and interacts with - menus, displays, themes

### Components (7 scripts, ~2,000 lines)

| Component | File | Size | Purpose |
|-----------|------|------|---------|
| **Display Manager** | display/display.sh | 450 lines | Main display handler |
| **Menu Framework** | display/menu.sh | 458 lines | Menu system core |
| **Git Menu** | menu/git-menu.sh | 362 lines | Version control UI |
| **Jester Menu** | menu/jester-menu.sh | ~250 lines | Jester interactions |
| **Main Menu** | menu/nook-menu.sh | ~300 lines | Primary navigation |
| **ZK Menu** | menu/nook-menu-zk.sh | ~200 lines | Zettelkasten mode |
| **Power Menu** | menu/power-menu.sh | ~280 lines | Power management UI |

### Themes & Assets
- `themes/ascii-art-library.txt` - ASCII art collection
- `themes/jester-collection.txt` - Jester moods and expressions

### Dependencies
- Calls: Layers 2, 3, 4
- External: FBInk for E-Ink display

## 📁 Layer 2: Application Services (2-application/)

### Purpose
Business logic, application features, and service management

### Components (9 scripts, ~2,400 lines)

| Service | File | Size | Function |
|---------|------|------|----------|
| **JesterOS Daemon** | jesteros/daemon.sh | ~200 lines | Main service daemon |
| **Service Manager** | jesteros/manager.sh | 357 lines | Service orchestration |
| **Mood System** | jesteros/mood.sh | ~250 lines | Dynamic mood engine |
| **Stats Tracker** | jesteros/tracker.sh | ~200 lines | Writing statistics |
| **Git Installer** | writing/git-installer.sh | 432 lines | Git setup wizard |
| **Git Manager** | writing/git-manager.sh | 313 lines | Repository management |

### Configuration
- `writing/vim-button-config.vim` - Button mappings for Vim

### Dependencies
- Calls: Layers 3, 4
- Provides: `/var/jesteros/` interface

## 📁 Layer 3: System Services (3-system/)

### Purpose
Core system functionality, common libraries, utilities

### Components (3 libraries, ~600 lines)

| Library | File | Lines | Provides |
|---------|------|-------|----------|
| **Common Functions** | common/common.sh | ~200 | Error handling, constants |
| **Service Functions** | common/service-functions.sh | ~150 | Service management |
| **Font Setup** | display/font-setup.sh | ~250 | Console font configuration |

### Key Features
- Unified error handling with `error_handler()`
- Safety headers (`set -euo pipefail`)
- Path validation and security checks
- Common constants and paths

### Dependencies
- Calls: Layer 4 only
- Used by: All upper layers

## 📁 Layer 4: Hardware Abstraction (4-hardware/)

### Purpose
Direct hardware interface and control - the foundation layer

### Components (6 interfaces, ~1,600 lines)

| Interface | Directory | Scripts | Purpose |
|-----------|-----------|---------|---------|
| **E-Ink Display** | eink/ | 2 scripts | FBInk wrapper, display control |
| **Button Input** | input/ | 2 files | GPIO buttons, USB keyboard |
| **Power Management** | power/ | 2 scripts | Battery monitor, optimization |
| **Sensors** | sensors/ | 1 script | Temperature monitoring (403 lines) |
| **USB Detection** | usb/ | TBD | USB device detection |

### Hardware Interfaces
- **E-Ink**: 800x600, 16-level grayscale
- **Buttons**: 4 physical GPIO buttons
- **Power**: Battery monitoring, sleep modes
- **Sensors**: Temperature, light (optional)
- **USB**: Keyboard detection, OTG support

### Dependencies
- Calls: None (bottom layer)
- External: Linux kernel interfaces, FBInk

## 🔄 Inter-Layer Communication

### Data Flow Examples

**Menu Selection → Action**:
```
Layer 1 (menu) → Layer 2 (service) → Layer 3 (common) → Layer 4 (hardware)
```

**Hardware Event → UI Update**:
```
Layer 4 (button press) → Layer 1 (menu update)
                       ↓
              Layer 2 (state change)
```

### Common Patterns

1. **Service Registration**:
   - Services in Layer 2 register with manager
   - Manager uses Layer 3 common functions
   - Status exposed via `/var/jesteros/`

2. **Display Updates**:
   - UI components call display functions
   - Display functions use Layer 4 E-Ink control
   - Optimized refresh strategies

3. **Error Handling**:
   - All layers use Layer 3 error handler
   - Consistent error messages
   - Writer-friendly language

## 📊 Architecture Metrics

### Code Distribution
| Layer | Scripts | Lines | Percentage |
|-------|---------|-------|------------|
| Layer 1 (UI) | 7 | ~2,000 | 31% |
| Layer 2 (App) | 9 | ~2,400 | 37% |
| Layer 3 (System) | 3 | ~600 | 9% |
| Layer 4 (Hardware) | 6 | ~1,600 | 23% |
| **Total** | **26** | **~6,600** | **100%** |

### Quality Metrics
| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Layer Isolation | 100% | 100% | ✅ |
| Safety Headers | 73% | 100% | 🔄 |
| Documentation | 85% | 80% | ✅ |
| Test Coverage | Good | Good | ✅ |

### Complexity Analysis
| Layer | Avg Size | Max Size | Complexity |
|-------|----------|----------|------------|
| Layer 1 | 285 lines | 458 lines | Medium |
| Layer 2 | 266 lines | 432 lines | Medium |
| Layer 3 | 200 lines | 250 lines | Low |
| Layer 4 | 266 lines | 403 lines | Medium |

## 🎯 Navigation Guide

### By Function
- **Menus**: `runtime/1-ui/menu/`
- **Services**: `runtime/2-application/jesteros/`
- **Libraries**: `runtime/3-system/common/`
- **Hardware**: `runtime/4-hardware/`

### By Technology
- **Shell Scripts**: All components use Bash
- **E-Ink**: `runtime/4-hardware/eink/`
- **Git Integration**: `runtime/2-application/writing/`
- **Power**: `runtime/4-hardware/power/`

### Key Files
- **Main Menu**: `runtime/1-ui/menu/nook-menu.sh`
- **Common Library**: `runtime/3-system/common/common.sh`
- **Service Manager**: `runtime/2-application/jesteros/manager.sh`
- **Display Control**: `runtime/4-hardware/eink/display-common.sh`

## 🔧 Development Guidelines

### Adding New Components

1. **Identify correct layer** based on functionality
2. **Follow layer dependencies** - only call lower layers
3. **Use common libraries** from Layer 3
4. **Add safety headers**: `set -euo pipefail`
5. **Follow naming conventions**: descriptive-name.sh
6. **Document purpose** in file header

### Best Practices

- **Layer 1**: Focus on user experience, keep logic minimal
- **Layer 2**: Implement business logic, manage state
- **Layer 3**: Provide reusable utilities, maintain consistency
- **Layer 4**: Abstract hardware complexity, provide clean interfaces

### Testing Strategy

- **Unit Tests**: Test each layer independently
- **Integration Tests**: Test layer interactions
- **Hardware Tests**: Validate Layer 4 on actual device
- **UI Tests**: Manual testing of Layer 1 components

## 📚 Related Documentation

- [ARCHITECTURE_4LAYER.md](../ARCHITECTURE_4LAYER.md) - Architecture design
- [ARCHITECTURE_ANALYSIS_REPORT.md](../ARCHITECTURE_ANALYSIS_REPORT.md) - Analysis & grade
- [README_ARCHITECTURE.md](README_ARCHITECTURE.md) - Architecture README
- [MIGRATION_COMPLETED.md](MIGRATION_COMPLETED.md) - Migration status

---

*"4 layers of elegance, built for writers!"* 🏛️📜