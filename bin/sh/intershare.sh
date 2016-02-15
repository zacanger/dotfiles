#!/bin/bash
# Shares internet from wlan0 through eth0
case "$1" in 
    start)
ifconfig enp0s25 up
ifconfig enp0s25 11.11.11.10
iptables --table nat --append POSTROUTING --out-interface wls3 -j MASQUERADE
iptables --append FORWARD --in-interface enp0s25 -j ACCEPT
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "set other computers in the range of"
echo "10.0.0.0 255.255.255.0"
echo "gateway 10.0.0.1"
echo "dns 10.0.0.1"   % this is actually my router, use yours, or another dns service.
;;
    stop)
echo 0 > /proc/sys/net/ipv4/ip_forward
ifconfig enp0s25 down
iptables --table nat --delete POSTROUTING --out-interface wls3 -j MASQUERADE
;;
    *)
echo "usage: $0 {start|stop}"
;;
esac
