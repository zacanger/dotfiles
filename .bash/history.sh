# shellcheck shell=bash

HISTCONTROL='erasedups:ignoreboth' # ignore lines with spaces, and duplicates
HISTIGNORE="ls:l:la:lo:lS:lv:a:k:cd:h:history:q:exit:c:clear:erm:clc:cerm"
HISTIGNORE="$HISTIGNORE:..:...:.:cs:co:ni:ns:vi:reload:gst:edrc:edal:fs:ncu"
HISTIGNORE="$HISTIGNORE:gd:g:v:nu:cla:todo:poweroff:tn:ncdu:startx"
HISTIGNORE="$HISTIGNORE:rbl:aca:dbup:dbdn:dbst:vv:sync:gdi:cf:f:gfa"
HISTIGNORE="$HISTIGNORE:rbl *:g *:radio.sh"
HISTSIZE=1000 # length
HISTFILESIZE=1000 # size
HISTTIMEFORMAT='%F %T  ' # timestamp
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a"
