# shellcheck shell=bash

# kinda like cli bookmarks

_g_init() {
  # init directory if it does not exist
  if [ ! -d "$HOME/.g" ]; then
    mkdir "$HOME/.g"
  fi
  # set completion function
  command -v complete &>/dev/null && complete -F _g_completions g gd
}

_g_completions() {
  for file in "$HOME/.g/${2//\\ / }"*; do
    if [ -f "$file" ]; then
      FILE_BASENAME=$(basename "${file}")
      COMPREPLY+=( "${FILE_BASENAME// /\\ }" )
    fi
  done
}

# go to mark
g() {
  if [ -f "$HOME/.g/${1-_back}" ]; then
    cd $(cat "$HOME/.g/${1-_back}" || echo .)
  else
    echo "Bookmark $1 not found!"
  fi
}

# set mark
gt() {
  pwd > "$HOME/.g/${1-_back}"
  echo "g ${1} will return to $(pwd)"
}

# delete mark
gd() {
  if [ -f "$HOME/.g/${1-_back}" ]; then
    rm "$HOME/.g/${1-_back}"
    echo "Deleted bookmark $1"
  else
    echo "Bookmark $1 not found!"
  fi
}

# show all
ga() {
  ( cd "$HOME/.g" ; grep '' * ) | awk 'BEGIN { FS=":" } { printf("%-10s %s\n",$1,$2) }' | grep -i -E "${1-.*}"
}

_g_init
unset -f _g_init
