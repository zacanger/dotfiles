#!/bin/sh

# Author: Tasos Latsas
#
# Easily extract any compressed file with one command
# Original script found at Archlinux wiki

check_bin() {
  type ${1} > /dev/null 2>&1

  if [ $? -ne 0 ]; then
    echo "Error: You need ${1} to uncompress this file."
    return 1
  fi

  return 0
}

FILE=$@

if [[ -f "$FILE" ]]; then
  case "${FILE}" in
    *.tar.bz2 | *.tbz | *.tbz2)
      tar xvjf "$FILE"
      ;;

    *.tar.gz | *.tgz)
      tar xvzf "$FILE"
      ;;

    *.tar.xz | *.txz)
      tar xvJf "$FILE"
      ;;

    *.bz2 | *.bz)
      bunzip2 "$FILE"
      ;;

    *.gz)
      gunzip "$FILE"
      ;;

    *.rar)
      check_bin unrar || exit 1
      unrar x "$FILE"
      ;;

    *.tar)
      tar xvf "$FILE"
      ;;

    *.zip)
      check_bin unzip || exit 1
      unzip "$FILE"
      ;;

    *.Z)
      uncompress "$FILE"
      ;;

    *.7z)
      check_bin 7z || exit 1
      7z x "$FILE"
      ;;

    *)
      echo "Error: I don't know how to extract '$FILE'"
      exit 1
      ;;
  esac
else
  echo "Error: '${FILE}' is not a valid file"
  exit 1
fi
exit 0

# vim: ts=2 sw=2 sts=2 et:
