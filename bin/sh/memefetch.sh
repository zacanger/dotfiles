#!/usr/bin/env bash

# memeFetch - a CLI Bash script to show system/theme info in screenshots
# copyright © 2015 Rob1NN
# License: AGPLv3

author="Rob1NN <robin@rob1nn.pw>"
ver="2"

verbose="false"

#colors
c0="\033[0m" #No color
c1="\033[0m\033[36m"
c2="\033[0m\033[34m"
c3="\033[38;5;202m"
c4='\033[0;37m' #White
c5='\033[0;32m' #Green
c6='\033[1;32m' #Bold Green
cB="\033[1m" #Bold
cU="\033[4m" #Underlined

help() {
	if [[ ${#ver} > 1 ]]; then
		version="V. $ver"
	else
		version="Ver $ver "
	fi

	echo -e "################\n#### $version ####\n################\n"
	echo "# memefetch help"
	echo "## -a art / --ascii art: choose ascii art, defaults to archlinux logo"
	echo "## -h / --help: return this help page"
	echo "## -v / --version: show version"
	echo "## -V / --Verbose: enable verbosity (disables ascii art too)"
}

verbose() {
	if [[ "$verbose" == "true" ]]; then
		echo "$1"
	fi
}

#arg/optparse
case $1 in
	--ascii|-a) art="$2"; verbose "Art set to $2";;
	--help|-h) help; exit 0;;
	--version|-v) echo "Version $ver"; exit 0;;
	--Verbose|-V) verbose="true";;
esac

#ascii
if [[ "$art" == "" ]]; then
	#default to archlinux ascii
	art="arch"
fi

