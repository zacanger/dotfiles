#!/bin/sh
# $Id: lessopen.sh,v 1.15 2012/06/22 09:35:13 tom Exp $
# wrapper for 'less' to open interesting archives, etc.
NUL=/dev/null
OUT=${TMPDIR-/tmp}/less.$$
rm -f $OUT

if test -d "$1" ; then
    ls -l "$1" >$OUT
else
    case "$1" in
    *.HTM|*.html|*.htm|*.html.gz|*.html.bz2|*.htm.gz|*.cgi)
  lynx -force_html -dump -with_backspaces "$1" >$OUT 2>$NUL
  ;;
    *.ms.gz)
  zcat "$1" | tbl |nroff -ms >$OUT 2>$NUL
  ;;
    *.ms)
  tbl "$1" |nroff -ms >$OUT 2>$NUL
  ;;
    *.[1-9].gz|*.[1-9][a-z].gz|*.man.gz)
  zcat "$1" | tbl |nroff -man >$OUT 2>$NUL
  ;;
    *.[1-9]|*.[1-9][a-z]|*.man)
  tbl "$1" |nroff -man >$OUT 2>$NUL
  ;;
    *.tar)
  tar tvf "$1" >$OUT 2>$NUL
  ;;
    *.tgz|*.tar.gz|*.tar.Z|*.tbz|*.tar.bz2)
  unarchive -l "$1" >$OUT 2>$NUL
  ;;
    *.gz|*.Z)
  zcat "$1" >$OUT 2>$NUL
  ;;
    *.zip|*.jar)
  unzip -l "$1" >$OUT 2>$NUL
  ;;
    *.bz2)
  bzip2 -dc "$1" >$OUT 2>$NUL
  ;;
    *.a)
  ar tv "$1" >$OUT 2>$NUL
  ;;
    *.o)
  nm "$1" >$OUT 2>$NUL
  ;;
    *.rpm)
  rpm -q -i -p "$1" >$OUT 2>$NUL
  ;;
    esac
fi

if [ -s $OUT ]; then
    echo $OUT
else
    rm -f $OUT
fi
