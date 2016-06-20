echogrey() {
	echo
	echo -ne "\e[30m\e[1m ✘ "
	echo -n "$@"
	echo -e "\e[0m"
}

