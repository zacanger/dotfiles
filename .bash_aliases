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
alias insd='dpkg -l | grep ii | most'
alias isit='dpkg -l | grep ii | grep '
alias rdepends='apt-cache rdepends '
alias show='apt-cache show '
alias dupg='sudo apt-get update && sudo apt-get dist-upgrade'
# disk usage
alias disk='du -S | sort -n -r | most'

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
alias cb='cd $OLDPWD'

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
alias tweet='twidge update '
alias feed='twidge lsrecent'
alias mytw='twidge lsarchive'

# https://github.com/nvbn/thefuck
alias fuck='eval $(thefuck $(fc -ln -1))'
alias please='fuck'

# misc shortcuts
alias fs='ranger'
alias web='firefox'
alias browser='chromium'
alias mu='mocp -y -T moc_theme'
alias sfm='spacefm'
alias dt='dvtm -m ^'
alias les='most'
alias k9='pkill -9'
alias gui='startxfce4'
alias shhh='xfce4-terminal --fullscreen & xtrlock'
alias gcl='git clone '
alias hcl='hub clone '
alias cheatsheet='most ~/bin/doc/cheatsheet.md'
alias halp='lo -R ~/bin/doc/'
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
alias tuner='for n in D2 A2 D3 G3 A3 D4;do play -n synth 4 pluck $n repeat 2;done'
alias localbin='zerobin && lt -p 8000'
alias vi='vim.tiny'
alias vim='nvim'
alias locate='locate -i'
alias sf='semistandard-format'
alias python='python3.5'
alias pip='pip3.5'
alias sw='time cat'
alias ds='dirsize'

