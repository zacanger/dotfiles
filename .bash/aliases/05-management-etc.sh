# shellcheck shell=bash

# kill everything
alias ka='killall'

# managing bash config
alias edrc="$EDITOR ~/.bashrc"
alias reload='_sourceif ~/.bashrc'

# clipboard
if [[ $(uname) == 'Darwin' ]]; then
    alias co='pbcopy'
    alias pa='pbpaste'
    alias clc='echo -n | co'
fi

# don't break cat if no bat
if hash bat 2>/dev/null; then
    alias cat='bat'
fi

# TODO: fix this, it's conflicting with bash_completion all of a sudden
# use ag if installed
# if hash ag 2>/dev/null; then
    # alias grep='ag'
# else
    alias grep='grep --color=auto'
# fi

if [[ $(uname) == 'Darwin' ]]; then
    alias file='file -h'
    if hash gfind 2>/dev/null; then
        alias find='gfind'
    fi
    if hash gsed 2>/dev/null; then
        alias sed='gsed'
    fi
    if hash gmake 2>/dev/null; then
        alias make='gmake'
    fi
    alias poweroff='sudo shutdown -h now'
fi
