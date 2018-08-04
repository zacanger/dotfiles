# kill everything
alias killx='sudo pkill -9 Xorg'
alias ka='killall'

# managing .bashrc & .bash_aliases
alias edrc='nvim ~/.bashrc'
alias edal='nvim ~/.bash/aliases.sh'
alias reload='source ~/.bashrc'

# git &co. ; see gitconfig for more
alias gfa='git fetch --all'
alias gd='git diff'
alias gc='git clone'
alias grv='git remote -v'
alias branches='git branches'
alias rpo='git rpo'
alias gg="git log --color --graph --pretty=format:'%Cgreen[%Creset%h%Cgreen]%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gittoday="git log --color --graph --pretty=format:'%Cgreen[%Creset%h%Cgreen]%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --since=yesterday"
alias gco='git checkout'
alias gw='ghwd.sh'
alias gdd='git diff --dirstat'
alias gtd='gittoday'
alias gs='git st'
alias gst='git st'
alias gitodo='git grep -EiI "FIXME|TODO"'
alias gds='git diff --stat'
alias rbl='git rebase -i HEAD~2'
alias aca='ac a'
alias gpt='git push --follow-tags'

# development package managers
alias np='npm publish'
alias ni='npm i'
alias ns='npm start -s'
alias ng='npm install -g'
alias ngh='ng $(basename $(pwd))'
alias nid='npm install --save-dev'
alias nis='npm install --save'
alias nr='npm run -s'
alias nu='npm i -g n ; n latest ; npm i -g npm@next ; npm i -g npx ; n prune ; node --version'
alias nt='npm test'
alias nb='npm run -s build'
alias lint='npm run -s test:lint'
alias jv='jq .version < package.json'
alias vp='vi package.json'
alias pipupd='pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U'
alias brewupd='brew update && brew upgrade && brew cleanup && brew prune && brew doctor'
alias vev='virtualenv -p /usr/bin/python3 venv'
alias lfd='lein figwheel dev'

# navigation
alias d='cd'
alias Cd='cd'
alias CD='cd'
alias cd..='cd ..'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../../"
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."
alias ........="cd ../../../../../../.."
alias ,,='..'
alias ,,,='...'
alias ,,,,='....'
alias ,,,,,='.....'
alias ,,,,,,='......'
alias ,,,,,,,='.......'
alias ,,,,,,,,='........'
alias ,,,,,,,,,='.........'
alias fonts="cd /usr/share/fonts"
alias cs='cd $OLDPWD'
alias ..a='.. && a'
alias ...a='... && a'
alias ....a='.... && a'

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
alias unl='unlink'
alias rml='unlink'

# ls things
alias ls='ls -F --color=auto --group-directories-first'
alias lS='ls -lSh'
alias k='ls'
alias l='ls -oshS'
alias la='ls -A'
alias lo='ls -lghtr'
alias a='ls -A'
alias f='k -1'
alias A='la'

# grep things
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# browsers
alias ch='chromium'
alias ff='firefox'
alias qu='qutebrowser --enable-webengine-inspector'
alias kk='kill-tabs'

# dropbox
alias dbup='dropbox-cli start'
alias dbdn='dropbox-cli stop'
alias dbst='dropbox-cli status'
alias dbls='dropbox-cli filestatus ~/Dropbox/*'
alias dbfs='dropbox-cli filestatus'

# this requires sox, and is for DADGAD. change to E2-E4 (etc) for standard.
alias tuner='for n in D2 A2 D3 G3 A3 D4;do play -n synth 4 pluck $n repeat 3;done'

# nvim
alias v='v.sh'
alias ex='nvim'
alias vi='nvim'
alias iv='nvim'
alias vib='nvim -b'
alias vim='nvim'
alias vir='nvim -R'
alias virb='nvim -R -b'
alias view='vim -R'
alias vl='v -l'
alias vv='nvim ~/.config/nvim/init.vim'
alias v='nvim'

# all the rest
alias q='exit'
alias :q='exit'
alias ag='ag --path-to-ignore ~/.agignore'
alias catlines="highlight $1 --out-format xterm256 --line-numbers --quiet --force --style solarized-light"
alias cat='ccat'
alias all='compgen -c | sort -u'
alias bs='bs.sh'
alias c='clear'
alias co='xclip -selection clipboard'
alias cuip='curl ifconfig\.me/ip'
alias cx='chmod +x'
alias dayofyear='date +%j'
alias ds='dirsize.sh'
alias fontlist='fc-list | cut -d : -f 2 | sort -u | uniq'
alias fs='ranger'
alias h='history'
alias hackurlist='wget -O - hackurls.com/ascii | less'
alias hackurls='w3m hackurls.com'
alias less='less -m -N -g -i -J --line-numbers --underline-special'
alias locate='locate -ie'
alias makelist="make -rpn | sed -n -e '/^$/ { n ; /^[^ .#][^ ]*:/p ; }' | egrep --color '^[^ ]*:'"
alias md='mkdir -p -v'
alias names='names.sh'
alias pa='xclip -selection clipboard -o'
alias clc='echo -n | co && echo -n | xclip -selection primary'
alias phps='php -S 127.0.0.1:5555'
alias randomchars='dd if=/dev/urandom count=1 2> /dev/null | uuencode -m - | sed -ne 2p | cut -c-16'
alias screencast='ffmpeg -f x11grab -s wxga -r 25 -i :0.0 -sameq ~/.tmp/screencast.mpg'
alias sf='standard --fix'
alias sprunge='sprunge.sh'
alias stopwatch='time read -N 1'
alias sw='time cat'
alias timestamp='date -d "$date" +%s'
alias vn='viewnior'
alias yt2mp3='youtube-dl --extract-audio --audio-format mp3'
alias shrug='echo "¯\_(ツ)_/¯"'
alias shco='shrug | co'
alias droplet='ssh root@zacanger.com'
alias rickroll='curl -sL http://bit.ly/10hA8iC | bash'
alias shittyusername='curl http://www.shittyusernames.com/api/get-username ; echo'
alias todo='nvim ~/Dropbox/work/wip/.todo.json'
alias reacterrorcodes='curl https://raw.githubusercontent.com/facebook/react/master/scripts/error-codes/codes.json | jq .'
alias am='alsamixer'
alias checkip='curl http://checkip.amazonaws.com/'
alias epochday="echo epoch day $(( $( date +%s) /86400 ))"
alias findallcolours="egrep -oi '#[a-f0-9]{6}' *.css | sort | uniq"
alias ghstatus='curl -s https://status.github.com/api/status.json | jq .status'
alias githubstatus='curl -s https://status.github.com/api/messages.json | jq .'
alias rkt='racket'
alias ytdl='youtube-dl'
alias alltlds="curl -s http://data.iana.org/TLD/tlds-alpha-by-domain.txt | grep -v XN | sed -e 1d -e 's/\(.*\)/\L\1/'"
alias ur='unrar x -kb'
alias cerm='c ; erm'
alias fx='find . -maxdepth 2 -type d -name x'
alias fnm='find . -type d -name node_modules'
alias acd='a ; cd'
alias checkjane='curl -s https://jane.com/-/diag | jq .status'
alias findlonglines="grep '.\{120\}' -r"
alias no='yes n'
alias shhh='lock.sh'
alias bye='poweroff'
alias zh='zathura'
alias cla='clc ; cerm'
alias lv='luvi'

if [[ `uname` == 'Darwin' ]]
then
  alias file='file -h'
  alias shhh='/System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend'
fi
