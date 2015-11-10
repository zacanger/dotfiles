# Move back up the directory tree to the first directory matching the name
bd() {

    # For completeness' sake, we'll pass any options to cd
    local arg
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

    # We should have zero or one arguments after all that, bail if there are
    # more
    if (($# > 1)) ; then
        printf 'bash: %s: usage: %s [PATH]\n' \
            "$FUNCNAME" "$FUNCNAME" >&2
        return 2
    fi

    # The requested pattern is the first argument; strip trailing slashes if
    # there are any
    local req=$1
    [[ $req != / ]] || req=${req%/}

    # What to do now depends on the request
    local dir
    case $req in

        # If no argument at all, just go up one level
        '')
            dir=..
            ;;

        # Just go straight to the root or dot directories if asked
        /|.|..)
            dir=$req
            ;;

        # Anything else with a leading / needs to anchor to the start of the
        # path
        /*)
            dir=$req
            if [[ $PWD != "$dir"/* ]] ; then
                printf 'bash: %s: Directory name not in path\n' \
                    "$FUNCNAME" >&2
                return 1
            fi
            ;;

        # In all other cases, iterate through the directory tree to find a
        # match, or whittle the dir down to an empty string trying
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

    # Try to change into the determined directory
    builtin cd "${opts[@]}" -- "$dir"
}

# Completion setup for bd
_bd() {
    local word
    word=${COMP_WORDS[COMP_CWORD]}

    # Build a list of dirs in $PWD
    local -a dirs
    while read -d / -r dir ; do
        if [[ -n $dir ]] ; then
            dirs=("${dirs[@]}" "$dir")
        fi
    done < <(printf %s "$PWD")

    # Complete with matching dirs
    COMPREPLY=( $(compgen -W "${dirs[*]}" -- "$word") )
}
complete -F _bd bd

