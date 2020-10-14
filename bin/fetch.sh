#!/usr/bin/env bash
set -e

# Originally from https://gitlab.com/jschx/ufetch/
# Just enough of a screenfetch/neofetch/whatever for me

host="$(hostname)"
os="$(lsb_release -ds)"
kernel="$(uname -sr)"
uptime="$(uptime -p | sed 's/up //')"
apt_packages=$(dpkg -l | wc -l)
snap_packages=$(snap list | wc -l)
packages=$((apt_packages + snap_packages))
shell="$(basename "$SHELL") $BASH_VERSION"
ui="$(tail -n 1 "${HOME}/.xinitrc" | cut -d ' ' -f 2)"
ui="$(basename "${ui}")"
term="$TERMINAL"

cat <<EOF

  ${USER}@${host}

  os:        ${os}
  kernel:    ${kernel}
  uptime:    ${uptime}
  packages:  ${packages}
  shell:     ${shell}
  wm:        ${ui}
  term:      ${term}

EOF
