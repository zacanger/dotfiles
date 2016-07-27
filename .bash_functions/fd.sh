# find dir, cd to it
fd() {
  SEARCH=$(echo "$@" | tr -d '/')
  dirs=()

  while read line ; do
    dirs+=("$line")
  done < <(find ./ -type d -name "$SEARCH" 2>/dev/null | sort)

  case ${#dirs[@]} in
    0)
      false
      ;;
    1)
      pushd "${dirs[@]}"
      ;;
    *)
      select dir in "${dirs[@]}" ; do
        pushd "$dir"
        break
      done
      ;;
  esac
}
