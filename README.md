# `$HOME`

![screenshot](/screenshot.png?raw=true)

These aren't really set up specifically with other people in mind, but
please feel free to use anything you like. Just keep in mind that some
stuff might not work exactly the way you expect.

I keep this repo at `/home/z/Dropbox/z` and symlink a lot of stuff to `/home/z`,
so there may be a few references to those paths scattered around.

## Things To Know

* Professionaly, I write Node, shell, and lots and lots of config. A lot of my
  setup is oriented around quick editing of text and quick navigation.
* This is shared between Ubuntu, Debian, Arch, macOS.
* Bash 5, Python 3 mostly, Node latest, Neovim.
* The files called `*.list` (under `/misc`) are to keep track of what I need on a fresh computer.
  * `apt.list`: generated with `apt-mark showmanual`
  * `arch.list`: Things to install on a brand-new Manjaro/i3 install, generated with `pacman -Qqe`. Some of these might need `yaourt` or whatever's cool this week.
  * `npm.list`: `npm i -g` all these things, generated with [global-packages-cli](https://npmjs.org/package/global-packages-cli)
  * `pip.list`: Python 3
  * `go.list`: `go get -u` this stuff
  * `gem.list`: I guess I need Ruby
* On a fresh Mac, first sync Dropbox, then run `new-mac.sh` and symlink all the shit.
* On fresh Arch or Debian, sync Dropbox and run `new-linux.sh`.

Unless otherwise noted, everything here is under the MIT license.
