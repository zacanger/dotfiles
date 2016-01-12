## G
I like to get myself around quickly and easily. These functions are super useful for this.  
They work in Bash (but are evidently compatible with other shells, with minor adjustments  
like removing the `()`).

### Usage
- `g`  — return to a saved directory
  - `g home` returns to `home` (defaults to `_back`)
- `ga` — list all saved directories
  - `ga` — `ga` lists all directories saved in `~/.g/`; it can take a pattern (egrep)
  - note, this pattern applies to both the saved name and the path it represents
- `gt` — save cwd
  - `gt` — `cd ~/`, `gt home` will save the current directory as `home` (defaults to `_back`)

#### Details
Store a path with `gt` (for _there_). This saves your `cwd` to `~/.g/`, in a file with the  
name you've assigned to this shortcut. (This way, these shortcuts last between sessions  
without needing to write to your `.bashrc` or somesuch.) You can get _back_ to that  
directory at any point by using the `g` command. And to see all available `g`s, just do  
a `ga` (for _all_).

### Installation
If you don't already use a directory for your functions, you should think about it.  
You could put something like this in your `.bashrc`:
```shell
if [-d ~/.bash_functions ]; then
    for file in ~/.bash_functions/*; do
        . "$file"
    done
fi
```
...but if you don't want to do that, you can always just put these directly in there.
```shell
function g(){ cd `cat ~/.g/${1-_back} || echo .` ; }  
function gt(){ pwd > ~/.g/${1-_back} ; echo "g ${1} will return to `pwd`" ;  }  
function ga(){ ( cd ~/.g ; grep '' * ) | awk '{ FS=":" ; printf("%-10s %s\n",$1,$2); }' | grep -i -E ${1-.\*} ; }
```
Also, `mkdir ~/.g` (so the little path files have a place to live).

#### Credits
- Original author: Malcom Dew-Jones, (GNU copyleft)
- Modified/redocumented/etc. by zacanger
