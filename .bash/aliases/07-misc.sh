# shellcheck shell=bash

if hash ranger 2>/dev/null; then
    alias fs='ranger'
else
    alias fs='fs.sh'
fi
alias q='exit'
alias ag='ag --path-to-ignore ~/.agignore'
alias c='clear'
alias cx='chmod +x'
alias ds='dirsize.sh'
alias h='history'
alias less='less -m -N -g -i -J --line-numbers --underline-special'
alias md='mkdir -p -v'
alias names='names.sh'
alias sw='time cat'
alias youtube-dl='yt-dlp'
alias yt2mp3='youtube-dl --extract-audio --audio-format mp3'
alias ytpls='youtube-dl --extract-audio --audio-format mp3 -o "%(playlist_index)s-%(title)s.%(ext)s"'
alias ur='unrar x -kb'
alias cerm='c ; erm'
alias fnm='find . -type d -name node_modules'
alias findlonglines="grep '.\{80\}' -r"
alias no='yes n'
alias cpr='cp -R'
alias tn='tmux new'

alias cla='clc; cerm; tmux clearhist'
if ! hash tmux 2>/dev/null; then
    alias cla='clc; cerm'
fi

if [ -f "$HOME/Dropbox/todo/todo.md" ]; then
    alias todo="vim $HOME/Dropbox/todo/todo.md"
fi
