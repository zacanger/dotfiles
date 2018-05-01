" minimal vim config for working on remote machines, in containers, etc.
" apk update && apk add vim
" curl -sL https://raw.githubusercontent.com/zacanger/z/master/.vimrc > ~/.vimrc

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
