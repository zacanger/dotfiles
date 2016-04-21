" zacanger's init.vim
" for nvim | neovim.io
" using neobundle | gh:Shougo/neobundle.vim

" this is not all that clean. if anyone wants to go ahead
" and clean things up, please feel free. i'm still kinda
" getting used to managing vim configs in a reasonable manner.

" neobundle stuff
if has('vim_starting')
  set nocompatible               " Be iMproved

  " Required:
  set runtimepath+=~/.config/nvim/bundle/neobundle.vim/
endif

let neobundle_readme=expand('~/.config/nvim/bundle/neobundle.vim/README.md')

let g:vim_bootstrap_langs = "javascript,python,html"
let g:vim_bootstrap_editor = "nvim"				" nvim or vim

if !filereadable(neobundle_readme)
  echo "Installing NeoBundle..."
  echo ""
  silent !mkdir -p ~/.config/nvim/bundle
  silent !git clone https://github.com/Shougo/neobundle.vim ~/.config/nvim/bundle/neobundle.vim/
  let g:not_finsh_neobundle = "yes"

  " Run shell script if exist on custom select language

endif

" Required:
call neobundle#begin(expand('~/.config/nvim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

"" NeoBundle install packages
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'tpope/vim-commentary'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'ctrlpvim/ctrlp.vim'
NeoBundle 'bling/vim-airline'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'sheerun/vim-polyglot'
NeoBundle 'vim-scripts/grep.vim'
NeoBundle 'vim-scripts/CSApprox'
NeoBundle 'bronson/vim-trailing-whitespace'
NeoBundle 'jiangmiao/auto-pairs'
NeoBundle 'Shougo/vimproc.vim', {
      \ 'build' : {
      \     'windows' : 'tools\\update-dll-mingw',
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak',
      \    },
      \ }

"" Vim-Session
NeoBundle 'xolox/vim-misc'
NeoBundle 'xolox/vim-session'

"" Snippets
NeoBundle 'honza/vim-snippets'

"" Color
if v:version >= 703
  NeoBundle 'Shougo/vimshell.vim'
endif

if v:version >= 704
  NeoBundle 'FelikZ/ctrlp-py-matcher'
endif

NeoBundle "scrooloose/syntastic"
NeoBundle 'vim-scripts/c.vim'

"" Python
NeoBundle "davidhalter/jedi-vim"
NeoBundle "majutsushi/tagbar"
NeoBundle "Yggdroot/indentLine"

NeoBundle 'vim-perl/vim-perl'
NeoBundle 'c9s/perlomni.vim'

"" HTML
NeoBundle 'amirh/HTML-AutoCloseTag'
NeoBundle 'hail2u/vim-css3-syntax'
NeoBundle 'gorodinskiy/vim-coloresque'
NeoBundle 'tpope/vim-haml'
NeoBundle 'mattn/emmet-vim'

"" PHP
NeoBundle 'arnaud-lb/vim-php-namespace'

"" Extra Bundles

call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck


"" Basic Setup

"" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8

"" Fix backspace indent
set backspace=indent,eol,start

"" Tabs. May be overriten by autocmd rules
set tabstop=2
set softtabstop=0
set shiftwidth=2
set expandtab
set smartindent
set smarttab
set autoindent

"" Map leader to ,
let mapleader="\<Space>"

"" Enable hidden buffers
set hidden

"" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

"" Encoding
set bomb
set binary

"" Directories for swp files
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
if !exists('g:not_finsh_neobundle')
  colorscheme janah
endif

set mousemodel=popup
set t_Co=256
set cursorline
set guioptions=egmrti
set gfn=Monospace\ 10

if has("gui_running")
  if has("gui_mac") || has("gui_macvim")
    set guifont=Menlo:h12
    set transparency=7
  endif
else
  let g:CSApprox_loaded = 1

  if $COLORTERM == 'gnome-terminal'
    set term=gnome-256color
  endif
endif

if &term =~ '256color'
  set t_ut=256
endif

"" Disable the blinking cursor.
set gcr=a:blinkon0
set scrolloff=3

