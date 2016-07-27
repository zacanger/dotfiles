# shows all sorta bookmarks
# also see `g()`, `ga()`

ga() {
  ( cd ~/.g ; grep '' * ) | awk '{ FS=":" ; printf("%-10s %s\n",$1,$2); }' | grep -i -E ${1-.\*}
}
