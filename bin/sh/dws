#!/bin/bash

# Script Name: dws
# Description: show distrowatch distro position for different distros/time frames.
# Author: Harald Hope
# Version: 1.3.4
# Date: 2013-10-20
# License: GPL 3 or later
# Bugs, issues
# Support forums: http://techpatterns.com/forums/forum-33.html
# IRC: irc.oftc.net channel #smxi

## Changes:
# 1.3.4 2013-10-20 - removed deprecated 'seq'; made output less verbose and neater for multiple distros

## user set defaults, change these you want something else here
# distro: any distro you want, no spaces, dash, or /
# case insensitive, sample: dw says: PC-BSD, make: pcbsd
# can also have multiple, comma separated list, no spaces, like:
# DISTRO='opensolaris,openbsd,pcbsd,arch'
DISTRO='debian'
# options: 7 30 (day) - 3 6 12 (month)
# years: 2002-<year before current year>
# sample: TIME_SPAN='2008'
# TIME_SPAN='6'
TIME_SPAN='7'

## do not change anything under this point
B_DEBUGGER='false'
DW_PAGE_DATA=''
LINE='------------------------------------------------------------'
SCRIPT_NAME='dws'
TIME_TEXT=''
VERSION='1.3.4'
# get list of | separated years, 2 digit, 2002 to one less than present
YEAR_LAST=$(( $( date +%Y ) - 1 ))
YEARS=$( tr ' ' '|' <<< $( for (( i=2002;i<=$YEAR_LAST;i++));do echo $i;done ) )
B_TTY='false'
if tty >/dev/null;then
	B_TTY='true'
fi

# error number/extra data
error_handler()
{
	local message=''
	case $1 in
		1)	message="Unsupported argument passed to script: -$2"
			;;
		2)	message="For some reason, even though the distro you requested: $DISTRO is listed at distrowatch.com,\nits ranking number is missing. This is probably a bug in $SCRIPT_NAME."
			;;
		3)	message="The distro you requested: $DISTRO - does not appear to be present in \nDistroWatch.com rankings, for the time period: $TIME_TEXT\nThe distro spelling must correspond to what you see in the right column\nranking section (minus any spaces, /, or dashes, case insensitive)."
			;;
		4)	message="Bad value passed to -t: $2 - Supported time spans: Days: 7 30 - Months: 3 6 12\nYears: $YEARS"
			;;
		5)	message="Wget of data failed. Wget error: $2"
			;;
		6)	message="The page data is null but wget reports no errors."
			;;
		7)	message="This action requires root user status."
			;;
		8)	message="The $SCRIPT_NAME autoupdater reports file corruption, no #**EOF**# found in downloaded file.\Something went wrong with your wget download."
			;;
		9)	message="The $SCRIPT_NAME updater reports you don't have permission to carry out the requested file operation.\n(error: $2) This probably means root owns the file or its directory. Check to make sure."
			;;
		10)	message="An unsupported user set value was used for TIME_SPAN: $TIME_SPAN"
			;;
		11)	message="$SCRIPT_NAME is not in your system \$PATH. Unable to update."
			;;
	esac
	echo -e "Error $1: $message"
	exit $1
}

# args: $1 - "$@"
get_options()
{
	local opt=''
	while getopts :d:Dht:Uv opt
	do
		case $opt in
			d)	DISTRO=$( tr ',' ' ' <<< $OPTARG )
				;;
			D)	B_DEBUGGER='true'
				;;
			h)	show_help
				;;
			t)	if [ -n "$( grep -Ei '^(3|6|7|12|30|'$YEARS')$' <<< $OPTARG )" ];then
					TIME_SPAN=$OPTARG
				else
					error_handler 4 "$OPTARG"
				fi
				;;
			U)	script_self_updater
				;;
			v)	show_version 'opt'
				;;
			*)	error_handler 1 $OPTARG
				;;
		esac
	done
}

