module.exports = () => ({
  startupPrograms: [
    'redshift -l 40.760780:-111.891045',
    'setxkbmap -option "caps:swapescape"'
  ],
  borderWidth: 1,
  borderColor: '9CD7A1',
  launcher: 'rofi-run.sh',
  terminal: 'alacritty',
  log: true
})
