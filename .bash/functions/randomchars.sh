# shellcheck shell=bash

randomchars() {
    one=$(dd if=/dev/urandom count=1 2> /dev/null \
        | uuencode - \
        | sed -ne 2p \
        | cut -c-10)

    two=$(dd if=/dev/urandom count=1 2> /dev/null \
        | uuencode -m - \
        | sed -ne 2p \
        | cut -c-10)

    three=$(echo "$one$two" | sed 's/./&\n/g' | shuf | tr -d "\n")
    echo "$three"
}
