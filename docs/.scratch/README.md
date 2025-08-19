# 📝 Scratch Notes Directory

> **⚠️ NOT FOR PRODUCTION DOCUMENTATION**  
> This directory contains work-in-progress notes, research, and drafts.  
> Contents here are excluded from official documentation.

## Purpose

This `.scratch/` directory is for:
- 🔬 Research notes and findings
- 📋 Todo lists and planning documents
- 🧪 Experimental documentation drafts
- 🐛 Debug logs and investigation notes
- 💭 Ideas and brainstorming
- 📊 Analysis reports that aren't ready for publication

## Organization

```
.scratch/
├── README.md           # This file
├── research/          # Investigation and research notes
├── drafts/           # Documentation drafts not ready for review
├── analysis/         # Deep-dive analysis and reports
├── todo/            # Task lists and planning
├── debug/           # Debug logs and troubleshooting notes
└── ideas/           # Feature ideas and brainstorming
```

## Guidelines

1. **Nothing here is official** - Don't reference these files in production docs
2. **Use descriptive names** - Include dates in filenames (e.g., `2025-01-18-android-layer-analysis.md`)
3. **Move when ready** - When content is ready, move it to the appropriate docs category
4. **Clean periodically** - Delete outdated scratch notes to avoid confusion

## Git Behavior

⚠️ **This entire directory is in .gitignore** - it exists only locally!

### Why This Works
- **Local files stay local** - Never accidentally commit WIP notes
- **Claude Code can access** - `.gitignore` only affects git, not file system
- **No cloud exposure** - Your private notes never leave your machine
- **Clean git history** - No cluttered commits with draft documents

### File Naming Patterns (also gitignored)
You can also use these patterns anywhere in the project:
- `*-NOTES.md` - Personal notes
- `*-TODO.md` - Task lists  
- `*.scratch.md` - Scratch work
- `*.wip.md` - Work in progress
- `*.local.md` - Local only
- `*-DRAFT.md` - Draft documents

Example: `android-investigation-NOTES.md` won't be committed

---

*"These are the scribblings in the margins, not the illuminated manuscript itself."* 🪶