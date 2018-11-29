command: "date +\"%a %d %b\""

refreshFrequency: 10000

render: (output) ->
  " | #{output}"

style: """
  -webkit-font-smoothing: antialiased
  color: #eeeeee
  font: 12px Hasklig
  right: 65px
  top: 3px
"""
