A simple powerline style prompt for my bash shell
=================================================

![shline-example](https://raw.github.com/saghul/shline/master/example.png)

# Overview

This is a simple powerline style shell line for myself. I use bash, so this project only
supports bash. If you like using another shell feel free to fork it (just as I did) and
modify it to your needs.

This project is a fork of [powerline-shell](https://github.com/milkbikis/powerline-shell)
tailored to suit my needs. The original project seems to be unmaintained, with many issues
and pull requests piling up. I also wanted something very simple, so you could say that
shline is a subset of powerline-shell. It does have some additions though.


# Segments

* Shows some important details about the git/hg branch and darcs status:
    * Displays the current branch which changes background color when the branch is dirty
    * A '+' appears when untracked files are present
    * When the local branch differs from the remote, the difference in number of commits is
      shown along with '⇡' or '⇣' indicating whether a git push or pull is pending
* Changes color if the last command exited with a failure code
* If you're too deep into a directory tree, shortens the displayed path with an ellipsis
* Shows the current Python [virtualenv](http://www.virtualenv.org/) environment
* Multi-line prompts are supported
* It's easy to customize and extend. See below for details.


# Setup

This script uses ANSI color codes to display colors in a terminal. These are
notoriously non-portable, so may not work for you out of the box, but try
setting your $TERM to `xterm-256color`, because that works for me.

* Install powerline's fonts by following the instructions [here](https://powerline.readthedocs.org/en/latest/installation.html#fonts-installation)

  * If you struggle too much to get working fonts in your terminal, you can use the "flat" mode.

* Clone this repository somewhere:

        git clone https://github.com/saghul/shline

* Copy `config.py.dist` to `config.py` and edit it to configure the segments you want. Then run

        ./install.py

* This will generate `~/.shline/shline.py`

### Configuration:

There are a few optional arguments which can be seen by running `~/.shline/shline.py --help`.

```
  --cwd-max-depth CWD_MAX_DEPTH
                        Maximum number of directories to show in path
  --mode {patched,flat}
                        The characters used to make separators between
                        segments
```

Add the following to your `.bashrc`:

        function _update_ps1() {
            local PREV_ERROR=$?
            local JOBS=$(jobs -p | wc -l)
            export PS1="$(python2.7 ~/.shline/shline.py --prev-error $PREV_ERROR --jobs $JOBS 2> /dev/null)"
        }

        export PROMPT_COMMAND="_update_ps1"


Note: Python 2 is needed, shline doesn't work with Python 3 yet.


# Customization

### Adding, Removing and Re-arranging segments

The `config.py` file defines which segments are drawn and in which order. Simply
comment out and rearrange segment names to get your desired arrangement. Every
time you change `config.py`, run `install.py`, which will generate a new
`~/.shline/shline.py` customized to your configuration. You should see the new
prompt immediately.

### Adding new types of segments

The `segments` directory contains python scripts which are injected as is into
a single file `powerline-shell.py.template`. Each segment script defines a
function that inserts one or more segments into the prompt. If you want to add a
new segment, simply create a new file in the segments directory and add its name
to the `config.py` file at the appropriate location.

Make sure that your script does not introduce new globals which might conflict
with other scripts. Your script should fail silently and run quickly in any
scenario.

Make sure you introduce new default colors in `themes/default.py` for every new
segment you create. Test your segment with this theme first.

### Themes

The `themes` directory stores themes for your prompt, which are basically color
values used by segments. The `default.py` defines a default theme which can be
used standalone, and every other theme falls back to it if they miss colors for
any segments. Create new themes by copying any other existing theme and
changing the values. To use a theme, set the `THEME` variable in `config.py` to
the name of your theme.

A script for testing color combinations is provided at `themes/colortest.py`.
Note that the colors you see may vary depending on your terminal. When designing
a theme, please test your theme on multiple terminals, especially with default
settings.

