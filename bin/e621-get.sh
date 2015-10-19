#!/bin/bash

# stop on unhandled error
set -e

: ${E621_PAGE_LENGTH:=100}

usage () {
    echo "Usage: $(basename "$0") [OPTION] [URL|ID]..."
    echo "Download images from e621.net to the current directory."
    echo
    echo "Options"
    echo "  -n, --no-fetch  just dump image urls, don't fetch"
    echo "  -h, --help      show this help message"
    echo
    echo "URLs can point to any of the following:"
    echo "  - a single image; that image will be fetched"
    echo "  - a pool; all images in that pool will be fetched"
    echo "  - a page of a tag search; all images on that page"
    echo "    will be fetched, using the environment variable"
    echo "    E621_PAGE_LENGTH (default 100) as the number of"
    echo "    posts on a page"
    echo "IDs will be interpreted as the image with that ID."
}

echo_msg () {
    echo "$@" 1>&2
}

extract_file_urls () {
    url_counter=1
    for url in $@ ; do
        if [ -z "$(echo "$url" | cut -sd '/' -f1-)" ] ; then
            echo_msg "#${url_counter}  Bare number, assuming post number."
            url="https://e621.net/post/show/${url}"
        fi
        link_type="$(echo "$url" | cut -d '/' -f4-5)"
        link_params="$(echo "$url" | cut -d '/' -f6-)"
        if [ "$link_type" = "pool/show" ] ; then
            echo_msg "#${url_counter}  Looks like a pool! Getting all image links..."
            link_id="$(echo "$link_params" | cut -d '/' -f1)"
            response="$(curl -s "https://e621.net/pool/show/${link_id}.json")"
            echo -n "$(paste -d ';' <(echo "${response}" | jq -r '.posts[].id') <(echo "${response}" | jq -r '.posts[].file_url')) "
        elif [ "$link_type" = "post/index" ] ; then
            echo_msg "#${url_counter}  Looks like a tag page! Getting all image links on that page (using ${E621_PAGE_LENGTH}-post page length)..."
            page_num="$(echo "$link_params" | cut -d '/' -f1)"
            tag_list="$(echo "$link_params" | cut -d '/' -f2)"
            response="$(curl -s "https://e621.net/post/index.json?limit=${E621_PAGE_LENGTH}&page=${page_num}&tags=${tag_list}")"
            echo -n "$(paste -d ';' <(echo "${response}" | jq -r '.[].id') <(echo "${response}" | jq -r '.[].file_url')) "
        elif [ "$link_type" = "post/show" ] ; then
            echo_msg "#${url_counter}  Looks like a single post! Getting single image link..."
            link_id="$(echo "$link_params" | cut -d '/' -f1)"
            response="$(curl -s "https://e621.net/post/show/${link_id}.json")"
            echo -n "$(echo "${response}" | jq -r '.id');$(echo "${response}" | jq -r '.file_url') "
        else
            echo_msg "#${url_counter}  Unknown link type '$link_type', please report this to <bitshift@bigmacintosh.net>"
        fi
        url_counter=$(( url_counter + 1 ))
    done
    echo
}

fetch_url () {
    in_url="$1"
    n="$2"
    prefix="$3"

    in_fname="$(echo $in_url | cut -d'/' -f7)"
    out_fname="${prefix}${in_fname}"

    if [ -f "$out_fname" ] ; then
        echo_msg "Already got image #$n as '$out_fname'"
    else
        curl -s "$in_url" > "$out_fname"
        if [ -f "$out_fname" ] ; then
            echo_msg "Downloaded image #$n as '$out_fname'"
        else
            echo_msg "Download failed for image #$n :("
        fi
    fi
}

print_id_urls() {
    for id_url in $@ ; do
        id="$(echo "${id_url}" | cut -d ';' -f1)"
        url="$(echo "${id_url}" | cut -d ';' -f2)"
        echo "${id}	${url}"
    done
}

fetch_file_urls() {
    counter=1
    for id_url in $@ ; do
        id="$(echo "${id_url}" | cut -d ';' -f1)"
        url="$(echo "${id_url}" | cut -d ';' -f2)"
        fetch_url "${url}" "${counter}" "${id}_"
        counter=$(( counter + 1 ))
    done
}

case "$1" in
    '') ;&
    '-h') ;&
    '--help')
        usage
        ;;
    '-n') ;&
    '--no-fetch')
        shift
        print_id_urls $(extract_file_urls "$@")
        ;;
    *)
        fetch_file_urls $(extract_file_urls "$@")
        ;;
esac
