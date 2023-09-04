#!/usr/bin/env bash
# based on fff by dylanaraps, MIT licensed
# also includes some changes from pierre dangauthier and
# roy-orbinson (on github; i assume not the real roy orbinson)

TRASH_DIR="$HOME/.z-trash"
# TODO:
# honestly, a lot. this is very large and includes a lot
# that i don't really care about.
# some things i already know i need to do:
# * slim it all down
# * build a convenient mime-type/opener map
# * fix all shellcheck issues
# * get rid of the custom trash implementation
# * consolidate help/usage
# * when it's ready, alias to fs, and get rid of ranger
# * copy into dotfiles-minimal when i'm happy with it

# Dependencies:
#- `coreutils`
#   - File operations.
#  `xdg-utils` (*optional*)
#   - Program handling (*non-text*).
#   - *Customizable (if not using `xdg-open`): `$FFF_OPENER`.*

manpage='
j: scroll down
k: scroll up
h: go to parent dir
l: go to child dir

enter: go to child dir
backspace: go to parent dir

-: go to previous dir

g: go to top
G: go to bottom

:: go to a directory by typing

/: search
t: go to trash
~: go to home
e: refresh current dir
!: open shell in current dir

x: view file/dir attributes

down:  scroll down
up:    scroll up
left:  go to parent dir
right: go to child dir

PgUp: page up
PgDown: page down
u: ncdu

f: new file
n: new dir
r: rename
X: toggle executable

y: mark copy
m: mark move
d: mark trash (TRASH_DIR)
b: mark bulk rename

p: paste/move/delete/bulk_rename
c: clear file selections

5: page up
6: page down

q: exit with "cd" (if enabled) or exit help
Ctrl+C: exit without "cd"

?: show help

### Customization
# Use LS_COLORS to color fff.
# (On by default if available)
# (Ignores FFF_COL1)
export FFF_LS_COLORS=1

# Show/Hide hidden files on open.
# (On by default)
export FFF_HIDDEN=0

# Directory color [0-9]
export FFF_COL1=2

# Status background color [0-9]
export FFF_COL2=7

# Selection color [0-9] (copied/moved files)
export FFF_COL3=6

# Cursor color [0-9]
export FFF_COL4=1

# Status foreground color [0-9]
export FFF_COL5=0

# Text Editor
export EDITOR="vim"

# File Opener
export FFF_OPENER="xdg-open"

# File Attributes Command
export FFF_STAT_CMD="stat"

# Enable or disable CD on exit.
# Default: "1"
export FFF_CD_ON_EXIT=1

# CD on exit helper file
# Default: "${XDG_CACHE_HOME}/fff/fff.d"
#          If not using XDG, "${HOME}/.cache/fff/fff.d" is used.
export FFF_CD_FILE=~/.fff_d

# File format.
# Customize the item string.
# Format ("%f" is the current file): "str%fstr"
# Example (Add a tab before files): FFF_FILE_FORMAT="%f"
export FFF_FILE_FORMAT="%f"

# Mark format.
# Customize the marked item string.
# Format ("%f" is the current file): "str%fstr"
# Example (Add a " >" before files): FFF_MARK_FORMAT="> %f"
export FFF_MARK_FORMAT=" %f*"

KKeeyybbiinnddiinnggss
For more information see:
   https://github.com/dylanaraps/fff#customizing-the-keybindings

### Moving around.

# Go to child directory.
export FFF_KEY_CHILD1="l"
export FFF_KEY_CHILD2=$"\[C" # Right Arrow
export FFF_KEY_CHILD3=""      # Enter / Return

# Go to parent directory.
export FFF_KEY_PARENT1="h"
export FFF_KEY_PARENT2=$"\[D" # Left Arrow
export FFF_KEY_PARENT3=$"177" # Backspace
export FFF_KEY_PARENT4=$"\b"   # Backspace (Older terminals)

# Go to previous directory.
export FFF_KEY_PREVIOUS="-"

# Search.
export FFF_KEY_SEARCH="/"

# Spawn a shell.
export FFF_KEY_SHELL="!"

# Scroll down.
export FFF_KEY_SCROLL_DOWN1="j"
export FFF_KEY_SCROLL_DOWN2=$"\[B" # Down Arrow

# Scroll up.
export FFF_KEY_SCROLL_UP1="k"
export FFF_KEY_SCROLL_UP2=$"\[A"   # Up Arrow

# Go to top and bottom.
export FFF_KEY_TO_TOP="g"
export FFF_KEY_TO_BOTTOM="G"

# Go to dirs.
export FFF_KEY_GO_DIR=":"
export FFF_KEY_GO_HOME="~"

### File operations.

export FFF_KEY_YANK="y"
export FFF_KEY_MOVE="m"
export FFF_KEY_TRASH="d"
export FFF_KEY_BULK_RENAME="b"

export FFF_KEY_PASTE="p"
export FFF_KEY_CLEAR="c"

export FFF_KEY_RENAME="r"
export FFF_KEY_MKDIR="n"
export FFF_KEY_MKFILE="f"

### Miscellaneous

# Show file attributes.
export FFF_KEY_ATTRIBUTES="x"

# Toggle executable flag.
export FFF_KEY_EXECUTABLE="X"

