# kill everything
alias killx='sudo pkill -9 Xorg'
alias ka='killall'

# managing .bashrc & .bash_aliases
alias edrc='nvim ~/.bashrc'
alias edal='nvim ~/.bash/aliases.sh'
alias reload='source ~/.bashrc'

# git; see gitconfig for more
alias gfa='git fetch --all'
alias gd='git diff'
alias gc='git clone'
alias grv='git remote -v'
alias branches='git branches'
alias rpo='git rpo'
alias gg='git g'
alias gco='git checkout'
alias gw='ghwd.sh'
alias gtd='gittoday'
alias gst='git st'
alias gitodo='git grep -EiI "FIXME|TODO"'
alias rbl='git rebase -i HEAD~2'
alias aca='ac a'
alias gp='git push'

# development package managers
alias np='npm publish'
alias ni='npm i'
alias ns='npm start -s'
alias ng='npm install -g'
alias nid='npm install --save-dev'
alias nr='npm run -s'
alias nt='npm test'
alias nb='npm run -s build'
alias niy='npm init -y'
alias lint='npm run -s test:lint'
alias jv='jq .version < package.json'
alias pipupd='pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U'
alias brewupd='brew update && brew upgrade && brew cleanup && brew prune && brew doctor'
alias venv='virtualenv -p /usr/bin/python3'
alias lfd='lein figwheel dev'

# navigation
alias d='cd'
alias Cd='cd'
alias CD='cd'
alias cd..='cd ..'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ,,='..'
alias ,,,='...'
alias ,,,,='....'
alias cs='cd $OLDPWD'
alias ..a='.. && a'
alias ...a='... && a'

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
alias la='ls -A'
alias a='ls -A'
alias f='k -1'
alias lt='ls -lt'

# dropbox
if [[ `uname -a` == *"Arch"* ]]; then
  dropbox_cmd=dropbox-cli
else
  dropbox_cmd=dropbox
fi
alias dbup="$dropbox_cmd start"
alias dbdn="$dropbox_cmd stop"
alias dbst="$dropbox_cmd status"
alias dbls="$dropbox_cmd filestatus ~/Dropbox/*"
alias dbfs="$dropbox_cmd filestatus"
unset dropbox_cmd

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
if [[ `uname` == 'Darwin' ]]; then
  alias co='pbcopy'
  alias pa='pbpaste'
  alias clc='echo -n | co'
else
  alias co='xclip -selection clipboard'
  alias pa='xclip -selection clipboard -o'
  alias clc='echo -n | co && echo -n | xclip -selection primary'
fi

# all the rest
alias grep='grep --color=auto'
alias q='exit'
alias :q='exit'
alias ag='ag --path-to-ignore ~/.agignore'
alias catlines="highlight $1 --out-format xterm256 --line-numbers --quiet --force --style solarized-light"
alias cat='ccat'
alias all='compgen -c | sort -u'
alias bs='bs.sh'
alias c='clear'
alias cx='chmod +x'
alias ds='dirsize.sh'
alias fontlist='fc-list | cut -d : -f 2 | sort -u | uniq'
alias fs='ranger'
alias h='history'
alias less='less -m -N -g -i -J --line-numbers --underline-special'
alias locate='locate -ie'
alias makelist="make -rpn | sed -n -e '/^$/ { n ; /^[^ .#][^ ]*:/p ; }' | egrep --color '^[^ ]*:'"
alias md='mkdir -p -v'
alias names='names.sh'
alias randomchars='dd if=/dev/urandom count=1 2> /dev/null | uuencode -m - | sed -ne 2p | cut -c-16'
alias screencast='ffmpeg -f x11grab -s wxga -r 25 -i :0.0 -sameq ~/.tmp/screencast.mpg'
alias sw='time cat'
alias vn='viewnior'
alias yt2mp3='youtube-dl --extract-audio --audio-format mp3'
alias shrug='echo "¯\_(ツ)_/¯"'
alias shco='shrug | co'
alias todo='nvim ~/Dropbox/work/wip/.todo.json'
alias am='alsamixer'
alias checkip='curl http://checkip.amazonaws.com/'
alias findallcolours="egrep -oi '#[a-f0-9]{6}' *.css | sort | uniq"
alias alltlds="curl -s http://data.iana.org/TLD/tlds-alpha-by-domain.txt | grep -v XN | sed -e 1d -e 's/\(.*\)/\L\1/'"
alias ur='unrar x -kb'
alias cerm='c ; erm'
alias fx='find . -maxdepth 2 -type d -name x'
alias fnm='find . -type d -name node_modules'
alias acd='a ; cd'
alias findlonglines="grep '.\{120\}' -r"
alias no='yes n'
alias shhh='lock.sh'
alias zh='zathura'
alias cla='clc ; cerm'
alias lv='luvi'
alias w3h='w3m -T text/html'
# requires moc and theme file
alias mu='mocp -T ~/.moc/themes/deephouse .'
alias y2j="python3 -c 'import sys, yaml, json; y=yaml.safe_load(sys.stdin.read ()); print(json.dumps(y, default=lambda obj: obj.isoformat() if hasattr(obj, \"isoformat\") else obj))' | jq ."
alias cpr='cp -R'
alias tn='tmux new'

if [[ `uname` == 'Darwin' ]]; then
  alias file='file -h'
  alias alacritty='open -a /Applications/Alacritty.app'
fi
