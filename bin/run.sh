#!/usr/bin/env bash
set -e -o pipefail

# Usage example: run.sh firefox, or run.sh then enter firefox
# Bind some keys to something like $TERMINAL -e run.sh to
# replace dmenu/rofi-like launching.

app="$1"
if [ -z "$app" ]; then
  read -rp '> ' app
fi

prev_ifs=$IFS
IFS=$'\n'
desktop_dirs=(${XDG_DATA_HOME-~/.local/share}/applications /usr/share/applications)
desktop_paths=($(find "${desktop_dirs[@]}" -type f -name "*.desktop" ! -name "chrome-*-*.desktop" 2>/dev/null || :))
desktop_names=("${desktop_paths[@]##*/}")
desktop_names=("${desktop_names[@]%.desktop}")
IFS=$prev_ifs

for i in "${!desktop_names[@]}"; do
  [[ ${desktop_names[$i]} == "$app" ]] || continue

  desktop_path=${desktop_paths[$i]}
  break
done

if [[ ! ${desktop_path-} ]]; then
  cmd=$app
else
  cmd=$(grep -oP -m 1 "(?<=^Exec=).+" "$desktop_path")
  cmd=${cmd// -[[:alnum:]]* %[[:alpha:]]/}
  cmd=${cmd// %[[:alpha:]]/}
  grep -q ^Terminal=true "$desktop_path" || exec nohup setsid "$cmd" > /dev/null
fi

printf "\e]0;${cmd%% *}\a"
exec "$cmd"
