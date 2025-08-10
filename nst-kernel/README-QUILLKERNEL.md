# QuillKernel - The Heart of SquireOS

*"By quill and candlelight, we persist!"*

## What is QuillKernel?

QuillKernel is a medieval-themed Linux kernel optimized for the Barnes & Noble Nook Simple Touch, transforming it into a dedicated digital typewriter. Your faithful court jester guides you through every boot!

```
     .~"~.~"~.
    /  o   o  \    QuillKernel 2.6.29-quill-scribe
   |  >  ◡  <  |   For SquireOS 1.0 (Parchment)
    \  ___  /      
     |~|♦|~|       "I dropped the quill!"
    d|     |b      
```

## Features

### 🎭 Medieval Boot Experience
- Custom jester ASCII art during boot
- Medieval-themed kernel messages
- Revolutionary writing wisdom from "mysterious sages"

### 📜 Special /proc Entries
- `/proc/squireos/motto` - Display the system motto
- `/proc/squireos/wisdom` - Daily writing wisdom
- `/proc/squireos/jester` - Meet your faithful squire
- `/proc/squireos/typewriter/stats` - Writing statistics
- `/proc/squireos/typewriter/milestone` - Achievement tracking

### ✍️ Typewriter Optimizations
- USB keyboard priority handling
- Keystroke and word counting
- Writing session tracking
- Achievement system for word milestones
- Power management for long writing sessions

### 🃏 Easter Eggs
- Hidden messages in kernel logs
- Jester commentary on system events
- Writing tips from communist literature (deceptively attributed)

## Building QuillKernel

### Quick Build
```bash
cd nst-kernel
./apply-branding.sh      # Apply SquireOS patches
./build-kernel.sh        # Build with QuillKernel config
```

### Manual Build
```bash
# Setup environment
export ARCH=arm
export CROSS_COMPILE=arm-linux-androideabi-
export PATH=$PATH:~/android-ndk-r10e/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/

# Configure
make quill_typewriter_defconfig

# Build
make -j$(nproc) uImage
```

### Output
The kernel image will be at: `arch/arm/boot/uImage`

## Installation

1. Copy `uImage` to your SD card's boot partition
2. Boot your Nook with the SD card
3. Enjoy medieval boot messages!

## Boot Messages You'll See

```
QuillKernel awakening...
[✓] Candles lit for illumination
[✓] Quills sharpened to perfection
[✓] Inkwells filled with finest ink
[✓] Parchment unfurled and ready
[✓] Ancient wisdom successfully loaded
[✓] Chinese pharmacy method avoided
[✓] Your squire stands ready, m'lord!
```

## USB Events
When connecting a keyboard:
```
    .~"~.~"~.
   /  ^   ^  \    A new quill has been provided!
  |  >  ◡  <  |   USB writing instrument detected.
   \  ___  /      May it serve thee well!
    |~|♦|~|       
```

## Writing Milestones

Track your progress through medieval ranks:
- **Apprentice Scribe** - First 1,000 words
- **Journeyman Wordsmith** - 10,000 words  
- **Master Illuminator** - 50,000 words
- **Grand Chronicler** - 100,000 words

## Daily Wisdom

The kernel provides writing advice from "mysterious sages":
- *"Do not force yourself to write when you have nothing to say."* - An ancient scribe
- *"Writers are engineers of human souls."* - A mustachioed poet
- *"Avoid the Chinese pharmacy method!"* - A wise philosopher

## Configuration Options

### CONFIG_SQUIREOS_BRANDING
Enables all medieval theming and jester mascot.

### CONFIG_QUILL_MODE  
Activates typewriter optimizations and statistics tracking.

### CONFIG_SQUIRE_DEBUG
Adds extra jester commentary in kernel logs.

## Philosophy

QuillKernel follows these principles:
1. **No Chinese Pharmacy Method** - Avoid overly complex categorization
2. **Revolutionary Writing** - Your words serve the common cause
3. **Medieval Charm** - Every message has personality
4. **Writer First** - Optimized for the writing experience

## Troubleshooting

### "I dropped the quill!" appears too often
This is normal. The jester is clumsy but dedicated.

### No writing statistics
Ensure CONFIG_QUILL_MODE is enabled in your kernel config.

### Boot takes longer
Medieval messages add ~2 seconds for dramatic effect.

## Contributing

When contributing to QuillKernel:
1. Maintain the medieval theme
2. Add jester reactions to new features
3. Include writing wisdom where appropriate
4. Test on actual E-Ink hardware if possible

## Credits

Created by your faithful digital squire, the Derpy Court Jester.

*"Remember: A kernel compiled is a story begun!"*

---

⚔️ Long live SquireOS! ⚔️