#!/bin/bash

# Usage:
#
# - create ~/.webdiff/pages with one page per line, in the format
#       <char changed threshold> <url>
#   e.g:
#       1 http://www.google.com/
#
# - create ~/.webdiff/mail with the destination mail adress in it. E.g.
#       echo 'webdiff@the-compiler.org' > ~/.webdiff/mail
#
# - Then just periodically call webdiff, e.g. in a cronjob

if [[ $1 == -v ]]; then
    shift 1
    verbose=1
else
    verbose=0
fi

if [[ ! -r ~/.webdiff/mail ]]; then
    echo "Error: ~/.webdiff/mail does not exist or is not readable!" >&2
    exit 1
fi

if [[ ! -r ~/.webdiff/pages ]]; then
    echo "Error: ~/.webdiff/pages does not exist or is not readable!" >&2
    exit 1
fi

if [[ ! -d ~/.webdiff/down ]]; then
    mkdir ~/.webdiff/down
    if (( $? != 0 )); then
        echo "Error: Could not create ~/.webdiff/down!" >&2
        exit 1
    fi
fi

mail_to=$(<~/.webdiff/mail)

tmp=$(mktemp)

if (( $? != 0 )); then
    echo "Error: Could not create temporary file!" >&2
    exit 1
fi

trap 'rm -f "$tmp"' EXIT

while read thresh page; do
    file=~/.webdiff/down/"${page//\//@}"
    ((verbose)) && echo "=== $page ==="

    elinks -dump -dump-color-mode 0 -dump-charset ascii -dump-width 80 \
           -no-references -no-numbering "$page" > "$tmp" 2>&1

    if [[ $? != 0 ]]; then
        ((verbose)) && echo "$page: elinks failed"
        continue
    fi

    if [[ ! -r "$file" ]]; then
        ((verbose)) && echo "First download"
        mv "$tmp" "$file"
        continue
    fi

    n_old=$(wc -c "$file" | awk '{ print $1 }')
    n_diff=$(diff -wy --suppress-common-lines <(sed 's/./&\n/g' "$file") \
             <(sed 's/./&\n/g' "$tmp") | wc -l)

    if (( n_diff >= thresh || verbose)); then
        diff -wu "$file" "$tmp" | \
            mailx -s "webdiff: $page $n_diff/$n_old chars changed" "$mail_to"
    fi

    mv "$tmp" "$file"
done < ~/.webdiff/pages

