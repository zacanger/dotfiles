# shellcheck shell=bash

# misc
alias ghc='stack ghc'
alias ghci='stack ghci'

# python
alias pipupd='cat ~/Dropbox/z/misc/pip.list | xargs pip3 install -U'
alias venv='virtualenv venv'

# node
alias np='npm publish'
alias ni='npm i'
alias niaf='npm i && npm audit fix'
alias ns='npm start -s'
alias ng='npm install -g'
alias nid='npm install --save-dev'
alias npmv='npm version'
alias nr='npm run -s'
alias nt='npm test'
alias nb='npm run -s build'
alias niy='npm init -y'
alias lint='npm run -s test:lint'
alias jv='jq .version < package.json'
alias nu='n latest && n prune && npm i -g npm && cat ~/Dropbox/z/misc/npm.list | xargs npm i -g'