# Toggle hidden files.
export FFF_KEY_HIDDEN="."
'

get_os() {
    # Figure out the current operating system to set some specific variables.
    # '$OSTYPE' typically stores the name of the OS kernel.
    case $OSTYPE in
        # Mac OS X / macOS.
        darwin*)
            opener=open
            file_flags=bIL
        ;;
    esac
}

setup_terminal() {
    # Setup the terminal for the TUI.
    # '\e[?1049h': Use alternative screen buffer.
    # '\e[?7l':    Disable line wrapping.
    # '\e[?25l':   Hide the cursor.
    # '\e[2J':     Clear the screen.
    # '\e[1;Nr':   Limit scrolling to scrolling area.
    #              Also sets cursor to (0,0).
    printf '\e[?1049h\e[?7l\e[?25l\e[2J\e[1;%sr' "$max_items"

    # Hide echoing of user input
    stty -echo
}

reset_terminal() {
    # Reset the terminal to a useable state (undo all changes).
    # '\e[?7h':   Re-enable line wrapping.
    # '\e[?25h':  Unhide the cursor.
    # '\e[2J':    Clear the terminal.
    # '\e[;r':    Set the scroll region to its default value.
    #             Also sets cursor to (0,0).
    # '\e[?1049l: Restore main screen buffer.
    printf '\e[?7h\e[?25h\e[2J\e[;r\e[?1049l'

    # Show user input.
    stty echo
}

clear_screen() {
    # Only clear the scrolling window (dir item list).
    # '\e[%sH':    Move cursor to bottom of scroll area.
    # '\e[9999C':  Move cursor to right edge of the terminal.
    # '\e[1J':     Clear screen to top left corner (from cursor up).
    # '\e[2J':     Clear screen fully (if using tmux) (fixes clear issues).
    # '\e[1;%sr':  Clearing the screen resets the scroll region(?). Re-set it.
    #              Also sets cursor to (0,0).
    printf '\e[%sH\e[9999C\e[1J%b\e[1;%sr' \
           "$((LINES-2))" "${TMUX:+\e[2J}" "$max_items"
}

