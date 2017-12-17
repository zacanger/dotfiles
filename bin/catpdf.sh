#!/bin/sh

if [ $# -lt 2 ]; then
  echo "usage: $(basename $0) OUTFILE INFILE..." >&2
  exit 1
fi

pdf=$1
shift

gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile="$pdf" "$@"
