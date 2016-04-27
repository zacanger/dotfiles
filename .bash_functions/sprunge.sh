# sprunge.us
sprunge() {
  curl -F 'sprunge=<-' http://sprunge.us < "${1:-/dev/stdin}"
}

