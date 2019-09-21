* reboot while holding escape and the 'refresh' looking button
* set up developer mode (ctrl+d skips pauses/screens)
  * the funky 'your shit is fucked' screen is not real, just ctrl+d
* after reboot, enable debugging features i guess
* after reboot again, switch to vt2 (the forward key is f2) and set up a password
* go back and ctrl+alt+t, enter 'shell'
* follow the crouton install instructions
* `crouton -r xenial -t x11,cli-extra`
  * crouton says xenial is the most recent supported ubuntu, so i guess just go with that
* `sudo enter-chroot -n xenial` and do all the setup there (install i3, set up xinitrc, etc)
* put some kinda start alias in the chronos .bashrc, like `alias start='sudo enter-chroot -n xenial xinit'`
* get back in and finish setup from bits of bin/new-linux.sh

https://www.codedonut.com/chromebook/install-full-native-standalone-linux-on-any-chromebook-elementaryos/#6_Modify_the_Chromebooks_BIOS
