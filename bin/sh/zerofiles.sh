#!/bin/bash
# Copyright (c) 2012 fbt <fbt@fleshless.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#   - Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#   - Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# About:
# A simple upload script for ZFH (http://zerofiles.org)

# Defaults
url_regex='^[a-z]+://.+'

tmp_dir='/tmp'
tmp_file="$tmp_dir/sup_tmp_$RANDOM"

script_url='http://zfh.so/upload'

default_tags='sup'
# /Defaults

[[ -f $HOME/.suprc ]] && { source $HOME/.suprc; }

usage() {
cat << EOF
Usage: $0 [-c title] [-t tags] [-RsF] [-D num] [file/url]
	-c			Comment/title (deprecated, optional)
	-t			File tags
	-R			Set to remove file after uploading (local fs only, obviously)
	-s			Grab a screenshot to upload instead of a file/url
	-F			Make a fullscreen shot instead of a selected window/area
	-D [num]	Delay the screenshot for [num] seconds
	-h			Show this message
EOF
}

while getopts "c:t:D:sFrRh" option; do
	arg="$OPTARG"

	case $option in
		c) comment="$arg";;
		t) tagstr="$arg";;

#		r) set_recursive='yes';;
		R) file_remove='yes';;

		s) scn='1';;
		F) scn_fs='1';;
		D) scn_delay="$arg";;

		h) usage; exit;;
	esac
done

[[ "$OPTIND" ]] && { shift $(($OPTIND-1)); }

cleanup() {
	[[ -f "$tmp_file" ]] && {
		rm "$tmp_file"
	}
}

upload() {
	[[ "$tagstr" ]] || { tagstr="sup"; }
	[[ "$comment" ]] || { comment="Uploaded: `date +%Y.%m.%d\ at\ %H:%M:%S`"; }

	curl -b "$HOME/.cookies" -F file="@$file" \
		-F tags="$tagstr" \
		-F upload_mode='api' \
		-F submit="" \
		"$script_url" -s -L -A 'Sup Phost'

	[[ "$file_remove" ]] && { rm "$file"; }
}

check_if_url() {
	echo "$1" | grep -oE "$url_regex" &>/dev/null && { return 0; }; return 1
}


trap "cleanup" EXIT

[[ "$scn" ]] && {
	scn_cmd='scrot'
	tags="$tags, screenshot"

	[[ "$scn_fs" ]] || { scn_cmd="${scn_cmd} -s"; }
	[[ "$scn_delay" ]] && { scn_cmd="${scn_cmd} -d ${scn_delay}"; }

	${scn_cmd} "${tmp_file}.png"; file="$tmp_file.png"
} || {
	[[ "$1" ]] || { echo "No file specified"; exit 1; }

	check_if_url "$1" && {
		[[ "$comment" ]] || { comment="Source: $1, uploaded: `date +%Y.%m.%d\ at\ %H:%M:%S`"; }
		curl -s "$1" > "$tmp_file"; file="$tmp_file"
	} || {
		[[ "$comment" ]] || { comment="Filename: ${1##*/}, uploaded: `date +%Y.%m.%d\ at\ %H:%M:%S`"; }
		file="$1"
	}
}

file_type=`file -ib "$file" | cut -d';' -f1`
[[ "$file_type" == "text/html" ]] || [[ "$file_type" == "application/x-empty" ]] && { exit 1; }

# DEBUG
upload
