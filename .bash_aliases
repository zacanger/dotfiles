# managing .bashrc & .bash_aliases
alias edrc='nvim ~/.bashrc'
alias edal='nvim ~/.bash_aliases'
alias reload='source ~/.bashrc'

# package managers
alias apmupd='apm update --no-confirm'
alias npmupd='npm update -g'
alias bupd='bower update'
alias pipupd='pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U'

# apt/dpkg stuff
alias upd='sudo apt-get update'
alias upg='sudo apt-get update && sudo apt-get upgrade'
alias purge='sudo apt-get purge'
alias brc='nvim ~/.bashrc'
alias search='apt-cache search'
alias policy='apt-cache policy'
alias depends='apt-cache depends'
alias ins='sudo apt-get install'
alias insd='dpkg -l | ag ii | less'
alias isit='dpkg -l | ag ii | ag'
alias rdepends='apt-cache rdepends'
alias show='apt-cache show'
alias dupg='sudo apt-get update && sudo apt-get dist-upgrade'

# disk usage
alias disk='du -S | sort -n -r | less'

# search
alias where="which"
alias what="apropos"
alias apr="apropos"

# navigation
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

# omg just go away
alias reboot='sudo /sbin/reboot'
alias poweroff='sudo /sbin/poweroff'
alias halt='sudo /sbin/halt'
alias shutdown='sudo /sbin/shutdown'
alias bye='sudo /sbin/poweroff'

# ls -ALL THE THINGS
alias ls='ls -F --color=auto --group-directories-first'
alias la='ls -A'
alias ll='ls -l'
alias l='ls -CF'
alias lo='ls -lghtr'
alias lS='ls -lhS'
alias lT='ls -rtH'
alias ld='ls -d */'
alias k='ls -htr'

# ag all the things! um, i mean...
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# https://bitbucket.org/sjl/t
alias t='python2.7 ~/bin/py/t.py --task-dir ~/Dropbox/tpytasks --list tasks'
alias tl='t | wc -l'

# browsers suck. destroy them.
alias kk='kill-tabs'
alias kch='pkill -15 chromium'
alias kice='pkill -15 iceweasel'
alias kff='pkill -15 firefox'
alias ksm='pkill -15 seamonkey'
alias kqu='pkill -15 qutebrowser'
alias klt='pkill -15 luakit'

# dropbox; basically may as well be ~/ at this point
alias dbup='dropbox start'
alias dbdn='dropbox stop'
alias dbst='dropbox status'
alias dbls='dropbox filestatus ~/Dropbox/*'

# twatter
alias tweet='twidge update'
alias feed='twidge lsrecent'
alias mytw='twidge lsarchive'

# https://github.com/nvbn/thefuck
alias fuck='eval $(thefuck $(fc -ln -1))'
alias please='fuck'

# this serves as a total replacement for the script from http://motd.sh/, with all of its
# absurd extraneous install & config mess
alias motd='curl -fsH "Accept: text/plain" "http://motd.sh/?v=0.01&weather=84601&degrees=f" && echo " "'

# this requires sox, and is for DADGAD. change to E2-E4 (etc) for standard.
alias tuner='for n in D2 A2 D3 G3 A3 D4;do play -n synth 4 pluck $n repeat 2;done'

# misc shortcuts, because i'm lazy
alias fs='ranger'
alias web='firefox'
alias browser='chromium'
alias mu='mocp -y -T moc_theme'
alias sfm='spacefm'
alias dt='dvtm -m ^'
alias les='less'
alias k9='pkill -9'
alias gui='startxfce4'
alias gcl='git clone'
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
alias bbp='bb.sh post'
alias hkurlist='wget -O - hackurls.com/ascii | less'
alias hackurls='w3m hackurls.com'
alias rbs='rainbowstream'
alias cn='connectivity'
alias cuip='curl ifconfig\.me/ip'
alias localbin='zerobin && lt -p 8000'
alias vi='nvim'
alias vim='nvim'
alias locate='locate -i'
alias sf='standard-format -w'
alias pip='pip3.5'
alias sw='time cat'
alias ds='dirsize'
alias ds.='dirsize .'
alias dfm='dmenu-fm'
alias lh='laenza.sh'
alias co='xclip -selection clipboard'
alias pa='xclip -o'
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
alias es='evilscan 127.0.0.1 --port=1024-14000'
alias phps='php -S 127.0.0.1:5555'
alias tpng='teenypng --apikey E5rJkw5V0aDutXwngFk2PZEEde940okM'
alias feh='viewnior'
alias zh='zathura'
alias nis='npm install --save'
alias nid='npm install --save-dev'
alias bi='bower install'
alias nig='npm install -g'
alias gg='git go'
alias a='la'
alias undo='undo -i'
alias vp='vtop'
alias alarm='alarm --config'
alias npms='npm start'

# mongo alias, for temporary school project purposes
alias mdb='mongod --dbpath=db/ --fork --nojournal --syslog'
alias kmdb='mdb --shutdown'

# temporary, testing, maybe, who knows
alias ot='otter-browser'

