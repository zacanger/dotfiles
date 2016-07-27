# print args, null-delimited. probably want to use in a file,
# or as part of a pipeline. see also: `pa()`
pan() {
  if (($#)) ; then
    printf '%s\0' "$@"
  fi
}
