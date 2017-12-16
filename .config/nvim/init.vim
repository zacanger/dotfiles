" zacanger's init.vim
" for nvim | neovim.io

call plug#begin('~/.local/share/nvim/plugged')

if has('vim_starting')
  set nocompatible " Be iMproved
endif

let g:vim_bootstrap_langs = "javascript,python,html"
let g:vim_bootstrap_editor = "nvim" " nvim or vim

Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'bling/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'sheerun/vim-polyglot'
Plug 'vim-scripts/grep.vim'
Plug 'vim-scripts/CSApprox'
Plug 'bronson/vim-trailing-whitespace'
Plug 'jiangmiao/auto-pairs'
Plug 'Shougo/vimproc.vim', {
      \ 'build' : {
      \     'windows' : 'tools\\update-dll-mingw',
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak',
      \    },
      \ }
Plug 'flowtype/vim-flow', {
        \ 'autoload': {
        \     'filetypes': 'javascript'
        \ }}

" Vim-Session
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'

" Snippets
Plug 'honza/vim-snippets'

" Color
if v:version >= 704
  Plug 'FelikZ/ctrlp-py-matcher'
endif

" misc
" todo: get rid of this
Plug 'scrooloose/syntastic'

Plug 'FooSoft/vim-argwrap'
Plug 'KabbAmine/lazyList.vim'
Plug 'KabbAmine/vCoolor.vim'
Plug 'Lokaltog/vim-distinguished'
Plug 'Quramy/tsuquyomi'
Plug 'Quramy/vison'
Plug 'Shougo/context_filetype.vim'
Plug 'Shougo/deoplete.nvim'
Plug 'Shougo/neopairs.vim'
Plug 'Shougo/unite-outline'
Plug 'Shougo/unite.vim'
Plug 'ahri/vim-sesspit'
Plug 'airblade/vim-accent'
Plug 'airblade/vim-rooter'
Plug 'bitc/vim-hdevtools'
Plug 'clausreinke/typescript-tools.vim'
Plug 'digitaltoad/vim-pug'
Plug 'ervandew/supertab'
Plug 'fleischie/vim-styled-components'
Plug 'flowtype/vim-flow'
Plug 'francoiscabrol/ranger.vim'
Plug 'frigoeu/psc-ide-vim'
Plug 'godlygeek/tabular'
Plug 'goldfeld/vim-seek'
Plug 'gorodinskiy/vim-coloresque'
Plug 'gregsexton/MatchTag'
Plug 'gregsexton/gitv'
Plug 'hail2u/vim-css3-syntax'
Plug 'isomoar/vim-css-to-inline'
Plug 'jbgutierrez/vim-babel'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'jparise/vim-graphql'
Plug 'junegunn/vim-easy-align'
Plug 'junegunn/vim-emoji'
Plug 'junegunn/vim-peekaboo'
Plug 'kien/rainbow_parentheses.vim'
Plug 'kien/tabman.vim'
Plug 'krisajenkins/vim-pipe'
Plug 'leafgarland/typescript-vim'
Plug 'mattn/emoji-vim'
Plug 'mhinz/vim-grepper'
Plug 'mhinz/vim-signify'
Plug 'mhinz/vim-startify'
Plug 'mklabs/vim-cowsay'
Plug 'moll/vim-node'
Plug 'mxw/vim-jsx'
Plug 'neomake/neomake'
Plug 'neovim/node-host'
Plug 'neovimhaskell/haskell-vim'
Plug 'othree/csscomplete.vim'
Plug 'othree/es.next.syntax.vim'
Plug 'othree/html5.vim'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'othree/yajs.vim'
Plug 'pangloss/vim-javascript'
Plug 'plasticboy/vim-markdown'
Plug 'posva/vim-vue'
Plug 'raichoo/purescript-vim'
Plug 'rbgrouleff/bclose.vim'
Plug 'reasonml/vim-reason-loader'
Plug 'reedes/vim-pencil'
Plug 'retorillo/istanbul.vim'
Plug 'rking/ag.vim'
Plug 'rstacruz/vim-xtract'
Plug 'scrooloose/nerdcommenter'
Plug 'sgur/vim-editorconfig'
Plug 'skwp/greplace.vim'
Plug 'snoe/nvim-parinfer.js'
Plug 'spolu/dwm.vim'
Plug 'ternjs/tern_for_vim'
Plug 'tpope/vim-afterimage'
Plug 'tpope/vim-fireplace'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-jp/vital.vim'
Plug 'vim-scripts/SyntaxRange'
Plug 'vim-scripts/c.vim'
Plug 'vim-scripts/ingo-library'
Plug 'vim-scripts/paredit.vim'
Plug 'vim-scripts/syntaxcomplete'
Plug 'vim-utils/vim-husk'
Plug 'vim-utils/vim-man'
Plug 'vim-utils/vim-troll-stopper'
Plug 'vivien/vim-linux-coding-style'
Plug 'xsnippet/vim-xsnippet'
Plug 'zacanger/angr.vim'

