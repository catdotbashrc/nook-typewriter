# Architecture-Aligned Project Restructuring

## Current vs Proposed Structure

### 🏗️ 5-Layer Architecture Mapping

```
Architecture Layer          Current Location            Proposed Location
─────────────────────────────────────────────────────────────────────────
1. UI Layer                 runtime/ui/                 runtime/1-ui/
   (User Interface)         runtime/scripts/menu/       ├── menu/
                           runtime/configs/ascii/       ├── display/
                                                       └── themes/

2. Application Services     runtime/scripts/services/   runtime/2-application/
   (Business Logic)         runtime/scripts/boot/       ├── jesteros/
                                                       ├── writing/
                                                       └── stats/

3. System Services          runtime/scripts/lib/        runtime/3-system/
   (OS Integration)         (FBInk in docker)           ├── display/
                                                       ├── filesystem/
                                                       └── process/

4. Kernel Interface         runtime/modules/            runtime/4-kernel/
   (Kernel Communication)   (currently empty)           ├── modules/
                                                       ├── proc/
                                                       └── sysfs/

5. Hardware Abstraction     (mixed in scripts)          runtime/5-hardware/
   (Hardware Control)                                   ├── eink/
                                                       ├── usb/
                                                       └── power/
```

## Proposed New Structure

```
nook/
├── runtime/                    # Device runtime code (matches architecture)
│   ├── 1-ui/                  # User Interface Layer
│   │   ├── menu/              # Menu system scripts
│   │   ├── display/           # Display components
│   │   └── themes/            # ASCII art, themes
│   │
│   ├── 2-application/         # Application Services Layer  
│   │   ├── jesteros/          # JesterOS services
│   │   │   ├── mood.sh        # Mood selector
│   │   │   ├── daemon.sh      # Main daemon
│   │   │   └── tracker.sh     # Stats tracking
│   │   ├── writing/           # Writing-specific services
│   │   └── stats/             # Statistics services
│   │
│   ├── 3-system/              # System Services Layer
│   │   ├── display/           # FBInk integration
│   │   ├── filesystem/        # File management
│   │   ├── process/           # Process management
│   │   └── common/            # Shared libraries
│   │
│   ├── 4-kernel/              # Kernel Interface Layer
│   │   ├── modules/           # Kernel modules (.ko files)
│   │   ├── proc/              # /proc interface scripts
│   │   └── sysfs/             # /sys interface scripts
│   │
│   ├── 5-hardware/            # Hardware Abstraction Layer
│   │   ├── eink/              # E-Ink specific code
│   │   ├── usb/               # USB/keyboard handling
│   │   └── power/             # Power management
│   │
│   ├── configs/               # All configuration files
│   │   ├── system/            # System configs
│   │   ├── services/          # Service configs
│   │   └── vim/               # Editor configs
│   │
│   └── init/                  # Boot/initialization
│       ├── boot.sh            # Main boot script
│       └── chroot.sh          # Chroot transition
│
├── development/               # Keep as-is (good separation)
├── tools/                     # Keep as-is
├── docs/                      # Keep as-is
└── tests/                     # Keep as-is
```

## Migration Plan

### Phase 1: Create New Structure
```bash
#!/bin/bash
# Create architecture-aligned directories

cd runtime/

# Create layer directories
mkdir -p 1-ui/{menu,display,themes}
mkdir -p 2-application/{jesteros,writing,stats}
mkdir -p 3-system/{display,filesystem,process,common}
mkdir -p 4-kernel/{modules,proc,sysfs}
mkdir -p 5-hardware/{eink,usb,power}
mkdir -p init
```

### Phase 2: Move Files (Examples)
```bash
# UI Layer
mv scripts/menu/* 1-ui/menu/
mv ui/components/* 1-ui/display/
mv ui/themes/* 1-ui/themes/
mv configs/ascii/* 1-ui/themes/

# Application Layer
mv scripts/services/jesteros-* 2-application/jesteros/
mv scripts/services/jester-daemon.sh 2-application/jesteros/daemon.sh

# System Layer
mv scripts/lib/common.sh 3-system/common/
mv scripts/lib/service-functions.sh 3-system/common/

# Kernel Layer
mv modules/* 4-kernel/modules/

# Init
mv scripts/boot/jesteros-init.sh init/
mv scripts/boot/boot-*.sh init/
```

## Benefits of This Structure

### 1. **Clear Layer Boundaries**
- Each directory number shows its layer in the stack
- Dependencies only flow downward (1→2→3→4→5)
- Easy to enforce architectural rules

### 2. **Better Maintainability**
- New developers immediately understand the architecture
- Clear where to add new features
- Obvious impact analysis for changes

### 3. **Testing Strategy**
```
tests/
├── 1-ui-tests/        # UI interaction tests
├── 2-app-tests/       # Service logic tests
├── 3-system-tests/    # System integration tests
├── 4-kernel-tests/    # Module tests
└── 5-hardware-tests/  # Hardware mock tests
```

### 4. **Documentation Alignment**
```
docs/
├── architecture/
│   ├── 1-ui-layer.md
│   ├── 2-application-layer.md
│   ├── 3-system-layer.md
│   ├── 4-kernel-layer.md
│   └── 5-hardware-layer.md
```

## Implementation Checklist

- [ ] Backup current structure
- [ ] Create new directory structure
- [ ] Move files to appropriate layers
- [ ] Update all script paths and imports
- [ ] Update documentation references
- [ ] Test boot sequence with new paths
- [ ] Update Docker build files
- [ ] Run full test suite

## Questions to Resolve

1. **Boot Scripts**: Should they be in `init/` or distributed across layers?
   - Recommendation: Keep in `init/` for clear boot sequence

2. **Configs**: Single `configs/` dir or distributed per layer?
   - Recommendation: Keep centralized for easier management

3. **Common Libraries**: In `3-system/common/` or separate `common/`?
   - Recommendation: In system layer as they're system services

4. **Cross-Layer Scripts**: Some scripts touch multiple layers
   - Recommendation: Place in highest layer they touch

## Script to Show Current Misalignment

```bash
#!/bin/bash
echo "Files that don't match their architectural layer:"
echo "================================================"

# UI files not in UI directory
echo "UI Layer files outside ui/:"
find runtime/scripts -name "*menu*" -o -name "*display*"

# System services in wrong place
echo -e "\nSystem service files not organized:"
find runtime/scripts -name "*common*" -o -name "*service*"

# Application services scattered
echo -e "\nApplication services not grouped:"
find runtime/scripts -name "*jester*"
```

## Next Steps

1. **Review & Approve**: Does this structure make sense?
2. **Gradual Migration**: Move one layer at a time
3. **Update Imports**: Fix all script dependencies
4. **Test Each Layer**: Ensure nothing breaks
5. **Document Changes**: Update all references

This restructuring will make the codebase much more intuitive and maintainable!