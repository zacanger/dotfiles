# #bash on Freenode use their own pastebin, this is a convenience function for
# posting code to it. <http://sprunge.us>
sprunge() {
    curl -F 'sprunge=<-' http://sprunge.us < "${1:-/dev/stdin}"
}

