---
description: Analyze codebase adherence to Nook typewriter constraints and philosophy
tools: ["Bash", "Grep", "Read", "Glob", "LS"]
---

# Constraint Audit

Perform a comprehensive audit of the Nook typewriter codebase to ensure it adheres to all project constraints and the writer-first philosophy.

## Analysis Instructions

### 1. Memory Budget Compliance
Check that the system respects the sacred memory allocation:
- Verify Dockerfile doesn't install unnecessary packages
- Check total image size stays reasonable (< 800MB)
- Confirm no memory-heavy services are added
- Look for any package that could steal from the 160MB writing space

### 2. Distraction-Free Verification
Scan for any features that could distract writers:
- Search for web browsers, email clients, or social media tools
- Check for games, media players, or entertainment software
- Verify no development environments beyond Vim
- Ensure no persistent network connections beyond sync

### 3. E-Ink Compatibility
Verify all UI elements work with E-Ink constraints:
- Check all FBInk commands have `|| true` fallbacks
- Ensure no animations or rapid refresh requirements
- Verify menu systems handle display gracefully
- Look for any graphics-heavy operations

### 4. USB Keyboard Support
Validate keyboard handling:
- Check kernel configuration mentions USB host mode
- Verify power consumption considerations (< 100mA)
- Look for keyboard-specific error handling
- Ensure fallback mechanisms exist

### 5. Philosophy Adherence
Confirm the project maintains its core values:
- Writers over features
- Simplicity over complexity
- Constraints as features, not limitations
- Medieval theme consistency where applicable

## What to Report

Focus your analysis on:
1. **Violations**: Any clear breaks from constraints
2. **Risks**: Changes that could lead to violations
3. **Opportunities**: Ways to better serve writers
4. **Memory waste**: Packages or features consuming unnecessary RAM
5. **Complexity creep**: Features that add confusion without value

## Key Files to Examine

- `nookwriter.dockerfile` - Check for package bloat
- `config/scripts/nook-menu.sh` - Verify E-Ink handling
- `config/vimrc` - Ensure writer-focused configuration
- `docker-compose.yml` - Check resource limits
- `CLAUDE.md` - Verify guidelines are being followed

Remember: Every byte of RAM matters, every feature is a potential distraction, and the goal is helping writers write, not adding technology.