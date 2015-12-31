#!/bin/sh

# credits for this little hack: http://exyr.org/2011/inotify-run/
# this watches all files in cwd. the flags are for recursively (r),
# quiet (q, suppressed warning if too many files to watch, not ever
# a real problem), and echo (e, to have color codes interpreted).
# %w%f is replaced by filename written to
# close_write means editor has finished writing; we could, instead, do
# just a regular write, there.
# example usage:
# inotifyrun xdotool search --name Chromium key --window %@ F5
# this will watch for changes in cwd, then have xdotool refresh (the F5)
# all matching windows (the --window %@) of Chromium. which would be
# a HORRIBLE idea, in my case. but it's just an example.

FORMAT=$(echo -e "\033[;33m%w%f\033[0m written")
"$@"
while inotifywait -qre close_write --format "$FORMAT" .
do
  "$@"
done

