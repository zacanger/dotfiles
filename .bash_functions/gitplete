# Completion for git local branch names
_git() {

    # Bail if not a git repo (or no git!)
    if ! git rev-parse --git-dir >/dev/null 2>&1 ; then
        return 1
    fi

    # Get current and previous word
    local word first
    word=${COMP_WORDS[COMP_CWORD]}
    first=${COMP_WORDS[1]}

    # Switch on the previous word
    case $first in

        # If the first word is appropriate, complete with branch/tag names
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

