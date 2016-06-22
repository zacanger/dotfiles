#! /bin/bash

case "$1" in
    '' | -h | --help)
        NOARGS=1 ;;
    -y)
        YES=1 ;;
    -d)
        DRY=1; FIND=$2 ;;
    *)
        DRY=0; FIND=$1 ;;
esac

if [[ $NOARGS -eq "1" ||  -z $FIND ]]
then
    echo '
usage: grepkill (-d for dry run) [thing_to_find_and_kill]'
    exit 0
fi

ps aux | head -n 1; ps aux | grep -v grep | grep $FIND

COMMAND="ps -eo pid,args | grep -v grep | grep $FIND"

PIDS=$(echo $COMMAND | sh | awk '{ print $1 }')

if [[ -z $PIDS ]]; then
    echo
    echo did not find anything to kill, bailing.
    exit 1
fi

KILLCOMMAND="kill -9 $PIDS"

echo
echo will: $KILLCOMMAND
echo

if [ "$DRY" == "1" ]
then
    echo
    echo 'dry run, nothing killed'
    exit 0
fi

if [ "$YES" = "1" ]
then
    echo $KILLCOMMAND | sh
else
    read -p "Are you sure? [y/N]: " -n 1 -r
    echo
    if [ "$REPLY" == "y" ]
    then
        echo $KILLCOMMAND | sh
    fi
fi

exit 0
