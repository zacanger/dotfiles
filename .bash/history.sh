# shellcheck shell=bash

HISTCONTROL='erasedups:ignoreboth' # ignore lines with spaces, and duplicates
HISTIGNORE="ls:l:la:lo:lS:lv:a:k:cd:h:history:q:exit:c:clear:erm:clc:cerm"
HISTIGNORE="$HISTIGNORE:..:...:.:cs:co:ni:ns:vi:reload:gst:edrc:edal:fs:ncu"
HISTIGNORE="$HISTIGNORE:gd:g:v:nu:cla:shhh:todo:poweroff:tn:ncdu:startx"
HISTIGNORE="$HISTIGNORE:rbl:aca:dbup:dbdn:dbst:vv:sync:gdi:cf:f:gfa"
HISTIGNORE="$HISTIGNORE:rbl *:git push *:g *"

if [[ $(uname) == 'Darwin' ]]; then
  HISTSIZE=10000 # length
  HISTFILESIZE=10000 # size
else
  HISTSIZE=500 # length
  HISTFILESIZE=500 # size
fi

HISTTIMEFORMAT='%F %T  ' # timestamp
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a"
