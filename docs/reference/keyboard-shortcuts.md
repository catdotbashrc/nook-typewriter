# Keyboard Shortcuts Reference

Complete keyboard reference for the Nook typewriter system.

## System Navigation

### Main Menu
| Key | Action |
|-----|--------|
| `1` | Open Vim editor |
| `2` | File browser |
| `3` | Sync to cloud |
| `4` | System information |
| `5` | WiFi setup |
| `6` | Settings menu |
| `7` | Terminal access |
| `8` | Power off |
| `q` | Quit/back (context dependent) |

### File Browser
| Key | Action |
|-----|--------|
| `↑`/`k` | Move up |
| `↓`/`j` | Move down |
| `Enter` | Open file/directory |
| `q` | Return to menu |
| `/` | Search |
| `n` | Next search result |

## Vim Editor Shortcuts

### Mode Switching
| Key | From → To | Description |
|-----|-----------|-------------|
| `i` | Normal → Insert | Insert before cursor |
| `a` | Normal → Insert | Insert after cursor |
| `o` | Normal → Insert | New line below |
| `O` | Normal → Insert | New line above |
| `Esc` | Any → Normal | Return to normal mode |
| `:` | Normal → Command | Enter command mode |
| `v` | Normal → Visual | Visual selection mode |

### Navigation (Normal Mode)
| Key | Movement |
|-----|----------|
| `h` | Left one character |
| `j` | Down one line |
| `k` | Up one line |
| `l` | Right one character |
| `w` | Next word start |
| `b` | Previous word start |
| `e` | End of word |
| `0` | Start of line |
| `$` | End of line |
| `gg` | Top of file |
| `G` | Bottom of file |
| `{` | Previous paragraph |
| `}` | Next paragraph |
| `Ctrl+F` | Page down |
| `Ctrl+B` | Page up |

### Editing (Normal Mode)
| Key | Action |
|-----|--------|
| `x` | Delete character |
| `dd` | Delete line |
| `yy` | Copy line |
| `p` | Paste after |
| `P` | Paste before |
| `u` | Undo |
| `Ctrl+R` | Redo |
| `.` | Repeat last command |
| `cc` | Change entire line |
| `cw` | Change word |
| `dw` | Delete word |

### File Operations
| Command | Action |
|---------|--------|
| `:w` | Save file |
| `:w filename` | Save as filename |
| `:q` | Quit (if saved) |
| `:q!` | Quit without saving |
| `:wq` or `:x` | Save and quit |
| `:e filename` | Open file |
| `:bn` | Next buffer |
| `:bp` | Previous buffer |
| `:ls` | List buffers |

### Search and Replace
| Command | Action |
|---------|--------|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` | Next match |
| `N` | Previous match |
| `:%s/old/new/g` | Replace all |
| `:%s/old/new/gc` | Replace with confirm |
| `*` | Search word under cursor |

## Writing Plugin Commands

### Leader Key Shortcuts
The leader key is `\` (backslash).

| Shortcut | Plugin | Action |
|----------|--------|--------|
| `\g` | Goyo | Toggle distraction-free mode |
| `\p` | Pencil | Toggle prose mode |
| `\s` | Built-in | Toggle spell check |
| `\l` | Built-in | Toggle line numbers |
| `\w` | Built-in | Strip trailing whitespace |
| `\z` | Zettel | Create new note |
| `\f` | Built-in | Format paragraph |

### Quick Save
| Key | Action |
|-----|--------|
| `Ctrl+S` | Quick save (custom mapping) |
| `Ctrl+Q` | Save and quit (custom) |

## Terminal Commands

### System Information
| Command | Shows |
|---------|-------|
| `free -h` | Memory usage |
| `df -h` | Disk space |
| `top` | Running processes |
| `ps aux` | All processes |
| `uname -a` | System info |

### File Management
| Command | Action |
|---------|--------|
| `ls -la` | List files (detailed) |
| `cd directory` | Change directory |
| `mkdir name` | Create directory |
| `rm file` | Delete file |
| `cp src dst` | Copy file |
| `mv old new` | Move/rename |

### Network Commands
| Command | Purpose |
|---------|---------|
| `ip addr` | Show IP address |
| `ping -c 4 google.com` | Test internet |
| `nmcli dev wifi` | List WiFi networks |

### Display Control
| Command | Effect |
|---------|--------|
| `fbink -c` | Clear screen (full refresh) |
| `fbink -y 10 "text"` | Print text at line 10 |
| `fbink -g file.png` | Display image |

## Special Key Combinations

### E-Ink Refresh
| Keys | Action |
|------|--------|
| `Ctrl+L` | Redraw screen (in Vim) |
| Menu exit/enter | Automatic full refresh |

### Emergency Recovery
| Keys | When | Action |
|------|------|--------|
| `Ctrl+C` | Any time | Interrupt command |
| `Ctrl+Z` | In program | Suspend to background |
| `Ctrl+Alt+F2` | System hang | Switch to TTY2 |

## Printable Quick Reference Card

Cut out and keep handy:

```
╔═══════════════════════════════════════╗
║         NOOK TYPEWRITER KEYS          ║
╠═══════════════════════════════════════╣
║ MENU           │ VIM BASICS           ║
║ 1: Vim         │ i: Insert text       ║
║ 2: Files       │ Esc: Normal mode     ║
║ 3: Sync        │ :w - Save            ║
║ 4: Info        │ :q - Quit            ║
║ 8: Power       │ :wq - Save & quit    ║
║                │                      ║
║ WRITING        │ QUICK KEYS           ║
║ \g: Focus mode │ Ctrl+S: Quick save   ║
║ \p: Prose mode │ u: Undo              ║
║ \s: Spelling   │ /text: Search        ║
╚═══════════════════════════════════════╝
```

## Customizing Shortcuts

### Adding Vim Mappings

Edit `~/.vimrc`:
```vim
" Map F5 to save
nnoremap <F5> :w<CR>

" Map F6 to spell check toggle
nnoremap <F6> :set spell!<CR>
```

### Adding Menu Options

Edit `/opt/nook/scripts/nook-menu.sh`:
```bash
"9")
    echo "My custom option"
    my_custom_command
    ;;
```

---

⌨️ **Tip**: Start with basic navigation (hjkl) and file operations (:w :q). Add more shortcuts as you become comfortable.