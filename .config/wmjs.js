module.exports = () => ({
  startupPrograms: [
    'wallpaper.sh',
    'xflux -z 84047',
    'setxkbmap -option "caps:swapescape"'
  ],
  borderWidth: 2,
  borderColor: '00ff00',
  launcher: 'dmenu_run',
  terminal: 'st'
})
