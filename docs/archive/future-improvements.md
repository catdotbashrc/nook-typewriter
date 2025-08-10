# Future Improvements

This document tracks potential enhancements and features to consider for the Nook Writing System project. These are not immediate priorities but ideas worth exploring when the core system is stable.

## Note-Taking Enhancements

### zk CLI Tool Integration
**Description**: Consider integrating the zk command-line Zettelkasten tool for more sophisticated note management.

**Pros**:
- Single static Go binary (~15-25MB)
- Provides note linking, tags, full-text search, and graph generation
- Can use vim as its editor
- Better structured note organization than timestamp-based files

**Cons**:
- Additional ~20MB storage/memory footprint
- E-ink screen refresh concerns with interactive commands
- May conflict with the minimalist "typewriter" philosophy
- Current vim-zettel plugin already provides basic features

**Alternative**: Enhance existing vim-zettel configuration to add note linking (`[[note-id]]` syntax) while maintaining lightweight footprint.

## Hardware Optimizations

### Kernel Improvements
- Investigate further memory optimizations by disabling unused kernel modules
- Explore custom kernel builds specifically for writing use case

### Power Management
- Implement aggressive power saving modes when not actively typing
- Auto-suspend after periods of inactivity

## Software Features

### Writing Tools
- `aspell` integration for spell checking (1-2MB)
- `wc` for word count statistics
- `par` for paragraph formatting

### Sync Improvements
- Bidirectional sync support
- Conflict resolution for notes edited on multiple devices
- Offline queue for syncs when WiFi unavailable

## User Experience

### E-Ink Optimizations
- Custom FBInk settings for different writing modes
- Partial refresh strategies to reduce screen flashing
- Font optimization for E-Ink readability

### Workflow Enhancements
- Session recovery after unexpected shutdown
- Auto-save functionality
- Writing statistics dashboard

## Documentation

### Video Tutorials
- Screen recordings of common workflows
- Hardware setup walkthroughs
- Troubleshooting guides

### Community Resources
- Template repository for custom configurations
- Plugin compatibility list
- User-contributed scripts and tools