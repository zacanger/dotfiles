#!/usr/bin/env bash
set -e

input_file=${1:-/etc/hosts}
bad_hosts_file=${2:-hosts_to_filter.txt}
filtered_hosts_file=${3:-filtered_hosts.txt}
split_hosts=$(cat "$input_file" | egrep '^0.0.0.0' | sed 's#0.0.0.0 ##')

check_live() {
    host "$1" 1>/dev/null || echo "$1" >> "$bad_hosts_file"
}

for line in "$split_hosts"; do
    check_live "$line"
done

grep -v -f "$input_file" "$bad_hosts_file" > "$filtered_hosts_file"
