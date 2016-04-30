#!/usr/bin/env bash

git clone https://github.com/christianalfoni/webpack-bin

cd webpack-bin

git clone https://github.com/christianalfoni/npm-extractor

if pgrep mongod ; then
  echo running
else
  mkdir -p db
  mongod --dbpath=db/ --fork --nojournal --syslog
fi

npm install

cd npm-extractor

npm install

cd ..

node npm-extractor/start & npm start

