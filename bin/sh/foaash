#!/bin/bash
#
# Author: Remy van Elst, https://raymii.org
# 
# This program is free software; you can redistribute it and/or modify it 
# under the terms of the GNU General Public License as published by the 
# Free Software Foundation; either version 2 of the License, or (at your 
# option) any later version.
# 
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along 
# with this program; if not, write to the Free Software Foundation, Inc., 
# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
# 

FOAAS_URL="http://foaas.com/"
FOAAS_FROM_ENDPOINTS=("this" "that" "everything" "everyone" "pink" "life" "thanks" "flying" "fascinating")
FOAAS_FROM_NAME_ENDPOINTS=("off" "you" "donut" "shakespeare" "linus" "king" "chainsaw" "madison")

USER="$(whoami)"

RAND_FROM_ENDPOINT="${FOAAS_FROM_ENDPOINTS[$RANDOM % ${#FOAAS_FROM_ENDPOINTS[@]} ]}"
RAND_FROM_NAME_ENDPOINT="${FOAAS_FROM_NAME_ENDPOINTS[$RANDOM % ${#FOAAS_FROM_NAME_ENDPOINTS[@]} ]}"

CURL_COMM="curl -s -H \"Accept: text/plain\""

usage() {
    echo "foaas.sh - command line Fuck Off as a Service client"
    echo "Usage:"
    echo "${0} [name|/:from endpoint]"
    echo
    echo "${0} [name] [from]"
    echo "${0} [/:name/:from endpoint] [name]"
    echo
    echo "${0} [/:name/:from endpoint] [name] [from]"
    echo
    echo "Endpoint is random by default."
    echo "All arguments are optional, unix username is used by default. "
    echo "When xclip is installed, the result will also be on your clipboard."
    echo
    echo "/:from endpoints: ${FOAAS_FROM_ENDPOINTS[*]}"
    echo "/:name/:from endpoints: ${FOAAS_FROM_NAME_ENDPOINTS[*]}"
    echo
}

in_array() {
    local haystack needle=$1
    shift
    for haystack; do
        [[ ${haystack} == ${needle} ]] && return 0
    done
    return 1
}

echo_clipboard() {
    if [[ "$(which xclip)" ]]; then
        echo $@ | xclip -selection c
    fi
    echo $@
}

if [[ "$#" == "0" ]]; then
    F_URL="${FOAAS_URL}${RAND_FROM_ENDPOINT}/${USER^}"
    echo ${F_URL}
    F_O="$(${CURL_COMM} ${F_URL})"
    echo_clipboard "${F_O}"
    exit
fi

if [[ "$#" == "1" ]]; then
    if [[ "$1" == "help" ]]; then
        usage
        exit
    else
        in_array $1 ${FOAAS_FROM_ENDPOINTS[@]}
        if [[ $? -eq 0 ]]; then
            F_ENDPOINT="$1"
            F_URL="${FOAAS_URL}${F_ENDPOINT}/${USER^}"
            echo ${F_URL}
            F_O="$(${CURL_COMM} ${F_URL})"
            echo_clipboard "${F_O}"
            exit
        else
            F_NAME="$1"
            F_URL="${FOAAS_URL}${RAND_FROM_NAME_ENDPOINT}/${F_NAME^}/${USER^}"
            echo ${F_URL}
            F_O="$(${CURL_COMM} ${F_URL})"
            echo_clipboard "${F_O}"
            exit
        fi
    fi
fi

if [[ "$#" == "2" ]]; then
    in_array $1 ${FOAAS_FROM_NAME_ENDPOINTS[@]}
    if [[ $? -eq 0 ]]; then
        F_NAME="$2"
        F_ENDPOINT="$1"
        F_URL="${FOAAS_URL}${F_ENDPOINT}/${F_NAME^}/${USER^}"
        echo ${F_URL}
        F_O="$(${CURL_COMM} ${F_URL})"
        echo_clipboard "${F_O}"
        exit
    else
        F_NAME="$1"
        F_FROM="$2"
        F_URL="${FOAAS_URL}${RAND_FROM_NAME_ENDPOINT}/${F_NAME^}/${F_FROM^}"
        echo ${F_URL}
        F_O="$(${CURL_COMM} ${F_URL})"
        echo_clipboard "${F_O}"
        exit
    fi
fi

if [[ "$#" == "3" ]]; then
    F_ENDPOINT="$1"
    F_NAME="$2"
    F_FROM="$3"
    F_URL="${FOAAS_URL}${F_ENDPOINT}/${F_NAME^}/${F_FROM^}"
    echo ${F_URL}
    F_O="$(${CURL_COMM} ${F_URL})"
    echo_clipboard "${F_O}"
    exit
fi

usage

