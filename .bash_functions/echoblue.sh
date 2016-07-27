echoblue() {
	echo
	echo -ne "\e[34m\e[1m ● "
	echo -n "$@"
	echo -e "\e[0m"
}
