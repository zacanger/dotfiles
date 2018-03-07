#!/bin/sh

# simple script for running stable chrome with a temporary profile,
# for testing and whatnot

profile_dir=`mktemp -d 'tmp_user.XXXX' -t`

/usr/bin/google-chrome \
  --disable-java \
  --disable-sync \
  --disable-first-run-ui \
  --no-default-browser-check \
  --no-first-run \
  --non-secure \
  --user-data-dir=$profile_dir \
  &
