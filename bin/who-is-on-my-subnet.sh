#!/usr/bin/env bash

# A quick script to see who (DNS names) are on the same subnet.
# Assumes eth0 and /24.
# Usage: who-is-on-my-subnet.sh [ip]

eth0Addr=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
addrWith4Octets="${1:-${eth0Addr}}"
addrWith3Octets=`echo $addrWith4Octets | cut -d"." -f1-3`

i=1;
while [ "$i" -lt 255 ]; do
  host ${addrWith3Octets}.$i | grep -v NX;
  i=$((i+1));
done
