#!/usr/bin/env bash
set -e

find_latest_semver() {
    pattern="^$PREFIX([0-9]+\.[0-9]+\.[0-9]+)\$"
    versions=$(for tag in $(git tag); do
        [[ "$tag" =~ $pattern ]] && echo "${BASH_REMATCH[1]}"
    done)
    if [ -z "$versions" ]; then
        echo 0.0.0
    else
        echo "$versions" | tr '.' ' ' | sort -nr -k 1 -k 2 -k 3 | tr ' ' '.' | head -1
    fi
}

increment_ver() {
    if [[ $4 == 'major' ]]; then
        awk_ptr='{printf("%d.%d.%d", $1+a, 0 , 0)}'
    elif [[ $4 == 'minor' ]]; then
        awk_ptr='{printf("%d.%d.%d", $1+a, $2+b , 0)}'
    elif [[ $4 == 'patch' ]]; then
        awk_ptr='{printf("%d.%d.%d", $1+a, $2+b , $3+c)}'
    fi

    find_latest_semver | \
        awk -F. -v a="$1" -v b="$2" -v c="$3" \
        "$awk_ptr"
}

bump() {
    next_ver="${PREFIX}$(increment_ver "$1" "$2" "$3" "$4")"
    git commit --allow-empty -m "$next_ver"
    git tag -a "$next_ver" -m "$next_ver"
    echo "Tagged $next_ver"
}

usage() {
    echo "Usage: bump [-p prefix] {major|minor|patch} | -l"
    echo "Bumps the semantic version field by one for a git-project."
    echo
    echo "Options:"
    echo "    -l    list the latest tagged version instead of bumping."
    echo "    -p    prefix [to be] used for the semver tags. default prefix: v"
    exit 1
}

while getopts p:l opt; do
    case $opt in
        p) PREFIX="$OPTARG";;
        l) LIST=1;;
        \?) usage;;
        :) echo "option -$OPTARG requires an argument"; exit 1;;
    esac
done

# set default PREFIX
if [[ ${PREFIX} == '' ]]; then PREFIX="v"; fi

shift $((OPTIND-1))

if [ -n "$LIST" ];then
    find_latest_semver
    exit 0
fi

case $1 in
    major) bump 1 0 0 major;;
    minor) bump 0 1 0 minor;;
    patch) bump 0 0 1 patch;;
    *) usage;;
esac
