#!/usr/bin/env bash

#
# Setup.
#

VERSION="0.0.1"
PLATFORMS=("node go")
FRAMEWORKS=("meteor rails express sinatra")
PKGMANAGERS=("npm brew mrt bower apm duo component gem")
DATABASES=("postgres")

#
# Display usage information.
#

display_help() {
  cat <<-EOF

  Usage: summary [options]

  Commands:

    summary         Output summary of all installed platforms, frameworks, and package managers

  Options:

    -V, --version   Output current version of summary
    -h, --help      Display help information
EOF
  exit 0
}

#
# Display summary version.
#

display_summary_version() {
  echo $VERSION && exit 0
}

#
# Check.
#

check () {
  if [[ -e `which $i` ]]; then
    printf "$i\n"
  fi
}

#
# Display platforms.
#

display_platforms() {
  printf "\033[35mPlatforms\033[0m\n"
  for i in $PLATFORMS; do
    check $i
  done
  echo
}

#
# Display frameworks.
#

display_frameworks() {
  printf "\033[36mFrameworks\033[0m\n"
  for i in $FRAMEWORKS; do
    check $i
  done
  echo
}

#
# Display package managers.
#

display_pkgmanagers() {
  printf "\033[32mPackage Managers\033[0m\n"
  for i in $PKGMANAGERS; do
    check $i
  done
  echo
}

#
# Display databases.
#

display_databases() {
  printf "\033[33mDatabases\033[0m\n"
  for i in $DATABASES; do
    check $i
  done
  echo
}

#
# Display summary.
#

display_summary() {
  echo
  display_platforms
  display_frameworks
  display_pkgmanagers
  display_databases
}

#
# Handle arguments.
#

if test $# -eq 0; then
  display_summary
else
  while test $# -ne 0; do
    case $1 in
      -V|--version) display_summary_version ;;
      -h|--help|help) display_help ;;
      *) display_summary; exit ;;
    esac
    shift
  done
fi
