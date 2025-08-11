# Writing Analysis Tools Reference

Shell-based writing analysis tools that use zero additional RAM - perfect for the Nook's limited resources.

## writing-check.sh

A lightweight prose analysis tool that runs entirely in shell, requiring no additional memory beyond the shell itself.

### Location
`/usr/local/bin/writing-check.sh`

### Usage
```bash
writing-check [OPTION] FILE

Options:
  -w, --weasel     Find weasel words (vague language)
  -p, --passive    Find passive voice
  -d, --dups       Find duplicate words
  -r, --repeat     Find repeated words in paragraphs
  -a, --all        Run all checks
  -h, --help       Show help
```

### Examples

Check for weasel words:
```bash
writing-check -w chapter1.txt
```

Run all checks:
```bash
writing-check --all draft.md
```

### What It Detects

#### Weasel Words
Vague qualifiers that weaken writing:
- many, various, very, fairly, several
- extremely, quite, remarkably, few
- surprisingly, mostly, largely, huge, tiny
- clearly, relatively, completely, really, just
- perhaps, maybe, somewhat, somehow, almost

#### Passive Voice
Detects constructions like:
- "was told", "were given", "been shown"
- "is being made", "are being sent"
- Any be-verb followed by past participle

#### Duplicate Words
Finds adjacent repeated words:
- "the the", "and and", "of of"
- Common copy-paste errors

#### Overused Words
Identifies words repeated 3+ times in a paragraph, helping you vary vocabulary.

### Document Statistics
Automatically shows:
- Total word count
- Line count
- Character count
- Approximate sentence count
- Average words per sentence
- Warning if sentences average >20 words

## Vim Integration

These tools can be called directly from Vim.

### Built-in Commands

Add to your `.vimrc`:
```vim
" Check for weasel words
command! Weasel :!writing-check -w %

" Check for passive voice
command! Passive :!writing-check -p %

" Find duplicate words
command! Dups :!writing-check -d %

" Run all checks
command! WriteCheck :!writing-check -a %
```

### Quick Access
Press `:WriteCheck` in Vim to analyze current file.

## Alternative: Vim-Only Commands

For even lighter weight, use these pure Vim commands (already in `vimrc-minimal`):

```vim
" Highlight weasel words
:Weasel

" Highlight passive voice
:Passive

" Find duplicate words
:Dups

" Clear highlights
:Clear
```

These use Vim's built-in regex matching - no external tools needed.

## Memory Usage Comparison

| Tool | RAM Usage | Features |
|------|-----------|----------|
| writing-check.sh | 0 MB | Full analysis, statistics |
| Vim commands | 0 MB | Highlighting only |
| vim-wordy plugin | 5 KB | Dictionary-based |
| LanguageTool | 500+ MB | Grammar checking |
| Grammarly | 1+ GB | AI-powered |

## Philosophy

These tools follow the Unix philosophy:
- Do one thing well
- Work with plain text
- Compose with other tools
- Use minimal resources

They don't enforce rules - they make you conscious of your choices. Sometimes passive voice or a "very" is exactly right. The tools just ensure it's intentional.

## Tips for E-Ink

1. **Pipe to less** for easier reading:
   ```bash
   writing-check -a chapter.txt | less
   ```

2. **Save results** for review:
   ```bash
   writing-check -a draft.txt > draft-analysis.txt
   ```

3. **Check before syncing** to catch issues early:
   ```bash
   writing-check -a ~/notes/*.txt
   ```

## Credit

Inspired by Matt Might's shell scripts for academic writing, adapted for fiction and general prose.