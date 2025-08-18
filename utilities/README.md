# JesterOS Utilities Directory

*Unified collection of scripts and tools for JesterOS/Nook project*

## Directory Structure

### `/lib/` - Common Libraries
- `common.sh` - Core library with logging, error handling, and utilities

### `/build/` - Build and Docker Management
- Docker cache management and optimization tools
- Build workflow improvements
- BuildKit optimization scripts

### `/deploy/` - Deployment Tools
- SD card creation and flashing utilities
- Deployment scripts for Nook devices

### `/maintain/` - Maintenance Scripts
- Project cleanup and maintenance
- Boot loop fixes and troubleshooting
- JesterOS installation utilities

### `/setup/` - Configuration and Setup
- System setup scripts
- Metadata application
- Version control utilities

### `/migrate/` - Migration Tools
- Architecture migration scripts
- Path fixing utilities

### `/test/` - Testing Framework
- Unified test framework with assertions
- Test runner and individual test scripts

### `/platform/` - Platform-Specific Tools
- Windows PowerShell scripts
- WSL utilities

### `/extras/` - Additional Tools
- Splash screen generator for E-Ink displays

## Usage

All scripts should be run from the project root:
```bash
./utilities/build/docker-cache-manager.sh
./utilities/test/run-all.sh
```

## Migration from scripts/ and tools/

This directory consolidates the former `/scripts/` and `/tools/` directories.
- 4 duplicate scripts eliminated
- Cleaner, more maintainable structure
- Standardized error handling across all scripts

---
*Migrated: $(date)*
