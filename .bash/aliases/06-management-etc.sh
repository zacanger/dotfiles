# shellcheck shell=bash

# kill everything
alias killx='sudo pkill -9 Xorg'
alias ka='killall'

# managing .bashrc & .bash_aliases
alias edrc='nvim ~/.bashrc'
alias edal='nvim ~/.bash/aliases'
alias reload='source ~/.bashrc'

# clipboard
if [[ $(uname) == 'Darwin' ]]; then
  alias co='pbcopy'
  alias pa='pbpaste'
  alias clc='echo -n | co'
else
  alias co='xclip -selection clipboard'
  alias pa='xclip -selection clipboard -o'
  alias clc='echo -n | co && echo -n | xclip -selection primary'
fi

# don't break cat if no bat
if hash bat 2>/dev/null; then
  alias cat='bat'
elif hash batcat 2>/dev/null; then
  alias cat='batcat'
fi

# use ag if installed
if hash ag 2>/dev/null; then
  alias grep='ag'
else
  alias grep='grep --color=auto'
fi

# more mac stuff
if [[ $(uname) == 'Darwin' ]]; then
  alias file='file -h'
  if hash gfind 2>/dev/null; then
    alias find='gfind'
  fi
fi
