#!/usr/bin/env bash

# the story behind this script:
# it's 16th march, 2016, and i've just finally treated myself to
# the 1TB dropbox subscription (a HUGE upgrade from the 8 gigs i've
# been using). obviously i've just thrown hundreds of gigs of stuff
# into my dropbox. i just need a simple thing to tell me what's going
# on with the sync every once-in-a-while, so i can stop typing `dbst`
# (an alias for `dropbox status`) every couple of minutes.
# so... this script.

while true
do
  sleep 300
  clear
  dropbox filestatus
done

