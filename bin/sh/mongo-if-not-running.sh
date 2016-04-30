#!/usr/bin/env bash

if pgrep mongod ; then
  echo running
else
  mkdir -p db
  mongod --dbpath=db/ --fork --nojournal --syslog
fi

