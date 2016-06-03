# usage : if itexists foo ; then (do things)
ifexists() {
  command -v "$1" &> /dev/null ;
}

