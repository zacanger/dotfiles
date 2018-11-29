command: "pmset -g batt | egrep '([0-9]+\%).*' -o --colour=auto | cut -f1 -d';'"

refreshFrequency: 150000 # ms

render: (output) ->
  " | batt #{output}"

style: """
  -webkit-font-smoothing: antialiased
  font: 12px Hasklig
  top: 3px
  right: 160px
  color: #eeeeee
"""
