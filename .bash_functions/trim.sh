trim() {
  set -f
  set -- $*
  printf "%s\\n" "$*"
  set +f
}
