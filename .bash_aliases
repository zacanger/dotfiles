# ~/.bash_aliases : sourced by ~/.bashrc

# kill everything, goddammit
alias killx='sudo pkill -9 Xorg'

# omg just go away
alias reboot='sudo /sbin/reboot'
alias poweroff='sudo /sbin/poweroff'
alias halt='sudo /sbin/halt'
alias shutdown='sudo /sbin/shutdown'
alias bye='sudo /sbin/poweroff'

# managing .bashrc & .bash_aliases
alias edrc='nvim ~/.bashrc'
alias brc='nvim ~/.bashrc'
alias edal='nvim ~/.bash_aliases'
alias reload='source ~/.bashrc'
alias fn='cd ~/.bash_functions'

# development package managers
alias ni='npm i'
alias ns='npm start'
alias npms='npm start'
alias nig='npm install -g'
alias nid='npm install --save-dev'
alias nis='npm install --save'
alias apmupd='apm update --no-confirm'
alias npmupd='npm update -g'
alias bupd='bower update'
alias bi='bower install'
alias pipupd='pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U'

# apt/dpkg stuff
alias upd='sudo apt-get update'
alias upg='sudo apt-get update && sudo apt-get upgrade'
alias prg='sudo apt-get purge'
alias search='apt-cache search'
alias policy='apt-cache policy'
alias depends='apt-cache depends'
alias ins='sudo apt-get install'
alias insd='dpkg -l | ag ii | less'
alias isit='dpkg -l | ag ii | ag'
alias rdepends='apt-cache rdepends'
alias show='apt-cache show'
alias dupg='sudo apt-get update && sudo apt-get dist-upgrade'
alias arm='sudo apt-get autoremove'
alias what-gives='apt-cache show "$1" | grep "^Filename:" | sed -e "s:\(.*\)/\(.*\)/\(.*\)/\(.*\)/.*:\4:"'
alias what-repo='apt-cache show "$1" | grep ^Filename: | head -n1 | col2 /'
alias what-source='apt-cache show "$1" | grep "^Filename:" | sed -e "s:\(.*\)/\(.*\)/\(.*\)/\(.*\)/.*:\4:"'

# navigation
alias Cd='cd'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../../"
alias ......="cd ../../../../.."
alias ,,='..'
alias ,,,='...'
alias ,,,,='....'
alias ,,,,,='.....'
alias ,,,,,,='......'
alias fonts="cd /usr/share/fonts"
alias cs='cd $OLDPWD'
alias ..a='.. && a'
alias ...a='... && a'
alias ....a='.... && a'

# safety
# alias rm='rm -Iv --preserve-root'
# gh:sindresorhus/trash,empty-trash
alias rm='trash'
alias erm='empty-trash'
alias mv='mv -iv'
alias cp='cp -iv'
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
# alias shred='shred -n 100 -z -v -u'
alias shred='echo NOPE, WE LIKE '

# ls things
alias ls='ls -F --color=auto --group-directories-first'
alias k='ls'
alias l='ls -oshS'
alias la='ls -A'
alias ll='ls -lh --author'
alias lo='ls -lghtr'
alias lT='ls -rtH'
alias ld='ls -d */'
alias lr='ls -aR'
alias lc='ls -ltcr'
alias lH='ls -hHsorA'
alias lS='ls -AosSh'

# ~~ag~~ _grep_ things
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# https://bitbucket.org/sjl/t (task list)
alias t='python2.7 ~/bin/py/t.py --task-dir ~/Dropbox/tpytasks --list tasks'
alias tl='t | wc -l'

# browsers rock.
alias ch='chromium'
alias ff='firefox'
alias ffs='firefox --safe-mode'
alias ffm='firefox --ProfileManager'
alias ffmps='firefox --ProfileManager --safe-mode'
alias ot='otter-browser'
alias qu='qutebrowser'
alias lk='luakit'
alias sm='seamonkey'
alias ice='iceweasel'

# browsers suck.
alias kk='kill-tabs'
alias kch='pkill -15 chromium'
alias kice='pkill -15 iceweasel'
alias kff='pkill -15 firefox'
alias ksm='pkill -15 seamonkey'
alias kqu='pkill -15 qutebrowser'
alias klk='pkill -15 luakit'

