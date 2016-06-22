#!/bin/sh
# $Header: /users/tom/bin/RCS/nm_cmp,v 1.1 1996/10/28 17:42:40 tom Exp $
#
# Compares the elements of an archive file, showing which are different
# or missing from one archive.
#
if [ $# != 2 ]
then
	echo 'usage: ar_cmp archive_1 archive_2'
	exit 1
fi
#
CMP=/tmp/cmp$$
OLD=/tmp/old$$
NEW=/tmp/new$$
mkdir $CMP
trap "rm -rf $OLD $NEW $CMP" 0 1 2 5 15
#
if ( ar t $1 |sort>$OLD )
then
	if ( ar t $2 |sort>$NEW )
	then
		if (cmp -s $OLD $NEW)
		then
			echo '** table-of-contents are similar'
		else
			echo '** table-of-contents differ:'
			diff $OLD $NEW
		fi
		Q=yes
		for N in `comm $OLD $NEW`
		do
			old=OLD:$N
			new=NEW:$N
			ar p $1 $N >$CMP/$old; (cd $CMP; nm $old |sed -e 's/OLD://' >$OLD)
			ar p $2 $N >$CMP/$new; (cd $CMP; nm $new |sed -e 's/NEW://' >$NEW)
			if (cmp -s $OLD $NEW )
			then
				echo same:$N
			else
				echo DIFF:$N
				diff $OLD $NEW
			fi
		done
	else
		echo '? not an archive: '$1
		exit 1
	fi
else
	echo '? not an archive: '$1
	exit 1
fi
