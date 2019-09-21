# `$HOME`

![screenshot](/screenshot.png?raw=true)

Please feel free to use anything you like! 
Unless otherwise noted, everything here is under the
LGPL-3.0 license.

I keep this repo at `/home/z/Dropbox/z` and symlink a lot of
stuff to `/home/z`, so there may be a few references to
those paths scattered around.

## Notes:

* Professionaly, I write Node, shell, and lots and lots of
  config. A lot of my setup is oriented around quick editing
  of text and quick navigation.
* This is shared between some Thinkpads (Ubuntu), one (work) macbook,
  and a Chromebook running Gallium.
* I use nvim, but init.vim config probably works fine with
  Vim 8 (if renamed to .vimrc)
* i3 on Linux, Spectacle on Mac.
* Bash 4 and 5, Python 3 mostly, Node latest, Neovim.
* The files called `*.list` (under `/misc`) are to keep
  track of what I need on a fresh computer.
  * `apt.list`: generated with `apt-mark showmanual`
  * `npm.list`: generated with
    [global-packages-cli](https://npmjs.org/package/global-packages-cli)
  * `pip.list`: Python 3
* On fresh computers, I sync Dropbox/z first, then run
  either `new-mac.sh` (and symlink all the things) or
  `new-linux.sh`.
