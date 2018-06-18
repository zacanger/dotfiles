# it's like bookmarks kinda
# also see `ga()`, `gt()`

g() {
  cd `cat $HOME/.g/${1-_back} || echo .`
}
