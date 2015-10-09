#!/bin/sh
#
# Add keys to ssh-agent on-demand

main() {
    unset DISPLAY
    unset SSH_ASKPASS

    if [ ! "$(ssh-add -l | grep -E '(rsa|ed25519)')" ]; then
        ssh-add
    fi

    ($(basename ${0%-wrapper}) $@)
}

main $@
