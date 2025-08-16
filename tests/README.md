# 🧪 Nook Typewriter Tests - Keep It Simple!

## Philosophy
**This is a hobby project!** We only care about:
1. ✅ Don't brick the device
2. ✅ It boots
3. ✅ Basic stuff works

*Perfect is the enemy of good. If it boots without bricking, ship it!*

## The Tests (All 3 of them!)

### 🛡️ `01-safety-check.sh`
**MUST PASS** - Checks that you won't brick your Nook
- Kernel exists
- No dangerous /dev/sda references  
- Build system ready

### 🥾 `02-boot-test.sh`
**SHOULD PASS** - Checks if it will boot
- Boot scripts exist
- Menu system present
- Basic services ready

### ✨ `03-functionality.sh`
**NICE TO HAVE** - Fun features
- ASCII art jesters
- Service scripts
- Vim config

## How to Test

```bash
# Run all tests (takes 5 seconds)
./run-tests.sh

# Or run individually
./01-safety-check.sh  # Must pass!
./02-boot-test.sh     # Should pass
./03-functionality.sh # Whatever...
```

## Test Results

- **All Pass**: Ship it! 🚀
- **Safety Fails**: DO NOT DEPLOY! Fix immediately!
- **Boot Fails**: Probably won't boot, fix it
- **Functionality Fails**: Meh, you'll miss some features

## Before Hardware Deploy

Check `DEPLOY_CHECKLIST.txt` - it's literally a checklist!

## Directory Structure

```
tests/
├── README.md              # You are here
├── DEPLOY_CHECKLIST.txt   # Pre-flight checklist
├── run-tests.sh           # Run all tests
├── 01-safety-check.sh     # Critical safety
├── 02-boot-test.sh        # Boot validation  
├── 03-functionality.sh    # Fun features
└── archive/               # Old complex tests (ignore these)
    ├── [50+ overcomplicated test files]
    └── unit/              # Even more tests we don't need
```

## FAQ

**Q: Why so few tests?**
A: It's a hobby project! We're making a typewriter, not a spacecraft.

**Q: What about code coverage?**
A: If it boots and types, coverage is 100% of what matters.

**Q: Should I run the archived tests?**
A: No! They're overcomplicated. Stick to the 3 simple ones.

**Q: What if only functionality fails?**
A: Deploy anyway! You'll just miss ASCII jesters.

**Q: How often should I test?**
A: Before putting on hardware. That's it.

## The Only Commands You Need

```bash
# Before deploying to Nook
make test          # Runs ./run-tests.sh

# Full build and deploy
make clean         # Start fresh
make firmware      # Build everything  
make test          # Run tests
make sd-deploy     # Deploy to SD card
```

## If Tests Fail

1. **Safety fails**: Fix it or risk bricking
2. **Boot fails**: Fix it or it won't boot
3. **Functionality fails**: Ignore it, ship anyway

---

*Remember: This is supposed to be fun! Don't overthink it.* 🎭