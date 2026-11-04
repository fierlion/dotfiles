" ---- Bells ----------------------------------------------------------------
" No beep and no screen flash, for every event. (visualbell would only swap
" the beep for a flash.) tmux and iTerm have their own bell settings too.
set belloff=all
set noerrorbells novisualbell t_vb=

" ---- General -------------------------------------------------------------
set nocompatible
filetype plugin indent on
syntax on
set number
set ruler showcmd
set incsearch hlsearch ignorecase smartcase
set backspace=indent,eol,start
set wildmenu wildoptions=pum,fuzzy
set splitright splitbelow
set hidden
set autoread autowrite
set scrolloff=5
set signcolumn=yes
set updatetime=300
let mapleader = " "

" Persistent undo, and swap files kept out of the repo.
for s:dir in ['~/.vim/undo', '~/.vim/swap']
  if !isdirectory(expand(s:dir))
    call mkdir(expand(s:dir), 'p')
  endif
endfor
set undofile undodir=~/.vim/undo//
set directory=~/.vim/swap//

" ---- Appearance (iTerm + tmux) ---------------------------------------------
" 24-bit colour. Inside tmux, $TERM is tmux-256color, so vim needs the colour
" escape codes spelled out.
if &term =~# '^tmux'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
set termguicolors
colorscheme habamax
" Bar cursor in insert mode, underline in replace mode, block otherwise.
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"

" ---- Built-in packages ------------------------------------------------------
packadd! matchit   " % also jumps between #if / #else / #endif
packadd! comment   " gcc toggles a line comment, gc{motion} a range
packadd! cfilter   " :Cfilter /pat/ narrows a long quickfix list
packadd! hlyank    " briefly highlights what you yanked

" ---- Finding things ---------------------------------------------------------
" <Space>p  fuzzy-find a file (fzf; respects .gitignore, so build/ is hidden)
" <Space>g  grep the word under the cursor into the quickfix list
" <Space>k  look up the word under the cursor on cppreference.com
" ]q / [q   next / previous quickfix entry
set grepprg=rg\ --vimgrep\ --smart-case grepformat=%f:%l:%c:%m
" $HOMEBREW_PREFIX is set by brew shellenv in ~/.zprofile.
if isdirectory($HOMEBREW_PREFIX . '/opt/fzf')
  let &runtimepath .= ',' . $HOMEBREW_PREFIX . '/opt/fzf'
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --glob "!.git"'
  nnoremap <silent> <leader>p :FZF<CR>
endif
nnoremap <silent> <leader>g :silent grep! -w <cword> <bar> redraw! <bar> cwindow<CR>
nnoremap <silent> <leader>k :silent !open
      \ 'https://en.cppreference.com/mwiki/index.php?search=<cword>'<CR>
      \ :redraw!<CR>
