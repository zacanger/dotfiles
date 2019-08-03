1. reboot while holding escape and the 'refresh' looking button
1. set up developer mode (ctrl+d skips pauses/screens)
  - the funky 'your shit is fucked' screen is not real, just ctrl+d
1. after reboot, enable debugging features i guess
1. after reboot again, switch to vt2 (the forward key is f2) and set up a password
1. go back and ctrl+alt+t, enter 'shell'
1. follow the crouton install instructions
1. `crouton -r xenial -t x11,cli-extra`
   - crouton says xenial is the most recent supported ubuntu, so i guess just go with that
1. `sudo enter-chroot -n xenial` and do all the setup there (install i3, set up xinitrc, etc)
1. put some kinda start alias in the chronos .bashrc, like `alias start='sudo enter-chroot -n xenial xinit'`
1. get back in and finish setup from bits of bin/new-linux.sh
