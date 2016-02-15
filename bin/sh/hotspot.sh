#!/bin/bash
#
# Start a hotspot in a non-bridged mode

# This is where the internet is
DEV_INTERNET=wlan0

# This is what you are listening on.
DEV_AP=wlan1

# We are nat'ing so we need an IP
IP_AP=172.16.10.1
MASK_AP=255.255.255.0
CLASS_AP=24

set -x
pkill hostapd
sleep 1
hostapd /etc/hostapd/hostapd.conf&
#service hostapd start

sysctl net.ipv4.conf.all.forwarding=1

ifconfig $DEV_AP $IP_AP netmask $MASK_AP
ip route add $IP_AP/$CLASS_AP dev $DEV_AP

service isc-dhcp-server restart

iptables -F
iptables --table nat -F
iptables --table nat --append POSTROUTING --out-interface $DEV_INTERNET -j MASQUERADE
iptables --append FORWARD --in-interface $DEV_AP -j ACCEPT

