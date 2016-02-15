#!/usr/bin/env bash
#######################################################################################
#
# weatherman - display weather information from the command line
#
# (c) Copyright (c) 2012, darkhorse.nu. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
#######################################################################################
VERSION="1.1"

type -P curl &>/dev/null || { echo "Could not find curl in $PATH" >&2; exit 1; }

usage() {
    EXE=$(basename $0)
    cat << EOF
Usage:
 $EXE [options] LOCATION 

Examples:
    $EXE "Tokyo, Japan"
    $EXE -e 77001

Options:
 -m          use metric units (Celcius, millibars, millimeters)
 -e          use English units (Fahrenheit, inches)
 -S          save unit and location as defaults in ~/.weathermanrc
 -F FORMAT   print output using specified format
 -h          display this help and exit
 -v          output version information and exit

EOF
    exit
}


UNITS=1
if [[ -r "$HOME/.weathermanrc" ]]; then
    . $HOME/.weathermanrc
fi

while getopts "emSF:hv" OPTION
do
    case $OPTION in
        e)
            UNITS=0
            ;;
        m)  UNITS=1
            ;;
        S)
            SAVE_OPTIONS=1
            ;;
        F)
            FORMAT=$OPTARG
            ;;
        h)
            usage
            ;;
        v)  echo "weatherman $VERSION" 
            exit
            ;; 
        ?)
            usage
            ;;
    esac
done
[[ $UNITS = "1" ]] && TEMP_UNIT=C || TEMP_UNIT=F

shift $(( $OPTIND -1 ))
while test $# -gt 0; do
    LOC="$1"
shift
done

if [[ -z $LOC ]]; then
    usage
fi

if [[ $(echo $LOC | awk '{ if ($1 ~ /^[0-9][0-9][0-9][0-9][0-9]$/) print "1"; }') ]];
then
    PROVIDER_URI="?zip=$LOC"
    UNITS_STRING="%26units=$UNITS"
else
    LOCSTRING=$(echo $LOC | awk -F'[,/]' '{print $2"/"$1}')
    PROVIDER_URI=$(echo $LOCSTRING-weather.html | sed 's/ /%20/g')
    UNITS_STRING="?units=$UNITS"
fi

