# copy files into newly created dir
# mkcp newdir files

mkcp() {
  mkdir -p -- "${@: -1}" && cp -- "$@"
}

