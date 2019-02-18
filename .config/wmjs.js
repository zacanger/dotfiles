module.exports = () => ({
  startupPrograms: [
    'wallpaper.sh',
    'redshift -l 40.760780:-111.891045',
    'setxkbmap -option "caps:swapescape"'
  ],
  borderWidth: 2,
  borderColor: '00ff00',
  launcher: 'dmenu_run',
  terminal: 'st'
})
