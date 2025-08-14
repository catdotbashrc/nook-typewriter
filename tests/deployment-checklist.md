# Deployment Checklist for Nook Typewriter

## Pre-Deployment (First Time)

### Safety First
- [ ] Nook internal storage backed up
- [ ] Using SD card for testing (NOT internal storage)
- [ ] Have a known-good SD card ready for rollback
- [ ] Understand how to remove SD card to revert

### Technical Validation
- [ ] `./tests/smoke-test.sh` passed
- [ ] `./tests/docker-test.sh` passed  
- [ ] `./tests/pre-flight.sh` completed
- [ ] Kernel built without errors
- [ ] Modules compiled successfully

## Hardware Deployment

### SD Card Preparation
- [ ] SD card formatted and ready
- [ ] Flash firmware: `sudo ./tools/deploy/flash-sd.sh`
- [ ] Verify flash completed without errors

### First Boot Test
- [ ] Insert SD card into Nook
- [ ] Power on device
- [ ] Watch for boot sequence
- [ ] Note boot time (target: <20 seconds)
- [ ] Verify jester appears
- [ ] Menu system loads

### Basic Functionality Test
- [ ] Can navigate menu
- [ ] Vim launches (target: <2 seconds)
- [ ] Can create new file
- [ ] Can type and edit text
- [ ] Can save file (target: <1 second)
- [ ] Can read saved file back

### Memory and Performance
- [ ] Run hardware memory test: `./tests/hardware-memory-test.sh`
- [ ] Check OS uses <96MB RAM (critical!)
- [ ] Verify >160MB available for writing
- [ ] Check `/var/jesteros/` interface works
- [ ] Verify JesterOS userspace services running
- [ ] Test vim memory usage (<10MB target)
- [ ] Monitor top memory consumers

## Post-Deployment

### Validation
- [ ] All basic functions work
- [ ] No kernel panics or crashes
- [ ] E-Ink display refreshes properly
- [ ] Device feels responsive

### Rollback Plan
- [ ] Know how to remove SD card
- [ ] Tested original Nook boots without SD card
- [ ] Keep working SD card image backup

## Memory Reality Check

Remember: Our memory calculations need review!
- Current check measures build artifacts, not runtime RAM
- Need actual memory measurement on running device
- Consider tools like `free`, `top`, `/proc/meminfo`
- May need to adjust 96MB target based on reality

## Notes

This is a hobby project - don't over-engineer the testing.
The goal is "won't brick" and "actually works", not enterprise compliance.

If something doesn't work perfectly, that's fine! 
It's a learning project with a whimsical jester theme.