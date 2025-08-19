# CLAUDE.md

<!--SUPERCLAUDE:START-->
SuperClaude enabled. Priority: USER > PROJECT > ~/.claude/
<!--SUPERCLAUDE:END-->

<!--PROJECT:START-->
## JesterOS for Nook SimpleTouch

### Critical Constraints
- **Hardware**: ARM Cortex-A8 (800MHz), 233MB RAM (35MB available), 6" E-Ink Pearl
- **Philosophy**: Writers > features, RAM saved = words written
- **Architecture**: U-Boot → Android → Linux chroot → JesterOS userspace → Vim

### Documentation Rules
- **DEFAULT**: Write to `docs/.scratch/` for all notes, research, WIP
- **EXPLICIT REQUEST ONLY**: Write to `docs/[category]/` for official docs

### Key Paths & Interfaces
```yaml
Services: /var/jesteros/{jester,typewriter/stats,wisdom}
Scratch: docs/.scratch/{analysis,research,debug,todo,drafts}
Writing: /root/{manuscripts,notes,drafts,scrolls}
```

### Safety Standards (MANDATORY)
```bash
set -euo pipefail                    # All shell scripts
trap 'echo "Error at line $LINENO"' ERR
```

### Memory Budget (CRITICAL)
```
Android Base:  188MB (measured from device)
JesterOS:       10MB (ABSOLUTE MAXIMUM)
Vim:             8MB (minimal config)
Available:      27MB (for actual writing)
```

### Development Constraints
- EXCLUDE `source/kernel/src/` from analysis (vanilla Linux 2.6.29)
- PREFER updating existing files over creating new ones
- NEVER exceed 96MB OS usage
- NO network features, compilers, or media players

### Quick Commands
```bash
make firmware        # Build complete system
make lenny-rootfs   # Build rootfs with vim
make test           # Run safety tests
```

### Full Reference
See `docs/PROJECT-REFERENCE.md` for complete:
- Build procedures & Docker commands
- Testing philosophy & procedures  
- Architecture details & boot sequence
- Troubleshooting & common issues
- Contributing guidelines

<!--PROJECT:END-->

<!--USER:START-->
## User Customizations
<!-- Add your personal rules below. They override everything above. -->




<!--USER:END-->