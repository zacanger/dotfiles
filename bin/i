#!/bin/bash

die() {
    echo -e $1; exit 1
}

depend() {
    for COMMAND in $@; do
        which $COMMAND &> /dev/null || die "FATAL ERROR: Required command '$COMMAND' is missing."
    done
}

is_integer() {
    [[ ! -z "$1" ]] || return 1
    [[ -z "$(echo $1 | tr -d 0-9)" ]] || return 1
}

usage() {
        echo "USAGE: $(basename $0) <started ACTIVITY|finished NUM|did|am>"
        echo "A time tracker for the command line."
        echo
        echo "  started ACTIVITY      Make an entry for starting ACTIVITY."
        echo "  finished NUM          Make an entry for finishing ongoing activity number NUM."
        echo "  stopped NUM           Alias for 'finished NUM'"
        echo "  did                   Show completed activities."
        echo "  am                    Show ongoing activities."
        echo
        echo "Activities are stored in the file named in \$I_ACTIVITY_FILE, which defaults to \$HOME/.Iactivities. The file will be created if nonexistent."
        exit 1
}


depend sed


I_ACTIVITY_FILE=${I_ACTIVITY_FILE:-$HOME/.Iactivities}


case $1 in
    started)
        [[ $# -lt 2 ]] && die "Too few arguments."
        echo "$(date --iso-8601=seconds) __ongoing__ ${@:2}" >> "$I_ACTIVITY_FILE"
        echo Started activity \#$(wc -l < "$I_ACTIVITY_FILE")
        ;;
    stopped) ;&
    finished)
        [[ $# -lt 2 ]] && die "Too few arguments."
        [[ $# -gt 2 ]] && die "Too many arguments."
        is_integer "$2" || die "Not a valid activity number."
        [[ -e "$I_ACTIVITY_FILE" ]] || touch "$I_ACTIVITY_FILE"
        NEW_ACTIVITIES=$(cat "$I_ACTIVITY_FILE" | sed "$2"'s/__ongoing__/'"$(date --iso-8601=seconds)"'/')
        echo "$NEW_ACTIVITIES" > "$I_ACTIVITY_FILE"
        echo Finished activity \#$2
        ;;
    did)
        [[ $# -gt 1 ]] && die "Too many arguments."
        [[ -e "$I_ACTIVITY_FILE" ]] || touch "$I_ACTIVITY_FILE"
        grep -v '__ongoing__' "$I_ACTIVITY_FILE" | while IFS= read -r line
        do
            echo $line | awk '{ print "from", $1, "to", $2 ":" }'
            echo "        $(echo $line | cut -d' ' -f 3-)"
        done
        ;;
    am)
        [[ $# -gt 1 ]] && die "Too many arguments."
        [[ -e "$I_ACTIVITY_FILE" ]] || touch "$I_ACTIVITY_FILE"
        nl -ba -nrn -w4 -s". " "$I_ACTIVITY_FILE" | grep '__ongoing__' | while IFS= read -r line
        do
            echo $line | awk '{ print $1, "from", $2 ":" }'
            echo "        $(echo $line | cut -d' ' -f 4-)"
        done
        ;;
    *)
        usage
        ;;
esac
