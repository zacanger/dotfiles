# usage : if itexists foo ; then (do things)
itexists() {
  command -v "$1" &> /dev/null ;
}

