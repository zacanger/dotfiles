#!/bin/bash

while getopts ":f:s:" arg; do
  case "$arg" in
    f)
      f="${OPTARG}"
      ;;
    s)
      s="${OPTARG}"
      ;;
  esac
done

if [ "$f" = "True" ]
then
  echo "You entered 'True' for 'f'"
else
  echo "Defaulting to 'False' for 'f'"
fi

if [ ! -z "${s}" ]
then
  echo "s is $s"
else
  echo "s is not set"
fi
