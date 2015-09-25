#!/bin/sh

echo -n "Paste the URL here --> "

read URL

 

if [ -z $URL ]; then

echo -n "\nYou did not paste any URL!\n\n"

exit 1

fi

 

if [ -x /usr/bin/cvlc ]; then

usewithtor /usr/bin/cvlc $URL

else

exit 1

fi