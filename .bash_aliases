alias upd='sudo apt-get update'
alias upg='sudo apt-get update && sudo apt-get upgrade'
alias purge='sudo apt-get purge'
alias brc='nano ~/.bashrc'
alias search='apt-cache search'
alias policy='apt-cache policy'
alias depends='apt-cache depends'
alias ins='sudo apt-get install'

## Space on drive
alias disk='du -S | sort -n -r | most'

# search
alias where="which"
alias what="apropos"
alias apr="apropos"
alias ff="find . -type f -name"

# navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../../"
alias ......="cd ../../../../.."
alias fonts="cd /usr/share/fonts"

#### SAFETY ####
# alias rm='rm -Iv --preserve-root'
alias mv='mv -iv'
alias cp='cp -iv'
alias ln='ln -i'

alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

alias shred='shred -n 100 -z -v -u'

#### REBOOT/SHUTDOWN ####
alias reboot='sudo /sbin/reboot'
alias poweroff='sudo /sbin/poweroff'
alias halt='sudo /sbin/halt'
alias shutdown='sudo /sbin/shutdown'

alias ls='ls -F --color=auto --group-directories-first'
alias la='ls -A'
alias ll='ls -l'
alias l='ls -CF'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias md='mkdir -p -v'
alias manb='man -H'

alias fclist='fc-list | cut -d : -f 2 | sort -u | uniq'

### zacanger's additions

alias edrc='nano ~/.bashrc'
alias edal='nano ~/.bash_aliases'
alias reload='source ~/.bashrc'
alias insd='dpkg -l | grep ii | most'
alias isit='dpkg -l | grep ii | grep '
alias rdepends='apt-cache rdepends '
alias show='apt-cache show '
alias cheatsheet='most ~/bin/cheatsheet.md'
alias h='history'
alias c='clear'
alias q='exit'
alias gcl='git clone '
alias hcl='hub clone '
alias dbup='dropbox start'
alias dbdn='dropbox stop'
alias dbstat='dropbox status'

# twatter
alias tweet='twidge update '
alias feed='twidge lsrecent'
alias mytw='twidge lsarchive'

# package managers
alias apmupd='apm update --no-confirm'
alias npmupd='npm update -g'
alias bupd='bower update'
alias pipupd='pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U'

# https://github.com/nvbn/thefuck
alias fuck='eval $(thefuck $(fc -ln -1))'
alias please='fuck'

# misc shortcuts
alias fls='ranger'
alias web='iceweasel'
alias browser='chromium'
alias mu='mocp -T green_theme'
alias sfm='spacefm'
alias kk='kill-tabs'
alias t='python ~/bin/t.py --task-dir ~/tpytasks --list tasks'
alias tl='t | wc -l'
alias ,,='..'
alias ,,,='...'
alias ,,,,='....'
alias lt='ls -rtH'
alias bye='poweroff'
alias les='most'
alias k9='pkill -9'
alias gui='startxfce4'
alias rm='trash'
alias blank='xflock4'
alias kch='pkill -15 chromium'
alias kice='pkill -15 iceweasel'
alias kff='pkill -15 firefox'
alias ksm='pkill -15 seamonkey'
alias kqu='pkill -15 qutebrowser'
alias dt='dvtm -m ^'
alias lo='ls -lghtr'
