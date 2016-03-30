#!/usr/bin/env bash

function debug {
    local severity="$1"
    shift
    local message="$@"

    echo -n "`date -u`"    1>&2
    echo -ne '\t'        1>&2
    echo -n "$severity"    1>&2
    echo -ne '\t'        1>&2
    echo "$message"        1>&2
}

function fix_path {
    echo -n "$1" | head -n 1 | sed 's|^[/.-]*||' | sed 's|/\.*|/|g'
}

function serve_dir {
    local dir="`fix_path "$1"`"
    if [ "$dir" = "" ]; then
        dir="./"
    fi
    echo 'HTTP/1.1 200 OK'
    echo 'Content-type: text/html;charset=UTF-8'
    echo
    echo LISTING "$dir"
    echo '<br/>'
    ls -p "$dir" | sed -e 's|^\(.*\)$|<a href="/'"$dir"'\1">\1</a><br/>|'
}

function serve_file {
    echo 'HTTP/1.1 200 OK'
    echo 'Content-type: application/x-download-this'
    echo
    local file="`fix_path "$1"`"
    debug INFO serving file "$file"
    cat "$file"
}

function process {
    local url="`gawk '{print $2}' | head -n 1`"
    case "$url" in
        */)
            debug INFO Processing "$url" as dir
            serve_dir "$url"
            break
            ;;
        *)
            debug INFO Processing "$url" as file
            serve_file "$url"
            ;;
    esac
}

function serve {
    local port="$1"
    local sin="$2"
    local sout="$3"

    while debug INFO Running nc; do

        nc -l -p "$port" < "$sin" > "$sout" &
        pid="$!"

        debug INFO Server PID: "$pid"

        trap cleanup SIGINT
        head -n 1 "$sout" | process > "$sin"
        trap - SIGINT

        debug INFO Killing nc

        kill "$pid"
    done

    debug INFO Quiting server
}

function cleanup {
    debug INFO Caught signal, quitting...
    rm -Rf "$tmp_dir"
    exit
}

tmp_dir="`mktemp -d -t http_server.XXXXXXXXXX`"
sin="$tmp_dir"/in
sout="$tmp_dir"/out
pid=0
port="$1"

mkfifo "$sin"
mkfifo "$sout"

debug INFO Starting server on port "$port"
serve "$port" "$sin" "$sout"
cleanup

