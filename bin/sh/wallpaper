#!/bin/bash
#
#	wallpaper.bash  Author: Jan Kandziora <jjj@gmx.de>
#	Licensed under the terms of the GNU General Public License, Version 2
#	See http://www.gnu.org/licenses/gpl.txt for details
#
#	This script tests if an image is useable as a desktop wallpaper.
#	A list of image types and a minimum and a maximum width and aspect ratio can be specified.
#	If a file passes all the tests, it is returned to stdout.
#
#	Note: This script needs GNU getopt, GNU gawk and ImageMagick to run.
#

#
#	Standard values.
#
MINIMUM_WIDTH=780
MAXIMUM_WIDTH=4000
MINIMUM_ASPECT=1.30
MAXIMUM_ASPECT=1.36
EXCLUDE_TYPES=""
INCLUDE_TYPES="JPEG,PNG,GIF,GIF87"
VERBOSE=0


#
#	Some functions:
#
function usage
{
	printf "USAGE: %s [OPTIONS] FILE ...\n" $(basename $0)
	printf "  -w  --min-width   Set the minimum width. Defaults to %s.\n" $MINIMUM_WIDTH
	printf "  -x  --max-width   Set the maximum width. Defaults to %s.\n" $MAXIMUM_WIDTH
	printf "  -a  --min-aspect  Set the minimum aspect ratio. Defaults to %s.\n" $MINIMUM_ASPECT
	printf "  -b  --max-aspect  Set the maximum aspect ratio. Defaults to %s.\n" $MAXIMUM_ASPECT
	printf "  -X  --exclude     Set the exclude file type list. Defaults to \"%s\".\n" $EXCLUDE_TYPES
	printf "  -I  --include     Set the include file type list. Defaults to \"%s\".\n" $INCLUDE_TYPES
	printf "  -v  --verbose     Print additonal info to stderr.\n"
	printf "      --help        Print this help and exit.\n"
	printf "      --version     Print the version and exit.\n"

	exit 1
}

#
#	Test if the needed programs are installed.
#
[ -x "$(which getopt)" ]   || { printf "Sorry, GNU getopt is not installed. I will not run without it.\n" >&2; exit 1; }
[ -x "$(which gawk)" ]     || { printf "Sorry, GNU gawk is not installed. I will not run without it.\n" >&2; exit 1; }
[ -x "$(which identify)" ] || { printf "Sorry, ImageMagick is not installed. I will not run without its \"identify\" utility.\n" >&2; exit 1; }

#
#	Parse the options.
#
GETOPT_RESULT=$(getopt -o vw:x:a:b:X:I: --long verbose,version,help,min-width:,max-width:,min-aspect:,max-aspect:,exclude:,include: -n 'wallpaper.bash' -- "$@")
[ $? != 0 ] && usage >&2
eval set -- "$GETOPT_RESULT"

while true
do
	case "$1" in
		-v|--verbose)  VERBOSE=1; shift;;
		--version) printf "%s Version 0.1 Author: Jan Kandziora <jjj@gmx.de>\nLicensed under the terms of the GNU General Public License, Version 2\nSee http://www.gnu.org/licenses/gpl.txt for details\n" $(basename $0) >&2; exit 1;;
		--help)    usage >&2;;
		-w|--min-width)  MINIMUM_WIDTH=$2;  shift 2;;
		-x|--max-width)  MAXIMUM_WIDTH=$2;  shift 2;;
		-a|--min-aspect) MINIMUM_ASPECT=$2; shift 2;;
		-b|--max-aspect) MAXIMUM_ASPECT=$2; shift 2;;
		-X|--exclude)    EXCLUDE_TYPES=$2;  shift 2;;
		-I|--include)    INCLUDE_TYPES=$2;  shift 2;;
		--) shift ; break ;;
		*) echo "Internal error." ; exit 1 ;;
	esac
done

#
#	Process some parameters.
#
EXCLUDE_TYPES=,${EXCLUDE_TYPES}
INCLUDE_TYPES=,${INCLUDE_TYPES},

#
#	Process the files.
#
for FILE
do
	IMAGE_INFO=$(identify "$FILE" 2>/dev/null) || continue 
	echo $IMAGE_INFO | gawk "{ printf(\"%s\n\",substr(\$0,length(\"$FILE\")+2)); }" | gawk \
	'{
		if (index("'$EXCLUDE_TYPES'",","$1",") != 0) next;
		if (index("'$INCLUDE_TYPES'",","$1",") == 0) next;
		split($2,geometry,"+");
		split(geometry[1],geometry,"x");
		width=geometry[1];
		height=geometry[2];
		aspect=width*1000/height;
		minaspect='$MINIMUM_ASPECT'*1000;
		maxaspect='$MAXIMUM_ASPECT'*1000;
		if (width < '$MINIMUM_WIDTH') { if ('$VERBOSE') printf("\"%s\" is too narrow.\n","'"$FILE"'") >"/dev/stderr"; next; }
		if (width > '$MAXIMUM_WIDTH') { if ('$VERBOSE') printf("\"%s\" is too wide.\n","'"$FILE"'") >"/dev/stderr"; next; }
		if (aspect < minaspect) { if ('$VERBOSE') printf("\"%s\" is too tall.\n","'"$FILE"'") >"/dev/stderr"; next; }
		if (aspect > maxaspect) { if ('$VERBOSE') printf("\"%s\" is too wide.\n","'"$FILE"'") >"/dev/stderr"; next; }
		if ('$VERBOSE') printf("\"%s\" is a wallpaper\n","'"$FILE"'") >"/dev/stderr";
		printf("%s\n","'"$FILE"'");
	}'
done

