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
        echo "USAGE: $(basename $0) COMMAND [OPTION...]"
        echo "Stores, manages, and displays short reminders."
        echo
        echo "COMMANDS:"
        echo "to ACTION	Log a reminder for ACTION"
        echo "now		Show all current reminders via osd_cat"
        echo "list		List all current reminders with id numbers"
        echo "not NUMBER	Stop reminding about action #NUMBER"
        echo
        echo "'to', 'now', and 'add' are also invokable as 'add', 'show', and 'del', respectively, but that's just so much more boring mnemonically. :P"
        echo
        echo "Reminders are stored in the file named in \$REMINDER_FILE, which defaults to \$HOME/.reminders. The file will be created if nonexistent. Currently yours is:"
        echo "$REMINDER_FILE"
        echo
        echo "When displaying reminders with osd_cat, the font given in \$REMINDER_FONT will be used, defaulting to "'-*-fixed-bold-*-*-*-*-*-*-*-*-*-*-*'
        echo "Currently yours is:"
        echo "$REMINDER_FONT"
        exit 1
}


depend osd_cat


REMINDER_FILE=${REMINDER_FILE:-$HOME/.reminders}
REMINDER_FONT=${REMINDER_FONT:-'-*-fixed-bold-*-*-*-*-*-*-*-*-*-*-*'}


if [[ ! -e $REMINDER_FILE ]] ; then
    touch $REMINDER_FILE
fi


case $1 in
    show) ;&
    now)
        osd_cat -w -d4 -l1 -A center -p middle -O2 -c white -f $REMINDER_FONT <(shuf $REMINDER_FILE)
        ;;
    add) ;&
    to)
        shift
        [[ "$@" != "" ]] || die "No action text was given."
        echo $@ >> $REMINDER_FILE
        ;;
    list)
        nl -ba $REMINDER_FILE
        ;;
    del) ;&
    not)
        is_integer $2 || die "No valid action number was given."
        NEW_REMINDERS=$(sed -e $2d <$REMINDER_FILE)
        echo "$NEW_REMINDERS" > $REMINDER_FILE
        ;;
    *)
        usage
        ;;
esac
