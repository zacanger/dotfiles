#!/bin/bash
#
# dmenu_wrapper.sh
#
# CREATED:  long ago
# MODIFIED: 2009-08-25 19:26

TERM="urxvt -e"
APP=$(dmenu_path | dmenu $@)

case $RUN in
    *,) exec $(echo $TERM $APP | sed 's/,$//') ;;
    *)  exec $APP ;;
esac