nnoremap ]q :cnext<CR>
nnoremap [q :cprevious<CR>
nnoremap <silent> <leader>/ :nohlsearch<CR>

" ---- C++ (cppStudy / OpenUSD house style) ---------------------------------
" Vim treats *.h as C++ by default. cinoptions mirror .clang-format:
" g0 = public:/private: at the class column, :0 = case at the switch column,
" N-s = no indent inside namespaces, (0 = align continuation lines after (.
augroup cs_cpp
  autocmd!
  autocmd FileType c,cpp setlocal shiftwidth=4 tabstop=4 softtabstop=4
        \ expandtab colorcolumn=81 cindent cinoptions=g0,:0,N-s,(0
  " gq formats a selection or motion with clang-format, using the repo's
  " .clang-format. <Space>f formats the whole file.
  autocmd FileType c,cpp setlocal formatprg=clang-format\ --assume-filename=%
  autocmd FileType c,cpp nnoremap <buffer> <leader>f
        \ :let _v = winsaveview()<CR>:%!clang-format --assume-filename=%<CR>
        \ :call winrestview(_v)<CR>
  " :make builds with CMake; errors land in the quickfix list.
  autocmd FileType c,cpp setlocal makeprg=cmake\ --build\ build
augroup END

" ---- Build, test, debug -----------------------------------------------------
" <Space>b  build; the quickfix list opens if anything failed
" <Space>t  build and run the tests for the exercise you are editing
" <Space>T  same, only tests whose name starts with the word under the cursor
" <Space>d  build and start lldb with a breakpoint on the cursor line
" Inside tmux these run in the pane beside vim (split off if there isn't
" one); outside tmux they open a vim terminal window. Run vim from the repo
" root.
nnoremap <silent> <leader>b :silent make! <bar> redraw! <bar> cwindow<CR>
nnoremap <silent> <leader>t :call <SID>CsRun(<SID>CsTestBinary())<CR>
nnoremap <silent> <leader>T :call <SID>CsRun(<SID>CsTestBinary() . ' ' .
      \ expand('<cword>'))<CR>
nnoremap <silent> <leader>d :call <SID>CsRun('lldb -o ' .
      \ shellescape('b ' . expand('%:t') . ':' . line('.')) . ' ' .
      \ <SID>CsTestBinary())<CR>
" Esc Esc leaves terminal mode, so you can scroll a long report.
tnoremap <Esc><Esc> <C-\><C-n>

" lesson01/ex2_file_handle/x.cpp is tested by build/lesson01/ex2_file_handle.
function! s:CsTestBinary() abort
  return 'build/' . expand('%:p:h:h:t') . '/' . expand('%:p:h:t')
endfunction

function! s:CsRun(cmd) abort
  silent wall
  let l:cmd = 'cmake --build build && ' . a:cmd
  if empty($TMUX)
    execute 'terminal ++shell ' . l:cmd
    return
  endif
  let l:panes = filter(systemlist('tmux list-panes -F "#{pane_id}"'),
        \ 'v:val !=# $TMUX_PANE')
  if empty(l:panes)
    let l:panes = systemlist('tmux split-window -h -d -P -F "#{pane_id}" -c '
          \ . shellescape(getcwd()))
  endif
  call system('tmux send-keys -t ' . l:panes[0] . ' C-u')
  call system('tmux send-keys -t ' . l:panes[0] . ' -l '
        \ . shellescape('clear; ' . l:cmd))
  call system('tmux send-keys -t ' . l:panes[0] . ' Enter')
endfunction

" ---- Language server (clangd) ----------------------------------------------
" Needs the yegappan/lsp plugin; without it this section does nothing.
" Install:  git clone --depth 1 https://github.com/yegappan/lsp \
"             ~/.vim/pack/plugins/start/lsp
" Inlay hints show the type auto deduced and parameter names at call sites.
let s:lspOpts = #{autoHighlightDiags: v:true, showDiagWithVirtualText: v:true,
      \ showInlayHints: v:true}
let s:lspServers = [#{name: 'clangd', filetype: ['c', 'cpp'],
      \ path: '/usr/bin/clangd',
      \ args: ['--background-index', '--header-insertion=never']}]
augroup cs_lsp
  autocmd!
  autocmd User LspSetup call LspOptionsSet(s:lspOpts)
  autocmd User LspSetup call LspAddServer(s:lspServers)
  " gd definition, K hover (shows what auto deduced), gr references,
  " ]d / [d next and previous diagnostic, <Space>h header <-> source,
  " <Space>r rename.
  autocmd User LspAttached nnoremap <buffer> gd :LspGotoDefinition<CR>
  autocmd User LspAttached nnoremap <buffer> K :LspHover<CR>
  autocmd User LspAttached nnoremap <buffer> gr :LspShowReferences<CR>
  autocmd User LspAttached nnoremap <buffer> ]d :LspDiag next<CR>
  autocmd User LspAttached nnoremap <buffer> [d :LspDiag prev<CR>
  autocmd User LspAttached nnoremap <buffer> <leader>h :LspSwitchSourceHeader<CR>
  autocmd User LspAttached nnoremap <buffer> <leader>r :LspRename<CR>
augroup END
