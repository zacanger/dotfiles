# repeat n times command
# `r 20 kk ; r 10 r 10 cn ; r 50 echo 'lol' > lol.lol `
r() {
  local i max
  max=$1; shift;
  for ((i=1; i <= max ; i++)); do
    eval "$@";
  done
}
