# search shell history file for pattern

hgrep() {
  grep "${@:?}" "${HISTFILE:?}"
}
