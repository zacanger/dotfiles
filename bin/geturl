:
##########################################################################
# Title      :	geturl - get WWW page specified by URL
# Author     :	Heiner Steven <heiner.steven@odn.de>
# Date       :	1997-02-20
# Requires   :	netcat
# Category   :	WWW
# SCCS-Id.   :	@(#) geturl	2.5 04/03/01
##########################################################################
# Note
#    o	Needs the non-standard program
#	    netcat	("net cat", sometimes named "nc")
#	to do the actual work
##########################################################################

PN=`basename "$0"`			# Program name
VER='2.5'

# Program to establish TCP connection, print to standard output (usage: $NETCAT
# host port)
: ${NETCAT:=netcat}
: ${NETCATFLAGS=}

MaxRedirs=5
Header=${TMPDIR:=/tmp}/gu$$		# Temp. file for HTTP response header
Verbose=false				# true/false
PrintHeader=false
Followredirections=true
JustCheck=false

proxy=${HTTP_PROXY:-$http_proxy}
if [ -n "$proxy" ]
then UseProxy=true
else UseProxy=false
fi

default_contenttype="application/x-www-form-urlencoded"

# Set default headers. "generalheader" and "requestheader" contains the
# names of all variables that may contain valid header settings.

head_connection="Connection: close"
head_useragent="User-Agent: $PN/$VER"
generalheader="head_connection head_useragent"
requestheader="head_host head_contenttype head_contentlength"

usage () {
    echo >&2 "$PN - get WWW page specified by URL, $VER
usage: $PN [-chgpsv] [-R num] url [...]
   -c: only check the url, do not get the contents (implies -h)
   -C: content-type header field (default $default_contenttype)
   -h: HEAD request (sets exit code; add -s to see header)
   -g: GET request (default)
   -p: POST request (reads post data from standard input)
   -R: number of redirections to follow (default is $MaxRedirs)
   -s: print server response header
   -v: verbose mode

An url has the form
	http:[//HOST][:PORT]PATH
i.e.
	http://www.shelldorado.com:80/index.html"
    exit 1
}

msg () {
    echo >&2 "$PN: $*"
}

fatal () { msg "$@"; exit 1; }

isint () {
    for _i
    do
	case "$_i" in
	     *[!0-9]*)	return 1;;
	esac
    done
    return 0
}

# Return the parsed URL in the variables
#	Protocol, Host, Port, Path
ParseUrl () {
    [ $# -ge 1 ] || return 2
    U=$1
    # URL-Format: http://HOST/DIR/.../FILE
    Protocol=`expr "$U" : '\([a-zA-Z0-9][a-zA-Z0-9]*\):.*'`
    [ -n "$Protocol" ] || return 1		# Protocol must be specified
    U=`expr "$U" : "$Protocol:\(.*\)"`		# Remove protocol
    H=`expr "$U" : '//\([^/][^/]*\).*'`		# hostname:portnumber
    if [ -n "$H" ]
    then
	Host=`expr "$H" : '\([^:][^:]*\).*'`
	Port=`expr "$H" : '[^:][^:]*:\([0-9][0-9]*\).*'`
	U=`expr "$U" : "//[^/][^/]*\(.*\)"`	# Remove hostname:portnumber
    fi
    Path="$U"
    return 0
}

# Strip header from HTTP response, and write it to a file.
# A header is terminated by an empty line

StripHeader () {
    # Line terminator may be CR LF (instead of LF)
    cat "$@" | {
	    OIFS="$IFS"; IFS=""
	    while read line
	    do
		echo "$line"
		case "$line" in
		    ""|"
")	break;
		esac
	    done > "$Header"
	    IFS="$OIFS"
	    [ $PrintHeader = true ] && cat "$Header"
	    cat
    }
    return 0
}

##########################################################################
# Start of main program
##########################################################################

set -- `getopt :cC:ghpR:sv "$@"` || usage
while [ $# -gt 0 ]
do
    case "$1" in
	-c)	Cmd=HEAD; JustCheck=true;;		# only check the file
	-C)	ContentType=$2; shift;;
	-g)	Cmd=GET;;
	-h)	Cmd=HEAD;;
	-p)	Cmd=POST;;
	-R)	
	    isint "$2" || fatal "invalid number: $2"
	    MaxRedirs=$2; shift;;
	-s)	PrintHeader=true;;
	-v)	Verbose=true;;
	--)	shift; break;;
	-*)	usage;;
	*)	break;;			# First file name
    esac
    shift
done

