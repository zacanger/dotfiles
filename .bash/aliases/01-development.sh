# shellcheck shell=bash

# python
alias pipupd='cat ~/Dropbox/z/misc/pip.list | xargs sudo pip3 install -U'
alias venv='virtualenv venv'
alias py='bpython'

# node
alias np='npm publish'
alias niaf='npm i && npm audit fix'
alias npmv='npm version'
alias nr='npm run -s'
alias nt='npm test'
alias niy='npm init -y'
alias jv='jq .version < package.json'
alias nu='cat ~/Dropbox/z/misc/npm.list | xargs npm i -g'