"" Map cursor for insert mode
if &term =~ "xterm\\|rxvt"
  let &t_SI .= "\<Esc>[5 q"
  let &t_EI .= "\<Esc>[0 q"
endif

"" Status bar
set laststatus=2

"" Use modeline overrides
set modeline
set modelines=10

set title
set titleold="Terminal"
set titlestring=%F

set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\

if exists("*fugitive#statusline")
  set statusline+=%{fugitive#statusline()}
endif

" vim-airline
let g:airline_theme = 'bubblegum'
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

" NERDTree
let g:NERDTreeChDirMode=2
let g:NERDTreeIgnore=['\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks=1
let g:nerdtree_tabs_focus_on_files=1
let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:NERDTreeWinSize = 50
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite
nnoremap <silent> <F2> :NERDTreeFind<CR>
noremap <F3> :NERDTreeToggle<CR>

" grep.vim
nnoremap <silent> <leader>f :Rgrep<CR>
let Grep_Default_Options = '-IR'
let Grep_Skip_Files = '*.log *.db'
let Grep_Skip_Dirs = '.git node_modules'

" vimshell.vim
let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
let g:vimshell_prompt =  '$ '

" terminal emulation
if g:vim_bootstrap_editor == 'nvim'
  nnoremap <silent> <leader>sh :terminal<CR>
else
  nnoremap <silent> <leader>sh :VimShellCreate<CR>
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

"" The PC is fast enough, do syntax highlight syncing from start
augroup vimrc-sync-fromstart
  autocmd!
  autocmd BufEnter * :syntax sync fromstart
augroup END

"" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

"" txt
augroup vimrc-wrapping
  autocmd!
  autocmd BufRead,BufNewFile *.txt call s:setupWrapping()
augroup END

"" make/cmake
augroup vimrc-make-cmake
  autocmd!
  autocmd FileType make setlocal noexpandtab
  autocmd BufNewFile,BufRead CMakeLists.txt setlocal filetype=cmake
augroup END

au BufRead,BufNewFile *.md setlocal textwidth=120

autocmd FileType css set omnifunc=csscomplete#CompleteCSS noci

set autoread


"" Mappings

"" Split
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

"" Git
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

"" Tabs
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <silent> <S-t> :tabnew<CR>

"" Set working directory
nnoremap <leader>. :lcd %:p:h<CR>

"" Opens an edit command with the path of the currently edited file filled in
noremap <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

"" Opens a tab edit command with the path of the currently edited file filled
noremap <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

"" ctrlp.vim
set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,*.rbc,*.pyc,__pycache__
let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist)|(\.(swp|tox|ico|git|hg|svn))$'
let g:ctrlp_user_command = "find %s -type f | grep -Ev '"+ g:ctrlp_custom_ignore +"'"
let g:ctrlp_use_caching = 0
cnoremap <C-P> <C-R>=expand("%:p:h") . "/" <CR>
noremap <leader>b :CtrlPBuffer<CR>
let g:ctrlp_map = '<leader>e'
let g:ctrlp_open_new_file = 'r'

" Disable visualbell
set noeb vb t_vb=
" set visualbell t_vb=

"" Copy/Paste/Cut
" if has('unnamedplus')
"   set clipboard=unnamed,unnamedplus
" endif
set clipboard^=unnamed,unnamedplus

noremap YY "+y<CR>
noremap P "+gP<CR>
noremap XX "+x<CR>

"" Buffer nav
noremap <leader>z :bp<CR>
noremap <leader>x :bn<CR>

"" Close buffer
noremap <leader>c :bd<CR>

"" Clean search (highlight)
nnoremap <silent> <leader><space> :noh<cr>

"" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

"" Vmap for maintain Visual Mode after shifting > and <
vmap < <gv
vmap > >gv

"" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

"" Open current line on GitHub
noremap ,o :!echo `git url`/blob/`git rev-parse --abbrev-ref HEAD`/%\#L<C-R>=line('.')<CR> \| xargs open<CR><CR>


"" Custom configs

" Tagbar
nmap <silent> <F4> :TagbarToggle<CR>
let g:tagbar_autofocus = 1

" vim-python
augroup vimrc-python
  autocmd!
  autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=8 colorcolumn=79
      \ formatoptions+=croq softtabstop=4 smartindent
      \ cinwords=if,elif,else,for,while,try,except,finally,def,class,with
augroup END

" jedi-vim
let g:jedi#auto_initialization = 0
let g:jedi#popup_on_dot = 0
let g:jedi#goto_assignments_command = "<leader>g"
let g:jedi#goto_definitions_command = "<leader>d"
let g:jedi#documentation_command = "K"
let g:jedi#usages_command = "<leader>n"
let g:jedi#rename_command = "<leader>r"
let g:jedi#show_call_signatures = "0"
let g:jedi#completions_command = "<C-Space>"

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
let g:syntastic_javascript_checkers = ['jshint']
" sh
let g:syntastic_sh_checkers = ['sh']
" hs
let g:syntastic_haskell_checkers = ['hlint']
" html
let g:syntastic_html_checkers = ['w3']

" vim-airline
let g:airline#extensions#virtualenv#enabled = 1
let g:airline#extensions#tagbar#enabled = 1

" Tagbar
nmap <silent> <F4> :TagbarToggle<CR>
let g:tagbar_autofocus = 1

let g:javascript_enable_domhtmlcss = 1

"" tryna get ranger to work... still no luck with this.
"" anyone know what's up?
"
" Compatible with ranger 1.4.2 through 1.7.*
"
" Add ranger as a file chooser in vim
"
" If you add this code to the .vimrc, ranger can be started using the command
" ":RangerChooser" or the keybinding "<leader>r".  Once you select one or more
" files, press enter and ranger will quit again and vim will open the selected
" files.
"
" function! RangeChooser()
"     let temp = tempname()
    " The option "--choosefiles" was added in ranger 1.5.1. Use the next line
    " with ranger 1.4.2 through 1.5.0 instead.
    "exec 'silent !ranger --choosefile=' . shellescape(temp)
"     if has("gui_running")
"         exec 'silent !xterm -e ranger --choosefiles=' . shellescape(temp)
"     else
"         exec 'silent !ranger --choosefiles=' . shellescape(temp)
"     endif
"     if !filereadable(temp)
"         redraw!
        " Nothing to read.
"         return
"     endif
"     let names = readfile(temp)
"     if empty(names)
"         redraw!
        " Nothing to open.
"         return
"     endif
    " Edit the first item.
"     exec 'edit ' . fnameescape(names[0])
    " Add any remaning items to the arg list/buffer list.
"     for name in names[1:]
"         exec 'argadd ' . fnameescape(name)
"     endfor
"     redraw!
" endfunction
" command! -bar RangerChooser call RangeChooser()
" nnoremap <leader>r :<C-U>RangerChooser<CR>

inoremap <Esc> <Esc>`^

autocmd User Node
  \ if &filetype == "javascript" |
  \   nmap <buffer> <C-w>f <Plug>NodeVSplitGotoFile |
  \   nmap <buffer> <C-w><C-f> <Plug>NodeVSplitGotoFile |
  \ endif


" xfce4-terminal
" if has("autocmd")
  " au InsertEnter * silent execute "!sed -i.bak -e 's/TERMINAL_CURSOR_SHAPE_BLOCK/TERMINAL_CURSOR_SHAPE_UNDERLINE/' ~/.config/xfce4/terminal/terminalrc"
  " au InsertLeave * silent execute "!sed -i.bak -e 's/TERMINAL_CURSOR_SHAPE_UNDERLINE/TERMINAL_CURSOR_SHAPE_BLOCK/' ~/.config/xfce4/terminal/terminalrc"
  " au VimLeave * silent execute "!sed -i.bak -e 's/TERMINAL_CURSOR_SHAPE_UNDERLINE/TERMINAL_CURSOR_SHAPE_BLOCK/' ~/.config/xfce4/terminal/terminalrc"
" endif

" general vte-compat terms
" let &t_SI = "\<Esc>[6 q"
" let &t_SR = "\<Esc>[4 q"
" let &t_EI = "\<Esc>[2 q"

cnoremap sudow w !sudo tee & >/dev/null

" theme nonsense
" autocmd ColorScheme janah highlight Normal ctermbg=235
colorscheme ego

" keeping rainbow parens on
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

" let g:netrw_nogx = 1
" nmap gx <Plug>(openbrowser-open)
" vmap gx <Plug>(openbrowser-open)
" nnoremap gx <Plug>(openbrowser-smart-search)
" vnoremap gx <Plug>(openbrowser-smart-search)

let g:SuperTabDefaultCompletionType = "<c-n>"

" greplace
let g:grep_cmd_opts = '--line-numbers --noheading'
set grepprg=ag

let g:vimfiler_as_default_explorer = 1

" commit message thing
autocmd Filetype gitcommit setlocal spell textwidth=80

" jsfmt on save
" let g:js_fmt_autosave = 1

" esformatter!
" nnoremap <silent> <leader>es :Esformatter<CR>
" vnoremap <silent> <leader>es :Esformatter<CR>

" clear screen between shell commands
nnoremap :! :!clear;
vnoremap :! :!clear;

" man = doc = help
nnoremap :man :help
vnoremap :man :help
nnoremap :doc :help
vnoremap :doc :help

" posero (presentations n shiz)
" let g:posero_default_mappings = 1

" semantic highlighting stuff
:nnoremap <Leader>s :SemanticHighlightToggle<cr>
" let g:semanticEnableFileTypes = ['javascript', 'css', 'vue', 'node', 'python', 'ruby', 'es6', 'jsx', 'react', 'jquery', 'angular', 'underscore', 'coffeescript', 'elm', 'clojure', 'clojurescript', 'json', 'c']
let g:semanticGUIColors = [ '#72d572', '#c5e1a5', '#e6ee9c', '#fff59d', '#ffe082', '#ffcc80', '#ffab91', '#e3d3ce', '#b0bec5', '#ffa726', '#ff8a65', '#f9bdbb', '#f9bdbb', '#f8bbd0', '#e1bee7', '#d1c4e9', '#ffe0b2', '#f9eddb', '#d0d9ff', '#b3e5fc', '#b2ebf2', '#b2dfdb', '#a3e9a4', '#dcedc8' , '#dff6c9', '#ffb74d' ]


" goddamned meta keys...
vnoremap <leader>nl :%s///g
nnoremap <leader>nl :%s///g
" :%s/\r$/g
" :%s/\r$//g

" peepopen, quit on vim exit
" let g:peepopen_quit = 1

nnoremap j gj
nnoremap k gk

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
let g:vim_markdown_fenced_languages = ['javascript=js', 'html=html', 'css=css', 'jsx=jsx', 'sass=css', 'less=css', 'scss=css', 'sh=sh', 'bash=sh']
let g:vim_markdown_new_list_item_indent = 2
let g:vim_markdown_folding_disabled = 1

" deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#max_list = 20
let g:deoplete#auto_complete_delay = 10
let g:deoplete#enable_smart_case = 1

" let g:context_filetype#same_filetypes = ['js,jsx,json', 'css,sass,scss,less,styl', 'html', 'ejs', 'jade']
let g:context_filetype#same_filetypes = '_'

" vim-gitgutter
" let g:gitgutter_max_signs = 200

" another two attempts at working with ranger....
" function RangerExplorer()
"     exec "silent !ranger --choosefile=/tmp/vim_ranger_current_file " . expand("%:p:h")
"     if filereadable('/tmp/vim_ranger_current_file')
"         exec 'edit ' . system('cat /tmp/vim_ranger_current_file')
"         call system('rm /tmp/vim_ranger_current_file')
"     endif
"     redraw!
" endfun
" map <Leader>x :call RangerExplorer()<CR>

" function! s:ChooseFile(dir_path)
"     let tmp_file = tempname()
"     let path = s:AbsolutePath(a:dir_path)
"
"     silent exec join(['!ranger', path, '--choosefile=' . tmp_file], ' ')
"     redraw!
"
"     let result = 0
"     if filereadable(tmp_file)
"         silent let result = system('cat '. tmp_file)
"     endif
"     silent call system('rm -rf ' . tmp_file)
"     return result
" endfunction

