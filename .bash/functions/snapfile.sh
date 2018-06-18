snapfile() {
  http --form POST https://file.io < "file=@$1"
}
