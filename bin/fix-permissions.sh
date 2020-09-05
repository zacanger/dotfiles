#!/usr/bin/env bash

# Author: Tasos Latsas

# Recursively set permissions for files and folders
# in a given path or in the working directory
# Especialy usefull when copying files from ntfs filesystems :P

show_help() {
cat << EOF
usage: $(basename "$0") OPTIONS

Fix all permissions for files and directories in given path.

Default permissions:
  Files:       644
  Directories: 755

Default path:
  Working directory

OPTIONS:
   -h               Show this message
   -p path          Change permissions from this path
   -f permissions   Folder permissions [octal]
   -d permissions   Directory permissions [octal]
   -v               Print command before execution
EOF
}

check_permissions() {
  # check for valid given permission mode
  mode=$1

  if [ ${#mode} -ne 3 ]; then
    return 1
  fi

  for i in 0 1 2; do
    if [ ${mode:${i}:1} -lt 0 ] || [ ${mode:${i}:1} -gt 7 ]; then
      return 1
    fi
  done
}

_path=""
_fmode="644"
_dmode="755"
_chmod=$(which chmod)
_xargs=$(which xargs)
if hash gfind 2>/dev/null; then
  _find=$(which gfind)
else
  _find=$(which find)
fi

while getopts ":hvp:f:d:" options; do
  case $options in
    h)
      show_help
      exit 0
      ;;
    v)
      _verbose="--verbose"
      ;;
    p)
      _path=${OPTARG}
      ;;
    f)
      check_permissions ${OPTARG}
      if [ $? -eq 1 ]; then
        echo "Invalid mode given"
        echo "(octal system mode only)"
        exit 1
      fi
      _fmode=${OPTARG}
      ;;
    d)
      check_permissions ${OPTARG}
      if [ $? -eq 1 ]; then
        echo "Invalid mode given"
        echo "(octal system mode only)"
        exit 1
      fi
      _dmode="${OPTARG}"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

echo "Setting file permissions to ${_fmode} ..."
$_find $_path -type f -print0 | $_xargs -0 $_verbose $_chmod $_fmode

echo
echo "Setting folder permissions to ${_dmode} ..."
$_find $_path -type d -print0 | $_xargs -0 $_verbose $_chmod $_dmode

exit 0