FINAL_URL=$(curl --connect-timeout 10 --max-time 10 -sL -w "%{url_effective}\\n" http://weather.weatherbug.com/$PROVIDER_URI -o /dev/null)
[[ $? > 0 ]] && { echo -en "\rConnection to data provider failed.\n"; exit 1; };

IFSOLD=$IFS
IFS="
"
for line in $(curl -f --connect-timeout 10 --max-time 10 -s -L $FINAL_URL$UNITS_STRING); do

    [[ $line =~ "tRecentLocation" ]] && { LOCATION=$(echo $line | awk -F"'" '{if ($8 == "") print $6", "$2; else print $6", "$4" "$8; }'); continue; };
    [[ $line =~ "divObsTime"      ]] && { OBSTIME=$(echo $line | sed -n '/\.*/s/.*>\(.*\)<\/div.*/\1/p'); continue; };
    [[ $line =~ "divTemp"         ]] && { TEMP_NOW=$(echo $line | sed -n '/\.*/s/.*>\(.*\)&deg.*/\1/p' | awk '{ rounded = sprintf("%.0f", $1); print rounded }'); continue; };
    [[ $line =~ "loc-windspd"     ]] && { WINDSPEED=$(echo $line | sed -n '/\.*/s/.*Speed">\(.*\)<\/span><span.*/\1/p'); continue; };
    [[ $line =~ "divWindVaneDir"  ]] && { WINDDIR=$(echo $line | sed -n '/\.*/s/.*loc-windvane-arrw-\(.*\)"><\/div.*/\1/p' | tr 'a-z' 'A-Z'); continue; };
    [[ $line =~ "divHi"           ]] && { TEMP_HIGH=$(echo $line | sed -n '/\.*/s/.*>\(.*\)&deg.*/\1/p'); continue; };
    [[ $line =~ "divLo"           ]] && { TEMP_LOW=$(echo $line | sed -n '/\.*/s/.*>\(.*\)&deg.*/\1/p'); continue; };
    [[ $line =~ "divFeelsLike"    ]] && { TEMP_INDEX=$(echo $line | sed -n '/\.*/s/.*>\(.*\)&deg.*/\1/p'); continue; };
    [[ $line =~ "divHumidity"     ]] && { HUMIDITY=$(echo $line | sed -n '/\.*/s/.*>\(.*\)%<\/span.*/\1/p'); continue; };
    [[ $line =~ "divRain"         ]] && { RAIN=$(echo $line | sed -n '/\.*/s/.*>\(.*\)<\/span.*/\1/p' | sed 's/&quot;/"/' | \
                                        awk '{ if ($1 == "0\"") print "0.00\""; \
                                               else if ($1 == "N/A\"") print "N/A"; \
                                               else print $1; }'); continue; };
    [[ $line =~ "divGust"         ]] && { GUST=$(echo $line | sed -n '/\.*/s/.*>\(.*\)<\/span.*/\1/p'); continue; };
    [[ $line =~ "divDewPoint"     ]] && { DEWPOINT=$(echo $line | sed -n '/\.*/s/.*>\(.*\)&deg.*/\1/p'); continue; };
    [[ $line =~ "divAvgWind"      ]] && { WINDAVG=$(echo $line | sed -n '/\.*/s/.*>\(.*\)<\/span.*/\1/p' | awk '{print $2" "$1}'); continue; };
    [[ $line =~ "divPressure"     ]] && { PRESSURE=$(echo $line | sed -n '/\.*/s/.*>\(.*\)<\/span.*/\1/p' | sed 's/&quot;/"/'); continue; };
    [[ $line =~ "Rain/Month:"     ]] && { RAINAVG=$(echo $line | sed -n '/\.*/s/.*>\(.*\)<\/span.*/\1/p' | sed 's/&quot;/"/' | \
                                        awk '{ if ($1 == "0\"") print "0.00\""; \
                                               else if ($1 == "N/A\"") print "N/A"; \
                                               else print $1; }'); continue; };
    [[ $line =~ "Sunrise:"        ]] && { SUNRISE=$(echo $line | sed -n '/\.*/s/.*>\(.*\)<\/span.*/\1/p'); continue; };
    [[ $line =~ "Sunset:"         ]] && { SUNSET=$(echo $line | sed -n '/\.*/s/.*>\(.*\)<\/span.*/\1/p'); continue; };
    [[ $line =~ "divStationName"  ]] && { STATION=$(echo $line | sed -n '/\.*/s/.*>\(.*\)<\/span.*/\1/p' | sed 's/\s$//'); continue; };
    [[ $line =~ "mphase"          ]] && { MOONPHASE=$(echo $line | sed -n '/\.*/s/.*mphase\(.*\).png".*/\1/p' | \
                                        awk '{ if ($1 == "01") print "New"; \
                                               else if ($1 ~ /^0[2-6]$/) print "Waxing Crescent"; \
                                               else if ($1 == "07") print "First Quarter"; \
                                               else if ($1 ~ /^0[8-9]$/ || $1 ~ /1[0-3]/) print "Waxing Gibbous"; \
                                               else if ($1 == "14") print "Full"; \
                                               else if ($1 ~ /^1[4-9]$/ || $1 == "20") print "Waning Gibbous"; \
                                               else if ($1 == "21") print "Last Quarter"; \
                                               else if ($1 ~ /^2[2-6]$/) print "Waning Crescent"; \
                                               else print "--"; }'); continue; };

    [[ $line =~ "loc-forecast"   ]] && FC_BEGIN=1
    [[ $line =~ "loc-changestat" ]] && break;

    if [[ $FC_BEGIN ]]; then
        [[ $line =~ "<h3>" ]] && FC_TIME+=( $(echo $line | sed -n '/\.*/s/.*<h3>\(.*\)<\/h3>.*/\1/p') )
        [[ $line =~ "<img" ]] && FC_DETAIL+=( $(echo $line | sed -n '/\.*/s/.* alt="\(.*\)" border.*/\1/p') )
    fi

done
IFS=$IFSOLD

# Assume we didn't get anything from the provider if OBSTIME is empty and exit
if [[ -z $OBSTIME ]]; then
    echo "No data.";
    exit 1;
fi

if [[ $FORMAT ]]; then
    declare -A metamap
    metamap[%u]=$TEMP_UNIT
    metamap[%l]=$LOCATION
    metamap[%a]=$STATION
    metamap[%o]=$OBSTIME
    metamap[%c]=$TEMP_NOW
    metamap[%T]=$TEMP_HIGH
    metamap[%t]=$TEMP_LOW
    metamap[%i]=$TEMP_INDEX
    metamap[%h]=$HUMIDITY
    metamap[%d]=$DEWPOINT
    metamap[%w]=$WINDSPEED
    metamap[%W]=$WINDDIR
    metamap[%g]=$WINDAVG
    metamap[%p]=$PRESSURE
    metamap[%r]=$RAIN
    metamap[%R]=$RAINAVG
    metamap[%s]=$SUNRISE
    metamap[%S]=$SUNSET
    metamap[%m]=$MOONPHASE

    for i in "${!metamap[@]}"; do
        FORMAT=$(echo -n $FORMAT | sed s/$i/"${metamap[$i]}"/g)
    done
  
    for i in $(echo $FORMAT | grep -o '%*%.*'); do

        # Handle literal %%
        if [[ $i =~ ^%%.*$ ]]; then
            LTRL_END=$(echo $i | sed -n '/\.*/s/^..\(.*\)/\1/p')
            
            if [[ $LTRL_END =~ ^% ]]; then
                echo "$LTRL_END is not a valid format sequence."
                exit 1
            else
                FORMAT=$(echo -n $FORMAT | sed s/%%$LTRL_END/%$LTRL_END/)
            fi
        else
            echo "$i is not a valid format sequence."
            exit 1
        fi

   done

    echo -e $FORMAT

else
    echo "weatherman $VERSION ( http://darkhorse.nu )"
    echo ""
    echo "Current Conditions for $LOCATION"
    echo "Reported by $STATION @ $OBSTIME"
    echo ""
    echo "Temp: $TEMP_NOW $TEMP_UNIT"
    echo "${FC_TIME[0]}: ${FC_DETAIL[0]}"
    echo "${FC_TIME[1]}: ${FC_DETAIL[1]}"
    echo ""
    echo -n "High: $TEMP_HIGH $TEMP_UNIT";     BFRLEN=$((11 - ${#TEMP_HIGH})); for((i=1;i<=$BFRLEN;i++)); do echo -n " "; done
    echo -n "Wind Speed: $WINDDIR $WINDSPEED"; BFRLEN=$((7 - (${#WINDSPEED} + ${#WINDDIR}))); for((i=1;i<=$BFRLEN;i++)); do echo -n " "; done
    echo "Rain: $RAIN"
    echo -n "Low: $TEMP_LOW $TEMP_UNIT"; BFRLEN=$((12 - ${#TEMP_LOW})); for((i=1;i<=$BFRLEN;i++)); do echo -n " "; done
    echo -n "Gust: $GUST";               BFRLEN=$((14 - ${#GUST})); for((i=1;i<=$BFRLEN;i++)); do echo -n " "; done
    echo "Rain/Month: $RAINAVG"
    echo -n "Feels Like: $TEMP_INDEX $TEMP_UNIT"; BFRLEN=$((5 - ${#TEMP_INDEX})); for((i=1;i<=$BFRLEN;i++)); do echo -n " "; done
    echo -n "Avg Wind: $WINDAVG";                 BFRLEN=$((10 - ${#WINDAVG})); for((i=1;i<=$BFRLEN;i++)); do echo -n " "; done
    echo "Sunrise: $SUNRISE"
    echo -n "Humidity: $HUMIDITY%";  BFRLEN=$((8 - ${#HUMIDITY})); for((i=1;i<=$BFRLEN;i++)); do echo -n " "; done
    echo -n "Pressure: $PRESSURE";  BFRLEN=$((10 - ${#PRESSURE})); for((i=1;i<=$BFRLEN;i++)); do echo -n " "; done
    echo "Sunset: $SUNSET"
    echo -n "Dew Point: $DEWPOINT $TEMP_UNIT"; BFRLEN=$((26 - ${#DEWPOINT})); for((i=1;i<=$BFRLEN;i++)); do echo -n " "; done
    echo "Moonphase: $MOONPHASE"
    echo ""
    echo "Data provided by WeatherBug.com"
fi

if [[ $SAVE_OPTIONS ]]; then

    cat > ~/.weathermanrc <<EOF
LOC="$LOC"
UNITS=$UNITS
EOF

    echo -e "\nSaved settings to ~/.weathermanrc"
fi

exit 0
