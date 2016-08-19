getrandomanimewallpapers() {
  curl https://raw-api.now.sh/q?=$1 | jq .
}
