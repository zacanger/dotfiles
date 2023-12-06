#!/usr/bin/env bash

brew update
brew upgrade
brew upgrade --cask
brew cleanup --prune=all
brew doctor --verbose

cat ~/Dropbox/z/misc/npm.list | xargs npm i -g
# TODO: figure out how to get brew and mac to just use one version already
cat ~/Dropbox/z/misc/pip.list | sed '/pip/d' | xargs pip3 install -U
cat ~/Dropbox/z/misc/pip.list | sed '/pip/d' | xargs python3 -m pip install -U
cat ~/Dropbox/z/misc/pip.list | sed '/pip/d' | xargs python3.9 -m pip install -U
cat ~/Dropbox/z/misc/pip.list | sed '/pip/d' | xargs python3.10 -m pip install -U
cat ~/Dropbox/z/misc/pip.list | sed '/pip/d' | xargs python3.12 -m pip install -U

vim +PlugUpgrade +qa
vim +PlugUpdate +qa

~/bin/update-dircolors.sh
~/bin/update-hosts.sh
