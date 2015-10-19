#!/bin/sh

#
# fedora-unrpm
# Extract RPMs into PWD, "tar zxvf"-style
#
# Author:  Ville Skyttä <ville.skytta at iki.fi>
# License: GPL
# $Id: unrpm,v 1.1 2006/04/03 15:14:59 tom Exp $

usage()
{
    echo "Usage: `basename $0` RPMFILE..."
}

extract()
{
    name=$(rpm -qp --qf "%{NAME}-%{VERSION}-%{RELEASE}" "$1")
    if [ $? -ne 0 -o -z "$name" ]; then
        echo "Warning: can't extract $name"
        return 1
    fi

    # Is it an absolute filename?
    absname="$1"
    if ! echo "$1" | grep -q "^/" -; then
        absname="$PWD/$1"
    fi

    (mkdir -p "$name" && \
    cd "$name" && \
    rpm2cpio "$absname" \
    | cpio --quiet -ivdum 2>&1 \
    | sed "s|^\(\./\)\?|$name/|" && \
    cd ..)
}

if [ -z "$*" ]; then
    usage
    exit 1
fi

for file in $*; do
    extract "$file"
done
