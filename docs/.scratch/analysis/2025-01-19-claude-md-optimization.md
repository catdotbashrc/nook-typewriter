# CLAUDE.md Optimization Analysis
*Date: 2025-01-19*
*Status: DRAFT*

## Problem Statement
Current CLAUDE.md is 540 lines (~8000 tokens). Need to minimize tokens while maintaining:
- SuperClaude compatibility
- Project functionality  
- User customization safety

## Current Structure Analysis

| Section | Lines | Tokens | Essential? |
|---------|-------|--------|------------|
| SuperClaude header | 18 | ~300 | Yes (but reducible) |
| Quick reference | 13 | ~200 | Partially |
| Project content | 448 | ~7000 | No (can reference) |
| User zone | 37 | ~400 | Yes |
| Notes | 11 | ~100 | Yes |
| **TOTAL** | **540** | **~8000** | - |

## Proposed Optimal Structure

### Token-Minimal CLAUDE.md (~60 lines, ~900 tokens)

```markdown
# CLAUDE.md

<!--SUPERCLAUDE:START-->
SuperClaude enabled. Priority: USER > PROJECT > ~/.claude/
<!--SUPERCLAUDE:END-->

<!--PROJECT:START-->
## JesterOS for Nook SimpleTouch

### Critical Constraints
- **Hardware**: ARM Cortex-A8, 35MB RAM available, E-Ink display
- **Philosophy**: Writers > features, simplicity > complexity
- **Architecture**: Android → Linux chroot → JesterOS userspace

### Key Paths
- **Notes**: Write to `docs/.scratch/` by default
- **Docs**: Write to `docs/[category]/` only when explicitly requested
- **Services**: `/var/jesteros/` filesystem interface

### Safety Standards
```bash
set -euo pipefail  # All scripts
trap 'echo "Error at line $LINENO"' ERR
```

### Memory Budget
- Android Base: 188MB
- Available: 35MB total
- JesterOS: <10MB
- Vim: <8MB

### Reference
See `docs/PROJECT-REFERENCE.md` for:
- Build commands
- Testing procedures
- Development guidelines
- Architecture details
- Troubleshooting

<!--PROJECT:END-->

<!--USER:START-->
## User Customizations
<!-- Your rules override everything above -->




<!--USER:END-->
```

## Benefits of This Approach

### Token Reduction
- **Before**: 540 lines, ~8000 tokens
- **After**: 60 lines, ~900 tokens  
- **Savings**: 89% reduction

### Clean Separation
- SuperClaude zone: 2 lines (immutable)
- Project zone: 35 lines (project-maintained)
- User zone: Unlimited (user-controlled)

### Protection Mechanism
- HTML comments as zone markers
- Users unlikely to modify comment syntax
- SuperClaude can parse specific zones
- Each zone independently maintainable

## Migration Strategy

1. **Create PROJECT-REFERENCE.md**
   - Move all detailed content there
   - Preserve everything for reference
   - Organize by topic

2. **Update CLAUDE.md**
   - Replace with minimal version
   - Add clear zone markers
   - Include migration note

3. **Benefits**
   - 90% token reduction
   - Full backwards compatibility
   - Easy rollback if needed
   - Better maintainability

## Key Insights

1. **CLAUDE.md as Router**: Should point to information, not contain it all
2. **Zones as Contracts**: Clear boundaries prevent conflicts
3. **Comments as Guards**: HTML comments protect zone integrity
4. **References over Repetition**: Link to details rather than embed them

## Implementation Priority

| Action | Impact | Effort |
|--------|--------|--------|
| Create minimal CLAUDE.md | High | Low |
| Move details to PROJECT-REFERENCE.md | High | Medium |
| Test SuperClaude compatibility | Critical | Low |
| Document migration | Medium | Low |

## Conclusion

The optimal CLAUDE.md is a **60-line manifest file** that:
- Acknowledges SuperClaude (2 lines)
- Lists critical constraints (35 lines)
- Provides user customization space (unlimited)
- References detailed documentation

This achieves **90% token reduction** while maintaining **100% functionality** through intelligent referencing.