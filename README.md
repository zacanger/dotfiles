my `$HOME`

Check my doc repo for documentation, and also in the `bin` dir.

These aren't really set up specifically with other people in mind, but
please feel free to use anything you like. Just keep in mind that some
stuff might not work exactly the way you expect.

I keep this repo in Dropbox and symlink most things to `/home/z`, so there
may be some references to that path scattered around.

I'm making an effort to fix the following:

* Loads of crap under `bin/` that I never use
* Way too many global Python and Node modules that I never use
* Changing references to `/home/z` or `~/` to `$HOME`
* Eventually, Bashisms

Things to know:

* This is shared between four Debian Sid laptops and one (work) Mac.
* Bash 4, Python3 when possible, Node latest, Neovim.
* I don't know Perl.
* There's an older archive branch and an old old repo of old old configs.
* I'm trying to weed out everything under `bin` because there's a crapton
  there that I've probably only used once or twice.
* The files called `*.list` are to keep track of what I need on a fresh PC.
  * `the.list`  --  /etc/apt/sources.list.d/the.list
  * `unused.list`  --  unused sources.list entries
  * `dpkg.list`  --  actually `apt-get install -fy` list, but that's not so succinct
    * This is generated with the following:
    `comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)`
  * `npm.list`  --  `npm i -g` all these things
    * generated with [global-packages-cli](https://npmjs.org/package/global-packages-cli)
  * `pip.list`  --  i try to use 3 as much as possible but some of these might actually be 2
    * generated with `pip list`
* I have two directories hidden from git (`~/x/` and `~/bin/x/`);
  they're referenced in some other files, and hold executables that are either totally
  non-free, totally non-original, totally full of extra stuff i don't want in my path
  (because my path is defined in a very not-safe way…), or just totally too large to want
  to put under version control.
