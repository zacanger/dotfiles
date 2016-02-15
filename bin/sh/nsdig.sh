#!/bin/sh
case "$#" in
   3) nssrc=$3;;
   2) nssrc=$2;;
   *) echo usage: nsdig T WHAT [DOM] 1>&2
      exit 1;;
 esac
 for i in `nsaddrs $nssrc`; do
     echo "---- $i ----"
     dig +norecurse $1 $2 @$i
 done
