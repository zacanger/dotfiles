#!/bin/bash
# vim: ai ts=2 sw=2 et sts=2 ft=sh

# Quickly compress folders using gnu tar or zip
#
# Author: Tasos Latsas

check() {
  type ${1} &>/dev/null || { echo "Error: You need ${1} to compress"; exit 1; }
}

show_help() {
cat << _END_HELP_
usage: $(basename "$0") [OPTIONS] <directory>

Create a compressed file from target directory

[OPTIONS]
  -h    Show this help message
  -H    Show extended help
  -c    Compression level to use
        (Works only with gzip/bzip2/xz)
  -e    Destination file extension, determines compression type
_END_HELP_
}

show_ehelp() {
cat << _END_HELP_

The following options are supported. Use with -e flag.

gz | tgz | tar.gz                 -> tar + gzip
bz | bz2 | tbz | tbz2 | tar.bz2   -> tar + bzip2
xz | txz | tar.xz                 -> tar + xz
tar                               -> tar
zip                               -> zip
_END_HELP_
}

compress() {
  # $1 - compression program
  # $2 - gnu tar flag for compression program
  # $3 - source/destination name
  # $4 - destination extension
  # $5 - compression level

  if [[ -z $5 ]]; then
    tar cvf${2} "$3.$4" "$3"
  else
    tar cvf - "$3" | $1 -$5 - > "$3.$4"
  fi
}

# set default extension, use tar+gzip
_ext="tar.gz"

while getopts ":hHc:e:" options; do
  case ${options} in
    h)
      show_help
      exit 0
      ;;
    H)
      show_help
      show_ehelp
      exit 0
      ;;
    c)
      if [[ ${OPTARG} -ne 6 ]]; then
        _level=${OPTARG}
      fi
      ;;
    e)
      _ext=${OPTARG}
      ;;
    \?)
      echo "Invalid option: -${OPTARG}" >&2
      exit 1
      ;;
    :)
      echo "Option -${OPTARG} requires an argument." >&2
      exit 1
      ;;
  esac
done

_target=${@:$OPTIND}
_target=${_target%/}
[[ -d $_target ]] || { echo "Error: cannot find directory $_target"; exit 1; }

case $_ext in
  gz | tgz | tar.gz)
    check gzip
    compress gzip z "$_target" tar.gz $_level
    ;;
  bz | bz2 | tbz | tbz2 | tar.bz2)
    check bzip2
    compress bzip2 j "$_target" tar.bz2 $_level
    ;;
  xz | txz | tar.xz)
    check xz
    compress xz J "$_target" tar.xz $_level
    ;;
  tar)
    tar cvf "$_target.$_ext" "$_target"
    ;;
  zip)
    check zip
    zip -r "$_target.$_ext" "$_target"
    ;;
  *)
    echo "Error: unknown extension $_ext"
    exit 1
esac

exit 0;
