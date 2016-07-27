# sets sorta bookmarks
# also see `g()`, `ga()`

gt() {
  pwd > $HOME/.g/${1-_back}
  echo "g ${1} will return to `pwd`"
}
