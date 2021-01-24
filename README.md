# `$HOME`

See <https://github.com/zacanger/junk/tree/master/dotfiles-archive> for old
Git history. I archived the repo and started fresh due to huge Git directory
size.

I keep this repo at `$HOME/Dropbox/z`, and my setup scripts (see below for
details) link everything to `$HOME/`. This repo is laid out exactly the same way
as it is in my home directory on Linux machines, with the exception of this
readme, the license file, the `misc` directory, and the `.github` directory,
which don't get symlinked or copied over.

## What I Use

* OS: Ubuntu LTS, macOS
* Window manager: plain i3, very light config, i3status; Rectangle
* Terminal: xterm, Terminal.app
* File manager: Ranger
* Editor: Vim
* Browser: Firefox
* Shell: Bash, with lots of aliases and handy functions. `~/.bashrc`
    mostly just sources a bunch of stuff in `~/.bash/`

## Notes

* `~/bin/mac-*` is all Mac-specific scripts. Several aliases and functions are
    written to be compatible with both Mac and Linux.
* `~/bin/new-linux.sh` and the files at `misc/*.list` are for setting up new
    Linux machines.
* I mostly work with configs, shell scripts, and some Python and Node, so my
    setup is oriented towards quick navigation and editing.
* Unless otherwise noted, everything here is under the LGPL-3.0 license.
