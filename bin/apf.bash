#
# apf -- arg-prepend-file -- Prepend null-delimited arguments read from a file
# to a command's arguments before running it. This is intended as a way of
# implementing *rc files for interactive Bash calls to programs that don't
# support such files, without having to use broken environment variables (e.g.
# GREP_OPTIONS); this enables you to, for example, use arguments with shell
# metacharacters and spaces in them that you do not want expanded.
#
# For example, given this simple program in our $PATH, printargs:
#
#   $ cat ~/.local/bin/printargs
#   #!/bin/sh
#   printf '%s\n' "$@"
#
# Which just prints its arguments:
#
#   $ printargs a b c
#   a
#   b
#   c
#
# We could do this:
#
#   $ printf '%s\0' -f --flag --option '? foo bar *' > "$HOME"/.printargsrc
#
#   $ apf "$HOME"/.printargsrc printargs a b c
#   -f
#   --flag
#   --option
#   ? foo bar *
#   a
#   b
#   c
#
# We could then make a permanent wrapper function with:
#
#   $ printargs() { apf "$HOME"/.printargsrc printargs "$@" ; }
#
#   $ printargs a b c
#   -f
#   --flag
#   --option
#   ? foo bar *
#   a
#   b
#   c
#
#   $ printf '%s\n' !-2:q >> "$HOME"/.bashrc
#
# This means you can edit the options in the *rc file and don't have to
# redefine a wrapper function.
#
# If you actually want those options to *always* be added, regardless of
# whether you're in an interactive shell, you really should make an actual
# wrapper script.
#
apf() {

    # Require at least two arguments, give usage otherwise
    if (($# < 2)) ; then
        printf 'bash: %s: usage: %s ARGFILE COMMAND [ARGS...]\n' \
            "$FUNCNAME" "$FUNCNAME" >&2
        return 2
    fi

    # First argument is the file containing the null-delimited arguments
    local argfile=$1
    shift

    # Check the arguments file makes sense
    if [[ ! -e $argfile ]] ; then
        printf 'bash: %s: %s: No such file or directory\n' \
            "$FUNCNAME" "$argfile"
        return 1
    elif [[ -d $argfile ]] ; then
        printf 'bash: %s: %s: Is a directory\n' \
            "$FUNCNAME" "$argfile"
        return 1
    elif [[ ! -r $argfile ]] ; then
        printf 'bash: %s: %s: Permission denied\n' \
            "$FUNCNAME" "$argfile"
        return 1
    fi

    # Read all the null-delimited arguments from the file
    local -a args
    local arg
    while read -d '' -r arg ; do
        args=("${args[@]}" "$arg")
    done < "$argfile"

    # Next argument is the command to run
    local cmd=$1
    shift

    # Run the command with the retrieved arguments first, then the rest of the
    # command line as passed to the function
    command "$cmd" "${args[@]}" "$@"
}

