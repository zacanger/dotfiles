# Search shell history file for a pattern. If you put your whole HISTFILE
# contents into memory, then you probably don't need this, as you can just do:
#
#     $ history | grep PATTERN
#
hgrep() {
    grep "${@:?}" "${HISTFILE:?}"
}

