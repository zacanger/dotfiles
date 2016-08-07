tolower() {
  local string="$*"
  local command=

  if [[ -n "$string" && "$string" != "-" ]]; then
    command="echo $string | "
  fi

  eval "$command tr '[:upper:]' '[:lower:]'"
}

