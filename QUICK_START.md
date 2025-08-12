# Quick Start Guide

## Project is cleaned and organized!

### Build Modules
```bash
./build/scripts/build_modules.sh
```

### Create Deployment Package
```bash
./build/scripts/create_deployment.sh
```

### Deploy to Nook
```bash
./build/scripts/deploy_to_nook.sh
```

### Built Modules Location
- `firmware/modules/*.ko` - Ready to deploy kernel modules

### Output Archives
- `build/output/` - All deployment packages

### Documentation
- `docs/deployment/` - Deployment guides
- `docs/development/` - Development docs

## Cleanup Notes
Some root-owned files remain in:
- `standalone_modules/` - Can be safely ignored or removed with sudo
- `source/kernel/src/` - Build artifacts from Docker operations

To fully clean (requires sudo):
```bash
sudo rm -rf standalone_modules
sudo find . -name "*.o" -delete
```
