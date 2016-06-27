gurl() {
  curl -sH "Accept-Encoding: gzip" "$@" | gunzip
}