show_help(){
	echo "$SCRIPT_NAME distrowatch distro position script. Version: $VERSION
Your default with no options is distro: $DISTRO - time span: $TIME_SPAN
$LINE
$SCRIPT_NAME script options ( any you want or none, like: $SCRIPT_NAME -d arch -t 3 ):
-d - distrowatch distro as listed in right bar, no spaces, /, or dashes, remove them, ie:
     PC-BSD must be: pcbsd (upper/lower case doesn't matter) - Sample: $SCRIPT_NAME -d pcbsd
     You can also check multiple distros, by creating a comma separated list, no spaces:
     $SCRIPT_NAME -d arch,opensolaris,debian
-t - time span: 7 30 (days) - Months: 3 6 12 - Years: 2002-$YEAR_LAST - Sample: $SCRIPT_NAME -t 30
-U - Update script to latest version
-D - show debugging output
-h - help menu
-v - show $SCRIPT_NAME current version
$LINE
Known exceptions to distro naming:
Ubuntu Christian: -d ubuntuce
$LINE
You can change the script defaults at top of script variable settings to what you want,
just change the values of these top variables and $SCRIPT_NAME will show by default what you
want to see with no arguments/options:
DISTRO='debian'
TIME_SPAN='7'
"
	exit 0
}

# args: $1 - opt (option fired, exit. Optional)
show_version()
{
	echo "Your current $SCRIPT_NAME version is: $VERSION"
	if [ "$1" == 'opt' ];then
		exit 0
	fi
}

script_self_updater(){
	local scriptLocation=$( which $SCRIPT_NAME )
	local scriptOwner=$( ls -l $scriptLocation | awk '{print $3}' )
	local downloadUrl="http://smxi.org/$SCRIPT_NAME"
	local scriptData='' newVersion=''
	local scriptUser=$( whoami )
	
	if [ -n "$scriptLocation" ];then
		# check for root. Note that if parent dir is owned by root
		# if you try to mv a file to that dir, it will require root
		# permissions as well, even if the file is owned by user.
		if [ "$scriptUser" != "root" -a "$scriptOwner" == 'root' ] || [ "$scriptUser" != "root" -a "$scriptOwner" != "$scriptUser" ];then
			error_handler 7
		fi
		echo $LINE
		show_version 'update'
		echo $LINE
		echo "Starting $SCRIPT_NAME self updater."
		# note that || case can't be in subshell...
		scriptData="$( wget -O - $downloadUrl )" || error_handler 5 "$?"
		# try it again just in case it fails
		if [ -z "$( grep '#\*\*EOF\*\*#' <<< "$scriptData" )" ];then
			echo "First download attempt failed, trying it again..."
			echo
			scriptData="$( wget -O - $downloadUrl )" || error_handler 5 "$?"
		fi
		# echoing the file data to the user owned file works but stops
		# or damages script execution, so a restart didn't work right.
		if [ -n "$( grep '#\*\*EOF\*\*#' <<< "$scriptData" )" ];then
			echo "$scriptData" > $scriptLocation || error_handler 9 "echo: $?"
			chmod +x $scriptLocation || error_handler 9 "chmod: $?"
			newVersion=$(  grep '^#[[:space:]]Version:' $scriptLocation | awk '{print $3}' )
			echo $LINE
			echo "Success! Restart $SCRIPT_NAME to run updated version: $newVersion"
			exit 0
		else
			error_handler 8
		fi
	else
		error_handler 11
	fi
}

## Script Main Data Get/Print
get_dw_data()
{
	local dwUrl='' dataSpan=''
	
	# null defaults to 7 day
	case $TIME_SPAN in
		3)
			dataSpan=13
			TIME_TEXT='3 month'
			;;
		6)
			dataSpan=26
			TIME_TEXT='6 month'
			;;
		7|'') # default to 7 if null and unset in top prefs
			dataSpan=1
			TIME_TEXT='7 day'
			;;
		12)
			dataSpan=52
			TIME_TEXT='12 month'
			;;
		30)
			dataSpan=4
			TIME_TEXT='30 day'
			;;
		# note: using $YEARS doesn't work with ) method, so doing explicit test
		200[2-9]|20[1-9][0-9])
			if [ -n "$( grep -Ei '^('$YEARS')$' <<< $TIME_SPAN )" ];then
				dataSpan=$TIME_SPAN
				TIME_TEXT="$TIME_SPAN year"
			else
				error_handler 10
			fi
			;;
		*)
			error_handler 10
			;;
	esac
	
	dwUrl="http://distrowatch.com/index.php?dataspan=$dataSpan"
	
	if [ "$B_DEBUGGER" == 'true' ];then
		echo $LINE
		echo "Debugger Started"
		echo "Step 1: pre wget data"
		echo "distro: $DISTRO :: timeFrame: $TIME_SPAN :: TIME_TEXT: $TIME_TEXT"
		echo "dataSpan: $dataSpan :: download url: $dwUrl"
	fi
	
	DW_PAGE_DATA="$( wget -qO - $dwUrl )" || error_handler 5 "$?"
	# no wget failure, but null data
	if [ -z "$DW_PAGE_DATA" ];then
		error_handler 6
	fi
}

