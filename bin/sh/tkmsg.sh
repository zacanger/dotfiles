#!/usr/bin/wish
#
# Ala xmessage but nicer: put up a window with a message in it; click on
# the window to make it go away. Handy for notifications. The message is
# given as the command line arguments.
#
# Usage: tkmsg [-geometry ...] msg ...

set myname "tkmsg"
wm title . $myname
wm iconname . $myname

frame .frame
button .text -text $argv -command {exit} -takefocus 0
pack .text

