command: "ESC=`printf \"\e\"`; ps -A -o %cpu | awk '{s+=$1} END {printf(\"%.2f\",s/8);}'"

refreshFrequency: 2000 # ms

render: (output) ->
  "cpu #{output}"

style: """
  -webkit-font-smoothing: antialiased
  color: #eeeeee
  font: 12px Hasklig
  right: 330px
  top: 3px
"""
