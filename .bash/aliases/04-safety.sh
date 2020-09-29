# shellcheck shell=bash

# safety, etc.
# gh:sindresorhus/trash,empty-trash
alias rm='trash'
alias erm='empty-trash'
alias mv='mv -iv'
alias cp='cp -iv'
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
