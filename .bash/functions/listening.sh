listening() {
  if [ -z "$1" ]; then

    lines=$(lsof -P -s TCP:LISTEN -i TCP | tail -n +2)
    pairs=$(echo -n "$lines" | awk '{split($9,a,":"); print $2":"a[2]}' | uniq)
    format_string="%5s %5s %s\n"

    if [ -n "$pairs" ]; then
      printf "$format_string" "PORT" "PID" "COMMAND"
      for pair in $pairs; do
        port="${pair/#*:}"
        proc="${pair/%:*}"
        cmnd="$(ps -p "$proc" -o command=)"

        printf "$format_string" "$port" "$proc" "${cmnd:0:$COLUMNS-12}"
      done
    fi

  else

    pid=$(lsof -P -s TCP:LISTEN -i TCP:"$1" -t | uniq)
    if [ -n "$pid" ]; then
      ps -p "$pid" -o pid,command
    fi

  fi
}
