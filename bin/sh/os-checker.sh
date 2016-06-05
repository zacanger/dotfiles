#!/usr/bin/env bash

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  echo 'linux'
elif [[ "$OSTYPE" == "darwin"* ]]; then
  echo 'mac'
elif [[ "$OSTYPE" == "cygwin" ]]; then
  echo 'cygwin'
elif [[ "$OSTYPE" == "msys" ]]; then
  echo 'mingw'
elif [[ "$OSTYPE" == "win32" ]]; then
  echo 'win32'
elif [[ "$OSTYPE" == "freebsd"* ]]; then
  echo 'bsd'
else
  echo 'wtf'
fi

