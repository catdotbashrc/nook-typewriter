" E-Ink Optimized Color Scheme for Vim
" High contrast monochrome theme for E-Ink displays
" Designed for Nook Simple Touch and similar devices

" === COLOR SCHEME INFO ===
let g:colors_name = "eink"
set background=light

" === CLEAR EXISTING HIGHLIGHTS ===
hi clear
if exists("syntax_on")
  syntax reset
endif

" === E-INK PHILOSOPHY ===
" 1. Pure black on white for maximum contrast
" 2. Use bold/underline instead of colors
" 3. Minimize visual noise
" 4. No background colors except for selections
" 5. Optimize for 16-level grayscale

" === TERMINAL COLORS ===
" Force monochrome mode
set t_Co=2

" === CORE HIGHLIGHTS ===
" Main text - pure black on white
hi Normal       ctermfg=0    ctermbg=15   cterm=NONE
hi NonText      ctermfg=8    ctermbg=NONE cterm=NONE
hi EndOfBuffer  ctermfg=15   ctermbg=NONE cterm=NONE

" Cursor and selections - inverted for visibility
hi Cursor       ctermfg=15   ctermbg=0    cterm=NONE
hi CursorLine   ctermfg=NONE ctermbg=NONE cterm=bold
hi CursorColumn ctermfg=NONE ctermbg=NONE cterm=NONE
hi Visual       ctermfg=15   ctermbg=0    cterm=NONE
hi VisualNOS    ctermfg=15   ctermbg=8    cterm=NONE

" Line numbers - gray for less distraction
hi LineNr       ctermfg=8    ctermbg=NONE cterm=NONE
hi CursorLineNr ctermfg=0    ctermbg=NONE cterm=bold
hi SignColumn   ctermfg=8    ctermbg=NONE cterm=NONE

" Status line - minimal contrast
hi StatusLine   ctermfg=0    ctermbg=NONE cterm=bold
hi StatusLineNC ctermfg=8    ctermbg=NONE cterm=NONE
hi VertSplit    ctermfg=8    ctermbg=NONE cterm=NONE

" === SEARCH ===
" High contrast for search results
hi Search       ctermfg=15   ctermbg=0    cterm=NONE
hi IncSearch    ctermfg=15   ctermbg=0    cterm=bold

" === MESSAGES ===
hi ErrorMsg     ctermfg=0    ctermbg=NONE cterm=bold
hi WarningMsg   ctermfg=0    ctermbg=NONE cterm=bold
hi ModeMsg      ctermfg=0    ctermbg=NONE cterm=bold
hi MoreMsg      ctermfg=0    ctermbg=NONE cterm=NONE
hi Question     ctermfg=0    ctermbg=NONE cterm=bold

" === SPELL CHECKING ===
" Underline only - no colors for E-Ink
hi SpellBad     ctermfg=0    ctermbg=NONE cterm=underline
hi SpellCap     ctermfg=0    ctermbg=NONE cterm=underline
hi SpellRare    ctermfg=8    ctermbg=NONE cterm=underline
hi SpellLocal   ctermfg=8    ctermbg=NONE cterm=underline

" === DIFF MODE ===
hi DiffAdd      ctermfg=0    ctermbg=NONE cterm=bold
hi DiffChange   ctermfg=0    ctermbg=NONE cterm=NONE
hi DiffDelete   ctermfg=8    ctermbg=NONE cterm=NONE
hi DiffText     ctermfg=0    ctermbg=NONE cterm=bold

" === FOLDING ===
hi Folded       ctermfg=8    ctermbg=NONE cterm=NONE
hi FoldColumn   ctermfg=8    ctermbg=NONE cterm=NONE

" === POPUP MENU ===
hi Pmenu        ctermfg=0    ctermbg=NONE cterm=NONE
hi PmenuSel     ctermfg=15   ctermbg=0    cterm=NONE
hi PmenuSbar    ctermfg=NONE ctermbg=8    cterm=NONE
hi PmenuThumb   ctermfg=NONE ctermbg=0    cterm=NONE

