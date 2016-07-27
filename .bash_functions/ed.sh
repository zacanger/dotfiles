# add colon prompt to ed rather than text, to feel more like ex
# only when stdin is terminal
# if needed, use -v for verbose err
ed() {
  if [[ -t 0 ]] ; then
    if ed -sv - </dev/null >/dev/null 2>&1 ; then
      command ed -vp: "$@"
    else
      command ed -p: "$@"
    fi
  else
    command ed "$@"
  fi
}
