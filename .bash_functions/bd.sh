# back up in dir tree to first dir that matches arg

bd() {

  local arg     # passing opts to cd
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

  # zero or one args; any more: bail
  if (($# > 1)) ; then
    printf 'bash: %s: usage: %s [PATH]\n' \
      "$FUNCNAME" "$FUNCNAME" >&2
    return 2
  fi

  # pattern is first arg. strip trailing slashes (if any).
  local req=$1
  [[ $req != / ]] || req=${req%/}

  # what do we do now?
  local dir
  case $req in

    # if no arg, just go up one
    '')
    dir=..
    ;;

    # go to root or dot dirs if passed
    /|.|..)
    dir=$req
    ;;

    # if leading slash, anchor to start of path
    /*)
    dir=$req
    if [[ $PWD != "$dir"/* ]] ; then
      printf 'bash: %s: Directory name not in path\n' \
        "$FUNCNAME" >&2
      return 1
    fi
    ;;

    # everything else: iterate through dir tree, find match
    # if nothing matches, we get an empty string
    *)
    dir=${PWD%/*}
    while [[ -n $dir && $dir != */"$req" ]] ; do
      dir=${dir%/*}
    done
    if [[ -z $dir ]] ; then
      printf 'bash: %s: Directory name not in path\n' \
        "$FUNCNAME" >&2
      return 1
    fi
    ;;
  esac

  # try to cd to dir
  builtin cd "${opts[@]}" -- "$dir"
 }

# completion
_bd() {
  local word
  word=${COMP_WORDS[COMP_CWORD]}

  # list of dirs at $PWD
  local -a dirs
  while read -d / -r dir ; do
    if [[ -n $dir ]] ; then
      dirs=("${dirs[@]}" "$dir")
    fi
  done < <(printf %s "$PWD")

  # complete with matching dirs
  COMPREPLY=( $(compgen -W "${dirs[*]}" -- "$word") )
}

complete -F _bd bd

