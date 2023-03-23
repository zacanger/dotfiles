#!/usr/bin/env bash
set -e

# this is too large, it breaks dns entirely....
# https://github.com/mitchellkrogza/Ultimate.Hosts.Blacklist
# curl \
    # -sSL \
    # https://hosts.ubuntu101.co.za/hosts \
    # > hosts1

# https://github.com/StevenBlack/hosts
curl \
    -sSL \
    https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn/hosts \
    > hosts2

# cat hosts1 hosts2 /etc/hosts \
cat hosts2 /etc/hosts \
    | sed -e '/^[ \t]*#/d' \
    | sort -u > hosts

echo "0.0.0.0 $(hostname)" >> hosts

# rm hosts1 hosts2
rm hosts2
sudo mv /etc/hosts /etc/hosts.bak
sudo mv hosts /etc/hosts
clear-dns-cache.sh
