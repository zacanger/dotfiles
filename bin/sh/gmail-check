#!/usr/bin/env bash

curl -u zacanger@gmail.com --silent "https://mail.google.com/mail/feed/atom" |
  perl -ne \
  '
    print "Subject: $1 " if /<title>(.+?)<\/title>/ && $title++;
    print "(from $1)\n" if /<email>(.+?)<\/email>/;
  '
