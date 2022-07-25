#!/usr/bin/env bash

brew update
brew upgrade
brew upgrade --cask
brew cleanup --prune=all
brew doctor --verbose

cat ~/Dropbox/z/misc/npm.list | xargs npm i -g
cat ~/Dropbox/z/misc/pip.list | sed '/pip/d' | xargs pip3 install -U

vim +PlugUpgrade +qa
vim +PlugUpdate +qa
