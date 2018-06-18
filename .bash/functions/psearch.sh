psearch() {
  local x ps=`ps -ef`
  for x
  do grep -iF -- "$x"<<<"$ps"
  done
}
