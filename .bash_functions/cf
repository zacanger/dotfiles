# Count files
cf() {
    local dir

    # Specify directory to check
    dir=${1:-$PWD}

    # Error conditions
    if [[ ! -e $dir ]] ; then
        printf 'bash: %s: %s does not exist\n' \
            "$FUNCNAME" "$dir" >&2
        return 1
    elif [[ ! -d $dir ]] ; then
        printf 'bash: %s: %s is not a directory\n' \
            "$FUNCNAME" "$dir" >&2
        return 1
    elif [[ ! -r $dir ]] ; then
        printf 'bash: %s: %s is not readable\n' \
            "$FUNCNAME" "$dir" >&2
        return 1
    fi

    # Count files and print; use a subshell so options are unaffected
    (
        shopt -s dotglob nullglob
        declare -a files=("$dir"/*)
        printf '%d\t%s\n' "${#files[@]}" "$dir"
    )
}
complete -A directory cf

