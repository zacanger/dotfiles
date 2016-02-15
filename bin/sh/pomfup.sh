#! /usr/bin/env bash
##
## pomfbash by lenormf
## Upload your files to a website running Pomf from the CLI
## https://github.com/nokonoko/Pomf
##

readonly URL_ENDPOINT="http://pomf.se"
readonly URL_FILES="http://a.pomf.se"

readonly DEPENDENCIES=(
    curl
)

function warning {
    for i in "$@"; do
        echo "${i}" >&2
    done
}

function fatal {
    warning "$@"

    exit 1
}

function assert_dependencies {
    for i in "$@"; do
        which "${i}" &>/dev/null || fatal "Unable to satisfy dependency: ${i}"
    done
}

function upload_file {
    local f="$1"

    local json=$(curl -sF "files[]=@${f}" "${URL_ENDPOINT}/upload.php")

    test $? -ne 0 && fatal "Unable to upload file \"${f}\""
    test -z "${json}" && warning "Invalid data returned by the server"

    local lnk=$(sed -r "s/^.+\"url\":\"([^\"]+)\".*$/${URL_FILES//\//\\\/}\/\1/" <<< "${json}")

    echo "${lnk}"

    which xsel &>/dev/null && xsel -ib <<< "${lnk}"
}

function main {
    test $# -lt 1 && fatal "Usage: $0 <file> ..." "Upload files to \"${URL_ENDPOINT}\" and print the URL of the file on the standard output"

    assert_dependencies "${DEPENDENCIES[@]}"

    for f in "$@"; do
        test -f "${f}" || fatal "No such file: ${f}"

        upload_file "${f}"
    done
}

main "$@"
