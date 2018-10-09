command: "ESC=`printf \"\e\"`; ps -A -o %mem | awk '{s+=$1} END {print \"\" s}'"

refreshFrequency: 30000 # ms

render: (output) ->
  "mem #{output}"

style: """
  -webkit-font-smoothing: antialiased
  color: #D5C4A1
  font: 12px Hasklig
  right: 220px
  top: 3px
"""
