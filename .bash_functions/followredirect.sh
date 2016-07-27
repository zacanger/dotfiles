followredirect() {
  curl -i "$1" 2>/dev/null | grep -i '^location: ' | cut -d ' ' -f 2
}
