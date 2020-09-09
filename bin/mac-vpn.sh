#!/usr/bin/env bash
set -e

stop() {
  launchctl unload -w /Library/LaunchAgents/com.paloaltonetworks.gp.pangp*.plist
  killall -9 GlobalProtect
}

start() {
  launchctl load -w /Library/LaunchAgents/com.paloaltonetworks.gp.pangp*.plist
}

main() {
  case $1 in
    stop) stop
      ;;
    start) start
      ;;
    *) echo 'usage: stop or start'
      ;;
  esac
}

main $@
