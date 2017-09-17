#!/usr/bin/env bash

platform='unknown'

if [ "$(uname)" == "Darwin" ]; then
  platform='mac'
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  platform='linux'
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
  platform='windows'
fi

