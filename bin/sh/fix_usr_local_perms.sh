#!/bin/bash

[ $UID -ne 0 ] && exec sudo /bin/bash "$0" "$@"

chown -R root:staff /usr/local
chmod -R ug+rwX /usr/local
find /usr/local -type d -print0 | xargs -0 chmod g+s

# vim:ts=2:sw=2:sts=2:et:ft=sh