#distro
command -v lsb_release >/dev/null 2>&1 || distro="Unknown"
if [[ "$distro" != "Unknown" ]]; then
	distro=$(lsb_release -a | sed -n -e 's/^.*ID://p')
	distro=${distro//[[:blank:]]/}
fi
verbose "Distro: $distro"

#user
user=${USER}
if [[ "$user" == "" ]]; then
	user="Unknown"
fi
verbose "User: $user"

#host
host=${HOSTNAME}
if [[ "$host" == "" ]]; then
	host="Unknown"
fi
verbose "Hostname: $host"

#kernel
kernel=$(uname -srm)
if [[ "$kernel" == "" ]]; then
	kernel="Unknown"
fi
verbose "Kernel: $kernel"

#uptime
if [[ -f /proc/uptime ]]; then
	uptime=$(</proc/uptime)
	uptime=${uptime//.*}
	secs=$((${uptime}%60))
	mins=$((${uptime}/60%60))
	hours=$((${uptime}/3600%24))
	days=$((${uptime}/86400))
	uptime="${mins}m"
	if [ "${hours}" -ne "0" ]; then
		uptime="${hours}h ${uptime}"
	fi
	if [ "${days}" -ne "0" ]; then
		uptime="${days}d ${uptime}"
	fi
else
	uptime="Unknown"
fi
verbose "Uptime: $uptime"

#memory
if [[ -f /proc/meminfo ]]; then
	mem_total=$[$(awk '/MemTotal/ {print $2}' /proc/meminfo)/1024]
	mem_avail=$[$(awk '/MemAvailable/ {print $2}' /proc/meminfo)/1024]
	mem_used=$[mem_total-mem_avail]
else
	mem_total="Unknown"
	mem_avail="Unknown"
	mem_used="Unknown"
fi
verbose "Total Memory: $mem_total MiB"
verbose "Available Memory: $mem_avail MiB"
verbose "Used Memory: $mem_used MiB"

#cpu usage
if [[ -f /proc/stat ]]; then
	cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}')
else
	cpu_usage="Unknown"
fi
verbose "CPU Usage: $cpu_usage"

#cpu cores
if [[ -f /proc/cpuinfo ]]; then
	cpu_cores=$(awk '/^processor/{n+=1}END{print n}' /proc/cpuinfo)
else
	cpu_cores="Unknown"
fi
verbose "CPU Cores: $cpu_cores"

#errors?
u="Unknown"
if \
	[[ "$distro" == "$u" ]] ||\
	[[ "$user" == "$u" ]] ||\
	[[ "$host" == "$u" ]] ||\
	[[ "$kernel" == "$u" ]] ||\
	[[ "$uptime" == "$u" ]] ||\
	[[ "$mem_total" == "$u" ]] ||\
	[[ "$mem_avail" == "$u" ]] ||\
	[[ "$mem_used" == "$u" ]] ||\
	[[ "$cpu_usage" == "$u" ]] ||\
	[[ "$cpu_cores" == "$u" ]]; then
	verbose "Some data could not be detected automagically. Please contact $author with information about your distro."
fi
verbose ""

#display config
declare -a o=(\
"" \
"${cB}$user${c0}@${cB}$host" \
"${c3}OS:${c0} $distro" \
"${c3}Kernel:${c0} $kernel" \
"${c3}Uptime:${c0} $uptime" \
"" \
"${c3}Memory:" \
"${cB}# ${c3}Total:${c0} $mem_total MiB" \
"${cB}# ${c3}Used:${c0} $mem_used MiB" \
"${cB}# ${c3}Available:${c0} $mem_avail MiB" \
"" \
"${c3}CPU:" \
"${cB}# ${c3}Cores:${c0} $cpu_cores" \
"${cB}# ${c3}Usage:${c0} $cpu_usage" \
"" \
"" \
"" \
"" \
"" \
)

#ascii art
arch=(\
"${c1}                   -\`                    \n"\
"${c1}                  .o+\`                ${o[1]}\n"\
"${c1}                 \`ooo/                ${o[2]}\n"\
"${c1}                \`+oooo:               ${o[3]}\n"\
"${c1}               \`+oooooo:              ${o[4]}\n"\
"${c1}               -+oooooo+:             ${o[5]}\n"\
"${c1}             \`/:-:++oooo+:            ${o[6]}\n"\
"${c1}            \`/++++/+++++++:           ${o[7]}\n"\
"${c1}           \`/++++++++++++++:          ${o[8]}\n"\
"${c1}          \`/+++o"${c2}"oooooooo"${c1}"oooo/\`        ${o[9]}\n"\
"${c2}         "${c1}"./"${c2}"ooosssso++osssssso"${c1}"+\`       ${o[10]}\n"\
"${c2}        .oossssso-\`\`\`\`/ossssss+\`      ${o[11]}\n"\
"${c2}       -osssssso.      :ssssssso.     ${o[12]}\n"\
"${c2}      :osssssss/        osssso+++.    ${o[13]}\n"\
"${c2}     /ossssssss/        +ssssooo/-    ${o[14]}\n"\
"${c2}   \`/ossssso+/:-        -:/+osssso+-  ${o[15]}\n"\
"${c2}  \`+sso+:-\`                 \`.-/+oso: ${o[16]}\n"\
"${c2} \`++:.                           \`-/+/${o[17]}\n"\
"${c2} .\`                                 \`/${o[18]}\n"\
"${c0}")

nose=(\
"${c4}                      ${c5}██      \n"\
"${c4}                        ${c5}██       ${o[1]}\n"\
"${c4}  █                      ${c5}██      ${o[2]}\n"\
"${c4} █   ███                  ${c5}██     ${o[3]}\n"\
"${c4} █   ███         ${c5}██       ██     ${o[4]}\n"\
"${c4}  █             ██${c5}██       ██    ${o[5]}\n"\
"${c4}               ██  ${c5}██      ██    ${o[6]}\n"\
"${c4}              ██    ${c5}██     ██    ${o[7]}\n"\
"${c4}             ██      ${c5}██    ██    ${o[8]}\n"\
"${c4}            ██        ${c5}██   ██    ${o[9]}\n"\
"${c4}    █      ██          ${c5}██  ██    ${o[10]}\n"\
"${c4}    ████                  ${c5}██     ${o[11]}\n"\
"${c4}    ████                  ${c5}██     ${o[12]}\n"\
"${c4}    █                    ${c5}██      ${o[13]}\n"\
"${c4}                        ${c5}██       ${o[14]}\n"\
"${c4}                      ${c5}██         ${o[15]}\n"\
"${c4}                                      ${o[16]}\n"\
"${c4}  --HOW HARD CAN ${c6}YOU${c4} MEME?--${o[17]}\n"\
"${c4}                                      ${o[18]}\n"\
"${c0}")

#show information
if [[ "$verbose" == "false" ]]; then
	if [[ "${!art}" == "" ]]; then
		echo "ASCII art \"$art\" not found."
	else
		echo -e "${!art}"
	fi
fi
