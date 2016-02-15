#!/bin/sh
for ip in $*
do
    echo "Blocking $ip"
    sudo iptables -I INPUT -s $ip -j DROP
done

