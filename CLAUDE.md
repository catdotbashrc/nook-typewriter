# CLAUDE.md - Nook Typewriter Project

## Project Philosophy

This transforms a $20 used e-reader into a $400 distraction-free writing device. Every decision prioritizes **writers over features**.

### Our Users
- **Digital Minimalist Writers**: Escaping notifications to focus on words
- **Retro Computing Enthusiasts**: Appreciating the "digital scriptorium" aesthetic  
- **Budget-Conscious Creators**: Can't afford Freewrite, have old Nooks
- **Environmental Advocates**: Preventing e-waste through repurposing

### What This IS
✅ Pure writing environment (Vim + E-Ink)
✅ Whimsical medieval theme (QuillKernel)
✅ Extreme battery life (weeks not hours)
✅ Zero distractions by design

### What This ISN'T
❌ Development environment
❌ Web browsing device
❌ Email/social media machine
❌ General purpose computer

## Critical Constraints

```yaml
Hardware Limits:
  CPU: 800 MHz ARM (slower than 2008 iPhone)
  RAM: 256MB total (160MB for writing after OS)
  Display: 6" E-Ink (800x600, 16 grayscale)
  Storage: SD card based
  Power: <100mA USB output

Design Implications:
  - Every MB matters for writing space
  - E-Ink refresh = feature not bug (prevents addiction)
  - Simple > Feature-rich
  - Text-only is perfect
```

## Writer-First Development Rules

### Before ANY Change, Ask:
1. **Does this help writers write?**
2. **What RAM does this steal from writing?**
3. **Will this add distractions?**
4. **Can writers understand the error messages?**

### Memory Budget
```
Reserved for OS:     95MB (Debian base)
Reserved for Vim:    10MB (editor + plugins)
SACRED Writing Space: 160MB (DO NOT TOUCH)
```

### E-Ink Considerations
- Full refresh (`fbink -c`) = intentional pause for thought
- Ghosting = gentle reminder of previous words
- Slow menus = mindful interaction
- No animations = focused attention

## Essential Commands

### For Writers Testing Features
```bash
# Quick test writing experience
docker run -it --rm nook-system vim /tmp/test.txt

# Check memory impact of changes
docker stats nook-system --no-stream

# Verify distraction-free (should fail)
docker run --rm nook-system ping google.com 2>/dev/null || echo "✓ No internet distractions"
```

### Building for Writers
```bash
# Standard build
docker build -t nook-system -f nookwriter.dockerfile .

# Test medieval theme
docker run --rm nook-system cat /proc/squireos/motto 2>/dev/null || echo "Not on real hardware"

# Create writer's deployment
docker create --name nook-export nook-system
docker export nook-export | gzip > nook-debian.tar.gz
docker rm nook-export
```

### QuillKernel (Medieval Magic)
```bash
cd nst-kernel
./squire-kernel-patch.sh  # Adds jester, achievements, writing stats

# Docker build (no toolchain needed!)
docker build -f Dockerfile.build -t quillkernel .

# Test the medieval experience
cd test
./verify-build-simple.sh  # Should see jester ASCII art
```

## Testing for Writers

### What to Test
```yaml
Writing Flow:
  - Can open Vim in <2 seconds?
  - Does Ctrl+S save intuitively?
  - Is word count visible?
  - Do writing plugins work?

Distractions:
  - No network browsing possible?
  - No app notifications?
  - No social media access?
  - Focus mode (\g in Vim) works?

Battery:
  - Changes increase power draw?
  - WiFi off by default?
  - CPU throttled appropriately?
```

### Writer-Friendly Error Messages
```bash
# BAD: Technical jargon
"Error: fbdev ioctl FBIOGET_VSCREENINFO failed"

# GOOD: Writer-friendly
"E-Ink display not found (normal in Docker testing)"

# BEST: Medieval theme
"Alas! The digital parchment is not ready!"
```

## Common Writer Issues

### "My keyboard doesn't work"
- Need USB host kernel (version 174+)
- Wireless keyboards need powered hub
- Best: Wired USB from ~2011 era

### "Screen looks weird"
- E-Ink ghosting is normal (not a bug)
- Press 5 in menu for full refresh
- It's supposed to be slow (mindfulness!)

### "Can't save my work"
- Space issue: Check with `df -h`
- Vim command: `:w!` forces save
- Emergency: USB mount SD card to recover

### "How do I get my writing off?"
- Option 1: rclone sync (menu option 3)
- Option 2: Remove SD card, mount on PC
- Option 3: Future feature - email to self

## File Organization

```
Critical Paths:
/usr/local/bin/nook-menu.sh    # Main writer interface
/root/.vimrc                    # Writing configuration  
/root/writing/                  # Sacred writing directory
/proc/squireos/                 # Medieval theme interface

Never Touch:
/usr/share/doc/                # Wastes writing space
/var/cache/                     # Precious RAM
/usr/share/man/                 # No one reads on E-Ink
```

## Contributing Guidelines

### Welcome Contributions
✅ Reducing memory usage
✅ Better writing tools (spell check, thesaurus)
✅ Battery life improvements
✅ More medieval whimsy
✅ Writer workflow enhancements

### Unwelcome Changes
❌ Web browsers or internet features
❌ Development tools (compilers, interpreters)
❌ Media players or graphics
❌ Anything using >5MB RAM
❌ Features requiring constant refresh

### Testing Checklist
- [ ] Works in 160MB free RAM?
- [ ] E-Ink friendly (minimal refresh)?
- [ ] No network dependencies?
- [ ] Writer can understand errors?
- [ ] Medieval theme maintained?
- [ ] Battery impact measured?

## Quick Reference

### Memory Monitor
```bash
# During development
watch -n 5 'free -h | grep Mem'

# Before committing
echo "=== Memory Impact ==="
docker stats nook-system --no-stream --format "RAM: {{.MemUsage}}"
```

### Writer's Toolbox
```vim
" Vim commands writers need
\g          " Goyo (focus mode)
\p          " Pencil (better writing)
:w          " Save
:q          " Quit
Ctrl+S      " Save (familiar to writers)
Ctrl+Q      " Quit (familiar to writers)
```

### Medieval Debug
```bash
# Check if QuillKernel is active
cat /proc/squireos/jester || echo "No jester (not QuillKernel)"

# View writing statistics  
cat /proc/squireos/typewriter/stats

# Get inspiration
cat /proc/squireos/wisdom
```

## Philosophy Reminders

> "Every feature is a potential distraction"

> "RAM saved is words written"

> "E-Ink limitations are features"

> "When in doubt, choose simplicity"

> "The jester reminds us: writing should be joyful"

## Hardware Reality Check

Remember what we're working with:
- **CPU**: Slower than a 2008 iPhone
- **RAM**: Less than a single Chrome tab
- **Display**: Refreshes like paper, not pixels
- **Purpose**: Writing, not computing

Every line of code should respect these limits while serving writers who chose this device specifically for its constraints.

---

*"By quill and candlelight, we code for those who write"* 🕯️📜