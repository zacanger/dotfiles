#! /usr/bin/env bash
# 
# gh:oss6/git-check 
# 

declare -a get_array_arr

is_repo() {
	if [[ -d .git ]]; then
		return 0
	else
		return 1
	fi
}

branch_name() {
	name="$(git symbolic-ref --short HEAD 2>/dev/null)"
	retcode="$?"

	if [[ "$retcode" == "0" ]]; then
		printf %s "$name"
	else
		return 1
	fi
}

commits_to_push() {
	branch=$1
	to_push="$(git rev-list origin/$branch..$branch 2>/dev/null)"
	retcode="$?"

	if [[ "$retcode" == "0" ]]; then
		printf %s "$to_push"
	else
		return 1
	fi
}

get_array() {
	get_array_arr=()

	local str=$1
	while read -r line; do
		get_array_arr+=("$line")
	done <<< "$str"
}

# Output docs
if  [[ $# -eq 0 ]]; then
	echo "git-check  -  provides basic git repo information in your prompt"
	echo ""
	echo "usage:"
	echo "  git-check [--bash]"
	echo ""
	echo "  --bash   # Output prompt using Bash style color characters"
	echo ""
	echo "Example:"
	echo "  export PS1=\"\$PS1\\\$(git-check --bash)\""
	echo ""
	echo "  This will show your current directory and the full git-check prompt."
	echo ""
	exit
fi

# Output prompt
if is_repo && [[ "$1" == "--bash" ]]; then
	IFS='%'

	branch="$(branch_name)"
	status="$(git status --porcelain)"
	to_push="$(commits_to_push $branch)"

	# Get status array
	get_array "$status"
	status_arr=("${get_array_arr[@]}")

	# Get commits to push array
	get_array "$to_push"
	to_push_arr=("${get_array_arr[@]}")

	# Staged and ready to be committed
	iadded=0
	ideleted=0
	imodified=0
	irenamed=0
	icopied=0
	
	# Unstaged or untracked
	added=0
	modified=0
	deleted=0
	
	# Conflicted
	conflict_u=0
	conflict_t=0
	conflict_b=0

	for sline in "${status_arr[@]}"; do
		letter=${sline:0:2}
		
		case "$letter" in
			"A ") ((iadded++));;
			"D ") ((ideleted++));;
			"R ") ((irenamed++));;
			"M ") ((imodified++));;
			"C ") ((icopied++));;
			"??") ((added++));;
			" D") ((deleted++));;
			" M") ((modified++));;
			"DD"|"AA"|"UU") ((conflict_b++));;
			"AU"|"DU") ((conflict_u++));;
			"UA"|"UD") ((conflict_t++));;
			* )
		esac
	done

	ostat=("istat=($iadded A 32)" "istat=($ideleted D 32)" "istat=($imodified M 32)" "istat=($irenamed R 32)" "istat=($icopied C 32)" \
			"istat=($added A 31)" "istat=($modified M 31)" "istat=($deleted D 31)" \
			"istat=($conflict_b B 33)" "istat=($conflict_u U 33)" "istat=($conflict_t T 33)")

	if [ ${#to_push_arr[@]} -gt 0 -a "$to_push_arr" != "" ]; then
		prompt="| git:($branch ${#to_push_arr[@]} \\033[0;32m\xe2\x86\x91\\033[0m) "
	else
		prompt="| git:($branch) "
	fi

	for elt in "${ostat[@]}"; do
		eval $elt
		count="${istat[0]}"
		text="${istat[1]}"
		colour="${istat[2]}"

		if [ $count -gt 0 ]; then
			prompt="${prompt}${count}\\033[0;${colour}m${text}\\033[0m "
		fi
	done

	echo -e $prompt

	unset IFS
else
	echo ""
fi

