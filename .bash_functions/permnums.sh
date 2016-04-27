# tells you permissions, in number form (like 755, etc.)
# usage: permnums file-to-check
# to do: make globbing work

permnums() {
  stat -c %a "$1"
}