# dropbox, aka ~/
alias dbup='dropbox start'
alias dbdn='dropbox stop'
alias dbst='dropbox status'
alias dbls='dropbox filestatus ~/Dropbox/*'

# twatter
alias tweet='twidge update'
alias feed='twidge lsrecent'
alias mytw='twidge lsarchive'

# https://github.com/nvbn/thefuck (correct me, please)
alias fuck='eval $(thefuck $(fc -ln -1))'
alias please='fuck'

# this serves as a replacement for the script from http://motd.sh/
# for your config, change the zip code, degrees (to c, if needed), stocks (to y, if needed),
# and quotes (to '' if needed).
alias motd='curl -fsH "Accept: text/plain" "http://motd.sh/?v=0.01&weather=84601&degrees=f&stocks=&quotes=y" && echo " "'

# this requires sox, and is for CGCFGC. change to E2-E4 (etc) for standard.
alias tuner='for n in C2 G2 C3 F3 G3 C4;do play -n synth 4 pluck $n repeat 2;done'

# all the rest
alias vir='nvim -R'
alias vib='nvim -b'
alias virb='nvim -R -b'
alias disk='du -S | sort -n -r | less'
alias fs='ranger'
alias makelist="make -rpn | sed -n -e '/^$/ { n ; /^[^ .#][^ ]*:/p ; }' | egrep --color '^[^ ]*:'"
alias mu='mocp -y -T moc_theme'
alias sfm='spacefm'
alias dt="dvtm -m ^"
alias Cat='cat'
alias les='less'
alias k9='pkill -9'
alias gui='startxfce4'
alias gcl='git clone'
alias git='git-feats'
alias hc='hub clone'
alias hl='hub clone'
alias hcl='hub clone'
alias cheatsheet='less ~/doc/cheatsheet.md'
alias halp='lo -R ~/doc/'
alias md='mkdir -p -v'
alias manb='man -H'
alias fontlist='fc-list | cut -d : -f 2 | sort -u | uniq'
alias h='history'
alias c='clear'
alias q='exit'
alias Q='q'
alias bbp='bb.sh post'
alias hkurlist='wget -O - hackurls.com/ascii | less'
alias hackurls='w3m hackurls.com'
alias rbs='rainbowstream'
alias cuip='curl ifconfig\.me/ip'
alias localbin='zerobin && lt -p 8000'
alias vi='nvim'
alias vim='nvim'
alias locate='locate -ie'
alias sf='standard-format -w'
alias pip='pip3.5'
alias sw='time cat'
alias ds='dirsize'
alias ds.='dirsize .'
alias dfm='dmenu-fm'
alias lh='laenza.sh'
alias co='xclip -selection clipboard'
alias pa='xclip -o'
alias mdb='mongod --dbpath=db/ --fork --nojournal --syslog'
alias kmdb='mdb --shutdown'
alias ms='msee'
alias cx='chmod +x'
alias vn='viewnior'
alias gv='gpicview'
alias cl='clone'
alias le='less'
alias kafe='coffee -c'
alias ta='textadept'
alias mc='msee'
alias mp='mplayer2'
alias fv='fervor -dark'
alias cat='ccat'
alias yt2mp3='youtube-dl --extract-audio --audio-format mp3'
alias pb='pinboard'
alias es='evilscan 127.0.0.1 --port=1024-29000'
alias phps='php -S 127.0.0.1:5555'
alias feh='viewnior'
alias zh='zathura'
alias gg='git go'
alias a='la'
alias undo='undo -i'
alias vp='vtop'
alias alarm='alarm --config'
alias sl='slack-desktop'
alias apr="apropos"
alias mpad='mousepad'
alias ad='atom -d'
alias abd='atom-beta -d'
alias xfds='xfce4-display-settings'
alias words="shuf -n 1000 /usr/share/dict/words | sed s/\'s// | tr '[:upper:]' '[:lower:]' | sort"
alias screencast='ffmpeg -f x11grab -s wxga -r 25 -i :0.0 -sameq ~/.tmp/screencast.mpg'
alias stopwatch='time read -N 1'
alias bofhexcuse='telnet towel.blinkenlights.nl 666'
alias wgetmir='wget --random-wait -r -e robots=off '
alias vn.='viewnior .'
alias glance='glance -p 9876 -v'
alias pc='pin-cushion'

