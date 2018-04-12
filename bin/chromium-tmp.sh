#!/bin/sh

# simple script for running chromium with a temporary profile, for testing and whatnot

profile_dir=`mktemp -d 'tmp_user.XXXX' -t`

ch=`/usr/bin/env chromium || /usr/bin/env chrome || /usr/bin/env google-chrome`

$ch \
  --disable-java \
  --disable-sync \
  --disable-first-run-ui \
  --no-default-browser-check \
  --no-first-run \
  --non-secure \
  --user-data-dir=$profile_dir \
  &

