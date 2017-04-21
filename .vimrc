" This is a SUPER minimal vim config.
" I use this when on a server, inside a container, breaking stuff, or whatever.
" I'm okay just using `vi` but sometimes I really miss things like `v`
" apk update && apk add vim
" curl (this file's raw github url) to ~/.vimrc
" I use nvim on my computers. See .config/nvim/init.vim for the real vimrc.

set nu
syntax enable
set shiftwidth=2
set expandtab
set tabstop=2
set nobackup
set nowritebackup
set noswapfile
autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber
