# shellcheck shell=bash

# tells you permissions, in number form (like 755, etc.)
# usage: permnums file-to-check

permnums() {
  stat -c %a "$1"
}
