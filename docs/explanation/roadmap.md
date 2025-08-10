# Project Roadmap

Future improvements and feature ideas for the Nook typewriter system, organized by feasibility and impact.

## Current Status

The Nook typewriter is fully functional with:
- ✅ Debian Linux base system
- ✅ Vim with writing plugins
- ✅ USB keyboard support
- ✅ Cloud sync capability
- ✅ E-Ink optimized display
- ✅ Comprehensive documentation

## Short Term (High Impact, Low Effort)

### Writing Tools
- **Spell checking**: Add `aspell` integration (1-2MB)
  - Command: `apt install aspell aspell-en`
  - Vim integration already configured
  
- **Word count**: Better statistics
  - Use built-in `wc` command
  - Add to menu system
  
- **Text formatting**: Add `par` for paragraph formatting
  - Clean paragraph reflow
  - Useful for long-form writing

### Power Optimization
- **Auto-suspend**: After 30 minutes idle
- **WiFi toggle**: Manual on/off to save battery
- **CPU governor tuning**: Lock to lowest speed when idle

## Medium Term (Moderate Effort)

### Enhanced Note Management

**Option 1: zk CLI Tool**
- Pros: Full Zettelkasten features, linking, tags
- Cons: 20MB footprint, may be overkill
- Alternative: Enhance vim-zettel configuration

**Option 2: Custom Scripts**
- Lightweight note linking
- Simple tagging system
- Fast search with `grep`/`rg`

### Sync Improvements
- **Conflict resolution**: Handle concurrent edits
- **Offline queue**: Sync when WiFi returns
- **Multiple services**: Add OneDrive, iCloud
- **Selective sync**: Choose folders to sync

### Display Optimizations
- **Custom fonts**: Optimized for E-Ink
- **Refresh modes**: User-selectable strategies
- **Reading mode**: Different settings for review

## Long Term (Significant Development)

### Alternative Interfaces

**Micro Editor Option**
```dockerfile
# Lighter than Vim (2MB vs 10MB)
RUN apt install micro
```
Benefits: Easier for beginners, modern keybindings

**Custom TUI**
- Purpose-built for E-Ink
- Minimal refresh design
- Writing-focused features only

### Hardware Support

**Nook GlowLight Support**
- Test compatibility
- Adjust for backlight control
- Power management differences

**Other E-Readers**
- Kobo Clara HD (similar specs)
- Older Kindle models (if jailbroken)
- Generic E-Ink tablets

### Advanced Features

**Local AI Integration**
- Grammar checking
- Style suggestions
- Requires significant RAM

**Version Control**
- Git integration for documents
- Visual diff for E-Ink
- Commit from menu

## Community Wishlist

Based on user feedback:

1. **Session Management**
   - Save/restore writing sessions
   - Multiple project support
   - Window layouts

2. **Export Options**
   - PDF generation
   - EPUB creation
   - Markdown to various formats

3. **Reading Features**
   - EPUB reader integration
   - PDF viewing (challenging on E-Ink)
   - RSS feed reader

## Won't Implement

These conflict with project goals:

- ❌ **Web browser** - Poor E-Ink experience
- ❌ **Email client** - Scope creep
- ❌ **Complex IDEs** - Not a coding device
- ❌ **Games** - Distraction from writing
- ❌ **Media players** - No speakers/video

## Contributing Ideas

Want to add features? Consider:

1. **Memory impact** - We have ~150MB free
2. **E-Ink compatibility** - Fast refresh needed?
3. **Battery usage** - Will it drain power?
4. **Complexity** - Can writers configure it?
5. **Philosophy fit** - Does it help writing?

## Implementation Priority Matrix

```
High Impact ↑
            │ Spell Check    zk Integration
            │ Word Count     
            │                Conflict Sync
            │ Power Opts     
Low Impact  │                              Custom TUI
            └────────────────────────────→
             Easy                    Hard
```

## Getting Involved

To implement features:

1. Fork the repository
2. Test in Docker first
3. Measure memory impact
4. Document thoroughly
5. Submit pull request

Priority goes to:
- Memory-efficient solutions
- E-Ink optimized features
- Writing-focused tools
- Well-documented code

---

💡 **Philosophy**: Every feature should make writing easier, not add complexity. When in doubt, choose simplicity.