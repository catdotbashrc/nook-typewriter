# How to Customize Vim Plugins

Tailor your writing environment by adding, removing, or configuring Vim plugins.

## Current Plugin Setup

Your Nook comes with these writing-focused plugins:

| Plugin | Purpose | Commands |
|--------|---------|----------|
| **Goyo** | Distraction-free mode | `\g` to toggle |
| **Pencil** | Prose improvements | `\p` to toggle |
| **Lightline** | Status bar | Always active |
| **vim-zettel** | Note management | `\z` for new note |

## Adding New Plugins

### Method 1: Docker Build (Permanent)

Edit `nookwriter.dockerfile`:

```dockerfile
# Add after existing plugin installations
RUN git clone https://github.com/user/plugin-name \
    /root/.vim/pack/plugins/start/plugin-name
```

Rebuild:
```bash
docker build -t nook-system -f nookwriter.dockerfile .
```

### Method 2: On Device (Temporary)

SSH into your Nook:
```bash
cd ~/.vim/pack/plugins/start/
git clone https://github.com/user/plugin-name
```

Note: This won't survive system reinstalls.

## Recommended Writing Plugins

### vim-table-mode
Easy table creation:
```vim
" Add to Dockerfile
RUN git clone https://github.com/dhruvasagar/vim-table-mode \
    /root/.vim/pack/plugins/start/vim-table-mode
```

Usage: `\tm` to enable, then `|` creates tables.

### vim-pandoc
Academic writing with citations:
```vim
" Heavier plugin, check memory first
RUN git clone https://github.com/vim-pandoc/vim-pandoc \
    /root/.vim/pack/plugins/start/vim-pandoc
```

### limelight.vim
Highlight current paragraph:
```vim
RUN git clone https://github.com/junegunn/limelight.vim \
    /root/.vim/pack/plugins/start/limelight.vim
```

Works great with Goyo!

## Removing Plugins

### Temporary Removal
```bash
cd ~/.vim/pack/plugins/start/
mv plugin-name plugin-name.disabled
```

### Permanent Removal
Remove from Dockerfile and rebuild.

## Configuring Plugins

### Edit vimrc

The main config is at `/root/.vimrc`:

```vim
" Example: Configure Pencil
let g:pencil#wrapModeDefault = 'soft'
let g:pencil#autoformat = 0
let g:pencil#conceallevel = 0

" Example: Configure Goyo
let g:goyo_width = 80
let g:goyo_height = '90%'
let g:goyo_linenr = 1
```

### Plugin-Specific Settings

#### Goyo Customization
```vim
" Wider margins
let g:goyo_width = 100

" Auto-enable Pencil with Goyo
autocmd! User GoyoEnter nested call pencil#init()
autocmd! User GoyoLeave nested call pencil#init()
```

#### Lightline Themes
```vim
" Change status bar theme
let g:lightline = {
    \ 'colorscheme': 'seoul256',
    \ }
```

Available themes: `wombat`, `solarized`, `jellybeans`, `seoul256`

#### Zettel Configuration
```vim
" Change note directory
let g:zettel_dir = "~/notes"

" Custom note naming
let g:zettel_format = "%Y%m%d-%H%M"
```

## Memory Considerations

Check plugin memory usage:
```bash
# Before installing
free -m

# After installing
free -m

# In Vim
:echo 'Memory used: ' . (system('ps aux | grep vim | awk "{print $6}"') / 1024) . 'MB'
```

Lightweight plugins (<1MB):
- vim-surround
- vim-commentary  
- vim-repeat

Heavy plugins (>5MB):
- YouCompleteMe
- vim-pandoc
- ale (linting)

## Creating Custom Plugins

### Simple Word Count Plugin

Create `~/.vim/plugin/wordcount.vim`:
```vim
function! WordCount()
    let s:old_status = v:statusmsg
    let position = getpos(".")
    exe ":silent normal g\<C-g>"
    let stat = v:statusmsg
    let s:word_count = 0
    if stat != '--No lines in buffer--'
        let s:word_count = str2nr(split(v:statusmsg)[11])
    end
    let v:statusmsg = s:old_status
    call setpos('.', position)
    return s:word_count
endfunction

" Show in status line
set statusline+=\ Words:%{WordCount()}
```

### E-Ink Refresh Command

Create `~/.vim/plugin/eink.vim`:
```vim
" Force E-Ink refresh
command! Refresh :silent !fbink -c

" Map to F5
nnoremap <F5> :Refresh<CR>
```

## Best Practices

### Do's
- Test plugins in Docker first
- Check memory impact
- Read plugin documentation
- Keep backups of working configs

### Don'ts
- Don't install IDE-like plugins
- Avoid plugins needing compilation
- Skip plugins with heavy dependencies
- Don't use bleeding-edge versions

## Troubleshooting

### Plugin Not Loading
```vim
:scriptnames  " List loaded scripts
:echo &runtimepath  " Check paths
```

### Conflicts Between Plugins
1. Disable plugins one by one
2. Check `:messages` for errors
3. Look for mapping conflicts

### Performance Issues
```vim
:profile start profile.log
:profile func *
" Do slow operation
:profile pause
:q
```

Check `profile.log` for bottlenecks.

## Plugin Recommendations by Use Case

### Fiction Writing
- Goyo + Limelight (focus)
- vim-pencil (prose)
- vim-wordy (style check)

### Academic Writing  
- vim-pandoc (citations)
- vim-table-mode (data)
- unicode.vim (symbols)

### Note Taking
- vim-zettel (current)
- vimwiki (alternative)
- vim-journal (daily entries)

### Minimal Setup
Just Goyo + Pencil for maximum simplicity and speed.

---

🔌 **Remember**: The best plugin is the one you'll actually use. Start minimal and add only what enhances your writing.