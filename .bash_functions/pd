# Attempt to change into the argument's parent directory; preserve any options
# and pass them to cd. This is intended for use when you've got a file path in
# a variable, or in history, or in Alt+., and want to quickly move to its
# containing directory. In the absence of an argument, this just shifts up a
# directory, i.e. `cd ..`
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

