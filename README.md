my `~/`

there are further docs in with the scripts and the doc directory.

these are very definitely my own personal configs, not really set up with others' uses in mind, but please feel free fork/grab/download/use away.

this repo is kept in dropbox (yes, i know, nonfree services…) for super extra convenience. 90% of what's in here is symlinked into `/home/z`, so there may be references to this path scattered about.

things to know:

* i use debian sid
* on three laptops of _vastly_ varying age and specs
* bash
* python 3 when possible
* i've switched to neovim, so while most vim configs will be compatible, that's just something to keep in mind
* i don't actually know perl, not really
* the scripts here are slowly being weeded out, and many longer, more complex ones are being replaced
  * it used to be that almost all of them were found/copied (and they should all have proper attribution, i believe)
  * the original scripts written in node, ruby, php, shell, and python are growing in number
    * especially the node ones
* the lists are meant for fresh debian installs (on sid, ish)
  * `the.list`  --  /etc/apt/sources.list.d/the.list
  * `unused.list`  --  unused sources.list entries
  * `dpkg.list`  --  actually `apt-get install -fy` list, but that's not so succinct
  * `npm.list`  --  `npm i -g` all these things
  * `pip2.list`  --  lol what's a ven
  * `pip3.list`  --  or ~~pip3.4~~ pip3.5, or pip3.seventeen, or python6-easy_pip.tools... whatever works
* i mostly use vim, though i really enjoy lighttable.
  * i don't use vs code, ever, but saved that config file from the one time that i gave in and tried it out. it's actually still a total piece of crap, as it happens, and its license is just _absurd_.
  * textadept configs might be kind of very messy, since i only comprehend about 30% of what i'm trying to write in lua
  * the nanorc and files will make your life _so much better_ (if you don't want to learn vi). seriously, especially for those who use graphical editors but also have virtual servers somewhere, just grab these bits and `export EDITOR='nano'`. you'll be delighted.

