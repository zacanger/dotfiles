# Add a colon prompt to ed when a command is expected rather than text; makes
# it feel a lot more like using ex. Only do this when stdin is a terminal,
# however. Also try and use -v for more verbose error output.
ed() {
    if [[ -t 0 ]] ; then
        if ed -sv - </dev/null >/dev/null 2>&1 ; then
            command ed -vp: "$@"
        else
            command ed -p: "$@"
        fi
    else
        command ed "$@"
    fi
}

