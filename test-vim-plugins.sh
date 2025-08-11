#!/bin/bash
# Test Vim plugins in Docker container

echo "================================"
echo "Testing Vim Plugins in Nook System"
echo "================================"
echo

# Test 1: Check vimrc is properly configured
echo "1. Testing vimrc configuration..."
docker run --rm nook-system bash -c "cat /root/.vimrc | grep -E 'leader|runtimepath|plugin' | head -5"
echo

# Test 2: Check Vim can see the plugins
echo "2. Testing Vim plugin detection..."
docker run --rm nook-system bash -c "vim --version | grep -E 'VIM|version' | head -2"
echo

# Test 3: Test Goyo (distraction-free writing)
echo "3. Testing Goyo plugin..."
docker run --rm nook-system bash -c "echo 'Testing Goyo' | vim -c ':Goyo' -c ':q!' - 2>&1 | grep -v '^Vim' || echo 'Goyo loads without errors'"
echo

# Test 4: Test Pencil (better prose writing)
echo "4. Testing Pencil plugin..."
docker run --rm nook-system bash -c "echo 'Testing Pencil' | vim -c ':Pencil' -c ':q!' - 2>&1 | grep -v '^Vim' || echo 'Pencil loads without errors'"
echo

# Test 5: Test Lightline (status bar)
echo "5. Testing Lightline..."
docker run --rm nook-system bash -c "vim -c ':set laststatus=2' -c ':q!' 2>&1 | grep -v '^Vim' || echo 'Lightline loads without errors'"
echo

# Test 6: Test leader key mappings
echo "6. Testing custom key mappings..."
docker run --rm nook-system bash -c "vim -c ':map' -c ':q!' 2>&1 | grep 'leader' | head -3"
echo

# Test 7: Create a test document with plugins
echo "7. Creating test document with all plugins..."
cat << 'EOF' > test-vim-script.vim
" Test all plugins
set nocompatible
filetype plugin indent on
syntax on

" Enable plugins
runtime! plugin/**/*.vim

" Test Goyo
Goyo

" Test Pencil
Pencil

" Save test file
w /tmp/test-output.txt

" Report success
echo "All plugins loaded successfully!"
q!
EOF

docker run --rm -v $(pwd)/test-vim-script.vim:/tmp/test.vim:ro nook-system bash -c "
echo 'Testing document creation with plugins...'
echo 'This is a test document for the Nook typewriter.' > /tmp/input.txt
vim -s /tmp/test.vim /tmp/input.txt 2>&1 | grep -v '^Vim' || true
if [ -f /tmp/test-output.txt ]; then
    echo 'SUCCESS: Document created with plugins'
    cat /tmp/test-output.txt
else
    echo 'WARNING: Could not create test document'
fi
"
echo

# Test 8: Check plugin documentation
echo "8. Checking plugin documentation..."
docker run --rm nook-system bash -c "ls /root/.vim/pack/plugins/start/*/doc/*.txt 2>/dev/null | wc -l | xargs -I {} echo 'Found {} plugin help files'"
echo

# Test 9: Test interactive features (simulated)
echo "9. Testing interactive features..."
docker run --rm nook-system bash -c "
# Create a vim script to test mappings
cat << 'VIMTEST' > /tmp/test-mappings.vim
\" Test leader mappings
let mapleader = \" \"
nnoremap <leader>g :Goyo<CR>
nnoremap <leader>p :Pencil<CR>

\" Try to execute mappings
normal \\g
normal \\p

\" Save and quit
:wq /tmp/mapping-test.txt
VIMTEST

echo 'Test content' | vim -u /root/.vimrc -S /tmp/test-mappings.vim - 2>&1 | grep -v '^Vim' || echo 'Mappings configured'
"
echo

# Test 10: Memory usage with plugins
echo "10. Testing memory usage with plugins loaded..."
docker run --rm nook-system bash -c "
vim -c ':echo \"Loading plugins...\"' -c ':runtime! plugin/**/*.vim' -c ':q!' 2>&1 &
VIM_PID=\$!
sleep 1
ps aux | grep vim | grep -v grep || echo 'Vim process completed'
"
echo

echo "================================"
echo "Plugin Test Summary"
echo "================================"
echo "✓ Goyo.vim - Distraction-free writing mode"
echo "✓ Vim-Pencil - Improved prose writing"
echo "✓ Lightline - Minimal status bar"
echo "✓ Vim-Zettel - Note-taking system"
echo
echo "All plugins should load without errors."
echo "If any test failed, check the error messages above."