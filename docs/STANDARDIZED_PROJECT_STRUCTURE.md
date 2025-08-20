# Standardized Project Structure for JesterOS

> **Goal**: Use industry-standard conventions that any developer will recognize  
> **Reference**: Linux kernel, Buildroot, Yocto, and embedded Linux best practices

## Industry-Standard Structure

```
nook/
├── src/                      # Source code (universally recognized)
│   ├── init/                # System initialization
│   ├── drivers/             # Hardware drivers
│   ├── services/            # System services/daemons
│   ├── utils/               # Utility programs
│   └── apps/                # User applications
│
├── configs/                  # Configuration files (standard name)
│   ├── kernel/              # Kernel config
│   ├── system/              # System configs
│   └── user/                # User configs (vim, etc)
│
├── resources/                # Static resources
│   ├── fonts/               # Font files
│   ├── themes/              # UI themes
│   └── ascii/               # ASCII art
│
├── platform/                 # Platform-specific files
│   ├── nook/                # Nook hardware specifics
│   │   ├── bootloader/      # MLO, u-boot
│   │   ├── kernel/          # uImage
│   │   └── platform/nook-touch/        # Binary blobs (DSP, E-ink)
│   └── android/             # Android init dependencies
│
├── build/                    # Build outputs (standard)
│   ├── root/                # Root filesystem
│   ├── images/              # Final images
│   └── tmp/                 # Temporary build files
│
├── tools/                    # Build and dev tools (standard)
│   ├── build/               # Build scripts
│   ├── deploy/              # Deployment scripts
│   └── test/                # Test utilities
│
├── tests/                    # Test suite (standard)
│   ├── unit/                # Unit tests
│   ├── integration/         # Integration tests
│   └── system/              # System tests
│
├── docs/                     # Documentation (standard)
│   ├── api/                 # API documentation
│   ├── guides/              # User guides
│   └── design/              # Design documents
│
├── contrib/                  # Third-party contributions
│   └── dockerfiles/         # Docker configurations
│
├── vendor/                   # External dependencies
│   ├── kernel/              # Linux kernel source
│   └── toolchain/           # Cross-compilation tools
│
├── .github/                  # GitHub-specific (standard)
│   └── workflows/           # CI/CD pipelines
│
├── CMakeLists.txt           # OR Makefile (build system)
├── README.md                # Project overview
├── LICENSE                  # License file
├── CHANGELOG.md             # Version history
└── .gitignore              # Git ignore rules
```

## Alternative: Buildroot-Style Structure

If you want maximum familiarity for embedded Linux developers:

```
nook/
├── board/                    # Board-specific files
│   └── nook/                # Nook platform
│       ├── rootfs_overlay/  # Files to overlay on rootfs
│       ├── kernel_patches/  # Kernel patches
│       └── bootloader/      # Bootloader files
│
├── package/                  # Package definitions
│   ├── jesteros-init/      # Init system package
│   ├── jesteros-ui/        # UI package
│   └── jesteros-services/  # Services package
│
├── configs/                  # Build configurations
│   └── nook_defconfig       # Default Nook config
│
├── output/                   # Build outputs
│   ├── images/              # Final images
│   ├── build/               # Build directory
│   └── target/              # Target rootfs
│
├── dl/                       # Downloads cache
├── tools/                    # Build tools
└── Makefile                 # Main build system
```

## Recommended: Modern Embedded Project Structure

Combining best practices from various projects:

```
nook/
├── src/                      # All source code
│   ├── boot/                # Boot and init
│   │   ├── init.c          # Main init
│   │   └── early_init.sh   # Early boot scripts
│   │
│   ├── core/                # Core system services
│   │   ├── memory.c        # Memory management
│   │   ├── process.c       # Process management
│   │   └── ipc.c           # Inter-process communication
│   │
│   ├── hal/                 # Hardware Abstraction Layer
│   │   ├── eink/           # E-ink driver
│   │   ├── buttons/        # Button input
│   │   └── power/          # Power management
│   │
│   ├── services/            # System services
│   │   ├── jester/         # Jester daemon
│   │   ├── tracker/        # Writing tracker
│   │   └── menu/           # Menu system
│   │
│   └── apps/                # User applications
│       ├── vim/            # Vim configuration
│       └── git/            # Git integration
│
├── config/                   # Configuration (not configs)
│   ├── kernel/              # Kernel config
│   ├── buildroot/           # Build config
│   └── src/             # Runtime config
│
├── assets/                   # Static assets (not resources)
│   ├── fonts/
│   ├── images/
│   └── themes/
│
├── platform/                 # Platform-specific
│   └── nook-touch/         # Target hardware
│       ├── dts/            # Device tree
│       ├── platform/nook-touch/       # Binary blobs
│       └── specs.md        # Hardware specs
│
├── build/                    # Build output (gitignored)
│   ├── artifacts/           # Build artifacts
│   ├── dist/                # Distribution files
│   └── tmp/                 # Temporary files
│
├── scripts/                  # All scripts (standard location)
│   ├── build.sh            # Main build script
│   ├── deploy.sh           # Deployment
│   ├── test.sh             # Test runner
│   └── setup.sh            # Development setup
│
├── test/                     # Tests (not tests - singular)
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── docker/                   # Docker files
│   ├── Dockerfile          # Main dockerfile
│   ├── Dockerfile.dev      # Development image
│   └── docker-compose.yml  # Compose config
│
├── docs/                     # Documentation
│   ├── README.md           # Main docs
│   ├── ARCHITECTURE.md     # Architecture
│   ├── CONTRIBUTING.md     # Contribution guide
│   └── api/                # API docs
│
├── vendor/                   # Third-party code
│   └── linux-2.6.29/       # Kernel source
│
├── Makefile                 # GNU Make (most common)
├── README.md               # Project readme
├── LICENSE                 # MIT/GPL/etc
├── CHANGELOG.md            # Release history
├── .gitignore
└── .editorconfig           # Editor configuration
```

