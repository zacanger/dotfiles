#!/usr/bin/env bash

file=`echo $1 | sed 's/\(.*\)\.\(.*\)/\1/'`
ext=`echo $1 | sed 's/.*\.\(.*\)/\1/'`

if [ ! -f $1 ] ; then
  if [ $ext = "pl" ] ; then
    echo "#!/usr/bin/env perl " > $1
  elif
    [ $ext = "py" ] ; then
    echo "#!/usr/bin/env python " > $1
  elif
    [ $ext = "c" ] ; then
    echo "#include<stdio.h>" >> $1
    echo -e "int main()\n{ \n\n}" >> $1
  elif
    [ $ext = "js" ] ; then
    echo "#!/usr/bin/env node" > $1
  elif [ $ext = "rb" ] ; then
    echo "#!/usr/bin/env ruby" > $1
  else
    echo "#!/usr/bin/env bash" > $1
  fi
fi

while [ 1 ] ;
do
  $EDITOR $1
  chmod 755 $1
  ./$1
  read dummy
done

