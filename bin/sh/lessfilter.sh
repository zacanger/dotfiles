#!/usr/bin/env sh

if [ -d "$1" ]; then
  if [ -n "$LS_COLORS" ]; then
    exec ls --color=force -lF "$1"
  else
    CLICOLOR_FORCE=1 exec ls -lF "$1"
  fi
else
  case $1 in
    *.json)
      type "jq" > /dev/null 2>&1 || { echo "Please intall jq first" >&2; exit 1; }
      jq -C . "$1"
      ;;
    *)
      type "src-hilite-lesspipe.sh" > /dev/null 2>&1 || { echo "Please source-highlight first" >&2; exit 1; }
      src-hilite-lesspipe.sh "$1";;
  esac
fi

exit 0
