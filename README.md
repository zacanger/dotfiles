# `$HOME`

![screenshot](/screenshot.png?raw=true)

These aren't really set up specifically with other people in mind, but
please feel free to use anything you like. Just keep in mind that some
stuff might not work exactly the way you expect.

I keep this repo in Dropbox and symlink most things to `/home/z`, so there
may be some references to that path scattered around.

## Things To Know

* This is shared between a work Mac, Arch laptop, and sometimes a Debian laptop.
* Bash 4, Python3 when possible, Node latest, Neovim.
* I don't know Perl.
* The files called `*.list` (under `/misc`) are to keep track of what I need on a fresh PC.
  * `arch.list`: Things to install on a brand-new Manjaro/i3 install, generated with `pacman -Qqe`. Some of these might need `yaourt`.
  * `npm.list`: `npm i -g` all these things, generated with [global-packages-cli](https://npmjs.org/package/global-packages-cli)
  * `pip.list`: Python 3
  * `gem.list`: I guess I need Ruby
* On a fresh Mac (we have to use those where I work), first sync Dropbox, then run `new-mac.sh` and symlink all the shit.
* I have a directory `~/bin/x` hidden from version control. It may be referenced
  in a few other files. This directory contains nonfree and/or non-original
  executables.
