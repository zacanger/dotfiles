# shellcheck shell=bash

COLS="$(tput cols)"
if (( COLS <= 0 )); then
  COLS="${COLUMNS:-80}"
fi

hr() {
  local WORD="$1"
  if [[ -n "$WORD" ]]; then
    local LINE=''
    while (( ${#LINE} < COLS )); do
      LINE="$LINE$WORD"
    done

    echo "${LINE:0:$COLS}"
  fi
}

hrs() {
  local WORD

  for WORD in "${@:-#}"; do
    hr "$WORD"
  done
}

[ "$0" == "$BASH_SOURCE" ] && hrs "$@"
