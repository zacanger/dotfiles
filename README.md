Archived dotfiles repo due to large repo size

# `$HOME`

Unless otherwise noted in the file, everything here is under the LGPL-3.0
license, so feel free to to fork or copy out anything useful to you.

I keep this repo at `/home/z/Dropbox/z`, and my setup scripts (see below for
details) link everything to `$HOME/`. This repo is laid out exactly the same way
as it is in my home directory on Linux machines, with the exception of this
readme, the license file, the `misc` directory, and the `.github` directory,
which don't get symlinked or copied over.

## What I Use

* Hardware: Thinkpads
* OS: Ubuntu 20.04 (I've tried every distro out there, this is fine for me)
* Window manager: plain i3, very light config, i3status
* Terminal: [st fork](https://github.com/zacanger/st)
* File manager: Ranger
* Editor: Neovim, but my configs probably work fine for Vim too
* Browser: Firefox
* Shell: Bash, with lots of aliases and handy functions. `~/.bashrc`
  mostly just sources a bunch of stuff in `~/.bash/`

## Notes

* I have WSL 2 on a spare laptop, but barely use it. Most of what's in here
  works fine, except for graphical apps and Snapcraft.
* I also have a work Macbook, which uses
  [Rectangle](https://github.com/rxhanson/Rectangle) for window placement.
  `~/bin/mac-new.sh` is the setup script for this. It's incomplete, symlinks
  are manual.
* I mostly write a lot of config and little shell scripts, plus some Node and
  Python, so my tools are optimized for quick editing of text and quick
  navigation.
* The files called `*.list` (under `/misc`) are to keep track of what I need on
  a fresh computer.
  * `apt.list`: generated with `apt-mark showmanual`
  * `npm.list`: generated with
    [global-packages-cli](https://npmjs.org/package/global-packages-cli)
  * `pip.list`: Python 3
* On fresh computers, I first sync `~/Dropbox/z`, then run each block in
  `~/bin/new-linux.sh` at a time.
