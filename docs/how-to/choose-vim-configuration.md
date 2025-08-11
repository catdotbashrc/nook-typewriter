# How to Choose Your Vim Configuration

This guide helps you select the right Vim setup for your Nook typewriter based on your needs and preferences.

## Available Configurations

### Writer Mode (Recommended)
**File**: `config/vimrc-writer`  
**RAM Usage**: 1.5MB  
**Docker Build**: `nookwriter-optimized.dockerfile` with `BUILD_MODE=writer`

#### Features
- **Goyo.vim**: Distraction-free writing mode (F5 to toggle)
- **Vim-pencil**: Soft line wrapping for prose
- **Litecorrect**: Auto-correct common typos
- **E-Ink optimized** color scheme
- **F-key shortcuts** for all functions
- **Word count** in status line
- **Auto-save** every 3 minutes
- **Writing analysis** commands built-in

#### Best For
- Writers who want a polished experience
- Users who value distraction-free mode
- Those who make frequent typos
- Anyone writing long-form content

### Minimal Mode
**File**: `config/vimrc-minimal`  
**RAM Usage**: 1.4MB  
**Docker Build**: `nookwriter-optimized.dockerfile` with `BUILD_MODE=minimal`

#### Features
- **No plugins** - pure Vim only
- **Maximum RAM** for documents (254MB available)
- **F-key shortcuts** for all functions
- **Built-in spell check**
- **Word count** function
- **Writing analysis** commands
- **Fastest possible** response

#### Best For
- Minimalists who want zero overhead
- Users comfortable with basic Vim
- Those who prioritize maximum writing space
- Anyone experiencing performance issues

### Standard Mode (Legacy)
**File**: `config/vimrc`  
**RAM Usage**: 15MB  
**Docker Build**: `nookwriter.dockerfile`

#### Features
- Original configuration with all plugins
- Includes vim-zettel and lightline
- More features but heavier

#### Best For
- Users upgrading from older versions
- Those who need vim-zettel integration
- Testing and development

## Quick Decision Guide

Choose **Writer Mode** if you want:
- ✅ Best writing experience
- ✅ Distraction-free mode (Goyo)
- ✅ Better text handling (Pencil)
- ✅ Auto-corrections
- ✅ Only 0.1MB more RAM than minimal

Choose **Minimal Mode** if you want:
- ✅ Absolute minimum RAM usage
- ✅ No dependencies
- ✅ Fastest possible startup
- ✅ Complete control

## Building Your Choice

### For Writer Mode (Recommended):
```bash
docker build -t nook-writer \
  --build-arg BUILD_MODE=writer \
  -f nookwriter-optimized.dockerfile .

docker create --name nook-export nook-writer
docker export nook-export | gzip > nook-writer.tar.gz
docker rm nook-export
```

### For Minimal Mode:
```bash
docker build -t nook-minimal \
  --build-arg BUILD_MODE=minimal \
  -f nookwriter-optimized.dockerfile .

docker create --name nook-export nook-minimal
docker export nook-export | gzip > nook-minimal.tar.gz
docker rm nook-export
```

## Key Mappings Comparison

| Function | Writer Mode | Minimal Mode |
|----------|------------|--------------|
| New note | F2 | F2 |
| Save | F3 or Ctrl+S | F3 or Ctrl+S |
| Quit | F4 or Ctrl+Q | F4 or Ctrl+Q |
| Focus mode | F5 (Goyo) | N/A |
| Word count | F6 | F6 |
| Spell check | F7 | F5 |
| Pencil toggle | F8 | N/A |

## Testing Before Deployment

Test your choice in Docker:

```bash
# Test Writer Mode
docker run -it --rm nook-writer vim /tmp/test.txt

# Test Minimal Mode
docker run -it --rm nook-minimal vim /tmp/test.txt
```

Check RAM usage:
```bash
docker stats --no-stream nook-writer
docker stats --no-stream nook-minimal
```

## Switching Configurations

You can switch between configurations by:

1. **Rebuilding** with different BUILD_MODE
2. **Manually copying** vimrc files:
   ```bash
   # Inside container or on Nook
   cp /root/config/vimrc-writer /root/.vimrc  # Switch to writer
   cp /root/config/vimrc-minimal /root/.vimrc # Switch to minimal
   ```

## E-Ink Considerations

Both configurations include:
- **Monochrome color scheme** (eink.vim)
- **No syntax highlighting** (saves RAM, better for E-Ink)
- **Lazy redraw** (reduces E-Ink flashing)
- **High contrast** settings
- **No animations** or gradual changes

## Performance Impact

| Configuration | Boot Time | Vim Startup | File Open | RAM Free |
|--------------|-----------|-------------|-----------|----------|
| Writer Mode | ~20 sec | <1 sec | Instant | 254 MB |
| Minimal Mode | ~20 sec | <0.5 sec | Instant | 254 MB |
| Standard | ~25 sec | 2-3 sec | 1 sec | 241 MB |

## Recommendation

**Start with Writer Mode.** The 0.1MB difference is negligible, but the experience is significantly better. Goyo alone makes writing more enjoyable on E-Ink, and Pencil handles prose much better than vanilla Vim.

Only choose Minimal if you:
- Have specific performance issues
- Prefer absolute simplicity
- Want to customize everything yourself

## Customization

Both configurations are starting points. Feel free to:
- Add your own mappings
- Adjust settings
- Remove features you don't use

The configurations live in `/root/.vimrc` on the Nook and can be edited directly.