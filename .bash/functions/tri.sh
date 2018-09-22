# simple `tree` for systems that don't have `tree`

tri() {
  find "$1" -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
}
