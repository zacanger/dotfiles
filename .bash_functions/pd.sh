# try to cd to arg's parent dir. preserve opts, pass them to cd.
# use with a dir in var, hist, or alt+./esc-.

pd() {
  local arg target
  local -a opts
  for arg ; do
    case $arg in
      --)
        shift
        break
        ;;
      -*)
        shift
        opts=("${opts[@]}" "$arg")
        ;;
      *)
        break
        ;;
    esac
  done
  case $# in
    0)
      target=..
      ;;
    1)
      target=$1
      target=${target%/}
      target=${target%/*}
      ;;
    *)
      printf 'bash: %s: too many arguments\n' \
        "$FUNCNAME" >&2
      return 2
      ;;
  esac
  if [[ -n $target ]] ; then
    builtin cd "${opts[@]}" -- "$target"
  else
    printf 'bash: %s: error calculating parent directory\n' \
      "$FUNCNAME" >&2
    return 2
  fi
}

