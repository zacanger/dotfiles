#!/usr/bin/env bash
set -e

# Others to look into
# (maybe need to just switch to dnsmasq...)
# https://firebog.net/
# https://github.com/nextdns/blocklists
# this is too large, it breaks dns entirely....
# https://github.com/mitchellkrogza/Ultimate.Hosts.Blacklist
# curl \
    # -sSL \
    # https://hosts.ubuntu101.co.za/hosts \
    # > hosts1

# https://github.com/StevenBlack/hosts
curl \
    -sSL \
    https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn/hosts \
    > hosts2

# https://github.com/hagezi/dns-blocklists
# curl \
    # -sSL \
    # https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/pro.txt \
    # > hosts3

curl \
    -sSL \
    https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/doh.txt \
    > hosts4

# curl \
    # -sSL \
    # https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/tif.txt \
    # > hosts5

echo "127.0.0.1 $(hostname)" >> hosts

# cat hosts1 hosts2 hosts3 hosts4 hosts5 /etc/hosts \
cat hosts2 hosts4 /etc/hosts \
    | sed -e '/^[ \t]*#/d' \
    | sort -u > hosts-almost

echo '# /etc/hosts' >> hosts-header
echo '# move to /etc/hosts and then run update-hosts.sh' >> hosts-header
echo '# TODO: consider moving to dnsmasq because this gets large' >> hosts-header
echo '' >> hosts-header

cat hosts-header hosts-almost > hosts
rm hosts2 hosts4 hosts-almost hosts-header

sudo mv /etc/hosts /etc/hosts.bak
cat hosts > "$HOME/Dropbox/notes/etc-hosts"
sudo mv hosts /etc/hosts
clear-dns-cache.sh
