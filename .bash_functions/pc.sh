# npm.im/pin-cushion
# needs jq

pc() {
  pin-cushion "$1" --format=json "$@" | jq .
}
