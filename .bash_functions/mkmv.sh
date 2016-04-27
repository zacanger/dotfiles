# mkmv newdir filestomoveintonewdir
mkmv() {
  mkdir -p -- "${@: -1}" && mv -- "$@"
}

