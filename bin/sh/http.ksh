#! /bin/ksh
#########################################################################
# Shellscript:	httpd.ksh - minimal HTTP-Server
# Author:	Heiner Steven (heiner.steven@odn.de)
# Date:		1999-09-05
# Requires:	netcat
# Category:	HTML, Internet
# SCCS-Id:	@(#) httpd.ksh	1.2 02/04/13
#########################################################################
# Description
#	Implements a minimal HTTP/1.0 Server
#
# Notes
#    o	Needs the following non-standard program(s):
#	    netcat
#	Alternatively the script can be started using "inetd"; the file
#	/etc/inetd.services should be changed for this purpose:
#	    8080 stream tcp nowait nobody /home/user/httpd.ksh
#    o	This script was first published with the
#	"SHELLdorado Newsletter 2/1999"
#	http://shelldorado.com/
#########################################################################
   
PORT=8080 # TCP port to listen to (standard is 80)
ROOT=$HOME # Document root. All paths are relative to this

echo >&2 "listening to port $PORT, documentroot is $ROOT"
while :
do
    # Start "netcat" in listen mode as server. On some systems
    # the command has# the name "nc".
    netcat -l -p $PORT |&
    exec 3<&p 4>&p	# redirect co-process' input to fd 3 and 4 

    # Read HTTP request header
    requestline=
    while read -u3 line
    do
	# An empty line marks end of request header
	[[ $line = ?(\r) ]] && break
	[[ -z $requestline ]] && requestline=$line
    done
    # Example request line:
    # GET /document.txt HTTP/1.0
    echo >&2 "< REQUEST: $requestline"
    set -- $requestline
    reqtype=$1

    # Create HTTP response header
    file=$ROOT/$2
    [[ -d "$file" ]] && file="$file/index.html"
    if [[ $reqtype = GET && -r $file && -f $file ]]    
    then
	print -u4 "HTTP/1.0 200 OK\r"
	print -u4 Content-Length: `wc -c < $file`"\r"
	print -u4 "\r"
	cat "$file" >&4
    else
	print -u4 "HTTP/1.0 404 Not Found\r"
	print -u4 "\r"
    fi
    # Close file descriptors of co-process.
    # This should terminate it:
    exec 3>&- 4>&-
    # "netcat" waits for the other party to close the
    # connection, but the browser will not do this:
    kill -1 $! >/dev/null 2>&1
done