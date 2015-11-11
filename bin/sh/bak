#!/bin/sh

cp='cp -r'
for opt in $*; do
  case $opt in
    -m) 
      cp=mv
      ;;
    -*)
      echo "Bad option: $opt"
      exit 1
      ;;
    *)
      args="$args $opt"
      ;;
  esac
done

suffix="`date +%Y%m%d-%H%M%S`.bak"
for obj in $args ; do
  echo "$obj saved as $obj.$suffix"
  $cp $obj "$obj.$suffix"
done


# vim:ts=2:sw=2:sts=2:et:ft=sh

