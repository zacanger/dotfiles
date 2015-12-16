# find directory and cd to it.  awesome for drupal modules with known names 8 dirs deep
function fd() {
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

