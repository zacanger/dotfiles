#!/usr/bin/env bash
set -e

default_trash_dir="$HOME/.z-trash"
trash_dir=${TRASH_DIR:-$default_trash_dir}

restore_trash_dir() {
    mkdir -p "$trash_dir"
}

trash_files() {
    for f in "$@"; do
        b=$(basename "$f")
        dest="$b"
        if [ -f "$trash_dir/$b" ]; then
            dest="$b-$RANDOM"
        fi
        mv -i "$f" "$trash_dir/$dest"
    done
}

empty_trash() {
    rm -rf --preserve-root "$trash_dir"
    restore_trash_dir
}

usage() {
    me=$(basename "$0")
    echo "$me usage:"
    echo "$me file1 file2...; move files to trash dir"
    echo "$me -e; empty trash dir"
    echo "$me trash dir: $trash_dir"
    exit 1
}

main() {
    if [ -z "$1" ]; then
        usage
    fi

    restore_trash_dir

    if [[ $1 == '-e' ]]; then
        empty_trash
    else
        trash_files "$@"
    fi
}

main "$@"
