# fn to manage contents of $PATH within current shell
path() {

  # cmd being called
  local pathcmd
  if (($#)) ; then
    pathcmd=$1
    shift
  else
    pathcmd=list
  fi

  # switch between commands
  case $pathcmd in

    # usage (also printed if cmd not found)
    help|h|-h|--help|-\?)
    printf '%s: Manage contents of PATH variable\n' "$FUNCNAME"
    printf '\n'
    printf 'USAGE:\n'
    printf '  %s h[elp]\n' "$FUNCNAME"
    printf '    Print this help message (also done if command not found)\n'
    printf '  %s l[ist]\n' "$FUNCNAME"
    printf '    Print the current dirs in PATH, one per line (default command)\n'
    printf '  %s i[nsert] DIR\n' "$FUNCNAME"
    printf '    Add a directory to the front of PATH, checking for existence and uniqueness\n'
    printf '  %s a[ppend] DIR\n' "$FUNCNAME"
    printf '    Add a directory to the end of PATH, checking for existence and uniqueness\n'
    printf '  %s r[emove] DIR\n' "$FUNCNAME"
    printf '    Remove all instances of a directory from PATH\n'
    printf '\n'
    printf 'INTERNALS:\n'
    printf '  %s s[et] [DIR1 [DIR2...]]\n' "$FUNCNAME"
    printf '    Set the PATH to the given directories without checking existence or uniqueness\n'
    printf '  %s c[heck] DIR\n' "$FUNCNAME"
    printf '    Return whether DIR is a component of PATH\n'
    printf '\n'
    ;;

    # current $PATH
    list|l)
    local -a patharr
    IFS=: read -a patharr < <(printf '%s\n' "$PATH")
    if ((${#patharr[@]})) ; then
      printf '%s\n' "${patharr[@]}"
    fi
    ;;

    # prepend dir to $PATH; check for existence and uniqueness
    insert|i)
    local -a patharr
    IFS=: read -a patharr < <(printf '%s\n' "$PATH")
    local dir
    dir=$1
    [[ $dir == / ]] || dir=${dir%/}
    if [[ -z $dir ]] ; then
      printf 'bash: %s: need a directory path to insert\n' \
        "$FUNCNAME" >&2
      return 1
    fi
    if [[ ! -d $dir ]] ; then
      printf 'bash: %s: %s not a directory\n' \
        "$FUNCNAME" "$dir" >&2
      return 1
    fi
    if [[ $dir == *:* ]] ; then
      printf 'bash: %s: Cannot add insert directory %s with colon in name\n' \
        "$FUNCNAME" "$dir" >&2
      return 1
    fi
    if path check "$dir" ; then
      printf 'bash: %s: %s already in PATH\n' \
        "$FUNCNAME" "$dir" >&2
      return 1
    fi
    patharr=("$dir" "${patharr[@]}")
    path set "${patharr[@]}"
    ;;

    # append
    append|add|a)
    local -a patharr
    IFS=: read -a patharr < <(printf '%s\n' "$PATH")
    local dir
    dir=$1
    [[ $dir == / ]] || dir=${dir%/}
    if [[ -z $dir ]] ; then
      printf 'bash: %s: need a directory path to append\n' \
        "$FUNCNAME" >&2
      return 1
    fi
    if [[ ! -d $dir ]] ; then
      printf 'bash: %s: %s not a directory\n' \
        "$FUNCNAME" "$dir" >&2
      return 1
    fi
    if [[ $dir == *:* ]] ; then
      printf 'bash: %s: Cannot append directory %s with colon in name\n' \
        "$FUNCNAME" "$dir" >&2
      return 1
    fi
    if path check "$dir" ; then
      printf 'bash: %s: %s already in PATH\n' \
        "$FUNCNAME" "$dir" >&2
      return 1
    fi
    patharr=("${patharr[@]}" "$dir")
    path set "${patharr[@]}"
    ;;

    # remove all instances of dir from $PATH
    remove|rm|r)
    local -a patharr
    IFS=: read -a patharr < <(printf '%s\n' "$PATH")
    local dir
    dir=$1
    [[ $dir == / ]] || dir=${dir%/}
    if [[ -z $dir ]] ; then
      printf 'bash: %s: need a directory path to remove\n' \
        "$FUNCNAME" >&2
      return 1
    fi
    if ! path check "$dir" ; then
      printf 'bash: %s: %s not in PATH\n' \
        "$FUNCNAME" "$dir" >&2
      return 1
    fi
    local -a newpatharr
    local part
    for part in "${patharr[@]}" ; do
      [[ $dir == "$part" ]] && continue
      newpatharr=("${newpatharr[@]}" "$part")
    done
    path set "${newpatharr[@]}"
    ;;

    # set $PATH to given dirs w/o checking
    set|s)
    local -a newpatharr
    local dir
    for dir ; do
      newpatharr=("${newpatharr[@]}" "$dir")
    done
    PATH=$(IFS=: ; printf '%s' "${newpatharr[*]}")
    ;;

    # return if dir is in $PATH
    check|c)
    local -a patharr
    IFS=: read -a patharr < <(printf '%s\n' "$PATH")
    local dir
    dir=$1
    [[ $dir == / ]] || dir=${dir%/}
    if [[ -z $dir ]] ; then
      printf 'bash: %s: need a directory path to check\n' \
        "$FUNCNAME" >&2
      return 1
    fi
    local part
    for part in "${patharr[@]}" ; do
      if [[ $dir == "$part" ]] ; then
        return 0
      fi
    done
    return 1
    ;;

    # wat
    *)
    printf 'bash: %s: Unknown command %s\n' \
      "$FUNCNAME" "$pathcmd" >&2
    path help >&2
    return 1
    ;;
esac
}

# completion
_path() {
  local word
  word=${COMP_WORDS[COMP_CWORD]}

  # op as first word
  if ((COMP_CWORD == 1)) ; then
    COMPREPLY=( $(compgen -W \
      'help list insert append remove set check' \
      -- "$word") )
  else
    case ${COMP_WORDS[1]} in

      # w/ one dir
      insert|i|append|add|a|check|c)
      if ((COMP_CWORD == 2)) ; then
        compopt -o filenames
        COMPREPLY=( $(compgen -A directory -- "$word") )
      fi
      ;;

      # w/ any number of dirs
      set|s)
      compopt -o filenames
      COMPREPLY=( $(compgen -A directory -- "$word") )
      ;;

      # with dirs from $PATH
      remove|rm|r)
      local -a promptarr
      IFS=: read -a promptarr < <(printf '%s\n' "$PATH")
      local part
      for part in "${promptarr[@]}" ; do
        if [[ $part && $part == "$word"* ]] ; then
          COMPREPLY=("${COMPREPLY[@]}" "$part")
        fi
      done
      ;;

      # none
      *)
      return 1
      ;;
  esac
fi
}

complete -F _path path

