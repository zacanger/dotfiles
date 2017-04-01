# Simple calculator
calc() {
  local result=""
  result="$(printf "scale=10;%s\n" "$*" | bc --mathlib | tr -d '\\\n')"
  #						└─ default (when `--mathlib` is used) is 20

  if [[ "$result" == *.* ]]; then
    # improve the output for decimal numbers
    # add "0" for cases like ".5"
    # add "0" for cases like "-.5"
    # remove trailing zeros
    printf "%s" "$result" |
    sed -e 's/^\./0./'  \
      -e 's/^-\./-0./' \
      -e 's/0*$//;s/\.$//'
  else
    printf "%s" "$result"
  fi
  printf "\n"
}
