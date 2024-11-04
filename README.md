# `$HOME`

[Donate](https://ko-fi.com/zacanger)

See <https://github.com/zacanger/junk/tree/master/dotfiles-archive> for old
Git history. I archived the repo and started fresh due to huge Git directory
size.

I keep this repo at `$HOME/Dropbox/z`, and my setup scripts (see below for
details) link everything to `$HOME/`. This repo is laid out exactly the same way
as it is in my home directory, with the exception of this readme, the license
file, the `misc` directory, and the `.github` directory, which don't get
symlinked or copied over.

`./install.sh` is how everything gets set up. This is written to handle three
types of environments: my usual Mac machine, full Ubuntu PC installations, and
generic slim Linux installations (for use in remote environments).

## What I Use

* macOS, Rectangle, stock Terminal.app
* File manager: Joshuto
* Editor: Vim
* Browser: Firefox
* Shell: Bash, with lots of aliases and handy functions. `~/.bashrc`
    mostly just sources a bunch of stuff in `~/.bash/`

## Notes

* `~/bin/mac-*` is all Mac-specific scripts. Most aliases and functions are
    written to be compatible with both Mac and Linux.
* The files at `misc/*.list` are for installing packages.
* I mostly work with configs, shell scripts, and some Python and Node, so my
    setup is oriented towards quick navigation and editing.
* I previously mostly used Ubuntu, and before that Arch, and before that Debian,
    so some lingering bits for those distros may still be lingering around.
* Unless otherwise noted, everything here is under the MIT license.