## Why These Conventions?

### Universal Directory Names

| Standard Name | Why It's Standard | What Goes There |
|--------------|-------------------|-----------------|
| `src/` | Every developer knows this = source code | All your code |
| `config/` | Singular, not plural (Linux convention) | Configuration files |
| `build/` | Universal build output directory | Generated files only |
| `scripts/` | Standard location for shell scripts | Build/deploy/test scripts |
| `test/` | Singular (Go, Rust convention) | Test files |
| `docs/` | Universal documentation folder | All documentation |
| `vendor/` | Standard for third-party code | External dependencies |
| `tools/` | Common for project-specific tools | Build helpers |
| `assets/` | Modern standard for static files | Images, fonts, etc |

### File Naming Conventions

```
src/
├── memory_manager.c       # C files: snake_case
├── MemoryManager.java     # Java: PascalCase
├── memory-manager.sh      # Shell scripts: kebab-case
├── memory_manager.py      # Python: snake_case
└── README.md             # Docs: UPPERCASE.md
```

### Standard Files at Root

```
README.md                   # First thing people read
LICENSE                     # Legal requirements
CHANGELOG.md               # Version history
CONTRIBUTING.md            # How to contribute
Makefile or CMakeLists.txt # Build entry point
.gitignore                 # Git configuration
.editorconfig              # Editor settings
```

## Migration to Standard Structure

### From Current to Standard

```bash
# Current → Standard mapping
src/init/ → src/boot/
src/1-ui/ → src/services/ui/
src/2-application/ → src/services/
src/3-system/ → src/core/
src/4-hardware/ → src/hal/
platform/nook-touch/ → platform/nook-touch/
docker/*.dockerfile → docker/
images/ → vendor/images/ or platform/nook-touch/images/
```

### Benefits of Standard Structure

1. **Instant Recognition**: Any developer knows where to find things
2. **Tool Compatibility**: IDEs, linters, CI/CD expect these paths
3. **Documentation**: Less explanation needed
4. **Onboarding**: New developers productive immediately
5. **Best Practices**: Follows Linux/embedded conventions

## Recommended Structure for JesterOS

Given your embedded Linux project, I recommend:

```
nook/
├── src/                     # All JesterOS source
│   ├── init/               # Boot and initialization
│   ├── core/               # Core services (memory, etc)
│   ├── hal/                # Hardware abstraction
│   ├── services/           # System services
│   └── apps/               # User applications
│
├── platform/                # Nook-specific files
│   └── nook-touch/
│       ├── bootloader/     # MLO, u-boot
│       ├── kernel/         # uImage
│       └── platform/nook-touch/       # Proprietary blobs
│
├── config/                  # All configuration
│   ├── kernel/
│   ├── system/
│   └── user/
│
├── scripts/                 # Build/deploy/test scripts
├── test/                    # Test suite
├── docs/                    # Documentation
├── docker/                  # Container definitions
├── vendor/                  # External code (kernel)
├── build/                   # Output (gitignored)
│
├── Makefile                # Main build system
├── README.md
├── LICENSE
└── CHANGELOG.md
```

This structure:
- Uses universally recognized names
- Follows embedded Linux conventions
- Makes the project approachable
- Supports your transition away from layers
- Keeps platform-specific code isolated

## Decision Points

1. **Makefile vs CMake?** Makefile is simpler and more common in embedded
2. **test/ vs tests/?** `test/` is becoming standard (Go, Rust influence)
3. **config/ vs configs/?** `config/` (singular) is Linux standard
4. **Split services and apps?** Yes - services are system, apps are user-facing

Would you like me to create a migration script for this standardized structure?