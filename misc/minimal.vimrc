" bare minimum vimrc, for working in containers,
" scp-ing up to servers, etc.
" there's no need for set nocompatible anymore

" turn on highlighting
syntax on

" make backspace actually work
set backspace=indent,eol,start

" turn on language detection and indentation
filetype plugin indent on

" use unsaved buffers
set hidden

" command-line mode completion
set wildmenu

" show partial commands
set showcmd

" highlight searches
set hlsearch

" incremental searching
set incsearch

" better searching
set ignorecase
set smartcase

" auto indent on o and O
set autoindent

" turn on line numbers
set nu

" do indentation the way i like it
set shiftwidth=2
set softtabstop=2
set expandtab
set tabstop=2

" map Y to work like D and C
map Y y$

" map leader to space
let mapleader="\<Space>"

" get rid of those ~ files
set nobackup

" get rid of .swp files
set noswapfile
