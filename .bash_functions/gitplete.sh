# completion for local branch names
_git() {

  # bail if no repo (or no git!)
  if ! git rev-parse --git-dir >/dev/null 2>&1 ; then
    return 1
  fi

  # current and previous word
  local word first
  word=${COMP_WORDS[COMP_CWORD]}
  first=${COMP_WORDS[1]}

  # switch on previous word
  # if first is good, complete with branches/tags
  case $first in
    checkout|merge|rebase)
      local -a branches
      local branch
      while read -r branch ; do
        branches=("${branches[@]}" "${branch##*/}")
      done < <(git for-each-ref refs/{heads,tags} 2>/dev/null)
      COMPREPLY=( $(compgen -W "${branches[*]}" -- "$word") )
      return
      ;;

      # Bail if it isn't
      *)
      return 1
      ;;
  esac

}

complete -F _git -o default git

