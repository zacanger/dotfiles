" zacanger's .vimrc

if has('vim_starting')
    set nocompatible " Be iMproved
endif

let g:coc_global_extensions = [
\ 'coc-json',
\ 'coc-tsserver',
\ 'coc-html',
\ 'coc-css',
\ 'coc-yaml',
\ 'coc-sh',
\ ]
" \ 'coc-pyright',
" \ 'coc-go',

call plug#begin('~/.local/share/vim/plugged')

Plug 'vim-jp/vital.vim'                           " deps
Plug 'vim-scripts/SyntaxRange'                    " deps
Plug 'vim-scripts/ingo-library'                   " deps
Plug 'FooSoft/vim-argwrap'                        " wrap items in blocks/lists
Plug 'airblade/vim-rooter'                        " set path to project root
Plug 'ervandew/supertab'                          " tab insert-mode completions
Plug 'bling/vim-airline'                          " better statusline
Plug 'bounceme/poppy.vim'                         " simple highlight/rainbow parens plugin
Plug 'bronson/vim-trailing-whitespace'            " highlight trailing whitespace
Plug 'jiangmiao/auto-pairs'                       " auto-complete pairs of things
Plug 'junegunn/seoul256.vim'                      " colo
Plug 'junegunn/vim-easy-align'                    " align stuff on a symbol (like the comments in this block)
" Plug 'fatih/vim-go'                               " go support
Plug 'junegunn/vim-peekaboo'                      " see registers easily
Plug 'junegunn/vim-slash'                         " better buffer search
Plug 'mhinz/vim-signify'                          " vcs markers in gutter, also see 'airblade/vim-gitgutter'
Plug 'moll/vim-node'                              " enchance vim for node (for example, better gf)
Plug 'scrooloose/nerdcommenter'                   " there are so many commenter plugins, but this one just works
Plug 'sgur/vim-editorconfig'                      " support editorconfig
Plug 'sheerun/vim-polyglot'                       " language support
Plug 'tpope/vim-surround'                         " surround things with other things
Plug 'vim-scripts/paredit.vim'                    " balance parens
Plug 'vim-scripts/syntaxcomplete'                 " super simple syn completion
Plug 'vim-utils/vim-husk'                         " bash emacs-mode mappings in command mode
Plug 'vim-utils/vim-troll-stopper'                " highlight unicode chars that look like ascii chars
Plug 'tmux-plugins/vim-tmux-focus-events'         " fix focus events from tmux
Plug 'blueyed/vim-diminactive'                    " dim inactive windows, works with the tmux fix
Plug 'dhruvasagar/vim-table-mode'                 " instant tables
Plug 'neoclide/coc.nvim', { 'branch': 'release' } " LSP support

call plug#end()

"" Basic Setup

filetype plugin indent on
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8

" Fix backspace indent
set backspace=indent,eol,start

" Tabs. May be overriten by autocmd rules
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set smarttab
set autoindent

" Map leader to ,
let mapleader="\<Space>"

" Enable hidden buffers
set hidden

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase
highlight clear Search
highlight Search ctermfg=White
" Clean search (highlight)
nnoremap <silent> <leader>/ :noh<cr>
" blink the line containing the match
fu! HLNext (blinktime)
    set invcursorline
    redraw
    exec 'sleep ' . float2nr(a:blinktime * 250) . 'm'
    set invcursorline
    redraw
endfu
" highlight matches when jumping to next
" This rewires n and N to do the highlighing...
nnoremap <silent> n n:call HLNext(0.4)<cr>
nnoremap <silent> N N:call HLNext(0.4)<cr>

" Encoding
set bomb
set binary

" Don't write these, it's not like Vim crashes all that often
set nobackup
set noswapfile

set fileformats=unix,dos,mac
set showcmd
set shell=/bin/bash

"" Visual Settings
syntax on
set ruler
set number

let no_buffers_menu=1

set mousemodel=popup
set t_Co=256
set cursorline
set guioptions=egmrti
set gfn=Monospace\ 10

if &term =~ '256color'
    set t_ut=256
endif

" Disable the blinking cursor.
set gcr=a:blinkon0
set scrolloff=3

