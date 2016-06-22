#! /usr/bin/env bash

# Uses nmap to perform a simple scan of a host
# for port status

type nmap >/dev/null 2>&1 || {
    echo >&2 "
this requires nmap, but it's not available."
    exit 1;
}

function usage {
    echo
    echo "Usage: `basename $0` {host, ports(single, comma separated, range)}"
    echo
    echo "ports defaults to range 1-1024"
}

if [ -z "$1" ]; then
    usage
    exit 1
fi

host=$1

if [ -n "$2" ]; then
    ports=$2
else
    ports="1-1024"
    echo defaulting ports to $ports
fi

cmd="nmap -PNF $host -p $ports"
echo $cmd
echo $cmd | sh
