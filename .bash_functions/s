# change part of pwd path, and cd to it
# example:
# /usr/lib/foo$ s lib src
# /usr/src/foo$
s() {
 local cd="$PWD"
 if [ "$1" = "--complete" ]; then
  awk -v q="${2/s /}" -v p="$PWD" '
   BEGIN {
    split(p,a,"/")
    for( i in a ) if( a[i] && tolower(a[i]) ~ tolower(q) ) print a[i]
   }
  '
 else
  while [ $1 ]; do
   #echo "s/$1/$2/"
   cd="$(echo $cd | sed "s/$1/$2/")"
   shift; shift
  done
  #echo $cd
  cd $cd
 fi
}
complete -C 's --complete "$COMP_LINE"' s