call plug#end()

" Required:
filetype plugin indent on

"" Basic Setup

" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8

" Fix backspace indent
set backspace=indent,eol,start

" Tabs. May be overriten by autocmd rules
set tabstop=2
set softtabstop=0
set shiftwidth=2
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

" Encoding
set bomb
set binary

" Directories for swp files
set nobackup
set noswapfile

set fileformats=unix,dos,mac
set showcmd
set shell=/bin/bash

" session management
let g:session_directory = "~/.config/nvim/session"
let g:session_autoload = "no"
let g:session_autosave = "yes"
let g:session_command_aliases = 1


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

let g:CSApprox_loaded = 1

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
let g:airline_theme = 'angr'
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

if !exists('g:airline_powerline_fonts')
  let g:airline#extensions#tabline#left_sep = ' '
  let g:airline#extensions#tabline#left_alt_sep = '|'
  let g:airline_left_sep          = '▶'
  let g:airline_left_alt_sep      = '»'
  let g:airline_right_sep         = '◀'
  let g:airline_right_alt_sep     = '«'
  let g:airline#extensions#branch#prefix     = '⤴' "➔, ➥, ⎇
  let g:airline#extensions#readonly#symbol   = '⊘'
  let g:airline#extensions#linecolumn#prefix = '¶'
  let g:airline#extensions#paste#symbol      = 'ρ'
  let g:airline_symbols.linenr    = '␊'
  let g:airline_symbols.branch    = '⎇'
  let g:airline_symbols.paste     = 'ρ'
  let g:airline_symbols.paste     = 'Þ'
  let g:airline_symbols.paste     = '∥'
  let g:airline_symbols.whitespace = 'Ξ'
else
  let g:airline#extensions#tabline#left_sep = ''
  let g:airline#extensions#tabline#left_alt_sep = ''

  " powerline symbols
  let g:airline_left_sep = ''
  let g:airline_left_alt_sep = ''
  let g:airline_right_sep = ''
  let g:airline_right_alt_sep = ''
  let g:airline_symbols.branch = ''
  let g:airline_symbols.readonly = ''
  let g:airline_symbols.linenr = ''
endif


" Abbreviations
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev E e
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall
cnoreabbrev X x
cnoreabbrev stu sort u
cnoreabbrev Stu sort u
cnoreabbrev Set set
cnoreabbrev Bd bd
abbr lmbd λ
abbr frll ∀
abbr midfing 🖕

