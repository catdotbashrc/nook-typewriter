# Writing Your First Document

Now that your Nook typewriter is running, let's learn how to write with it. This tutorial covers Vim basics and the special features for distraction-free writing.

## Starting Your First Writing Session

### Step 1: Open Vim

From the main menu, press **1** to launch Vim.

You'll see:
- A mostly blank screen (this is normal!)
- `~` symbols down the left side
- A status line at the bottom

### Step 2: Enter Insert Mode

Vim starts in "Normal" mode. To type, you need "Insert" mode:

1. Press `i` 
2. You'll see `-- INSERT --` at the bottom
3. Now you can type!

Try typing:
```
My first note on my Nook typewriter!

This is amazing - I'm writing on an e-reader.
```

### Step 3: Save Your Work

1. Press `Esc` to return to Normal mode
2. Type `:w mynote.txt` and press Enter
3. You'll see `"mynote.txt" [New] 2L, 67C written`

✅ Your first document is saved!

## Essential Vim Commands

### The Modes You Need

| Mode | Purpose | How to Enter | How to Exit |
|------|---------|--------------|-------------|
| Normal | Navigation & commands | `Esc` | Press `i`, `a`, or `o` |
| Insert | Typing text | `i`, `a`, or `o` | `Esc` |
| Command | Save, quit, settings | `:` | `Esc` or Enter |

### Must-Know Commands

```vim
" Moving around (Normal mode)
h, j, k, l    - Left, down, up, right
w             - Next word  
b             - Previous word
0             - Start of line
$             - End of line
gg            - Top of file
G             - Bottom of file

" Editing (Normal mode -> Insert)
i             - Insert before cursor
a             - Insert after cursor  
o             - New line below
O             - New line above
A             - Insert at end of line
I             - Insert at start of line

" File operations (Command mode)
:w            - Save
:q            - Quit
:wq           - Save and quit
:q!           - Quit without saving
:w filename   - Save as filename
```

## Using Writing Plugins

Your Nook comes with plugins designed for writers:

### Goyo - Distraction-Free Mode

1. In Normal mode, type `\g` (backslash then g)
2. Your text centers with margins
3. All UI elements hide
4. Type `\g` again to exit

This is perfect for focused writing sessions!

### Pencil - Better Text Handling

Pencil improves how Vim handles prose:

1. Type `\p` to toggle Pencil
2. Now text wraps naturally
3. Navigation works by display lines
4. Better for long paragraphs

### Quick Toggle Commands

| Command | Action |
|---------|--------|
| `\g` | Toggle Goyo (focus mode) |
| `\p` | Toggle Pencil (prose mode) |
| `\l` | Toggle line numbers |
| `\s` | Toggle spell check |

## Writing Workflow Example

Let's write a real document:

### 1. Start Fresh
```bash
# From menu, press 1 for Vim
# Then immediately:
:e journal.txt
```

### 2. Set Up Your Environment
```vim
\g    " Enable Goyo for focus
\p    " Enable Pencil for prose
\s    " Enable spell checking
```

### 3. Write Your Entry
```
i     " Enter insert mode

Thursday, November 16, 2023

Today I successfully set up my Nook as a typewriter. The e-ink 
display is surprisingly pleasant for writing. There's something 
meditative about the slow refresh rate - it prevents me from 
constantly editing and encourages forward momentum.

The keyboard feels responsive despite the limited hardware. I'm 
using a simple USB keyboard connected via OTG cable. Battery 
life should be excellent since the screen only updates when 
necessary.

[Press Esc when done]
```

### 4. Save and Continue
```vim
:w                " Quick save
o                 " New line and continue writing
```

## Managing Multiple Documents

### Creating a New Document
```vim
:w                " Save current
:e story.txt      " Edit new file
```

### Switching Between Files
```vim
:ls               " List open files
:b journal.txt    " Switch to journal
:bn               " Next buffer
:bp               " Previous buffer
```

### File Browser
From the main menu, press **2** to browse files:
- Use arrow keys to navigate
- Enter to open in Vim
- `q` to return to menu

## E-Ink Display Tips

### Understanding Refresh
- Text appears after a slight delay
- Full refresh (screen flash) happens periodically
- This is normal for e-ink!

### Optimizing for E-Ink
1. Type steadily - don't wait for each character
2. Use Goyo mode to reduce UI updates
3. Save frequently with `:w`
4. Avoid rapid scrolling

### Manual Refresh
If the screen gets "ghosty":
- Exit to menu (`:q`)
- The menu does a full refresh
- Re-open your file

## Daily Writing Tips

### Morning Pages Workflow
```vim
" Quick start for morning writing
:e ~/journal/$(date +%Y-%m-%d).txt
\g\p
i
```

### Project Organization
```
~/writing/
├── journal/
│   ├── 2023-11-16.txt
│   └── 2023-11-17.txt
├── stories/
│   ├── chapter1.txt
│   └── ideas.txt
└── notes/
    └── writing-tips.txt
```

### Quick Saves
- Map `Ctrl+S` for quick save (already configured)
- Auto-save every 5 minutes (enabled)
- Recovery files in case of power loss

## Practice Exercises

### Exercise 1: Basic Navigation
1. Open Vim and type a paragraph
2. Use `h`, `j`, `k`, `l` to move around
3. Jump words with `w` and `b`
4. Try `gg` and `G` for top/bottom

### Exercise 2: Editing Practice
1. Write three sentences
2. Add a word in the middle (position cursor, press `i`)
3. Add text at line end (press `A`)
4. Create a new paragraph (press `o`)

### Exercise 3: Focus Writing
1. Start a new file: `:e practice.txt`
2. Enable focus mode: `\g`
3. Write for 5 minutes without stopping
4. Save and exit: `:wq`

## Common Issues

### "Cannot save" Error
- You're in the wrong mode (press `Esc` first)
- No filename set (use `:w filename.txt`)
- Disk full (check with menu option 4)

### Lost in Vim?
1. Press `Esc` several times
2. Type `:q!` to exit without saving
3. Or `:wq` to save and exit

### Text Not Appearing
- E-ink delay is normal
- Keep typing, it will catch up
- For immediate refresh, press `Ctrl+L`

## Next Steps

Now you can write on your Nook! Continue with:

1. **[Setting Up Cloud Sync](03-syncing-to-cloud.md)** - Back up your writing
2. **[Customizing Vim](../how-to/customize-vim-plugins.md)** - Make it yours
3. **[Advanced Vim Tips](../reference/vim-commands.md)** - Power user guide

## Quick Reference

Print and keep handy:

```
VIM SURVIVAL COMMANDS
====================
i         - Start typing
Esc       - Stop typing
:w        - Save
:q        - Quit
:wq       - Save & quit
u         - Undo
Ctrl+R    - Redo

NOOK WRITING MODE
=================
\g        - Focus mode
\p        - Prose mode
\s        - Spell check
Ctrl+S    - Quick save
```

---

📝 **Remember**: The best way to learn Vim is to use it daily. Start with basic commands and gradually add more as needed.