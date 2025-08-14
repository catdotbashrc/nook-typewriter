# 📜 QuillOS Style Guide
## *The Definitive Visual & Technical Standards for the Digital Scriptorium*

### Version 1.0.0 | Copyright © 2025 Justin Yeary

---

## 🏰 Table of Contents

1. [Core Philosophy](#core-philosophy)
2. [Visual Language](#visual-language)
3. [ASCII Art Standards](#ascii-art-standards)
4. [Typography & Text](#typography--text)
5. [Interface Components](#interface-components)
6. [Color Palette (Grayscale)](#color-palette-grayscale)
7. [Iconography System](#iconography-system)
8. [Animation & Transitions](#animation--transitions)
9. [Writing Mode Aesthetics](#writing-mode-aesthetics)
10. [Code Style Standards](#code-style-standards)
11. [Documentation Standards](#documentation-standards)
12. [Brand Voice & Tone](#brand-voice--tone)

---

## 🎯 Core Philosophy

### The Three Pillars

```
┌────────────────────────────────────────────┐
│   SIMPLICITY · WHIMSY · FUNCTIONALITY     │
└────────────────────────────────────────────┘
```

1. **Simplicity**: Every pixel serves a purpose
2. **Whimsy**: Medieval charm in every interaction
3. **Functionality**: Writers write, nothing else matters

### Design Principles

- **E-Ink First**: Optimize for 16-level grayscale, 800x600 resolution
- **Memory Sacred**: Every byte counts, 160MB reserved for writing
- **Medieval Authentic**: Historical accuracy with digital practicality
- **Distraction Free**: No animations, notifications, or interruptions
- **Accessibility**: Clear contrast, readable fonts, logical navigation

---

## 🎨 Visual Language

### Screen Layout

```
╔═══════════════════════════════════════════════════════╗
║  QuillOS v1.0 · Folio XLII · Words: MMM              ║  <- Header
╠═══════════════════════════════════════════════════════╣
║                                                       ║
║                   [Content Area]                     ║  <- Main
║                                                       ║
╠═══════════════════════════════════════════════════════╣
║  ⚔ Menu  📜 Save  🪶 Write  📚 Library  ⚙ Settings  ║  <- Footer
╚═══════════════════════════════════════════════════════╝
```

### Border Hierarchy

```c
// Primary containers (system level)
╔═══════════════╗
║ Double Border ║
╚═══════════════╝

// Secondary containers (menus)
┌───────────────┐
│ Single Border │
└───────────────┘

// Tertiary elements (inputs)
+---------------+
| Simple Border |
+---------------+

// Decorative only
❦ ═══════════ ❦
```

### Spacing Standards

- **Line Height**: 1.5x character height
- **Margins**: 2 characters minimum
- **Padding**: 1 character internal
- **Paragraph Gap**: 1 blank line
- **Section Gap**: 2 blank lines

---

## 🖼️ ASCII Art Standards

### Character Usage

#### Preferred Characters (High E-Ink Contrast)
```
Primary:   # @ % & * = █ ▓ ▒ ░
Secondary: + - | / \ < > [ ] { }
Borders:   ═ ║ ╔ ╗ ╚ ╝ ┌ ┐ └ ┘
Decoration: ❦ ⚜ ✦ ◆ ♦ • ·
```

#### Avoided Characters (Poor E-Ink Rendering)
```
Avoid: . , ' " ` ~ _ (too light)
Never: Unicode beyond basic box drawing
```

### Jester Specifications

```
Standard Jester (10 lines max):
     .·:·.·:·.      <- Hat (alternating dots)
    /         \     <- Hat brim
   | {eyes}   |     <- Face with dynamic eyes
   |    >     |     <- Nose (always center)
   | {mouth}  |     <- Dynamic mouth
    \_______/       <- Chin
     |~|~|~|        <- Collar bells
    /|  ♦  |\       <- Tunic with gem
   d |     | b      <- Arms
     |__|__|        <- Feet

Eyes:  ^ ^ (happy)  - - (thinking)  > < (mischief)
Mouth: \_/ (smile)  --- (neutral)   /‾\ (frown)
```

### Logo Variations

```
Primary Mark:
    ╔═══╗
    ║ Q ║ uillOS
    ╚═══╝

Secondary Mark:
    🪶 QuillOS

Minimal Mark:
    [Q]OS
```

---

## 📝 Typography & Text

### Font Hierarchy

```c
// Banner text (FIGlet "small" font)
 ___        _ _ _ ___  ____
/ _ \ _   _(_) | / _ \/ ___|
| | | | | | | | | | | \___ \
| |_| | |_| | | | |_| |___) |
\__\_\\__,_|_|_|_|\___/|____/

// Headers (Box capitals)
╔══════════════╗
║ CHAPTER ONE  ║
╚══════════════╝

// Subheaders (Underlined)
Section Title
═════════════

// Body text (Standard 8x8)
Normal console font for reading

// Emphasis (Inverse or surrounded)
»Important«  or  [EMPHASIS]

// Code/Technical (Indented)
    function writingMode() {
        // Indented 4 spaces
    }
```

### Text Alignment

- **Headers**: Center aligned
- **Body**: Left aligned (ragged right)
- **Numbers**: Right aligned in tables
- **Menus**: Left aligned with spacing

### Medieval Flourishes

```
// Chapter beginnings
Chapter the First
Of Writing & Wonder

// Section breaks
        ❦ ❦ ❦

// Quote attribution
    "Wise words here"
        — Ye Olde Sage

// List markers
  ▸ Primary point
    ◦ Secondary point
      · Tertiary point
```

---

## 🎭 Interface Components

### Menu System

```
┌─────────────────────────┐
│ ▸ New Document         │  <- Selected (arrow)
│   Open Manuscript      │
│   Save Parchment       │
│ ──────────────────────  │  <- Separator
│   Settings & Sorcery   │
│   Quit to Castle       │
└─────────────────────────┘

Selection indicators: ▸ ▶ → ►
Disabled items: (surrounded by parens)
Shortcuts: [N]ew [O]pen [S]ave
```

### Progress Indicators

```
// Word count progress
[████████░░░░░░░] 523/1000 words

// Chapter progress
Chapter: [===>    ] 3 of 10

// Time-based progress
Writing Session: 45 minutes ⧗

// Achievement progress
Next Badge: [▓▓▓▓▓▓▒▒▒▒] 60%
```

### Input Fields

```
// Text input
Name: [________________]
      └─ Cursor position: █

// Password input  
Secret: [••••••••______]

// Numeric input
Words per day: [1000    ]↕

// Selection box
Mode: [×] Focused  [ ] Casual
```

### Notifications

```
// Success
╔════════════════════════╗
║ ✓ Document Saved!      ║
╚════════════════════════╝

// Warning
┌────────────────────────┐
│ ⚠ Low Battery (10%)    │
└────────────────────────┘

// Error
[!] Failed to save: Disk full

// Info
(i) Autosave in 5 minutes
```

---

## 🎨 Color Palette (Grayscale)

### E-Ink Grayscale Levels (16 levels)

```c
#define COL_WHITE       0x0F  // Background
#define COL_PARCHMENT   0x0E  // Main content bg
#define COL_LIGHT       0x0C  // Disabled text
#define COL_MEDIUM      0x08  // Secondary text
#define COL_DARK        0x04  // Primary text
#define COL_INK         0x02  // Emphasis
#define COL_BLACK       0x00  // Maximum contrast

// Usage mapping
Background:     COL_PARCHMENT
Text:           COL_DARK
Headers:        COL_BLACK
Borders:        COL_MEDIUM
Highlights:     COL_WHITE
Shadows:        COL_INK
```

### Dithering Patterns (for gradients)

```
Light to dark gradient:
░░░░▒▒▒▒▓▓▓▓████

Checkerboard (50% gray):
░▓░▓░▓░▓
▓░▓░▓░▓░

Vertical lines (25% gray):
│ │ │ │
```

---

## 🛡️ Iconography System

### Core System Icons (8x8 pixels)

```
Document:   Menu:      Settings:   Quill:
┌──────┐    ≡≡≡        ⚙           ╱
│······│    ───                   ╱
│······│    ≡≡≡                  ╱██
│······│    ───                 ╱██
└──────┘    ≡≡≡                ╲__/

Save:       Open:      Close:     Write:
💾 or [S]   📁 or [O]  ✕ or [X]  ✎ or [W]

ASCII fallbacks for all icons required!
```

### Status Indicators

```
// Connection status
Connected:    [●]
Disconnected: [○]
Syncing:      [◐]

// Battery (if applicable)
[████] 100%
[██__] 50%
[█___] 25%
[!__] Critical

// Writing mode
📝 Active
⏸  Paused
💤 Idle
```

### Medieval Decorations

```
// Corner ornaments
╔═❦═╗  ╔═♦═╗  ╔═✦═╗
║   ║  ║   ║  ║   ║

// Section dividers
═══❦═══  ···⚜···  ─ ◆ ─

// Bullet alternatives
▸ Primary level
⚔ Combat/action items
📜 Documents/files
🏰 System items
```

---

## 🎬 Animation & Transitions

### Permitted Animations

```c
// Jester mood transitions (2 frames max)
Frame 1: ^_^  Frame 2: -_-  (blink)

// Progress updates (instant)
[████░░░░] -> [█████░░░] (no animation)

// Menu selection (instant)
  Item 1     ▸ Item 1
▸ Item 2  ->   Item 2
  Item 3       Item 3
```

### E-Ink Refresh Strategy

- **Full refresh**: On major screen changes only
- **Partial refresh**: For text input and cursor
- **No refresh**: Static viewing (power save)
- **Ghost acceptance**: Allow slight ghosting for speed

---

## ✍️ Writing Mode Aesthetics

### Focused Writing Screen

```
════════════════════════════════════════════════
    Chapter XII: The Digital Quill

    Lorem ipsum dolor sit amet, consectetur
    adipiscing elit. The cursor blinks gently
    as words flow onto the digital parchment.█

    Words: 2,847 | Time: 32 min | WPM: 89
════════════════════════════════════════════════
```

### Writing Statistics Display

```
┌─────────────────────────────────┐
│ Today's Writing Statistics      │
├─────────────────────────────────┤
│ Words Written:     1,234        │
│ Time Active:       2h 15m       │
│ Best Streak:       523 words    │
│ Daily Goal:        [███░░] 62%  │
│                                 │
│ Lifetime:          45,678 words │
└─────────────────────────────────┘
```

### Achievement Notifications

```
        ⭐ Achievement Unlocked! ⭐
       ╔═══════════════════════╗
       ║   THOUSAND WORD SAGE  ║
       ║   "Thy quill flows     ║
       ║    with wisdom"        ║
       ╚═══════════════════════╝
```

---

## 💻 Code Style Standards

### C Code (Kernel Modules)

```c
/*
 * module_name.c - Brief description
 * 
 * Detailed description of module purpose
 * 
 * Copyright (C) 2025 Justin Yeary
 * Licensed under GPL v2
 */

// Constants in CAPS with prefix
#define QUILLOS_MAX_BUFFER 512
#define QUILLOS_VERSION "1.0.0"

// Functions: snake_case with module prefix
int quillos_init_module(void) {
    // 4-space indentation
    if (condition) {
        do_something();
    }
    return 0;
}

// Structures: typedef with _t suffix
typedef struct {
    char name[32];
    int value;
} quillos_data_t;
```

### Shell Scripts

```bash
#!/bin/sh
# script_name.sh - Brief description
# Copyright (C) 2025 Justin Yeary

set -euo pipefail  # Always use safe mode

# Constants in CAPS
readonly QUILLOS_VERSION="1.0.0"
readonly QUILLOS_PATH="/opt/quillos"

# Functions with quillos_ prefix
quillos_display_banner() {
    cat <<'EOF'
     QuillOS v1.0
    Ready to Write!
EOF
}

# Main execution
main() {
    quillos_display_banner
    # Main logic here
}

main "$@"
```

### ASCII Art Embedding

```c
// Embedded as static const char arrays
static const char QUILLOS_BANNER[] = 
    "  ___        _ _ _ ___  ____  \n"
    " / _ \\ _   _(_) | / _ \\/ ___| \n"
    "| | | | | | | | | | | \\___ \\ \n"
    "| |_| | |_| | | | |_| |___) |\n"
    " \\__\\_\\\\__,_|_|_|_|\\___/|____/ \n";

// Or as byte arrays for bitmaps
static const unsigned char QUILLOS_ICON[8] = {
    0x18, 0x3C, 0x7E, 0xFF, 0xFF, 0x7E, 0x3C, 0x18
};
```

---

## 📚 Documentation Standards

### File Headers

```markdown
# Component Name
## *Medieval-themed tagline*

**Version**: 1.0.0  
**Copyright**: © 2025 Justin Yeary  
**License**: GPL v2

---

### Purpose
Brief description of what this component does...
```

### Function Documentation

```c
/**
 * @brief Generate jester ASCII art
 * @param mood The jester's current mood
 * @param buffer Output buffer for ASCII art
 * @param size Size of output buffer
 * @return 0 on success, -1 on error
 * @note Memory usage: <512 bytes stack
 * @medieval "Summons forth the digital jester"
 */
int generate_jester(enum mood mood, char *buffer, size_t size);
```

### Medieval Comments

```c
// Hark! This function doth process the user's input
// with great care and validation most thorough

/* 
 * Here begins the sacred writing loop,
 * where words transform into digital ink
 */

// TODO: Implement ye olde spell checker
// FIXME: The jester's mood calculation needeth work
// NOTE: This consumeth but 10KB of precious RAM
```

---

## 🎭 Brand Voice & Tone

### Writing Principles

1. **Clarity First**: Technical accuracy with charm
2. **Medieval Flair**: Subtle, not overwhelming
3. **Respectful**: Honor the writer's craft
4. **Encouraging**: Positive, supportive messages
5. **Concise**: Every word earns its place

### Voice Examples

#### System Messages
```
Good:
"Thy document has been saved successfully!"
"Welcome back, noble scribe."
"500 words! Thy quill flows well today."

Avoid:
"File saved." (too plain)
"Huzzah! Forsooth! Thy parchment!" (too much)
"ERROR: WRITE_FAIL" (too technical)
```

#### Error Messages
```
Good:
"Alas! The parchment could not be saved."
"The scroll appears to be missing."
"Thy writing space is full (98% used)."

Avoid:
"Error 0x2847" (meaningless to writers)
"Segmentation fault" (too technical)
"Catastrophic failure!" (too dramatic)
```

#### Achievements
```
Good:
"Wordsmith: 10,000 words written!"
"Dawn Writer: Started before sunrise"
"Consistent Scribe: 7 days straight"

Avoid:
"ACHIEVEMENT_001" (no personality)
"You wrote stuff" (too casual)
"Thou hast achieved greatness!" (too grandiose)
```

### Medieval Vocabulary Guide

#### Use Sparingly
- Thy/Thine (your)
- Hath (has)
- Doth (does)
- 'Tis (it is)

#### Modern Preferred
- You/Your (clearer)
- Has/Have
- Does/Do
- It's/It is

#### Always Appropriate
- Scribe (writer)
- Manuscript (document)
- Parchment (file)
- Quill (cursor/writing)
- Scroll (list/document)

---

## 🏁 Implementation Checklist

### Phase 1: Foundation
- [ ] Implement border system
- [ ] Create jester base art
- [ ] Define grayscale palette
- [ ] Establish text hierarchy

### Phase 2: Components
- [ ] Design menu system
- [ ] Create progress indicators
- [ ] Build notification system
- [ ] Implement input fields

### Phase 3: Polish
- [ ] Add achievement badges
- [ ] Create seasonal themes
- [ ] Implement boot sequence
- [ ] Add easter eggs

### Phase 4: Documentation
- [ ] Document all components
- [ ] Create examples library
- [ ] Build asset pipeline
- [ ] Write contributor guide

---

## 📜 Appendices

### A. Quick Reference Card
```
Borders:  ═║╔╗╚╝  ─│┌┐└┘  +|-
Arrows:   ← → ↑ ↓  ◄ ► ▲ ▼  < > ^ v
Bullets:  • ◦ ▸ ▹  □ ■ ▪ ▫
Symbols:  ♦ ❦ ⚜ ✦  § ¶ † ‡
```

### B. ASCII Art Templates
Available in `/source/configs/ascii/templates/`

### C. Color Testing
Use `/proc/squireos/art/grayscale_test` to verify rendering

---

*"Consistency in design is like rhythm in writing - it carries the reader forward"*

**End of QuillOS Style Guide v1.0.0**

*By quill and code, we craft beauty* 🪶