" NERDTree
let g:NERDTreeChDirMode=2
let g:NERDTreeIgnore=['\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks=1
let g:nerdtree_tabs_focus_on_files=1
let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:NERDTreeWinSize = 50
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite
set wildignore+=*.o,*.obj,.git,*.rbc,__pycache__,node_modules/**,bower_components/**
set wildignore+=solr/**,log/**,*.psd,*.PSD,.git/**,.gitkeep,.gems/**
set wildignore+=*.ico,*.ICO,backup/**,*.sql,*.dump,*.tmp,*.min.js,Gemfile.lock
set wildignore+=*.png,*.PNG,*.JPG,*.jpg,*.JPEG,*.jpeg,*.GIF,*.gif,*.pdf,*.PDF
set wildignore+=vendor/**,coverage/**,tmp/**,rdoc/**,*.BACKUP.*,*.BASE.*,*.LOCAL.*,*.REMOTE.*,.sass-cache/**

" nnoremap <silent> <F2> :NERDTreeFind<CR>
noremap <F3> :NERDTreeToggle<CR>

" grep.vim
nnoremap <silent> <leader>f :Rgrep<CR>
let Grep_Default_Options = '-IR'
let Grep_Skip_Files = '*.log *.db'
let Grep_Skip_Dirs = '.git node_modules'

if has("nvim")
  " Make escape work in the Neovim terminal.
  tnoremap <Esc> <C-\><C-n>

  " Make navigation into and out of Neovim terminal splits nicer.
  tnoremap <C-h> <C-\><C-N><C-w>h
  tnoremap <C-j> <C-\><C-N><C-w>j
  tnoremap <C-k> <C-\><C-N><C-w>k
  tnoremap <C-l> <C-\><C-N><C-w>l

  " I like relative numbering when in normal mode.
  autocmd TermOpen * setlocal conceallevel=0 colorcolumn=0 relativenumber

  " Prefer Neovim terminal insert mode to normal mode.
  autocmd BufEnter term://* startinsert
endif

"" Functions
if !exists('*s:setupWrapping')
  function s:setupWrapping()
    set wrap
    set wm=2
    set textwidth=79
  endfunction
endif


"" Autocmd Rules

" The PC is fast enough, do syntax highlight syncing from start
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


"" Mappings

" Split
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

" Git
noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Gcommit<CR>
noremap <Leader>gsh :Gpush<CR>
noremap <Leader>gll :Gpull<CR>
noremap <Leader>gs :Gstatus<CR>
noremap <Leader>gb :Gblame<CR>
noremap <Leader>gd :Gvdiff<CR>
noremap <Leader>gr :Gremove<CR>

" session management
nnoremap <leader>so :OpenSession
nnoremap <leader>ss :SaveSession
nnoremap <leader>sd :DeleteSession<CR>
nnoremap <leader>sc :CloseSession<CR>

" Tabs
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <silent> <S-t> :tabnew<CR>

" Set working directory
nnoremap <leader>. :lcd %:p:h<CR>

" Opens an edit command with the path of the currently edited file filled in
noremap <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Opens a tab edit command with the path of the currently edited file filled
noremap <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

" shows current hi group
map ,hi :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">" . " FG:" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"fg#")<CR>

" ctrlp.vim
set wildmode=list:longest,list:full
let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist)|(\.(swp|tox|ico|git|hg|svn))$'
let g:ctrlp_user_command = "find %s -type f | grep -Ev '"+ g:ctrlp_custom_ignore +"'"
let g:ctrlp_use_caching = 0
cnoremap <C-P> <C-R>=expand("%:p:h") . "/" <CR>
noremap <leader>b :CtrlPBuffer<CR>
let g:ctrlp_map = '<leader>e'
let g:ctrlp_open_new_file = 'r'

" Disable visualbell
set noeb vb t_vb=

"" system clipboard
set clipboard^=unnamed,unnamedplus

noremap YY "+y<CR>
noremap P "+gP<CR>
noremap XX "+x<CR>

" Buffer nav
noremap <leader>z :bp<CR>
noremap <leader>x :bn<CR>

" Close buffer
noremap <leader>c :bd<CR>

" Clean search (highlight)
nnoremap <silent> <leader><space> :noh<cr>

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

" Open current line on GitHub
noremap ,o :!echo `git url`/blob/`git rev-parse --abbrev-ref HEAD`/%\#L<C-R>=line('.')<CR> \| xargs open<CR><CR>


"" Custom configs

" vim-python
augroup vimrc-python
  autocmd!
  autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=8 colorcolumn=79
      \ formatoptions+=croq softtabstop=4 smartindent
      \ cinwords=if,elif,else,for,while,try,except,finally,def,class,with
augroup END

" syntastic
let g:syntastic_always_populate_loc_list=1
let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'
let g:syntastic_style_error_symbol = '✗'
let g:syntastic_style_warning_symbol = '⚠'
let g:syntastic_auto_loc_list=1
let g:syntastic_aggregate_errors = 1
" py
let g:syntastic_python_checkers=['python', 'flake8']
let g:syntastic_python_flake8_post_args='--ignore=W391'
" js
let g:syntastic_javascript_jshint_generic = 1
let g:syntastic_javascript_checkers = ['eslint']
" sh
let g:syntastic_sh_checkers = ['sh']
" hs
let g:syntastic_haskell_checkers = ['hlint']

let g:syntastic_disabled_checkers = ['html']

" vim-airline
let g:airline#extensions#virtualenv#enabled = 1

let g:javascript_enable_domhtmlcss = 1

inoremap <Esc> <Esc>`^

autocmd User Node
  \ if &filetype == "javascript" |
  \   nmap <buffer> <C-w>f <Plug>NodeVSplitGotoFile |
  \   nmap <buffer> <C-w><C-f> <Plug>NodeVSplitGotoFile |
  \ endif

cnoremap sudow w !sudo tee & >/dev/null

colo angr

" keeping rainbow parens on
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

let g:netrw_gx="<cWORD>"

let g:SuperTabDefaultCompletionType = "<c-n>"

" greplace
let g:grep_cmd_opts = '--line-numbers --noheading'
set grepprg=ag

let g:vimfiler_as_default_explorer = 1

" commit message thing
autocmd Filetype gitcommit setlocal spell textwidth=80

" clear screen between shell commands
nnoremap :! :!clear;
vnoremap :! :!clear;

" man = doc = help
nnoremap :man :help
vnoremap :man :help
nnoremap :doc :help
vnoremap :doc :help

" yank whole file
nnoremap :yal :%y+
vnoremap :yal :%y+

" fucking windows
vnoremap <leader>nl :%s///g
nnoremap <leader>nl :%s///g

noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" insert current line number in normal mode with f1
nnoremap <F1> :execute "normal! i" . ( line(".") )<cr>
nnoremap <F2> :execute "normal! i console.log(" . ( line(".") ) . ")"<cr>

" keep Y consistent
nnoremap Y y$

" buftabs
let g:buftabs_enabled = 1
let g:buftabs_in_statusline = 1
let g:buftabs_in_cmdline = 0
let g:buftabs_only_basename = 1
let g:buftabs_active_highlight_group = "Visual"
let g:buftabs_inactive_highlight_group = ""
let g:buftabs_statusline_highlight_group = ""
let g:buftabs_marker_start = "["
let g:buftabs_marker_end = "]"
let g:buftabs_separator = "-"
let g:buftabs_marker_modified = "!"
nnoremap <C-left> :bprev<CR>
nnoremap <C-right> :bnext<CR>

" vim-markdown
let g:vim_markdown_conceal = 0
let g:vim_markdown_fenced_languages = [
      \'bash=Shell',
      \'console=Shell',
      \'css=CSS',
      \'html=HTML',
      \'javascript=JavaScript',
      \'js=JavaScript',
      \'jsx=JSX',
      \'less=CSS',
      \'sass=CSS',
      \'scss=CSS',
      \'sh=Shell'
      \]
let g:vim_markdown_new_list_item_indent = 2
let g:vim_markdown_folding_disabled = 1

let g:context_filetype#same_filetypes = '_'

" vim-gitgutter
let g:gitgutter_max_signs = 700

" let g:jsx_ext_required = 0
let g:neomake_javascript_enabled_makers = ['eslint']

function! SortLines() range
  execute a:firstline . "," . a:lastline . 's/^\(.*\)$/\=strdisplaywidth( submatch(0) ) . " " . submatch(0)/'
  execute a:firstline . "," . a:lastline . 'sort n'
  execute a:firstline . "," . a:lastline . 's/^\d\+\s//'
endfunction

" because of docker + mac + webpack (or whatever)...
let g:backupcopy = 'yes'

" flow
let g:flow#enable = 0
" let g:javascript_plugin_flow = 1

let g:csstoinline_wrap_pixels = 1

if !exists('g:loaded_matchit')
  runtime macros/matchit.vim
endif

" better ctrl-l
nnoremap <leader>l :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>

" edit macros
nnoremap <leader>m  :<c-u><c-r><c-r>='let @'. v:register .' = '. string(getreg(v:register))<cr><c-f><left>

" show tabs
set list lcs=tab:\|\

" typescript
let g:tsuquyomi_disable_quickfix = 1
let g:syntastic_typescript_checkers = ['tsuquyomi']

" break line on words
set linebreak

" fix where new splits show up
set splitbelow
set splitright

" relative dirs
set autochdir

" just trying this out...
autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber

let g:paredit_mode=0
let g:paredit_leader="\<Space>"

let g:parinfer_mode="off"

" use <F8> to go to next conflict marker
map <silent> <F8> /^\(<\{7\}\\|>\{7\}\\|=\{7\}\\|\|\{7\}\)\( \\|$\)<cr>

" command! UnMinify call UnMinify()
function! UnMinify()
    normal mj
    %s/{\ze[^\r\n]/{\r/ge
    " %s/){/) {/ge
    %s/};\?\ze[^\r\n]/\0\r/ge
    %s/;\ze[^\r\n]/;\r/ge
    " %s/[^\s]\zs[=&|]\+\ze[^\s]/ \0 /ge
    normal ggVG=`j
endfunction

" close nerdtree on file open
let NERDTreeQuitOnOpen=1

let g:tern_map_keys=1
let g:tern_show_argument_hints='on_hold'

let g:rooter_manual_only=1
