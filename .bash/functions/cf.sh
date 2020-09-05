# shellcheck shell=bash

# count files
cf() {
  local dir

  # dir to check
  dir=${1:-$PWD}

  # err conditions
  if [[ ! -e $dir ]]; then
    printf 'bash: %s: %s does not exist\n' \
      "$FUNCNAME" "$dir" >&2
    return 1
  elif [[ ! -d $dir ]]; then
    printf 'bash: %s: %s is not a directory\n' \
      "$FUNCNAME" "$dir" >&2
    return 1
  elif [[ ! -r $dir ]]; then
    printf 'bash: %s: %s is not readable\n' \
      "$FUNCNAME" "$dir" >&2
    return 1
  fi

  # count files; print. use subshell to preserve opts
  (
  shopt -s dotglob nullglob
  declare -a files=("$dir"/*)
  printf '%d\t%s\n' "${#files[@]}" "$dir"
  )
}

complete -A directory cf
