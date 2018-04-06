module.exports = () => ({
  startupPrograms: [
    'compton -b',
    'wallpaper.sh',
    'xflux -z 84047',
    'setxkbmap -option "caps:swapescape"'
  ],
  borderWidth: 4,
  borderColor: '00ff00',
  launcher: 'dmenu_recency',
  terminal: 'zt'
})
