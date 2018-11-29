command: "date +\"%H:%M\""

refreshFrequency: 10000 # ms

render: (output) ->
  " | #{output}"

style: """
  -webkit-font-smoothing: antialiased
  color: #eeeeee
  font: 12px Hasklig
  right: 10px
  top: 3px
"""
