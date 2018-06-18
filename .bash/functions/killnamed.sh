killnamed() {
  ps ax | grep $1 | cut -d ' ' -f 2 | xargs kill
}
