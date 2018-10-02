# go up dir tree arbitrary amount
# pwd -> /home/z/.config/nvim
# ud 3
# pwd -> /home

ud() {
  # check/save first arg (optional) (number of steps up); defaults to one
  local -i steps
  steps=${1:-1}
  if ! ((steps > 0)); then
    printf 'bash: %s: Invalid step count %s\n' "$FUNCNAME" "$1" >&2
    return 2
  fi

  # check/save second arg (optional) (target dir); defaults to $PWD
  local dir
  dir=${2:-$PWD}
  if [[ ! -e $dir ]]; then
    printf 'bash: %s: Target dir %s does not exist\n' "$FUNCNAME" "$2" >&2
    return 1
  fi

  # append /.. to target specified number of times
  local -i i
  for (( i = 0; i < steps; i++ )); do
    dir=${dir%/}/..
  done

  # attempt to cd
  cd -- "$dir"
}

# useful for the second arg
_ud() {
  if ((COMP_CWORD == 2)); then
    local word
    word=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -A directory -- "$word" ) )
  else
    return 1
  fi
}

complete -F _ud ud
