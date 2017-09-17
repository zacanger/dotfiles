#!/bin/bash

show_usage() {
  echo "Usage: "$0" [get <jq_filter> | set <jq_filter> <new_value>]"
  echo ""
  exit 1
}

y2j() {
  python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)'
}

j2y() {
  python -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, indent=2, default_flow_style=False)'
}

yq() {
  local jq_response="$(y2j | jq "$@")" 
  if is_json "$jq_response"; then
    echo "$jq_response" | j2y
  else
    echo "$jq_response"
  fi
}

is_json() {
  echo "$1" | jq -e 'if type=="array" or type=="object" then true else false end' &>/dev/null
}

set_value() {
  [ $# -ne 3 ] && show_usage

  if is_json $1; then
    echo "$1" | jq "$2 |= $3" 
  else
    echo "$1" | y2j | jq "$2 |= $3" | j2y
  fi
}

read_value() {
  [ $# -ne 2 ] && show_usage

  if is_json "$1"; then
    echo "$1" | jq "$2"
  else
    echo "$1" | yq "$2"
  fi
}

main() {
  [ $# -ge 1 -a -f "$1"  ] && input="$(cat $1)" && shift || input="$(cat)"
	case "$1" in
    set)            shift; set_value "$input" "$@";;
    get)            shift; read_value "$input" "$@";;
    *)              show_usage;;
	esac
}

main "$@"
