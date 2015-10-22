#!/bin/bash

# stop on unhandled error
set -e

die() {
    echo -e $1; exit 1
}

depend() {
    for COMMAND in $@; do
        which $COMMAND &> /dev/null || die "FATAL: Required command '$COMMAND' is missing."
    done
}

usage () {
    echo "Usage: $(basename "$0") [OPTION] [URL]..."
    echo "Download images from 4chan threads to subdirectories"
    echo "of the current directory (named based on thread)."
    echo
    echo "Options"
    echo "  -n, --no-fetch      just dump image urls, don't fetch"
    echo "  -N, --fetch         reverse an earlier --no-fetch"
    echo "  -f, --flat          don't use subdirectories"
    echo "  -F, --no-flat       reverse an earlier --flat"
    echo "  -r T, --repeat T    repeat process every T (where T is"
    echo "                        a time format as defined by the"
    echo "                        sleep command) dropping any thread"
    echo "                        which 404s"
    echo "  -R, --no-repeat     reverse an earlier --repeat"
    echo "  -s, --suppress      suppress 'already got image #X'"
    echo "  -S, --no-suppress   reverse an earlier --suppress"
    echo "  -c, --continue      continue downloading any threads"
    echo "                        with directories already created"
    echo "  -C, --no-continue   reverse an earlier --continue"
    echo "  -h, --help          show this help message"
}

log_msg () {
    echo "$(date --iso-8601=seconds)	$@" 1>&2
}

extract_urls () {
    declare -a valid_urls
    for url in $@ ; do
        link_scheme="$(echo "$url" | cut -d '/' -f1)"
        link_board="$(echo "$url" | cut -d '/' -f4)"
        link_thread="$(echo "$url" | cut -d '/' -f6)"
        response="$(curl -s "$link_scheme//a.4cdn.org/$link_board/thread/${link_thread}.json")"
        if [ -z "$response" ] ; then
            log_msg "$url seems to have 404'd, or your connection's janky."
            continue
        fi
        valid_urls[${#valid_urls[@]}]="$url"  # if still valid, add
        thread_name="$(echo "${response}" | jq -r '.posts[].semantic_url | select(. != null)' | head -n1)"
        if [ -z "$thread_name" ] ; then
            thread_name="${link_board}_${link_thread}"
        else
            thread_name="${thread_name}_${link_board}_${link_thread}"
        fi
        echo "${response}" \
            | jq -r '.posts[] | select(.ext != null) | (.tim | tostring) + .ext + ";" + (.tim | tostring) + "_" + (@base64 "\(.filename)") + .ext' \
            | sed 's_^_'"$link_scheme"'//i.4cdn.org/'"$link_board"'/_' \
            | sed 's|$|;'"$thread_name"'|'
    done
    echo "${valid_urls[@]}" 1>&3  # use FD 3 to not contaminate main output
}

fetch_url () {
    in_url="$1"
    out_fname="$2"
    out_id="${2%%_*}"
    out_dir="$3"
    n="$4"
    show_repeats="$5"

    out_fpath="$out_dir/$out_fname"

    mkdir -p "$out_dir"

    if [ -n "$(find $out_dir -name "${out_id}"'_*.*' -print -quit)" ] ; then
        if [ "$show_repeats" = "yes" ] ; then
            log_msg "Already got image #$n"
        else
            return 1  # don't count this
        fi
    else
        curl -s "$in_url" > "$out_fpath"
        if [ -f "$out_fpath" ] ; then
            log_msg "Downloaded image #$n as '$out_fpath'"
        else
            log_msg "Download failed for image #$n :("
        fi
    fi
    return 0  # count this
}

print_urls() {
    while read url_fname_dir; do
        [ -n "$url_fname_dir" ] || continue
        url="$(echo "${url_fname_dir}" | cut -d ';' -f1)"
        fname="$(echo "${url_fname_dir}" | cut -d ';' -f2)"
        echo "${url}"
    done
}

fetch_urls() {
    use_dirs="$1"
    show_repeats="$2"
    counter=1
    while read url_fname_dir; do
        [ -n "$url_fname_dir" ] || continue
        url="$(echo "${url_fname_dir}" | cut -d ';' -f1)"
        fname="$(echo "${url_fname_dir}" | cut -d ';' -f2)"
        if [ "$use_dirs" = "yes" ] ; then
            out_dir="$(echo "${url_fname_dir}" | cut -d ';' -f3)"
        else
            out_dir="."
        fi
        if fetch_url "${url}" "${fname}" "${out_dir}" "${counter}" "${show_repeats}" ; then
            counter=$(( counter + 1 ))
        fi
    done
}


depend jq curl

declare -a in_urls
show_usage=no
do_fetch=yes
use_dirs=yes
repeat=no
show_repeats=yes

if [ -z "$1" ] ; then
    show_usage=yes
fi

while [ -n "$1" ] ; do
    case "$1" in
        '-h' | '--help')
            show_usage=yes
            shift
            ;;
        '-n' | '--no-fetch')
            do_fetch=no
            shift
            ;;
        '-N' | '--fetch')
            do_fetch=yes
            shift
            ;;
        '-f' | '--flat')
            use_dirs=no
            shift
            ;;
        '-F' | '--no-flat')
            use_dirs=yes
            shift
            ;;
        '-r' | '--repeat')
            if [ -n "$2" ] ; then
                repeat="$2"
            else
                echo "FATAL: --repeat takes an argument"
                show_usage=yes
            fi
            shift 2
            ;;
        '-R' | '--no-repeat')
            repeat=no
            shift
            ;;
        '-s' | '--suppress')
            show_repeats=no
            shift
            ;;
        '-S' | '--no-suppress')
            show_repeats=yes
            shift
            ;;
        '-c' | '--continue')
            do_continue=yes
            shift
            ;;
        '-C' | '--no-continue')
            do_continue=no
            shift
            ;;
        *)
            in_urls[${#in_urls[@]}]="$1"
            shift
            ;;
    esac
done

if [ "$do_fetch" = "no" ] ; then
    process="print_urls"
else
    process="fetch_urls $use_dirs $show_repeats"
fi

if [ "$do_continue" = "yes" ] ; then
    for thread_folder in * ; do
        echo "$thread_folder" | grep '^.*_[a-z0-9]*_[0-9]*$' 2>&1 >/dev/null || continue
        thread_board="$(echo $thread_folder | cut -d'_' -f2)"
        thread_id="$(echo $thread_folder | cut -d '_' -f3)"
        in_urls[${#in_urls[@]}]="http://boards.4chan.org/$thread_board/thread/$thread_id"
    done
fi

if [ "$show_usage" = "yes" ] ; then
    usage
elif [ "$repeat" = "no" ] ; then
    extract_urls "${in_urls[@]}" 3>/dev/null | $process
else
    valid_urls_file="$(mktemp)"
    valid_urls="${in_urls[@]}"
    while true ; do
        until (ping -n 3 8.8.8.8 2>&1 >/dev/null) ; do
          log_msg "Connection seems to be down. Retrying in 30 seconds..."
          sleep 30s
        done

        extract_urls "$valid_urls" 3>"$valid_urls_file" | $process

        valid_urls="$(cat "$valid_urls_file")"
        if [ -n "$valid_urls" ] ; then
            sleep "$repeat"
        else
            die "No more valid thread URLs, exiting."
        fi
    done
fi
