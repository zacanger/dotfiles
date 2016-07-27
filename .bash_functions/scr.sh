scr() {
  if (($# <= 1)) ; then
    pushd -- "$(mktemp -dt "${1:-scr}".XXXXX)"
  else
    printf 'bash: %s: too many arguments\n' \
      "$FUNCNAME" >&2
    return 2
  fi
}
