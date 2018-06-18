[ -z "$PS1" ] && return

# load from interactive shell, don't from scripts/scp
echo $- | grep -q i 2>/dev/null && source /usr/bin/liquidprompt
