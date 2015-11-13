# NVM - Node Version Manager
NVM allows you to use switch versions of node/io.js in your environment.
### Quickstart and Notes
GitHub: https://github.com/creationix/nvm
```bash
# make sure this URL is up to date on their github.
curl https://raw.githubusercontent.com/creationix/nvm/v0.23.3/install.sh | bash
# restart shell
# list versions (remote)
nvm ls-remote # this also updates the list
nvm install 0.10
# defaults
nvm alias default 0.10
```
