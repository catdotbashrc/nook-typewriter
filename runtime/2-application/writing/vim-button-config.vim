" vim-button-config.vim - Button integration for JesterOS Vim
" Maps physical buttons to Vim navigation commands

" ═══════════════════════════════════════════════════════════════
"                    JesterOS Button Mappings
" ═══════════════════════════════════════════════════════════════

" Page Turn Button Mappings
" -------------------------
" These work when button-daemon sends the appropriate signals

" Left page button - Previous page
" Receives Ctrl+B from button daemon
" Already mapped by default to page up

" Right page button - Next page  
" Receives Ctrl+F from button daemon
" Already mapped by default to page down

" Additional mappings for writing mode
" -------------------------------------

" Function to toggle writing mode optimizations
function! ToggleWritingMode()
    if !exists('g:writing_mode')
        let g:writing_mode = 0
    endif
    
    let g:writing_mode = !g:writing_mode
    
    if g:writing_mode
        " Enable writing mode optimizations
        echo "📝 Writing Mode ON"
        
        " Disable distractions
        set nonumber
        set norelativenumber
        set laststatus=0
        set noshowmode
        set noshowcmd
        set noruler
        
        " Focus mode - center text
        set scrolloff=999
        
        " Soft wrap for better readability
        set wrap
        set linebreak
        set breakindent
        
        " Autosave every 30 seconds
        autocmd CursorHold,CursorHoldI * silent! update
        set updatetime=30000
        
        " Map page buttons to paragraph navigation
        map <C-b> {
        map <C-f> }
        
    else
        " Disable writing mode
        echo "📖 Reading Mode"
        
        " Restore normal display
        set number
        set relativenumber
        set laststatus=2
        set showmode
        set showcmd
        set ruler
        
        " Normal scrolling
        set scrolloff=5
        
        " Restore page navigation
        unmap <C-b>
        unmap <C-f>
        
        " Disable autosave
        autocmd! CursorHold,CursorHoldI
    endif
endfunction

" Button combination handlers
" ---------------------------

" Power + Home = Save and quit
" (Handled by button daemon, but we can add a shortcut)
nnoremap <C-q> :wq<CR>

" Quick save on double page turn
" (Simulated by quick succession of both buttons)
let g:last_page_press = 0
function! CheckDoublePage()
    let now = localtime()
    if (now - g:last_page_press) < 1
        " Double press detected - save
        silent! write
        echo "✓ Saved"
    endif
    let g:last_page_press = now
endfunction

" Writing Navigation Modes
" ------------------------

" Mode 1: Page navigation (default)
" Ctrl+B/F = Full page up/down

" Mode 2: Paragraph navigation
function! SetParagraphMode()
    map <C-b> {
    map <C-f> }
    echo "¶ Paragraph mode"
endfunction

" Mode 3: Section navigation (markdown headers)
function! SetSectionMode()
    map <C-b> ?^#<CR>
    map <C-f> /^#<CR>
    echo "§ Section mode"
endfunction

" Mode 4: Chapter navigation (for novels)
function! SetChapterMode()
    map <C-b> ?^Chapter<CR>
    map <C-f> /^Chapter<CR>
    echo "📚 Chapter mode"
endfunction

" Cycle through navigation modes
let g:nav_mode = 0
function! CycleNavigationMode()
    let g:nav_mode = (g:nav_mode + 1) % 4
    
    if g:nav_mode == 0
        " Page mode (default)
        unmap <C-b>
        unmap <C-f>
        echo "📄 Page mode"
    elseif g:nav_mode == 1
        call SetParagraphMode()
    elseif g:nav_mode == 2
        call SetSectionMode()
    else
        call SetChapterMode()
    endif
endfunction

" Status line for button feedback
" --------------------------------

function! ButtonStatus()
    if filereadable('/var/jesteros/buttons/last_action')
        return system('cat /var/jesteros/buttons/last_action')[:-2]
    endif
    return ''
endfunction

" Add to status line if desired
" set statusline+=%{ButtonStatus()}

" Auto-commands for button events
" --------------------------------

" Check for button status changes
function! CheckButtonEvents()
    " Check if writing mode was toggled externally
    if filereadable('/var/jesteros/buttons/writing_mode')
        let mode = system('cat /var/jesteros/buttons/writing_mode')[:-2]
        if mode == 'on' && !exists('g:writing_mode')
            call ToggleWritingMode()
        elseif mode == 'off' && exists('g:writing_mode') && g:writing_mode
            call ToggleWritingMode()
        endif
    endif
    
    " Check for screenshot notification
    if filereadable('/var/jesteros/buttons/last_action')
        let action = system('cat /var/jesteros/buttons/last_action')[:-2]
        if action == 'screenshot'
            echo "📸 Screenshot saved"
            call system('rm /var/jesteros/buttons/last_action')
        endif
    endif
endfunction

" Check button events periodically
if has('timers')
    let g:button_timer = timer_start(1000, {-> CheckButtonEvents()}, {'repeat': -1})
endif

" E-Ink specific optimizations
" -----------------------------

" Reduce screen updates for E-Ink
set lazyredraw
set ttyfast

" Minimize cursor blinking
set guicursor=a:blinkon0

" Reduce update frequency
set updatetime=4000

" Commands for manual control
" ---------------------------

command! WritingMode call ToggleWritingMode()
command! NavMode call CycleNavigationMode()
command! PageMode unmap <C-b> | unmap <C-f> | echo "📄 Page mode"
command! ParaMode call SetParagraphMode()
command! SectionMode call SetSectionMode()
command! ChapterMode call SetChapterMode()

" Help text
" ---------

function! ShowButtonHelp()
    echo "═══════════════════════════════════════════════════════════════"
    echo "                    JesterOS Vim Button Guide"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "Physical Buttons:"
    echo "  Left Page    - Page up (Ctrl+B)"
    echo "  Right Page   - Page down (Ctrl+F)"
    echo "  Home         - Exit to menu"
    echo "  Power        - System menu"
    echo ""
    echo "Combinations:"
    echo "  Both Pages   - Toggle writing mode"
    echo "  Power + Home - Screenshot"
    echo ""
    echo "Vim Commands:"
    echo "  :WritingMode - Toggle focused writing"
    echo "  :NavMode     - Cycle navigation modes"
    echo "  :PageMode    - Navigate by page"
    echo "  :ParaMode    - Navigate by paragraph"
    echo "  :SectionMode - Navigate by section"
    echo "  :ChapterMode - Navigate by chapter"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
endfunction

command! ButtonHelp call ShowButtonHelp()

" Initialize on startup
" --------------------

" Show welcome message
echo "JesterOS Vim - Buttons ready! Use :ButtonHelp for guide"

" Check initial button state
call CheckButtonEvents()

" ═══════════════════════════════════════════════════════════════
"            'By button and key, thy words fly free!'
"                      - The Jester
" ═══════════════════════════════════════════════════════════════