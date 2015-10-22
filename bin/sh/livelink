#!/bin/sh
# Copyright 2010 Joey Hess <joey@kitenet.net>. License: GPL-2+
# WARNING: can easily eat systems alive if not used with caution!
set -e

usage () {
	(
	echo "usage: livelink packagename"
	echo ""
	echo "Replaces files included in packagename with symlinks to identical"
	echo "files in the current directory."
	) >&2
	exit 1
}

package="$1"
if [ -z "$package" ] || [ -n "$2" ]; then
	usage
fi

if [ ! -e "debian/control" ]; then
	echo "debian/control not found, not attempting livelink" >&2
fi

srcsums=`tempfile`
destsums=`tempfile`
tempfile=`tempfile`
trap cleanup EXIT
cleanup () {
	rm -f "$srcsums"
	rm -f "$destsums"
	rm -f "$tempfile"
}

munge () {
	# sort so join works
	# single quote filenames to avoid unpleasant suprises
	sort | sed -e "s/'/'\"'\"'/" -e "s/  / '/" -e "s/$/'/"
}

echo "Checksumming files in current directory ..."
find . -type f -exec md5sum {} \; | munge > "$srcsums"

if [ -e "/var/lib/dpkg/info/$package.md5sums" ]; then
	grep -v "  etc" "/var/lib/dpkg/info/$package.md5sums" |
	sed -e 's/  /  \//'|
	munge > "$destsums"
else
	echo "Checksumming installed files ..."
	for f in $(dpkg -L "$package" | grep -v /etc ); do
		if [ -f "$f" ] && [ ! -L "$f" ]; then
			md5sum "$f" >> "$tempfile"
		fi
	done
	cat "$tempfile" | munge > "$destsums"
fi

# build a script to run that does the desired linking
join "$srcsums" "$destsums" | sed 's/^[^ ]*/doln/' > "$tempfile"

err=0
doln () {
	if ! echo ln -svf "$1" "$2"; then
		err=1
	fi
}

. "$tempfile"
exit "$err"