" Map cursor for insert mode
if &term =~ "xterm\\|rxvt"
    let &t_SI .= "\<Esc>[5 q"
    let &t_EI .= "\<Esc>[0 q"
endif

" Status bar
set laststatus=2

" Use modeline overrides
set modeline
set modelines=10

set title
set titleold="Terminal"
set titlestring=%F

set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\

" vim-airline
let g:airline_theme = 'seoul256'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

if !exists('g:airline_powerline_fonts')
    let g:airline#extensions#tabline#left_sep     = ' '
    let g:airline#extensions#tabline#left_alt_sep = '|'
    let g:airline_left_sep                        = '▶'
    let g:airline_left_alt_sep                    = '»'
    let g:airline_right_sep                       = '◀'
    let g:airline_right_alt_sep                   = '«'
    let g:airline#extensions#branch#prefix        = '⤴' "➔, ➥, ⎇
    let g:airline#extensions#readonly#symbol      = '⊘'
    let g:airline#extensions#linecolumn#prefix    = '¶'
    let g:airline#extensions#paste#symbol         = 'ρ'
    let g:airline_symbols.linenr                  = '␊'
    let g:airline_symbols.branch                  = '⎇'
    let g:airline_symbols.paste                   = 'ρ'
    let g:airline_symbols.paste                   = 'Þ'
    let g:airline_symbols.paste                   = '∥'
    let g:airline_symbols.whitespace              = 'Ξ'
else
    let g:airline#extensions#tabline#left_sep     = ''
    let g:airline#extensions#tabline#left_alt_sep = ''

    " powerline symbols
    let g:airline_left_sep         = ''
    let g:airline_left_alt_sep     = ''
    let g:airline_right_sep        = ''
    let g:airline_right_alt_sep    = ''
    let g:airline_symbols.branch   = ''
    let g:airline_symbols.readonly = ''
    let g:airline_symbols.linenr   = ''
endif

" abbrs
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qa! qa!
cnoreabbrev qa1 qa!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev WQ wq
cnoreabbrev E e
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev X x
cnoreabbrev stu sort u
cnoreabbrev Stu sort u
cnoreabbrev Set set
cnoreabbrev Bd bd
inoreabbr lmbd λ
inoreabbr frll ∀
inoreabbr (tm) ™
inoreabbr (c) ©
inoreabbr (r) ®
inoreabbr hamsic ☭
inoreabbr neccessary necessary
inoreabbr neccesary necessary

