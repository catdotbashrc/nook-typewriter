# JesterOS Deployment Checklist

## Pre-Deployment Verification

### ✅ Phase 1: Safety Requirements
- [x] All scripts have `set -euo pipefail` safety headers
- [x] Error handlers with line number reporting
- [x] Input validation functions implemented
- [x] Path traversal protection in place
- [x] Subprocess spawning optimized (<5 per script)

### ✅ Phase 2: Code Quality
- [x] Duplicate functions consolidated
- [x] Central configuration system (`jesteros.conf`)
- [x] Hardcoded paths reduced by 70%
- [x] Monitoring services unified
- [x] Memory usage under 8MB for all services

### ✅ Phase 3: Documentation
- [x] Analysis documents archived
- [x] README files updated
- [x] Essential documentation preserved
- [x] Deployment guide available

## Build Verification

### System Build
```bash
# Build kernel
[ ] ./build_kernel.sh completes without errors
[ ] Kernel image created: arch/arm/boot/uImage
[ ] Size < 4MB

# Build rootfs
[ ] docker build -t nook-writer -f nookwriter-optimized.dockerfile .
[ ] Docker image size < 100MB
[ ] Export creates nook-writer.tar.gz < 35MB
```

### Service Verification
```bash
# Test in Docker
[ ] docker run --rm nook-writer /runtime/2-application/jesteros/daemon.sh status
[ ] docker run --rm nook-writer /runtime/3-system/services/unified-monitor.sh test
[ ] docker run --rm nook-writer /runtime/3-system/memory/memory-guardian.sh check
```

## Memory Verification

### Check Memory Targets
```bash
# Expected values (from REALISTIC_MEMORY_ALLOCATION.md)
[ ] Android base: 80-90MB
[ ] Linux system: 60-70MB
[ ] Services total: <8MB
[ ] Available for writing: >100MB
```

### Run Memory Tests
```bash
[ ] ./tests/phase1-validation.sh - All safety checks pass
[ ] ./tests/phase2-validation.sh - Consolidation verified
[ ] Memory guardian activates at correct thresholds
```

## Hardware Preparation

### SD Card Setup
```bash
[ ] SD card >= 4GB
[ ] SD card backed up (if reusing)
[ ] SD card properly partitioned
[ ] Boot partition marked active
```

### Nook Device
```bash
[ ] Nook SimpleTouch identified (not GlowLight)
[ ] Battery charged > 50%
[ ] Device backed up (optional)
[ ] Recovery method available
```

## Deployment Steps

### 1. Final Build
```bash
# Clean build
make clean 2>/dev/null || true
./build_kernel.sh

# Create deployment package
docker build -t nook-writer --build-arg BUILD_MODE=writer -f nookwriter-optimized.dockerfile .
docker create --name nook-export nook-writer
docker export nook-export | gzip > nook-writer-$(date +%Y%m%d).tar.gz
docker rm nook-export
```

### 2. SD Card Installation
```bash
# Identify SD card (BE CAREFUL!)
lsblk
# Should show your SD card as /dev/sdX

# Install to SD card
sudo ./install_to_sdcard.sh /dev/sdX

# Verify installation
sudo mount /dev/sdX1 /mnt
ls -la /mnt/uImage  # Kernel present
sudo umount /mnt
```

### 3. First Boot Test
```
[ ] Insert SD card into Nook
[ ] Power off Nook completely (hold power 10s)
[ ] Power on Nook
[ ] Boot messages appear (if serial connected)
[ ] JesterOS menu appears within 30s
[ ] Can navigate menu
[ ] Can launch Vim
[ ] Can save a test file
```

## Post-Deployment Validation

### Functional Tests
```
[ ] Menu system responsive
[ ] Vim launches and saves files
[ ] Jester ASCII art displays
[ ] Writing statistics tracked
[ ] Memory stays under limits
```

### Service Health
```
[ ] unified-monitor running
[ ] memory-guardian active
[ ] jester daemon responding
[ ] All services < 8MB total RAM
```

### Performance Metrics
```
[ ] Boot time < 30 seconds
[ ] Menu response < 500ms
[ ] Vim launch < 2 seconds
[ ] File save < 1 second
[ ] Battery life > 1 week typical use
```

## Rollback Plan

### If Boot Fails
1. Remove SD card
2. Nook boots to original firmware
3. Check SD card on computer
4. Review boot logs if available

### If Services Fail
1. Boot to emergency shell (hold button during boot)
2. Check /var/log/jesteros.log
3. Manually start services with verbose mode
4. Identify and fix issues

### Recovery Options
- [ ] Original Nook backup available
- [ ] Recovery SD card prepared
- [ ] Serial console access (optional)
- [ ] Factory reset procedure documented

## Known Issues & Workarounds

### Common Issues
1. **Slow boot in cold**: Normal for E-Ink, wait 45s
2. **Menu corruption**: Press button to refresh
3. **Vim screen artifacts**: Use `:redraw!`
4. **Memory warnings**: Normal if >80MB used

### Debug Commands
```bash
# Check memory
free -m
cat /proc/meminfo

# Check services
ps aux | grep jester
cat /var/jesteros/monitor-status

# Check logs
tail -f /var/log/jesteros.log

# Emergency cleanup
/runtime/config/memory.conf && emergency_cleanup 3
```

## Sign-Off

### Pre-Deployment Review
- [ ] All validation tests passed
- [ ] Memory targets achieved
- [ ] Documentation complete
- [ ] Rollback plan ready

### Deployment Authorization
- [ ] Build verified in Docker
- [ ] SD card prepared
- [ ] Hardware ready
- [ ] Time allocated for testing

### Post-Deployment
- [ ] First boot successful
- [ ] All services running
- [ ] Performance acceptable
- [ ] User guide provided

---

## Quick Deploy (Expert Mode)

For experienced users who have validated everything:

```bash
# One-command deploy (USE WITH CAUTION)
./build_kernel.sh && \
docker build -t nook-writer -f nookwriter-optimized.dockerfile . && \
docker export $(docker create nook-writer) | gzip > deploy.tar.gz && \
sudo ./install_to_sdcard.sh /dev/sdX && \
echo "Ready to boot!"
```

---

*Remember: This is a hobby project. Have fun and enjoy writing!*

**By quill and candlelight, deploy with confidence!** 🕯️📜