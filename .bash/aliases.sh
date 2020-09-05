# shellcheck shell=bash

# kill everything
alias killx='sudo pkill -9 Xorg'
alias ka='killall'

# managing .bashrc & .bash_aliases
alias edrc='nvim ~/.bashrc'
alias edal='nvim ~/.bash/aliases.sh'
alias reload='source ~/.bashrc'

# git; see gitconfig for more
alias gfa='git fetch --all'
alias gdi='git diff'
alias gcl='git clone'
alias grv='git remote -v'
alias branches='git all-branches'
alias rpo='git rpo'
alias gg='git g'
alias gco='git checkout'
alias gw='ghwd.sh'
alias gst='git st'
alias gitodo='git grep -EiI "FIXME|TODO"'
alias aca='ac a'
alias gp='git push'
alias gpft='git push origin master --follow-tags'

# development
alias np='npm publish'
alias ni='npm i'
alias niaf='npm i && npm audit fix'
alias ns='npm start -s'
alias ng='npm install -g'
alias nid='npm install --save-dev'
alias npmv='npm version'
alias nr='npm run -s'
alias nt='npm test'
alias nb='npm run -s build'
alias niy='npm init -y'
alias lint='npm run -s test:lint'
alias jv='jq .version < package.json'
alias pipupd='cat ~/Dropbox/z/misc/pip.list | xargs sudo pip3 install -U'
alias venv='virtualenv -p /usr/bin/python3 venv'
alias nu='npm i -g n && n latest && n prune && npm i -g npm npm-check-updates'
alias npmupd='cat ~/Dropbox/z/misc/npm.list | xargs npm i -g'
alias ghc='stack ghc'
alias ghci='stack ghci'
alias python='python3' # until they get around to updating...

# navigation
alias d='cd'
alias Cd='cd'
alias CD='cd'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ,,='..'
alias ,,,='...'
alias ,,,,='....'
alias cs='cd $OLDPWD'
alias ..a='.. && a'

# safety, etc.
# gh:sindresorhus/trash,empty-trash
alias rm='trash'
alias erm='empty-trash'
alias mv='mv -iv'
alias cp='cp -iv'
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# ls things
alias ls='ls -F --color=auto --group-directories-first'
alias lS='ls -lSh'
alias k='ls'
alias l='ls -oshS'
alias a='ls -A'
alias f='k -1'
alias lt='ls -ltrh'

# dropbox
alias dbup="dropbox start"
alias dbdn="dropbox stop"
alias dbst="dropbox status"
alias dbls="dropbox filestatus ~/Dropbox/*"
alias dbfs="dropbox filestatus"

# this requires sox, and is for DADGAD. change to E2-E4 (etc) for standard.
alias tuner='for n in D2 A2 D3 G3 A3 D4;do play -n synth 4 pluck $n repeat 3;done'

# nvim
alias v='nvim'
alias ex='nvim'
alias vi='nvim'
alias iv='nvim'
alias vim='nvim'
alias vv='nvim ~/.config/nvim/init.vim'

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
fi

# all the rest
alias py='bpython'
alias q='exit'
alias ag='ag --path-to-ignore ~/.agignore'
alias c='clear'
alias cx='chmod +x'
alias ds='dirsize.sh'
alias fontlist='fc-list | cut -d : -f 2 | sort -u | uniq'
alias fs='ranger'
alias h='history'
alias less='less -m -N -g -i -J --line-numbers --underline-special'
alias makelist="make -rpn | sed -n -e '/^$/ { n ; /^[^ .#][^ ]*:/p ; }' | egrep --color '^[^ ]*:'"
alias md='mkdir -p -v'
alias names='names.sh'
alias randomchars='dd if=/dev/urandom count=1 2> /dev/null | uuencode -m - | sed -ne 2p | cut -c-16'
alias screencast='ffmpeg -f x11grab -s wxga -r 25 -i :0.0 -sameq ~/.tmp/screencast.mpg'
alias sw='time cat'
alias vn='viewnior'
alias yt2mp3='youtube-dl --extract-audio --audio-format mp3'
alias ytpls='youtube-dl --extract-audio --audio-format mp3 -o "%(playlist_index)s-%(title)s.%(ext)s"'
alias shrug='echo "¯\_(ツ)_/¯" | co'
alias todo='nvim ~/Dropbox/work/wip/todo.md'
alias am='alsamixer'
alias checkip='curl http://checkip.amazonaws.com/'
alias alltlds="curl -s http://data.iana.org/TLD/tlds-alpha-by-domain.txt | sed -e 1d -e 's/\(.*\)/\L\1/'"
alias ur='unrar x -kb'
alias cerm='c ; erm'
alias fx='find . -maxdepth 2 -type d -name x'
alias fnm='find . -type d -name node_modules'
alias acd='a ; cd'
alias findlonglines="grep '.\{120\}' -r"
alias no='yes n'
alias shhh='lock.sh'
alias cla='clc ; cerm'
alias cpr='cp -R'
alias tn='tmux new'
alias twa='docker run --rm -t trailofbits/twa'
alias lv='luvi'
alias shellcheck='shellcheck --shell=bash'