" === TABS ===
hi TabLine      ctermfg=8    ctermbg=NONE cterm=NONE
hi TabLineSel   ctermfg=0    ctermbg=NONE cterm=bold
hi TabLineFill  ctermfg=NONE ctermbg=NONE cterm=NONE

" === SYNTAX GROUPS (Minimal for prose) ===
" Comments and strings in gray
hi Comment      ctermfg=8    ctermbg=NONE cterm=NONE
hi String       ctermfg=0    ctermbg=NONE cterm=NONE
hi Character    ctermfg=0    ctermbg=NONE cterm=NONE

" Keywords and identifiers in black with styling
hi Keyword      ctermfg=0    ctermbg=NONE cterm=bold
hi Identifier   ctermfg=0    ctermbg=NONE cterm=NONE
hi Function     ctermfg=0    ctermbg=NONE cterm=bold
hi Statement    ctermfg=0    ctermbg=NONE cterm=bold

" Constants and types
hi Constant     ctermfg=0    ctermbg=NONE cterm=NONE
hi Number       ctermfg=0    ctermbg=NONE cterm=NONE
hi Boolean      ctermfg=0    ctermbg=NONE cterm=bold
hi Type         ctermfg=0    ctermbg=NONE cterm=bold

" Special characters
hi Special      ctermfg=0    ctermbg=NONE cterm=bold
hi SpecialKey   ctermfg=8    ctermbg=NONE cterm=NONE
hi Delimiter    ctermfg=0    ctermbg=NONE cterm=NONE

" Preprocessor
hi PreProc      ctermfg=0    ctermbg=NONE cterm=bold
hi Define       ctermfg=0    ctermbg=NONE cterm=bold
hi Include      ctermfg=0    ctermbg=NONE cterm=bold

" Errors and TODOs
hi Error        ctermfg=0    ctermbg=NONE cterm=bold,underline
hi Todo         ctermfg=0    ctermbg=NONE cterm=bold,underline

" === MARKDOWN SPECIFIC ===
hi markdownH1   ctermfg=0    ctermbg=NONE cterm=bold
hi markdownH2   ctermfg=0    ctermbg=NONE cterm=bold
hi markdownH3   ctermfg=0    ctermbg=NONE cterm=bold
hi markdownBold ctermfg=0    ctermbg=NONE cterm=bold
hi markdownItalic ctermfg=0  ctermbg=NONE cterm=underline
hi markdownCode ctermfg=8    ctermbg=NONE cterm=NONE
hi markdownCodeBlock ctermfg=8 ctermbg=NONE cterm=NONE
hi markdownUrl  ctermfg=8    ctermbg=NONE cterm=underline

" === HELP FILES ===
hi helpHyperTextJump ctermfg=0 ctermbg=NONE cterm=underline
hi helpHyperTextEntry ctermfg=0 ctermbg=NONE cterm=bold

" === QUICKFIX ===
hi qfLineNr     ctermfg=8    ctermbg=NONE cterm=NONE
hi qfFileName   ctermfg=0    ctermbg=NONE cterm=bold

" === SPECIAL ADJUSTMENTS FOR E-INK ===
" Reduce visual noise
hi Whitespace   ctermfg=15   ctermbg=NONE cterm=NONE
hi Conceal      ctermfg=8    ctermbg=NONE cterm=NONE
hi Ignore       ctermfg=15   ctermbg=NONE cterm=NONE

" Directory listings
hi Directory    ctermfg=0    ctermbg=NONE cterm=bold

" Wild menu
hi WildMenu     ctermfg=15   ctermbg=0    cterm=NONE

" Matching parentheses
hi MatchParen   ctermfg=0    ctermbg=NONE cterm=bold,underline

" Column markers
hi ColorColumn  ctermfg=NONE ctermbg=NONE cterm=NONE

" === FINAL ADJUSTMENTS ===
" Ensure no color bleeding
hi clear SpellBad
hi clear SpellCap  
hi clear SpellRare
hi clear SpellLocal
hi SpellBad     cterm=underline
hi SpellCap     cterm=underline
hi SpellRare    cterm=underline
hi SpellLocal   cterm=underline