[ $# -lt 1 ] && usage

: ${Cmd:=GET}

if [ X"$Cmd" = X"POST" ]
then
    contenttype=${ContentType:-$default_contenttype}
elif [ X"$ContentType" != X"" ]
then
    fatal "a content type may only be specified with POST requests"
fi

# Remove temporary files at signal or exit
trap 'rm -f "$Header" >/dev/null 2>&1' 0
trap "exit 2" 1 2 3 15

redircnt=0			# number of redirections followed
exitcode=0
while [ $# -gt 0 ]
do
    Url=$1; shift

    if [ $UseProxy = true ]
    then
        ParseUrl "$Url"; DstHost=$Host
	ParseUrl "$proxy" || {
	    msg "malformed proxy URL: $proxy"; continue; }
	Path=$Url
    else
        ParseUrl "$Url" || { msg "malformed URL: $Url"; continue; }
	DstHost=$Host
    fi

    [ "${Protocol:-INVALID}" = http ] ||
	{ msg "unknown protocol \"$Protocol\" (only \"http\" allowed)";
	  continue; }

    # Set default values
    : ${method:=${Cmd:-GET}}
    : ${Host:=127.0.0.1}
    : ${Port:=80}
    : ${Path:=/}
    [ $Verbose = true ] && msg "$method http://$Host:$Port$Path"

    # Build request from three parts: req_line, req_header, [req_body]
    request=
    req_line=
    req_header=
    req_body=

    # Clear request-specific header fields
    for header in $requestheader
    do eval "$header="
    done

    req_line="$method $Path HTTP/1.0"
    head_host="Host: $DstHost"

    case "$method" in
    	POST)
	    # Read post data from standard input. Note that we store all
	    # data in an environment variable. This is not strictly
	    # necessary, but simplifies our script.

	    [ -t 0 ] && msg "[Enter POST data; EOF to continue]" 
	    postdata=`cat || exit 1` || exit 1
	    req_body="$postdata"
	    head_contenttype="Content-Type: $contenttype"
	    length=`wc -c <<-EOT
		$req_body
		EOT
	    `
	    head_contentlength="Content-Length: `echo $length`"
	    ;;
    esac

    # Set all headers from $generalheader and $requestheader which
    # currently have a value

    req_header=
    for header in $generalheader $requestheader
    do
    	eval "[ -n \"\$$header\" ]" || continue
	[ -n "$req_header" ] && req_header="$req_header
"
	eval req_header="\$req_header\$$header"
    done

    #echo >&2 "DEBUG: header=<$requestheader>"

    # All header lines need to be terminated by CR LF (not just LF)

    request=`sed 's/$/
/' <<-EOT
	${req_line}
	${req_header}
	
	EOT
	`
    [ -n "$req_body" ] && request="$request
$req_body"
    #echo >&2 "DEBUG: request=<$request>"

    ######################################################################
    # Now issue the request
    ######################################################################

    "$NETCAT" $NETCATFLAGS ${Host:=127.0.0.1} ${Port:=80} <<EOT |
$request
EOT
	StripHeader || { msg "could not connect to $Host:$Port"; continue; }

     if [ -s "$Header" ]
     then
	# Get the three digit status code from status line (the fist line
	# of the response.

	statuscode=`sed 's|HTTP/[0-9.]* \([0-9][0-9]*\) .*|\1|;q' "$Header"`
	#echo >&2 "DEBUG: statuscode=<$statuscode>"

	case "$statuscode" in
	    1*|2*)
		exitcode=0
		;;
	    300|301|302)		# Temporary/permanent redirection
		exitcode=0
		if [ $Followredirections = true ]
		then
		    redircnt=`expr ${redircnt:-0} + 1`
		    [ $redircnt -gt $MaxRedirs ] &&
			fatal "too many redirections (more than $MaxRedirs)"

		    newlocation=`grep -i '^Location:' "$Header" | head -1 |
			    sed 's/^[^:][^:]*:[ 	]*//'`
		    if [ -n "$newlocation" ]
		    then
			set -- "$newlocation" "$@"
			#echo >&2 "DEBUG: newlocation=<$newlocation>"
			[ $method = POST ] && method=GET

			[ $Verbose = true ] && msg "redirected ($statuscode)"
		    else
			msg "NOTE: could not get new location of redirected" \
				" resource"
		    fi
		fi
		;;
	    4*|5*)				# Client/server errors
		exitcode=1
		;;
	    *)
		exitcode=1
		msg "NOTE: unexpected status code: $statuscode - ignored"
		;;
	esac
    else
    	exitcode=1
    fi

    if [ $JustCheck = true ]
    then
	[ $exitcode -eq 0 ] && echo "OK	$Url" || echo "ERROR	$Url"
    fi
done
exit $exitcode