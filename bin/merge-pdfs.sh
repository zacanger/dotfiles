#!/usr/bin/env bash
set -e

gs \
  -q \
  -dNOPAUSE \
  -dBATCH \
  -sDEVICE=pdfwrite \
  -sOutputFile=merged.pdf \
  "$@"