print_distro_ranking()
{
	local dwWorkingData='' dwDistroRanking='' dwDistroHits='' dwDistroStatus='' 
	local bPrintLine='false' bIsMultiple='false' lineData='' item='' dwHitData=''
	local charCount=0 maxCount=0 charCount=''
	
	if [ "$( wc -w <<< $DISTRO )" -gt 1 ];then
		bIsMultiple='true'
		echo "Distrowatch.com $TIME_TEXT rankings:"
	fi
	# first get max length of distro name to set printf
	for item in $DISTRO
	do
		charCount=$(wc -c <<< $item)
		if [ "$charCount" -gt "$maxCount" ];then
			maxCount=$charCount
		fi
	done
	((maxCount++))
	
	for item in $DISTRO
	do
		# slice out distro name line and 1 line above/below it, then the two lines below ranking
# 		dwWorkingData=$( grep -iB 1 -A 1 "<td class=\"News\"><a href=\"$item\">" <<< "$DW_PAGE_DATA" | grep -iEA 2 "<th class=\"News\">[0-9]+</th>" )
# 		
# 		# slice out just the ranking number from those 3 lines
# 		dwDistroRanking=$( grep -iE "<th class=\"News\">[0-9]+</th>" <<< "$dwWorkingData" | grep -Eo '[0-9]+' )
# 		# then the hits and status indicator, using the line after the distro name line
# 		dwDistroHits=$( grep -iEA 1 "<a href=\"$item\">" <<< "$dwWorkingData" | grep -Eo '>[0-9]+<' | grep -Eo '[0-9]+' )
# 		dwDistroStatus=$( grep -iEA 1 "<a href=\"$item\">" <<< "$dwWorkingData" | grep -ioE '(aup|alevel|adown)\.png' )
		
		dwWorkingData=$( grep -iB 1 -A 1 "<td class=\"phr2\"><a href=\"$item\">" <<< "$DW_PAGE_DATA" | grep -iEA 2 "<th class=\"phr1\">[0-9]+</th>" )
		
		# slice out just the ranking number from those 3 lines
		dwDistroRanking=$( grep -iE "<th class=\"phr1\">[0-9]+</th>" <<< "$dwWorkingData" | grep -Eo '>[0-9]+<' | grep -Eo [0-9]+ )
		# then the hits and status indicator, using the line after the distro name line
		dwDistroHits=$( grep -iEA 1 "<a href=\"$item\">" <<< "$dwWorkingData" | grep -Eo '>[0-9]+<' | grep -Eo '[0-9]+' )
		dwDistroStatus=$( grep -iEA 1 "<a href=\"$item\">" <<< "$dwWorkingData" | grep -ioE '(aup|alevel|adown)\.png' )
		bPrintLine='false'
		
		if [ "$B_DEBUGGER" == 'true' ];then
			echo "Step 2: post wget data"
			echo "$item dwWorkingData: $dwWorkingData"
			echo "$item dwDistroRanking: $dwDistroRanking"
			echo "$item dwDistroHits: $dwDistroHits"
			echo "$item dwDistroStatus: $dwDistroStatus"
			echo "End Debugging"
			echo $LINE
		fi
		# then make status nice for printout
		case $dwDistroStatus in
			aup.png)	
				dwDistroStatus='+'
				;;
			adown.png)
				dwDistroStatus='-'
				;;
			alevel.png)
				dwDistroStatus='~'
				;;
		esac
		# and set the status data
		if [ -n "$dwDistroHits" ];then
			# note that many gui irc clients make ) stuff into emoticons
			if [ "$B_TTY" == 'true' ];then
				dwHitData=" ($dwDistroHits$dwDistroStatus)"
			else
				dwHitData=" :: $dwDistroHits$dwDistroStatus"
			fi
		fi
		if [ "$bIsMultiple" != 'true' ];then
			# no distro ranking detected
			if [ -z "$dwWorkingData" ];then
				error_handler 3
			# largely non-existent condition
			elif [ -z "$dwDistroRanking" ];then
				error_handler 2 "$timeFrame"
			else
				bPrintLine='true'
				lineData="$item distrowatch.com $TIME_TEXT ranking: $dwDistroRanking$dwHitData"
			fi
		else
			# note: because irc can use various fonts with various spacing for space, just use regular output for irc
			# no distro ranking detected.
			if [ -z "$dwWorkingData" ];then
				if [ "$B_TTY" == 'true' ];then
					lineData="$( printf "%-${maxCount}s%s" "${item}:" "not ranked" )"
				else
					lineData="$( printf "%s: %s" "${item}" "not ranked" )"
				fi
			else
				if [ "$B_TTY" == 'true' ];then
					lineData="$( printf "%-${maxCount}s%s" "${item}:" "$dwDistroRanking$dwHitData" )"
				else
					lineData="$( printf "%s: %s" "${item}" "$dwDistroRanking$dwHitData" )"
				fi
			fi
			bPrintLine='true'
		fi
		if [ "$bPrintLine" == 'true' ];then
			echo "$lineData"
		fi
	done
}

## Execute
get_options "$@"
get_dw_data
print_distro_ranking

exit 0
###**EOF**###
