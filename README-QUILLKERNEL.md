# QuillKernel - The Medieval Nook Kernel

```
     .~"~.~"~.
    /  o   o  \    Welcome to QuillKernel!
   |  >  ◡  <  |   Where thy Nook becomes
    \  ___  /      a digital scriptorium!
     |~|♦|~|       
```

## What is QuillKernel?

QuillKernel is a custom Linux kernel for the Barnes & Noble Nook Simple Touch that transforms it into SquireOS - a whimsical medieval-themed digital typewriter. Your faithful court jester accompanies you through boot messages, system interfaces, and writing achievements.

## Key Features

### 🏰 Medieval Experience

**Boot Messages**
```
Your faithful court jester awakens...
Preparing thy digital quill...
By candlelight, we begin...
Your squire stands ready!
```

**Achievement System**
- Apprentice Scribe (0-999 words)
- Journeyman Wordsmith (1,000-9,999 words)  
- Master Illuminator (10,000-49,999 words)
- Expert Chronicler (50,000-99,999 words)
- Grand Chronicler (100,000+ words)

**System Interface**
- `/proc/squireos/motto` - "By quill and candlelight"
- `/proc/squireos/wisdom` - Rotating quotes about writing
- `/proc/squireos/jester` - ASCII art companion
- `/proc/squireos/typewriter/stats` - Writing statistics

### ⌨️ Technical Features

- **USB Host Mode**: Full keyboard support via OTG
- **Typewriter Module**: Tracks keystrokes, words, sessions
- **Fast E-Ink Mode**: Reduced ghosting, faster refresh
- **Memory Optimized**: Works within 256MB constraint
- **Power Efficient**: Extended battery for writing

### 🧪 Professional Testing

QuillKernel includes a comprehensive test suite:
- 12+ test scripts covering all aspects
- Graceful hardware detection
- Docker build support
- CI/CD ready
- Clear, helpful error messages

## Quick Start

### 1. Apply Patches
```bash
cd nst-kernel
./squire-kernel-patch.sh
```

### 2. Configure
```bash
cd src
make ARCH=arm quill_typewriter_defconfig
```

### 3. Build
```bash
# Traditional build
make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- uImage

# Or use Docker (no toolchain needed!)
docker build -f ../Dockerfile.build -t quillkernel ..
```

### 4. Test
```bash
cd ../test
./verify-build-simple.sh  # Quick check
./run-all-tests.sh        # Full suite
```

## The Jester's Guidance

Throughout QuillKernel, the court jester provides feedback:

**Success** ✅
```
     .~"~.~"~.
    /  ^   ^  \    Excellent! All tests passed!
   |  >  ◡  <  |   Thy kernel is ready!
    \  ___  /      
     |~|♦|~|       
```

**Warnings** ⚠️
```
     .~"~.~"~.
    /  o   o  \    Some warnings found.
   |  >  _  <  |   'Tis acceptable, but
    \  ___  /      could be better...
     |~|♦|~|       
```

**Errors** ❌
```
     .~!!!~.
    / O   O \    Alas! Errors detected!
   |  >   <  |   Fix these issues forthwith!
    \  ~~~  /    
     |~|♦|~|     
```

## Writing Philosophy

QuillKernel embraces the philosophy of focused, distraction-free writing. The medieval theme isn't just decoration - it's a reminder that writing is a craft, requiring patience and dedication like the scribes of old.

### Inspirational Quotes

The `/proc/squireos/wisdom` file rotates through quotes like:
- *"Writing is easy. Just apply pen to paper and bleed."* - A wise scribe
- *"The first draft is just you telling yourself the story."* - An illuminated manuscript
- *"There is no greater agony than bearing an untold story inside you."* - A suffering poet

## System Requirements

- **Device**: Barnes & Noble Nook Simple Touch (rooted)
- **Hardware**: USB OTG adapter, USB keyboard
- **Build**: Linux system with ARM cross-compiler or Docker
- **Memory**: 256MB RAM (kernel optimized for this)
- **Storage**: SD card for boot

## Testing Philosophy

All tests follow "graceful degradation":
- Work in Docker without hardware
- Clear [SKIP] messages for missing components
- Never fail due to environment
- Helpful error messages
- Medieval personality throughout

Example test output:
```
Testing USB subsystem... [PASS]
Testing E-Ink display... [SKIP] No framebuffer device
Testing typewriter module... [PASS]
Testing memory constraints... [PASS]

     .~"~.~"~.
    /  ^   ^  \    Tests complete!
   |  >  ◡  <  |   9 passed, 0 failed, 3 skipped
    \  ___  /      
     |~|♦|~|       
```

## Documentation

Complete documentation available in `/docs/`:
- [Testing Overview](docs/testing-overview.md) - Start here
- [Test Documentation](docs/test-documentation.md) - Detailed reference
- [Writing Tests](docs/writing-tests.md) - Add your own tests
- [Docker Testing](docs/docker-testing.md) - Container builds
- [CI Integration](docs/ci-integration.md) - Automation setup

## Community

QuillKernel is open source and welcomes contributions! Whether you're fixing bugs, adding features, or improving the medieval theme, your patches are welcome.

Remember the scribe's wisdom: *"A manuscript shared is knowledge doubled!"*

## License

GPL v2 (as required by Linux kernel)

---

*"By quill and candlelight, we code..."* 🕯️📜