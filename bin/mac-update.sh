#!/usr/bin/env bash

brew update
brew upgrade --cask
brew upgrade
brew cleanup --prune=all

for p in $(cat ~/Dropbox/z/misc/npm.list); do npm i -g "$p"; done
cat ~/Dropbox/z/misc/pip.list | sed '/pip/d' | xargs python3.9 -m pip install -U
cat ~/Dropbox/z/misc/pip.list | sed '/pip/d' | xargs python3.10 -m pip install -U
cat ~/Dropbox/z/misc/pip.list | sed '/pip/d' | xargs python3.12 -m pip install -U --break-system-packages
cat ~/Dropbox/z/misc/pip.list | sed '/pip/d' | xargs python3.13 -m pip install -U --break-system-packages

vim +PlugUpgrade +qa
vim +PlugUpdate +qa

# Only as needed
# brew doctor --verbose
# ~/bin/update-dircolors.sh
# ~/bin/update-hosts.sh
