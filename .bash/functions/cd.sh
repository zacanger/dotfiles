# shellcheck shell=bash

# if given two args to cd, replace first with second in $PWD. preserves options.
cd() {
  local arg
  local -a opts
  for arg; do
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
  if (($# == 2)); then
    if [[ $PWD == *"$1"* ]]; then
      builtin cd "${opts[@]}" -- "${PWD/$1/$2}"
    else
      printf 'bash: %s: could not replace substring\n' \
        "$FUNCNAME" >&2
      return 2
    fi
  else
    builtin cd "${opts[@]}" -- "$@"
  fi
}
