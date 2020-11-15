# shellcheck shell=bash

prompt() {
  case $1 in
    on)
      PROMPT_COMMAND='history -a'
      PROMPT_DIRTRIM=2

      PS1=
      PS1=$PS1'\w'
      PS1=$PS1'$(prompt git)'

      # Add a helpful prefix if this shell appears to be exotic
      case ${SHELL##*/} in
        (bash) ;;
        (*) PS1=bash:$PS1 ;;
      esac

      # Add prefix and suffix
      PS1='${PROMPT_PREFIX}'$PS1'${PROMPT_SUFFIX}'

      # Declare variables to contain terminal control strings
      local format reset

      # Disregard output and error from these tput(1) calls
      {
        reset=$(tput sgr0 || tput me)
        format=$(
          pc=${PROMPT_COLOR:-10}
          tput setaf "$pc" ||
          tput setaf "$pc" 0 0 ||
          tput AF "$pc" ||
          tput AF "$pc" 0 0
        )
      } >/dev/null 2>&1

      # String it all together
      PS1='\['"$format"'\]'"$PS1"'\['"$reset"'\] '
      PS2='> '
      PS3='? '
      PS4='+<$?> ${BASH_SOURCE:-$BASH}:${FUNCNAME[0]}:$LINENO:'
      ;;

    git)
      # Wrap as compound command; we don't want to see output from any of these calls
      {
        # Bail if we're not in a work tree - or, implicitly, if we don't have git
        [[ $(git rev-parse --is-inside-work-tree) == true ]] || return

        # Refresh index so e.g. git-diff-files(1) is accurate
        git update-index --refresh

        # Find a local branch, remote branch, or tag (annotated or not), or failing all of that just show the short
        # commit ID, in that order of preference; if none of that works, bail out
        local name
        name=$(
          git symbolic-ref --quiet HEAD ||
          git describe --tags --exact-match HEAD ||
          git rev-parse --short HEAD
        ) || return
        name=${name#refs/*/}
        [[ -n $name ]] || return

        # Check various files in .git to flag processes
        local proc
        [[ -d .git/rebase-merge || -d .git/rebase-apply ]] && proc=${proc:+"$proc",}'REBASE'
        [[ -f .git/MERGE_HEAD ]] && proc=${proc:+"$proc",}'MERGE'
        [[ -f .git/CHERRY_PICK_HEAD ]] && proc=${proc:+"$proc",}'PICK'
        [[ -f .git/REVERT_HEAD ]] && proc=${proc:+"$proc",}'REVERT'
        [[ -f .git/BISECT_LOG ]] && proc=${proc:+"$proc",}'BISECT'

        # Collect symbols representing repository state
        local state

        # Upstream HEAD has commits after local HEAD; we're "behind"
        (($(git rev-list --count 'HEAD..@{u}'))) && state=${state}'<'

        # Local HEAD has commits after upstream HEAD; we're "ahead"
        (($(git rev-list --count '@{u}..HEAD'))) && state=${state}'>'

        # Tracked files are modified
        git diff-files --no-ext-diff --quiet || state=${state}'!'

        # Changes are staged
        git diff-index --cached --no-ext-diff --quiet HEAD || state=${state}'+'

        # There are some untracked and unignored files
        git ls-files --directory --error-unmatch --exclude-standard \
            --no-empty-directory --others -- ':/*' &&
            state=${state}'?'

        # There are stashed changes
        git rev-parse --quiet --verify refs/stash && state=${state}'^'
      } >/dev/null 2>&1

      # For some reason, five commands in the above block seem to stick around as jobs after this command is over; I
      # don't know why, but this clears it; might be a bug
      jobs >/dev/null

      # Print the status in brackets; add a git: prefix only if there might be another VCS prompt (because PROMPT_VCS is
      # set)
      printf '(%s%s%s%s)' \
        "${PROMPT_VCS:+git:}" \
        "${name//\\/\\\\}" \
        "${proc:+:"${proc//\\/\\\\}"}" \
        "${state//\\/\\\\}"
      ;;

    *)
      printf '%s: Unknown command %s\n' "${FUNCNAME[0]}" "$1" >&2
      return 2
      ;;
  esac
}

prompt "${PROMPT_MODE:-on}"
