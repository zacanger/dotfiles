# shellcheck shell=bash

# repeat command n times
# example: r 20 echo y # same as yes | head -n 20

r() {
  local i max
  max=$1; shift;
  for ((i=1; i <= max; i++)); do
    eval "$@";
  done
}
