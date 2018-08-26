[ -z "$PS1" ] && return

# load from interactive shell, don't from scripts/scp
# echo $- | grep -q i 2>/dev/null && source /usr/bin/liquidprompt

B='\[\e[1;38;5;33m\]'
LB='\[\e[1;38;5;81m\]'
GY='\[\e[1;38;5;242m\]'
G='\[\e[1;38;5;82m\]'
P='\[\e[1;38;5;161m\]'
PP='\[\e[1;38;5;93m\]'
R='\[\e[1;38;5;196m\]'
Y='\[\e[1;38;5;214m\]'
W='\[\e[0m\]'

get_prompt_symbol() {
  [[ $UID == 0 ]] && echo "#" || echo "\$"
}

if [[ $PS1 && -f /usr/share/git/git-prompt.sh ]]; then
  source /usr/share/git/git-prompt.sh

  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWSTASHSTATE=1
  export GIT_PS1_SHOWCOLORHINGS=1
  export GIT_PS1_SHOWUPSTREAM='auto'
  export GIT_PS1_SHOWUNTRACKEDFILES=1

  export PROMPT_DIRTRIM=3
  export PS1="$B\w\$(__git_ps1 \"$GY|$LB%s\")$GY $W\$(get_prompt_symbol) "
else
  export PS1="$B\w$GY $W\$(get_prompt_symbol) "
fi
