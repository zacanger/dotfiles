#!/bin/sh

# take screenshot
import -window root /tmp/screenshot.png

# blur it
convert /tmp/screenshot.png -blur 0x9 /tmp/screenshotblur.png
rm /tmp/screenshot.png

# lock the screen
i3lock -i /tmp/screenshotblur.png

exit 0
