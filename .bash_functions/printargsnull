# Print arguments, null-delimited; you will probably want to write this into a
# file or as part of a pipeline. Compare pa().
pan() {
    if (($#)) ; then
        printf '%s\0' "$@"
    fi
}