" wild
set wildmenu
set path+=**
set wildmode=list:longest,list:full
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite
set wildignore+=*.o,*.obj,.git,*.rbc,__pycache__,node_modules/**,bower_components/**
set wildignore+=solr/**,log/**,*.psd,*.PSD,.git/**,.gitkeep,.gems/**
set wildignore+=*.ico,*.ICO,backup/**,*.sql,*.dump,*.tmp,*.min.js,Gemfile.lock
set wildignore+=*.png,*.PNG,*.JPG,*.jpg,*.JPEG,*.jpeg,*.GIF,*.gif,*.pdf,*.PDF
set wildignore+=vendor/**,coverage/**,tmp/**,rdoc/**,*.BACKUP.*,*.BASE.*,*.LOCAL.*,*.REMOTE.*,.sass-cache/**

if !exists('*s:setupWrapping')
    fu s:setupWrapping()
        set wrap
        set wm=4
        set textwidth=79
    endfu
endif

"" aus
" syntax highlight syncing from start
augroup vimrc-sync-fromstart
    autocmd!
    autocmd BufEnter * :syntax sync fromstart
augroup END

" Remember cursor position
augroup vimrc-remember-cursor-position
    autocmd!
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" txt
augroup vimrc-wrapping
    autocmd!
    autocmd BufRead,BufNewFile *.txt call s:setupWrapping()
augroup END

" make/cmake
augroup vimrc-make-cmake
    autocmd!
    autocmd FileType make setlocal noexpandtab
    autocmd BufNewFile,BufRead CMakeLists.txt setlocal filetype=cmake
augroup END

au BufRead,BufNewFile *.md setlocal textwidth=80

autocmd FileType css set omnifunc=csscomplete#CompleteCSS noci

set autoread

"" mappings
nnoremap > >>
nnoremap < <<

" select most recently edited text
nnoremap vp `[v`]

" gq: format, ip: in paragraph. i do this a lot, so leader-q is nice.
noremap <Leader>q gqip

" split
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

" Disable visualbell
set noeb vb t_vb=

"" system clipboard
set clipboard^=unnamed,unnamedplus

noremap YY "+y<CR>
noremap P "+gP<CR>
noremap XX "+x<CR>

" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

" Vmap for maintain Visual Mode after shifting > and <
vmap < <gv
vmap > >gv

" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" vim-python
augroup vimrc-python
    autocmd!
    autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=4
        \ formatoptions+=croq softtabstop=4 smartindent
        \ cinwords=if,elif,else,for,while,try,except,finally,def,class,with
augroup END

" vim-airline
let g:airline#extensions#virtualenv#enabled = 1

let g:javascript_enable_domhtmlcss = 1

inoremap <Esc> <Esc>`^

cnoremap sudow w !sudo tee & >/dev/null

let g:seoul256_background = 233
try
    colorscheme seoul256
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme elflord
endtry

let g:netrw_banner=0
let g:netrw_browser_split=4
let g:netrw_altv=1
let g:netrw_liststyle=3
let g:netrw_gx="<cWORD>"

" commit message thing
autocmd Filetype gitcommit setlocal spell textwidth=80

autocmd Filetype markdown set spell
autocmd Filetype text set spell

" clear screen between shell commands
nnoremap :! :!clear;
vnoremap :! :!clear;

noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" keep Y consistent
nnoremap Y y$

" vim-markdown (from polyglot)
let g:vim_markdown_conceal = 0
let g:vim_markdown_new_list_item_indent = 4
let g:vim_markdown_folding_disabled = 1

let g:csstoinline_wrap_pixels = 1

" match % on more stuff
if !exists('g:loaded_matchit')
    runtime macros/matchit.vim
endif

" better ctrl-l
nnoremap <leader>l :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>

" show tabs
set list lcs=tab:\|\
" except in go, because gofmt says so
autocmd FileType go set nolist

" break line on words
set linebreak
" keep indentation
set breakindent
set showbreak=\\\\\

" fix where new splits show up
set splitbelow
set splitright

" relative dirs
set autochdir

" use relative numbers in most modes
autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber

let g:paredit_mode=0
let g:paredit_leader="\<Space>"

let g:parinfer_mode="off"

" use <F8> to go to next conflict marker
map <silent> <F8> /^\(<\{7\}\\|>\{7\}\\|=\{7\}\\|\|\{7\}\)\( \\|$\)<cr>

if has('mouse')
    set mouse=a
endif

" pixie
au BufNewFile,BufRead *.pxi set ft=clojure

" I don't ever write Verilog, but might try out V
au BufNewFile,BufRead *.v set ft=vlang

" cshtml
au BufNewFile,BufRead *.cshtml set ft=html

" alternate jenkinsfiles
au BufNewFile,BufRead Promotionfile set ft=jenkinsfile
au BufNewFile,BufRead *.jenkinsfile set ft=jenkinsfile

" babelrc
au BufNewFile,BufRead .babelrc set ft=json

" highlight the 121st column of wide lines
hi ColorColumn ctermbg=235
call matchadd('ColorColumn', '\%121v', 100)

" syntaxcomplete
if has("autocmd") && exists("+omnifunc")
    autocmd Filetype *
        \ if &omnifunc == "" |
        \     setlocal omnifunc=syntaxcomplete#Complete |
        \ endif
endif

nnoremap <leader>w :w<CR>
nnoremap <leader>x :x<CR>
nnoremap <leader>m :make<CR>

" nerdcommenter
let g:NERDSpaceDelims=1
let g:NERDCommentEmptyLines=1

" argwrap
let g:argwrap_padded_braces = '[{'
let g:argwrap_tail_comma_braces = '[{'
nnoremap <silent> <leader>a :ArgWrap<CR>

" match angle brackest
set matchpairs+=<:>

" preserve flags for pattern when repeating substitution with &
nnoremap <silent> & :<C-U>&&<CR>
vnoremap <silent> & :<C-U>&&<CR>

" don't redraw the screen when executing macros, etc
set lazyredraw

if has('virtualedit')
    set virtualedit+=block
endif

set nojoinspaces
set display=lastline

" node native addons
au BufNewFile,BufRead *.gyp set ft=json

" easyalign
" start in visual mode (vipga)
xmap ga <Plug>(EasyAlign)
" start for object/motion (gaip)
nmap ga <Plug>(EasyAlign)

" vim-trailing-whitespace
let g:extra_whitespace_ignored_filetypes = ['go', 'md']

" if Poppy isn't loaded (like when first installing plugins),
" calling it will error, so we just set some defaults instead
if exists('poppyhigh')
    au! cursormoved * call PoppyInit()
else
    " match pairs
    inoremap { {}<Esc>ha
    inoremap ( ()<Esc>ha
    inoremap [ []<Esc>ha
    inoremap " ""<Esc>ha
    inoremap ' ''<Esc>ha
    inoremap ` ``<Esc>ha
endif

" don't use {{{  }}}, also syntax never really works the way i want
set foldmethod=manual

let g:AutoPairsShortcutToggle = ''

" Silence the cd echo
let g:rooter_silent_chdir = 1

" dimming settings
let g:diminactive_enable_focus = 1
let g:diminactive_use_colorcolumn = 1
let g:diminactive_use_syntax = 1

" fix imports + format on save
" let g:go_fmt_command = "goimports"

" convert camelCase to snake_case
nnoremap <leader>crs :g;<c-r><c-w>; s;[a-z]\@<=[A-Z];_\l&;g<cr>

" coc settings
" use <tab> to trigger completion and navigate to the next complete item
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"

"   TODO: maybe use these instead of some plugins
"   function! StripTrailingWhitespaces() abort
"       let l:save = winsaveview()
"       keeppatterns %s/\v\s+$//e
"       call winrestview(l:save)
"   endfunction
"   autocmd BufWritePost * StripTrailingWhitespaces
"
"   " dylan araps wrote this. i don't think he'll mind.
"   let g:root#patterns = get(g:, 'root#patterns', ['.git', '_darcs', '.hg', '.bzr', '.svn'])
"   let g:root#auto = get(g:, 'root#auto', 0)
"   let g:root#autocmd_patterns = get(g:, 'root#autocmd_patterns', '*')
"   let g:root#echo = get(g:, 'root#echo', 1)
"
"   function! s:findRoot()
"       if &buftype ==? ''
"           " The plugin doesn't work with autochdir
"           set noautochdir
"
"           " The plugin only works with local directories
"           if expand('%:p') =~? '://'
"               return
"           endif
"
"           " Start in open file's directory
"           silent! lcd %:p:h
"           let l:liststart = 0
"
"           for l:pattern in g:root#patterns[l:liststart : len(g:root#patterns)]
"               " If l:pattern is a file use findfile() else use finddir()
"               if matchstr(l:pattern, '\m\C\w\+\.\w*$') == l:pattern
"                   let l:fullpath = findfile(l:pattern, ';')
"               else
"                   let l:fullpath = finddir(l:pattern, ';')
"               endif
"
"               " Split the directory into path/match
"               let l:match = matchstr(l:fullpath, '\m\C[^\/]*$')
"               let l:path = matchstr(l:fullpath, '\m\C.*\/')
"
"               " $HOME + match
"               let l:home = $HOME . '/' . l:pattern
"               if l:fullpath == '' || l:fullpath == l:home
"                   let l:liststart = l:liststart + 1
"                   lcd %:p:h
"               elseif empty(l:match) == 0
"                   break
"               endif
"
"               " If the search hits the end of the list start over
"               if l:liststart == len(g:root#patterns)
"                   let l:liststart = 0
"               endif
"           endfor
"
"           " If path is anything but blank
"           if l:path !=? ''
"               exe 'lcd' . ' ' l:path
"           endif
"
"           if g:root#echo == 1 && l:match !=? ''
"               echom 'Found' l:match 'in' getcwd()
"           elseif g:root#echo == 1
"               echom 'Root dir not found'
"           endif
"       endif
"   endfunction
"
"   command! Root call s:findRoot()
"   augroup root
"       au!
"       exe 'autocmd BufEnter ' . g:root#autocmd_patterns . ' :Root'
"   augroup END
