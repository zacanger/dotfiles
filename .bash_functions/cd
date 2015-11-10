# If given two arguments to cd, replace the first with the second in $PWD,
# emulating a Zsh function that I often find useful; preserves options too
cd() {
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
    if (($# == 2)) ; then
        if [[ $PWD == *"$1"* ]] ; then
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

