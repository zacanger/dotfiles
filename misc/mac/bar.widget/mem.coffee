command: "ESC=`printf \"\e\"`; ps -A -o %mem | awk '{s+=$1} END {print \"\" s}'"

refreshFrequency: 30000 # ms

render: (output) ->
  " | mem #{output}"

style: """
  -webkit-font-smoothing: antialiased
  color: #eeeeee
  font: 12px Hasklig
  right: 240px
  top: 3px
"""
