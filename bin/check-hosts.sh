#!/usr/bin/env bash
set -e

input_file=${1:-/etc/hosts}
bad_hosts_file=${2:-hosts_to_filter.txt}
filtered_hosts_file=${3:-filtered_hosts.txt}
split_hosts=$(cat "$input_file" | egrep '^0.0.0.0' | sed 's#0.0.0.0 ##')

for line in $split_hosts; do
    if [ -n "$line" ]; then
        nslookup "$line" 1>/dev/null || echo "$line" >> "$bad_hosts_file"
    fi
done

grep -v -f "$bad_hosts_file" "$input_file" > "$filtered_hosts_file"
