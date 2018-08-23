# kinda like cli bookmarks

# go to mark
g() {
  cd `cat $HOME/.g/${1-_back} || echo .`
}

# set mark
# echo ${PWD/#$HOME/'~'} ??
gt() {
  pwd > $HOME/.g/${1-_back}
  echo "g ${1} will return to `pwd`"
}

# show all
ga() {
  ( cd ~/.g ; grep '' * ) | awk 'BEGIN { FS=":" } { printf("%-10s %s\n",$1,$2) }' | grep -i -E ${1-.\*}
}
