# shellcheck shell=bash

pp() {
  npm publish --otp="$1" && git push --follow-tags
}
