# 🏰 JesterOS/JoKernel 🃏

### _A Most Noble Quest to Transform Thy Humble Nook into a Mystical Writing Device_

```
     _______________
    |  ___________  |
    | |  J E S T  | |
    | |    E R    | |    Hark! A Nook transformed!
    | |    O S    | |    Where quills meet silicon,
    | |___________| |    And jesters dance in binary!
    |_______________|
         | | | |
        /  | |  \
       /__/   \__\
```

## 📜 The Royal Proclamation

Hear ye, hear ye! By decree of the Mad King of Minimalism, we hereby transform a lowly $20 Barnes & Noble Nook Simple Touch into the most magnificent distraction-free writing apparatus in all the realm!

This mystical contraption runs upon the ancient Linux 2.6.29 kernel, constrained by the sacred memory limits of 256MB total RAM (with but 95MB for the OS, lest ye anger the Memory Guardian!).

## 🗡️ Thy Quest Begins Here (Getting Started)

### Prerequisites for Thy Noble Journey

- **Docker** - The mystical containment spell for cross-compilation sorcery
- **Make** - The ancient build incantation tool
- **A Brave Heart** - For the path ahead is fraught with embedded Linux perils!
- **SD Card** - A SanDisk Class 10, blessed by the Phoenix Project standards
  TODO: Link XDA phoenix project forums post

### 🎯 The Quick Quest (For Impatient Knights)

```bash
# Summon the complete firmware with one mighty spell!
make firmware

# Deploy to thy SD card (the system shall divine which device)
make sd-deploy

# Test thy creation before unleashing it upon the realm
make test-quick
```

## ⚔️ Ye Olden Features & Specifications

### The Four Pillars of Power (Architecture Layers)

1. **Adventurers Journey** _(UI Layer)_ - Where pixels dance upon e-ink parchment (200-980ms refresh, patience young squire!)
2. **Guild Hall** _(Applications Layer)_ - Home to the Jester Daemon, keeper of words and wit
3. **Sorcerers Tower** _(System Layer)_ - The Memory Guardian dwells here (95MB limit enforced with iron fist!)
4. **Lich Kings Tomb** _(Hardware Layer)_ - Android Init lurks below (we cannot slay it, only tame it). Are you brave enough to venture in to the depths heretofore unseen?

### Divine King's Proclamations! (Specifications)

- **Kernel**: Linux 2.6.29 (ancient, yet proven in battle)
- **Total RAM**: 256MB (A kings ransom in the days before!)
- **OS Memory Limit**: 95MB (enforced by the fearsome Memory-Guardian of the
  Shell)
- **Squire's Roost**: 160MB of SACRED AND INVIOLABLE space!
- **Boot Chain**: ROM → MLO (16KB) → U-Boot (159KB) → Kernel (1.9MB) → JesterOS

## 🛡️ The Arsenal of Commands

### Battle-Ready Build Spells

```bash
# The Necromancer's Incantation - summons the dead; breathes life into old Hardware!
make firmware

# Blessings of the Holy Paladin
make kernel          # Forge the kernel in Docker's crucible
make rootfs          # Craft the root filesystem with JesterOS magic
make lenny-rootfs    # Summon ancient Debian Lenny spirits
make image           # Create the sacred bootable SD scroll

# Swift Strike Options (for repeat battles)
make quick-build     # Skip unchanged components, save precious time
make quick-deploy    # Deploy kernel only to existing card
```

### The Champions Tournament (Prove Thy Worth!)

```bash
# The Complete Three Trials of Testing
make test           # Run all tests (as thorough as a royal inspection)

# The Quick Safety Dance (mandatory before deployment!)
make test-quick     # Critical checks only
make test-safety    # Even MORE critical checks

# Individual Combat Tests
make test-pre-build   # Test thy tools before Docker summoning
make test-post-build  # Verify Docker's output after the ritual
make test-runtime     # Test execution in the containment circle
```

### Docker Dungeon Management

```bash
# Construct the Docker Dungeons
make docker-build        # All images at once!
make docker-lenny        # The Ancient Debian Chamber
make docker-production   # The JesterOS Production Fortress
make docker-kernel       # The Kernel Compilation Catacomb

# Cleanse the Docker Catacombs
make docker-cache-clean  # Purge the cached spirits
```

## 📚 The Sacred Scrolls (Documentation)

Seek wisdom in these ancient texts:

- `docs/BOOT-INFRASTRUCTURE-COMPLETE.md` - The Complete Boot Prophecy
- `docs/JESTEROS_BOOT_PROCESS.md` - The JesterOS Ascension Ritual
- `.simone/constitution.md` - The Sacred Laws of the Covenant
- `.simone/architecture.md` - Blueprints of the Castle
- `CLAUDE.md` - Instructions for Summoning the Egregore, **Ser Claude of the Opus Realm**!

## 🏰 Tales from the Battlefield (Troubleshooting)

### When Dragons Attack (Common Issues)

**The Memory Beast Awakens**

```bash
# If you see "MEMORY LIMIT EXCEEDED! OS using X MB!"
# The Memory Guardian has spoken! Reduce thy footprint or face doom!
make test-runtime  # Check memory usage in safe environment
```

**The SD Card Refuses Thy Advances**

```bash
# Detection spell for finding the right device
make detect-sd    # Lists safe SD card paths

# Manual override for the bold
make sd-deploy SD_DEVICE=/dev/sdX  # Replace X with thy device letter
```

**The E-Ink Scroll Flickers Madly**

- Remember: E-ink refresh takes 200-980ms
- Design thy UI for minimal updates
- Patience is a virtue, young scribe!

## 👑 The Royal Court (Contributors)

- **The Mad Architect** - Designer of the 4-layer castle
- **The Memory Guardian** - Keeper of the 95MB limit
- **The Jester Daemon** - Bringer of whimsy and word counts
- **Brave Knights of XDA** - Who proved the Phoenix configurations

_Join our noble quest! Fork, enhance, and submit thy pull requests!_

## ⚖️ The Royal Decree (License & Rules)

### The Seven Sacred Commandments

1. **Thou Shalt Not Exceed 95MB** - The Memory Guardian watches always
2. **Thou Shalt Test Before Deploy** - `make test-quick` or face hardware doom
3. **Thou Shalt Respect the E-Ink** - Slow refreshes are a feature, not a bug
4. **Thou Shalt Use Docker** - Cross-compilation happens in containers only
5. **Thou Shalt Follow Phoenix Standards** - Firmware 1.2.2, SanDisk Class 10
6. **Thou Shalt Protect the Bootloader** - MLO and u-boot.bin are sacred
7. **Thou Shalt Not Disturb the Writing Space** - 160MB is inviolable!

## 🎭 The Jester's Final Jest

```
    Why did the Nook cross-compile?
    To get to the other architecture!

    *ba dum tss* 🥁

    Thank you, thank you, I'll be here all kernel panic!
```

---

### 🚀 Quick Start for the Impatient Noble

```bash
git clone https://github.com/yourrealm/jesteros.git
cd jesteros
make firmware && make test-quick && make sd-deploy
# Insert SD card into Nook, boot, and write thy masterpiece!
```

May your builds be swift, your memory usage low, and your words flow like mead at a royal feast! 🍺

_~ Crafted with love, madness, and exactly 95MB of OS memory ~_
