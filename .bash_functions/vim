# If Vim exists on the system, use it instead of ex, vi, and view
if ! hash vim 2>/dev/null ; then
    return
fi

# Define functions proper
ex() {
    vim -e "$@"
}
vi() {
    vim "$@"
}
view() {
    vim -R "$@"
}