setup_options() {
    # Some options require some setup.
    # This function is called once on open to parse
    # select options so the operation isn't repeated
    # multiple times in the code.

    # Format for normal files.
    [[ $FFF_FILE_FORMAT == *%f* ]] && {
        file_pre=${FFF_FILE_FORMAT/'%f'*}
        file_post=${FFF_FILE_FORMAT/*'%f'}
    }

    # Format for marked files.
    # Use affixes provided by the user or use defaults, if necessary.
    if [[ $FFF_MARK_FORMAT == *%f* ]]; then
        mark_pre=${FFF_MARK_FORMAT/'%f'*}
        mark_post=${FFF_MARK_FORMAT/*'%f'}
    else
        mark_pre=" "
        mark_post="*"
    fi

    # Find supported 'file' arguments.
    file -I &>/dev/null || : "${file_flags:=biL}"

    helping=0
}

get_term_size() {
    # Get terminal size ('stty' is POSIX and always available).
    # This can't be done reliably across all bash versions in pure bash.
    read -r LINES COLUMNS < <(stty size)

    # Max list items that fit in the scroll area.
    ((max_items=LINES-3))
    ((scroll_page=max_items-5))
}

get_ls_colors() {
    # Parse the LS_COLORS variable and declare each file type
    # as a separate variable.
    # Format: ':.ext=0;0:*.jpg=0;0;0:*png=0;0;0;0:'
    [[ -z $LS_COLORS ]] && {
        FFF_LS_COLORS=0
        return
    }

    # Turn $LS_COLORS into an array.
    IFS=: read -ra ls_cols <<< "$LS_COLORS"

    for ((i=0;i<${#ls_cols[@]};i++)); {
        # Separate patterns from file types.
        [[ ${ls_cols[i]} =~ ^\*[^\.] ]] &&
            ls_patterns+="${ls_cols[i]/=*}|"

        # Prepend 'ls_' to all LS_COLORS items
        # if they aren't types of files (symbolic links, block files etc.)
        [[ ${ls_cols[i]} =~ ^(\*|\.) ]] && {
            ls_cols[i]=${ls_cols[i]#\*}
            ls_cols[i]=ls_${ls_cols[i]#.}
        }
    }

    # Strip non-ascii characters from the string as they're
    # used as a key to color the dir items and variable
    # names in bash must be '[a-zA-z0-9_]'.
    ls_cols=("${ls_cols[@]//[^a-zA-Z0-9=\\;]/_}")

    # Store the patterns in a '|' separated string
    # for use in a REGEX match later.
    ls_patterns=${ls_patterns//\*}
    ls_patterns=${ls_patterns%?}

    # Define the ls_ variables.
    # 'declare' can't be used here as variables are scoped
    # locally. 'declare -g' is not available in 'bash 3'.
    # 'export' is a viable alternative.
    export "${ls_cols[@]}" &>/dev/null
}

get_mime_type() {
    # Get a file's mime_type.
    mime_type=$(file "-${file_flags:-biL}" "$1" 2>/dev/null)
}

status_line() {
    # Status_line to print when files are marked for operation.
    local mark_ui="[${#marked_files[@]}] selected (${file_program[*]}) [p] ->"
    mark_ui="${marked_files[*]:+"$mark_ui"}"

    if ((helping)); then
        mark_ui=
        PWD_escaped=help
    else
        # Escape the directory string.
        # Remove all non-printable characters.
        PWD_escaped=${PWD//[^[:print:]]/^[}
    fi

    # '\e7':       Save cursor position.
    #              This is more widely supported than '\e[s'.
    # '\e[%sH':    Move cursor to bottom of the terminal.
    # '\e[30;41m': Set foreground and background colors.
    # '%*s':       Insert enough spaces to fill the screen width.
    #              This sets the background color to the whole line
    #              and fixes issues in 'screen' where '\e[K' doesn't work.
    # '\r':        Move cursor back to column 0 (was at EOL due to above).
    # '\e[m':      Reset text formatting.
    # '\e[H\e[K':  Clear line below status_line.
    # '\e8':       Restore cursor position.
    #              This is more widely supported than '\e[u'.
    printf '\e7\e[%sH\e[3%s;4%sm%*s\r%s %s%s\e[m\e[%sH\e[K\e8' \
           "$((LINES-1))" \
           "${FFF_COL5:-0}" \
           "${FFF_COL2:-1}" \
           "$COLUMNS" "" \
           "($((scroll+1))/$((list_total+1)))" \
           "$mark_ui" \
           "${1:-${PWD_escaped:-/}}" \
           "$LINES"
}

read_dir() {
    # Read a directory to an array and sort it directories first.
    local dirs
    local files
    local item_index

    # Set window name.
    printf '\e]2;fff: %s\e'\\ "$PWD"

    # If '$PWD' is '/', unset it to avoid '//'.
    [[ $PWD == / ]] && PWD=

    for item in "$PWD"/*; do
        if [[ -d $item ]]; then
            dirs+=("$item")

            # Find the position of the child directory in the
            # parent directory list.
            [[ $item == "$OLDPWD" ]] &&
                ((previous_index=item_index))
            ((item_index++))
        else
            files+=("$item")
        fi
    done

    list=("${dirs[@]}" "${files[@]}")

    # Indicate that the directory is empty.
    [[ -z ${list[0]} ]] &&
        list[0]=empty

    ((list_total=${#list[@]}-1))

    # Save the original dir in a second list as a backup.
    cur_list=("${list[@]}")
}

print_line() {
    # Format the list item and print it.
    local file_name=${list[$1]##*/}
    local file_ext=${file_name##*.}
    local format
    local suffix

    # Help line
    if ((helping)); then
        file_name=${list[$1]}
        if [[ "$file_name" ]]; then
            # Highlight the key(s), escaping any specials in overrides to a human-readable form
            format+=\\e[${di:-1;3${FFF_COL1:-2}}m
            local action="${file_name%: *}"
            format+="$(cat -A <<<"$action" | head -c -2)\\e[${fi:-37}m: "
            file_name="${file_name##*: }"
        fi
        format+=\\e[${fi:-37}m

    # If the dir item doesn't exist, end here.
    elif [[ -z ${list[$1]} ]]; then
        return

    # Directory.
    elif [[ -d ${list[$1]} ]]; then
        format+=\\e[${di:-1;3${FFF_COL1:-2}}m
        suffix+=/

    # Block special file.
    elif [[ -b ${list[$1]} ]]; then
        format+=\\e[${bd:-40;33;01}m

    # Character special file.
    elif [[ -c ${list[$1]} ]]; then
        format+=\\e[${cd:-40;33;01}m

    # Executable file.
    elif [[ -x ${list[$1]} ]]; then
        format+=\\e[${ex:-01;32}m

    # Symbolic Link (broken).
    elif [[ -h ${list[$1]} && ! -e ${list[$1]} ]]; then
        format+=\\e[${mi:-01;31;7}m

    # Symbolic Link.
    elif [[ -h ${list[$1]} ]]; then
        format+=\\e[${ln:-01;36}m

    # Fifo file.
    elif [[ -p ${list[$1]} ]]; then
        format+=\\e[${pi:-40;33}m

    # Socket file.
    elif [[ -S ${list[$1]} ]]; then
        format+=\\e[${so:-01;35}m

    # Color files that end in a pattern as defined in LS_COLORS.
    # 'BASH_REMATCH' is an array that stores each REGEX match.
    elif [[ $FFF_LS_COLORS == 1 &&
            $ls_patterns &&
            $file_name =~ ($ls_patterns)$ ]]; then
        match=${BASH_REMATCH[0]}
        file_ext=ls_${match//[^a-zA-Z0-9=\\;]/_}
        format+=\\e[${!file_ext:-${fi:-37}}m

    # Color files based on file extension and LS_COLORS.
    # Check if file extension adheres to POSIX naming
    # standard before checking if it's a variable.
    elif [[ $FFF_LS_COLORS == 1 &&
            $file_ext != "$file_name" &&
            $file_ext =~ ^[a-zA-Z0-9_]*$ ]]; then
        file_ext=ls_${file_ext}
        format+=\\e[${!file_ext:-${fi:-37}}m

    else
        format+=\\e[${fi:-37}m
    fi

    # If the list item is under the cursor.
    (($1 == scroll)) &&
        format+="\\e[1;3${FFF_COL4:-6};7m"

    # If the list item is marked for operation.
    !((helping)) && [[ ${marked_files[$1]} == "${list[$1]:-null}" ]] && {
        format+=\\e[3${FFF_COL3:-1}m${mark_pre}
        suffix+=${mark_post}
    }

    # Escape the directory string.
    # Remove all non-printable characters.
    file_name=${file_name//[^[:print:]]/^[}

    printf '\r%b%s\e[m\r' \
        "${file_pre}${format}" \
        "${file_name}${suffix}${file_post}"
}

draw_dir() {
    # Print the max directory items that fit in the scroll area.
    local scroll_start=$scroll
    local scroll_new_pos
    local scroll_end

    # When going up the directory tree, place the cursor on the position
    # of the previous directory.
    ((find_previous == 1)) && {
        ((scroll_start=previous_index))
        ((scroll=scroll_start))

        # Clear the directory history. We're here now.
        find_previous=
    }

    # If current dir is near the top of the list, keep scroll position.
    if ((list_total < max_items || scroll < max_items/2)); then
        ((scroll_start=0))
        ((scroll_end=max_items))
        ((scroll_new_pos=scroll+1))

    # If current dir is near the end of the list, keep scroll position.
    elif ((list_total - scroll < max_items/2)); then
        ((scroll_start=list_total-max_items+1))
        ((scroll_new_pos=max_items-(list_total-scroll)))
        ((scroll_end=list_total+1))

    # If current dir is somewhere in the middle, center scroll position.
    else
        ((scroll_start=scroll-max_items/2))
        ((scroll_end=scroll_start+max_items))
        ((scroll_new_pos=max_items/2+1))
    fi

    # Reset cursor position.
    printf '\e[H'

    for ((i=scroll_start;i<scroll_end;i++)); {
        # Don't print one too many newlines.
        ((i > scroll_start)) &&
            printf '\n'

        print_line "$i"
    }

    # Move the cursor to its new position if it changed.
    # If the variable 'scroll_new_pos' is empty, the cursor
    # is moved to line '0'.
    printf '\e[%sH' "$scroll_new_pos"
    ((y=scroll_new_pos))
}

redraw() {
    # Redraw the current window.
    # If 'full' is passed, re-fetch the directory list.
    [[ $1 == full ]] && {
        ((helping)) && {
            helping=0
            find_previous=1
        }
        read_dir
        scroll=0
    }

    # If 'help' is passed, list help text.
    [[ $1 == help ]] && {
        helping=1
        list_help
        scroll=0
    }

    clear_screen
    draw_dir
    status_line
}

list_help() {
    # Set window name.
    printf '\e]2;fff: help\e'\\

    list=(
        "${FFF_KEY_SCROLL_DOWN1:-j}: scroll down"
        "${FFF_KEY_SCROLL_UP1:-k}: scroll up"
        "${FFF_KEY_PARENT1:-h}: go to parent dir"
        "${FFF_KEY_CHILD1:-l}: go to child dir"
        ''
        'enter: go to child dir'
        'backspace: go to parent dir'
        ''
        "${FFF_KEY_PREVIOUS:--}: go to previous dir"
        ''
        "${FFF_KEY_TO_TOP:-g}: go to top"
        "${FFF_KEY_TO_BOTTOM:-G}: go to bottom"
        ''
        "${FFF_KEY_GO_DIR:-:}: go to a directory by typing"
        ''
        "${FFF_KEY_HIDDEN:-.}: toggle hidden files"
        "${FFF_KEY_SEARCH:-/}: search"
        "${FFF_KEY_GO_HOME:-~}: go to home"
        "${FFF_KEY_REFRESH:-e}: refresh current dir"
        "${FFF_KEY_SHELL:-!}: open shell in current dir"
        ''
        "${FFF_KEY_ATTRIBUTES:-x}: view file/dir attributes"
        ''
        'down:  scroll down'
        'up:    scroll up'
        'left:  go to parent dir'
        'right: go to child dir'
        ''
        "${FFF_KEY_MKFILE:-f}: new file"
        "${FFF_KEY_MKDIR:-n}: new dir"
        "${FFF_KEY_RENAME:-r}: rename"
        "${FFF_KEY_EXECUTABLE:-X}: toggle executable"
        ''
        "${FFF_KEY_YANK:-y}: mark copy"
        "${FFF_KEY_MOVE:-m}: mark move"
        "${FFF_KEY_TRASH:-d}: mark trash (TRASH_DIR)"
        "${FFF_KEY_BULK_RENAME:-b}: mark bulk rename"
        ''
        "${FFF_KEY_PASTE:-p}: paste/move/delete/bulk_rename"
        "${FFF_KEY_CLEAR:-c}: clear file selections"
        ''
        "q: exit with 'cd' (if enabled) or exit this help"
        "Ctrl+C: exit without 'cd'"
        ''
        "${FFF_KEY_HELP:-?}: show this help"
    )

    ((list_total=${#list[@]}-1))

    # Save the original list in a second list as a backup.
    cur_list=("${list[@]}")
}

mark() {
    # Mark file for operation.
    # If an item is marked in a second directory,
    # clear the marked files.
    [[ $PWD != "$mark_dir" ]] &&
        marked_files=()

    # Don't allow the user to mark the empty directory list item.
    [[ ${list[0]} == empty && -z ${list[1]} ]] &&
        return

    if [[ ${marked_files[$1]} == "${list[$1]}" ]]; then
        unset 'marked_files[scroll]'

    else
        marked_files[$1]="${list[$1]}"
        mark_dir=$PWD
    fi

    # Clear line before changing it.
    printf '\e[K'
    print_line "$1"

    # Find the program to use.
    case "$2" in
        ${FFF_KEY_YANK:=y}) file_program=(cp -iR) ;;
        ${FFF_KEY_MOVE:=m}) file_program=(mv -i)  ;;

        # These are 'fff' functions.
        ${FFF_KEY_TRASH:=d}) file_program=(trash) ;;
        ${FFF_KEY_BULK_RENAME:=b}) file_program=(bulk_rename) ;;
    esac

    status_line
}

trash() {
    # Trash a file.
    cmd_line "trash [${#marked_files[@]}] items? [y/n]: " y n

    [[ $cmd_reply != y ]] &&
        return

    cd "$TRASH_DIR" || cmd_line "error: Can't cd to trash directory."

    if cp -alf "$@" &>/dev/null; then
        rm -r "${@:1:$#-1}"
    else
        mv -f "$@"
    fi

    # Go back to where we were.
    cd "$OLDPWD" ||:
}

bulk_rename() {
    rename_file=''
    if hash mktemp 2>/dev/null; then
        rename_file=$(mktemp)
    else
        rename_file="$HOME/.fs_tmp_bulk_rename"
    fi
    # Bulk rename files using '$EDITOR'.
    marked_files=("${@:1:$#-1}")

    # Save marked files to a file and open them for editing.
    printf '%s\n' "${marked_files[@]##*/}" > "$rename_file"
    "${EDITOR:-vi}" "$rename_file"

    # Read the renamed files to an array.
    IFS=$'\n' read -d "" -ra changed_files < "$rename_file"

    # If the user deleted a line, stop here.
    ((${#marked_files[@]} != ${#changed_files[@]})) && {
        rm "$rename_file"
        cmd_line "error: Line mismatch in rename file. Doing nothing."
        return
    }

    printf '%s\n%s\n' \
        "# This file will be executed when the editor is closed." \
        "# Clear the file to abort." > "$rename_file"

    # Construct the rename commands.
    for ((i=0;i<${#marked_files[@]};i++)); {
        [[ ${marked_files[i]} != "${PWD}/${changed_files[i]}" ]] && {
            printf 'mv -i -- %q %q\n' \
                "${marked_files[i]}" "${PWD}/${changed_files[i]}"
            local renamed=1
        }
    } >> "$rename_file"

    # Let the user double-check the commands and execute them.
    ((renamed == 1)) && {
        "${EDITOR:-vi}" "$rename_file"

        source "$rename_file"
        rm "$rename_file"
    }

    # Fix terminal settings after '$EDITOR'.
    setup_terminal
}

open() {
    # Open directories and files.
    if [[ -d $1/ ]]; then
        search=
        search_end_early=
        cd "${1:-/}" ||:
        redraw full

    elif [[ -f $1 ]]; then
        # Figure out what kind of file we're working with.
        get_mime_type "$1"

        # Open all text-based files in '$EDITOR'.
        # Everything else goes through 'xdg-open'/'open'.
        case "$mime_type" in
            text/*|*x-empty*|*json*)
                clear_screen
                reset_terminal
                "${VISUAL:-${EDITOR:-vi}}" "$1"
                setup_terminal
                redraw
            ;;

            application/x-gzip*)
                clear_screen
                reset_terminal
                "zcat" "$1" | less -S
                setup_terminal
                redraw
            ;;

            *)
                # 'nohup':  Make the process immune to hangups.
                # '&':      Send it to the background.
                # 'disown': Detach it from the shell.
                nohup "${FFF_OPENER:-${opener:-xdg-open}}" "$1" &>/dev/null &
                disown
            ;;
        esac
    fi
}

cmd_line() {
    # Write to the command_line (under status_line).
    cmd_reply=

    # '\e7':     Save cursor position.
    # '\e[?25h': Unhide the cursor.
    # '\e[%sH':  Move cursor to bottom (cmd_line).
    printf '\e7\e[%sH\e[?25h' "$LINES"

    # '\r\e[K': Redraw the read prompt on every keypress.
    #           This is mimicking what happens normally.
    while IFS= read -rsn 1 -p $'\r\e[K'"${1}${cmd_reply}" read_reply; do
        case $read_reply in
            # Backspace.
            $'\177'|$'\b')
                cmd_reply=${cmd_reply%?}

                # Clear tab-completion.
                unset comp c
            ;;

            # Tab.
            $'\t')
                ((helping)) && return

                comp_glob="$cmd_reply*"

                # Pass the argument dirs to limit completion to directories.
                [[ $2 == dirs ]] &&
                    comp_glob="$cmd_reply*/"

                # Generate a completion list once.
                [[ -z ${comp[0]} ]] &&
                    IFS=$'\n' read -d "" -ra comp < <(compgen -G "$comp_glob")

                # On each tab press, cycle through the completion list.
                [[ -n ${comp[c]} ]] && {
                    cmd_reply=${comp[c]}
                    ((c=c >= ${#comp[@]}-1 ? 0 : ++c))
                }
            ;;

            # Escape / Custom 'no' value (used as a replacement for '-n 1').
            $'\e'|${3:-null})
                read "${read_flags[@]}" -rsn 2
                cmd_reply=
                break
            ;;

            # Enter/Return.
            "")
                # If there's only one search result and its a directory,
                # enter it on one enter keypress.
                !((helping)) && [[ $2 == search && -d ${list[0]} ]] && ((list_total == 0)) && {
                    # '\e[?25l': Hide the cursor.
                    printf '\e[?25l'

                    open "${list[0]}"
                    search_end_early=1

                    # Unset tab completion variables since we're done.
                    unset comp c
                    return
                }

                break
            ;;

            # Custom 'yes' value (used as a replacement for '-n 1').
            ${2:-null})
                cmd_reply=$read_reply
                break
            ;;

            # Replace '~' with '$HOME'.
            "~")
                cmd_reply+=$HOME
            ;;

            # Anything else, add it to read reply.
            *)
                cmd_reply+=$read_reply

                # Clear tab-completion.
                unset comp c
            ;;
        esac

        # Search on keypress if search passed as an argument.
        [[ $2 == search ]] && {
            # '\e[?25l': Hide the cursor.
            printf '\e[?25l'

            # Use a greedy glob to search.
            if ((helping)); then
                local item
                list=()
                for item in "${cur_list[@]}"; do
                    [[ "$item" == *"$cmd_reply"* ]] && list+=("$item")
                done
            else
                list=("$PWD"/*"$cmd_reply"*)
            fi
            ((list_total=${#list[@]}-1))

            # Draw the search results on screen.
            scroll=0
            redraw

            # '\e[%sH':  Move cursor back to cmd-line.
            # '\e[?25h': Unhide the cursor.
            printf '\e[%sH\e[?25h' "$LINES"
        }
    done

    # Unset tab completion variables since we're done.
    unset comp c

    # '\e[2K':   Clear the entire cmd_line on finish.
    # '\e[?25l': Hide the cursor.
    # '\e8':     Restore cursor position.
    printf '\e[2K\e[?25l\e8'
}

key() {
    # Handle special key presses.
    [[ $1 == $'\e' ]] && {
        read "${read_flags[@]}" -rsn 2

        # Handle a normal escape key press.
        [[ ${1}${REPLY} == $'\e\e['* ]] &&
            read "${read_flags[@]}" -rsn 1 _

        local special_key=${1}${REPLY}
    }

    case ${special_key:-$1} in
        "${FFF_KEY_HELP:=?}")
            redraw help
        ;;

        # Open list item.
        # 'C' is what bash sees when the right arrow is pressed
        # ('\e[C' or '\eOC').
        # '' is what bash sees when the enter/return key is pressed.
        ${FFF_KEY_CHILD1:=l}|\
        ${FFF_KEY_CHILD2:=$'\e[C'}|\
        ${FFF_KEY_CHILD3:=""}|\
        ${FFF_KEY_CHILD4:=$'\eOC'})
            ((helping)) && return

            open "${list[scroll]}"
        ;;

        # Go to the parent directory.
        # 'D' is what bash sees when the left arrow is pressed
        # ('\e[D' or '\eOD').
        # '\177' and '\b' are what bash sometimes sees when the backspace
        # key is pressed.
        ${FFF_KEY_PARENT1:=h}|\
        ${FFF_KEY_PARENT2:=$'\e[D'}|\
        ${FFF_KEY_PARENT3:=$'\177'}|\
        ${FFF_KEY_PARENT4:=$'\b'}|\
        ${FFF_KEY_PARENT5:=$'\eOD'})
            ((helping)) && return

            # If a search was done, clear the results and open the current dir.
            if ((search == 1 && search_end_early != 1)); then
                open "$PWD"

            # If '$PWD' is '/', do nothing.
            elif [[ $PWD && $PWD != / ]]; then
                find_previous=1
                open "${PWD%/*}"
            fi
        ;;

        # Page up
        # "${FFF_KEY_PAGE_DOWN1:=6}")
        ${FFF_KEY_PAGE_DOWN1:=6}|\
        ${FFF_KEY_PAGE_DOWN2:=$'\e[6'})
            for ((ii=0; ii<scroll_page; ii++)) do
                ((scroll >= list_total)) && break
                ((scroll++))
                ((y < max_items )) && ((y++))

                print_line "$((scroll-1))"
                printf '\n'
                print_line "$scroll"
                status_line
            done
        ;;

        # Page down
        ${FFF_KEY_PAGE_UP1:=5}|\
        ${FFF_KEY_PAGE_UP2:=$'\e[5'})
            for ((ii=0; ii<scroll_page; ii++)) do
                ((scroll <= 0)) && break
                ((scroll--))

                print_line "$((scroll+1))"

                if ((y < 2)); then
                    printf '\e[1L'
                else
                    printf '\e[A'
                    ((y--))
                fi

                print_line "$scroll"
                status_line
            done
        ;;

        # Scroll down.
        # 'B' is what bash sees when the down arrow is pressed
        # ('\e[B' or '\eOB').
        ${FFF_KEY_SCROLL_DOWN1:=j}|\
        ${FFF_KEY_SCROLL_DOWN2:=$'\e[B'}|\
        ${FFF_KEY_SCROLL_DOWN3:=$'\eOB'})
            while ((scroll < list_total)); do
                ((scroll++))
                ((y < max_items)) && ((y++))

                print_line "$((scroll-1))"
                printf '\n'
                print_line "$scroll"
                status_line

                [[ "${list[scroll]}" ]] && break
            done
        ;;

        # Scroll up.
        # 'A' is what bash sees when the up arrow is pressed
        # ('\e[A' or '\eOA').
        ${FFF_KEY_SCROLL_UP1:=k}|\
        ${FFF_KEY_SCROLL_UP2:=$'\e[A'}|\
        ${FFF_KEY_SCROLL_UP3:=$'\eOA'})
            # '\e[1L': Insert a line above the cursor.
            # '\e[A':  Move cursor up a line.
            while ((scroll > 0)); do
                ((scroll--))

                print_line "$((scroll+1))"

                if ((y < 2)); then
                    printf '\e[L'
                else
                    printf '\e[A'
                    ((y--))
                fi

                print_line "$scroll"
                status_line

                [[ "${list[scroll]}" ]] && break
            done
        ;;

        # Go to top.
        ${FFF_KEY_TO_TOP:=g})
            ((scroll != 0)) && {
                scroll=0
                redraw
            }
        ;;

        # Go to bottom.
        ${FFF_KEY_TO_BOTTOM:=G})
            ((scroll != list_total)) && {
                ((scroll=list_total))
                redraw
            }
        ;;

        # Show hidden files.
        ${FFF_KEY_HIDDEN:=.})
            ((helping)) && return

            # 'a=a>0?0:++a': Toggle between both values of 'shopt_flags'.
            #                This also works for '3' or more values with
            #                some modification.
            shopt_flags=(u s)
            shopt -"${shopt_flags[((a=${a:=$FFF_HIDDEN}>0?0:++a))]}" dotglob
            redraw full
        ;;

        # Search.
        ${FFF_KEY_SEARCH:=/})
            cmd_line "/" "search"

            # If the search came up empty, redraw the current dir.
            if [[ -z ${list[*]} ]]; then
                list=("${cur_list[@]}")
                ((list_total=${#list[@]}-1))
                redraw
                search=
            else
                search=1
            fi
        ;;

        # Spawn a shell.
        ${FFF_KEY_SHELL:=!})
            ((helping)) && return

            reset_terminal

            # Make fff aware of how many times it is nested.
            export FFF_LEVEL
            ((FFF_LEVEL++))

            cd "$PWD" && "$SHELL"
            setup_terminal
            redraw full
        ;;

        # Mark files for operation.
        ${FFF_KEY_YANK:=y}|\
        ${FFF_KEY_MOVE:=m}|\
        ${FFF_KEY_TRASH:=d}|\
        ${FFF_KEY_BULK_RENAME:=b})
            ((helping)) && return

            mark "$scroll" "$1"
        ;;

        # Do the file operation.
        ${FFF_KEY_PASTE:=p})
            ((helping)) && return

            [[ ${marked_files[*]} ]] && {
                [[ ! -w $PWD ]] && {
                    cmd_line "warn: no write access to dir."
                    return
                }

                # Clear the screen to make room for a prompt if needed.
                clear_screen
                reset_terminal

                stty echo
                printf '\e[1mfff\e[m: %s\n' "Running ${file_program[0]}"
                "${file_program[@]}" "${marked_files[@]}" .
                stty -echo

                marked_files=()
                setup_terminal
                redraw full
            }
        ;;

        # Clear all marked files.
        ${FFF_KEY_CLEAR:=c})
            ((helping)) && return

            [[ ${marked_files[*]} ]] && {
                marked_files=()
                redraw
            }
        ;;

        # Rename list item.
        ${FFF_KEY_RENAME:=r})
            ((helping)) && return

            [[ ! -e ${list[scroll]} ]] &&
                return

            cmd_line "rename ${list[scroll]##*/}: "

            [[ $cmd_reply ]] &&
                if [[ -e $cmd_reply ]]; then
                    cmd_line "warn: '$cmd_reply' already exists."

                elif [[ -w ${list[scroll]} ]]; then
                    mv "${list[scroll]}" "${PWD}/${cmd_reply}"
                    redraw full

                else
                    cmd_line "warn: no write access to file."
                fi
        ;;

        # Create a directory.
        ${FFF_KEY_MKDIR:=n})
            ((helping)) && return

            cmd_line "mkdir: " "dirs"

            [[ $cmd_reply ]] &&
                if [[ -e $cmd_reply ]]; then
                    cmd_line "warn: '$cmd_reply' already exists."

                elif [[ -w $PWD ]]; then
                    mkdir -p "${PWD}/${cmd_reply}"
                    redraw full

                else
                    cmd_line "warn: no write access to dir."
                fi
        ;;

        # Create a file.
        ${FFF_KEY_MKFILE:=f})
            ((helping)) && return

            cmd_line "mkfile: "

            [[ $cmd_reply ]] &&
                if [[ -e $cmd_reply ]]; then
                    cmd_line "warn: '$cmd_reply' already exists."

                elif [[ -w $PWD ]]; then
                    : > "$cmd_reply"
                    redraw full

                else
                    cmd_line "warn: no write access to dir."
                fi
        ;;

        # Show file attributes.
        ${FFF_KEY_ATTRIBUTES:=x})
            ((helping)) && return

            [[ -e "${list[scroll]}" ]] && {
                clear_screen
                status_line "${list[scroll]}"
                "${FFF_STAT_CMD:-stat}" "${list[scroll]}"
                read -ern 1
                redraw
            }
        ;;

        # Toggle executable flag.
        ${FFF_KEY_EXECUTABLE:=X})
            ((helping)) && return

            [[ -f ${list[scroll]} && -w ${list[scroll]} ]] && {
                if [[ -x ${list[scroll]} ]]; then
                    chmod -x "${list[scroll]}"
                    status_line "Unset executable."
                else
                    chmod +x "${list[scroll]}"
                    status_line "Set executable."
                fi
            }
        ;;

         ## run du/ncdu to get sizes
        u)
            [[ -e "${list[scroll]}" ]] && {
                clear_screen
                reset_terminal
                status_line "${list[scroll]}"
                type ncdu &> /dev/null && ncdu "${list[scroll]}" || du "${list[scroll]}"
                setup_terminal
                redraw
            }
        ;;

        ## add ? to display keyboard shortcuts
        "?")
            clear_screen
            cat ~/bin/fff/fff.1 | grep -A 62 "Usage"| grep -v "^\." | less
            setup_terminal
            redraw
        ;;


        # Go to dir.
        ${FFF_KEY_GO_DIR:=:})
            ((helping)) && return

            cmd_line "go to dir: " "dirs"

            # Let 'cd' know about the current directory.
            cd "$PWD" &>/dev/null ||:

            [[ $cmd_reply ]] &&
                cd "${cmd_reply/\~/$HOME}" &>/dev/null &&
                    open "$PWD"
        ;;

        # Go to '$HOME'.
        ${FFF_KEY_GO_HOME:='~'})
            ((helping)) && return

            open ~
        ;;

        # Go to previous dir.
        ${FFF_KEY_PREVIOUS:=-})
            ((helping)) && return

            open "$OLDPWD"
        ;;

        # Refresh current dir.
        ${FFF_KEY_REFRESH:=e})
            ((helping)) && {
                list=("${cur_list[@]}")
                redraw
                return
            }

            open "$PWD"
        ;;

        # Quit and store current directory in a file for CD on exit.
        # Don't allow user to redefine 'q' so a bad keybinding doesn't
        # remove the option to quit.
        q)
            ((helping)) && {
                redraw full
                return
            }

            : "${FFF_CD_FILE:=${XDG_CACHE_HOME:=${HOME}/.cache}/fff/.fff_d}"

            [[ -w $FFF_CD_FILE ]] &&
                rm "$FFF_CD_FILE"

            [[ ${FFF_CD_ON_EXIT:=1} == 1 ]] &&
                printf '%s\n' "$PWD" > "$FFF_CD_FILE"

            exit
        ;;
    esac
}

main() {
    # Handle a directory as the first argument.
    # 'cd' is a cheap way of finding the full path to a directory.
    # It updates the '$PWD' variable on successful execution.
    # It handles relative paths as well as '../../../'.
    #
    # '||:': Do nothing if 'cd' fails. We don't care.
    cd "${2:-$1}" &>/dev/null ||:

    [[ $1 == -h ]] && {
        man fff
        exit
    }

    # bash 5 and some versions of bash 4 don't allow SIGWINCH to interrupt
    # a 'read' command and instead wait for it to complete. In this case it
    # causes the window to not redraw on resize until the user has pressed
    # a key (causing the read to finish). This sets a read timeout on the
    # affected versions of bash.
    # NOTE: This shouldn't affect idle performance as the loop doesn't do
    # anything until a key is pressed.
    # SEE: https://github.com/dylanaraps/fff/issues/48
    ((BASH_VERSINFO[0] > 3)) &&
        read_flags=(-t 0.05)

    ((${FFF_LS_COLORS:=1} == 1)) &&
        get_ls_colors

    ((${FFF_HIDDEN:=0} == 1)) &&
        shopt -s dotglob

    # Create the trash and cache directory if they don't exist.
    mkdir -p "${XDG_CACHE_HOME:=${HOME}/.cache}/fff" \
             "${TRASH_DIR}"

    # 'nocaseglob': Glob case insensitively (Used for case insensitive search).
    # 'nullglob':   Don't expand non-matching globs to themselves.
    shopt -s nocaseglob nullglob

    # Trap the exit signal (we need to reset the terminal to a useable state.)
    trap 'reset_terminal' EXIT

    # Trap the window resize signal (handle window resize events).
    trap 'get_term_size; redraw' WINCH

    get_os
    get_term_size
    setup_options
    setup_terminal
    redraw full

    # Vintage infinite loop.
    for ((;;)); {
        read "${read_flags[@]}" -srn 1 && key "$REPLY"

        # Exit if there is no longer a terminal attached.
        [[ -t 1 ]] || exit 1
    }
}

main "$@"
