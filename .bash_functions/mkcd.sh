# mkdir, cd into it

mkcd() {
  mkdir -p -- "$1" && builtin cd -- "$1"
}
complete -A directory mkcd
