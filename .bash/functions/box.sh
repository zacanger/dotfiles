box() {
  t="$1xxxx"
  c=${2:-=}
  echo ${t//?/$c}
  echo "$c $1 $c"
  echo ${t//?/$c}
}
