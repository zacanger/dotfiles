#!/bin/sh
set -e

brew update
brew cask upgrade
brew upgrade
brew cleanup
brew doctor
brew cask doctor
