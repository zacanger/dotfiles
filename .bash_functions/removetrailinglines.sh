removetrailinglines() {
  sed -e :a -e '/^\n*$/{$d;N;}' -e '/\n$/ba' $1 > $1.sed-tmp
  chmod --reference $1 $1.sed-tmp
  mv $1.sed-tmp $1
}

