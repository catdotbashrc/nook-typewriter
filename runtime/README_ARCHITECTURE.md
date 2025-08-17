# Runtime Architecture - 4 Layer Structure

## Current Structure (Userspace-Only Implementation)

The runtime directory follows a **4-layer architecture** that reflects our purely userspace implementation without kernel modules.

```
runtime/
├── 1-ui/           # User Interface Layer
├── 2-application/  # Application Services (JesterOS)
├── 3-system/       # System Services
├── 4-hardware/     # Hardware Abstraction
├── configs/        # Configuration files
└── init/           # Boot initialization
```

## Why 4 Layers?

Originally planned as 5 layers with kernel modules, we simplified to 4 layers because:
- JesterOS runs entirely in **userspace** (no kernel modules)
- Uses `/var/jesteros/` instead of `/proc/jesteros/`
- Avoids kernel compilation complexity
- Aligns with "writers over features" philosophy

## Layer Dependencies

```
1-ui → 2-application → 3-system → 4-hardware
```

- Higher layers can call lower layers
- Lower layers cannot call higher layers
- No circular dependencies allowed

## Layer Contents

### Layer 1: User Interface
- Menu systems
- Display components
- Themes and ASCII art

### Layer 2: Application Services
- JesterOS services (mood, stats, quotes)
- Writing modes
- Business logic

### Layer 3: System Services
- Common libraries
- File system operations
- Process management

### Layer 4: Hardware Abstraction
- E-Ink display control
- USB keyboard detection
- Power management

## Clean Up Old Structure

The following directories are obsolete and can be removed:
- `runtime/scripts/` - Duplicated in layers
- `runtime/ui/` - Moved to 1-ui
- `runtime/modules/` - No kernel modules (userspace only)

```bash
# Clean up obsolete directories
rm -rf runtime/scripts runtime/ui runtime/modules
```