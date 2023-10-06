#!/usr/bin/env bash
# set -ex

# Based on fff by dylanaraps, MIT licensed.
# Also includes some changes from Pierre Dangauthier and
# Roy-Orbison (GH username, not the famous one).
# Depends on coreutils and some kind of opener (xdg-open, etc.).

# See also, for ideas: https://github.com/wick3dr0se/fml

# TODO:
# Finish keybind fixes (see below)
# Fix anything Shellcheck complains about
# Get rid of custom trash implementation
# Swap : to work for complex commands (functions in here, I guess)
# n and N handling in search
# Add an open_with
# Fix renaming (I, A, r?)

# Ranger keybinds I care about that aren't working here yet:
# make everything match.
#   :          console
#   !          console shell
#   <space>    mark_files toggle=True
#   v          mark_files all=True toggle=True
#   V          toggle_visual_mode
#   dd         cut
#   yy         copy
#   pp         paste
#   n          search_next
#   N          search_next forward=False
#   xx         console delete
#   XX         shell trash %s

# Keybinds I don't really like, want to fix:
#
#  :: go to a directory by typing     # :cd in ranger
#  !: open shell in current dir       # FFF_KEY_SHELL
#
#  operations:
#  y: mark copy           # FFF_KEY_YANK
#  m: mark move           # FFF_KEY_MOVE
#  d: mark trash          # FFF_KEY_TRASH
#  b: mark bulk rename    # FFF_KEY_BULK_RENAME
#  p: paste/move/delete/bulk_rename
#  c: clear file selections

init_options() {
    # All config.
    # In a function for easy folding.

    # keys
    FSSH_KEY_UP='k'                 # vim-alike
    FSSH_KEY_DOWN='j'               # vim-alike
    FSSH_KEY_RIGHT='l'              # vim-alike
    FSSH_KEY_LEFT='h'               # vim-alike

    FSSH_KEY_PAGE_UP='K'            # page up
    FSSH_KEY_PAGE_DOWN='J'          # page down
    FSSH_KEY_BOTTOM='G'             # vim-alike
    FSSH_KEY_TOP='g'                # vim-alike - this is gg in ranger
    FSSH_KEY_GO_HOME='~'            # cd ~/
    FSSH_KEY_GO_DIR=':'             # go to directory

    FSSH_KEY_TOGGLE_HIDDEN='.'      # toggle hidden file display
    FSSH_KEY_RENAME='A'             # rename files (A to match vim A)
    FSSH_KEY_PASTE='p'              # multi file ops
    FSSH_KEY_CLEAR='c'              # clear files selected for op
    FSSH_KEY_MKFILE='f'             # touch
    FSSH_KEY_MKDIR='n'              # mkdir
    FSSH_KEY_REFRESH='R'            # refresh dir and redraw

    FSSH_KEY_SEARCH='/'             # search through files in dir
    FSSH_KEY_ATTRIBUTES='i'         # show info with stat
    FSSH_KEY_HELP='?'               # display keybinds
    FSSH_KEY_QUIT='q'               # exit

    # options
    FSSH_EDITOR='vim'               # maybe VISUAL | EDITOR | vim | vi
    FSSH_TRASH_DIR="$HOME/.z-trash" # move to trash instead of rm
    FSSH_STAT_CMD='stat'            # show attrs
    FSSH_HIDDEN=1                   # show hidden files by default
    FSSH_MARK_FORMAT=" %f*"
    FSSH_FILE_FORMAT="%f"

    # Use LS_COLORS (will cancel if not available)
    # LS_COLORS takes priority over the other color settings
    FSSH_LS_COLORS=1                # use LS_COLORS
    FSSH_COL1=5                     # directory color, magenta
    FSSH_COL2=4                     # status background color, cyan
    FSSH_COL3=1                     # selection color, red
    FSSH_COL4=2                     # cursor color, green
    FSSH_COL5=0                     # status foreground color, black
    if [[ $(uname) == 'Darwin' ]]; then
        FSSH_DEFAULT_OPENER=open
        file_flags=bIL
    else
        FSSH_DEFAULT_OPENER=xdg-open
    fi
}

has_program() {
    hash "$1" &> /dev/null
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
    [[ $FSSH_FILE_FORMAT == *%f* ]] && {
        file_pre=${FSSH_FILE_FORMAT/'%f'*}
        file_post=${FSSH_FILE_FORMAT/*'%f'}
    }

    # Format for marked files.
    # Use affixes provided by the user or use defaults, if necessary.
    if [[ $FSSH_MARK_FORMAT == *%f* ]]; then
        mark_pre=${FSSH_MARK_FORMAT/'%f'*}
        mark_post=${FSSH_MARK_FORMAT/*'%f'}
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
        FSSH_LS_COLORS=0
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
           "${FSSH_COL5:-0}" \
           "${FSSH_COL2:-1}" \
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
    printf '\e]2;fs: %s\e'\\ "$PWD"

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
            # TODO: Janky output. But it works, for now
            format+=\\e[${di:-1;3${FSSH_COL1:-2}}m
            # local action="${file_name%: *}"
            # format+="$(cat -A <<<"$action" | head -c -2)\\e[${fi:-37}m: "
            file_name="${file_name##*: }"
        fi
        format+=\\e[${fi:-37}m

    # If the dir item doesn't exist, end here.
    elif [[ -z ${list[$1]} ]]; then
        return

    # Directory.
    elif [[ -d ${list[$1]} ]]; then
        format+=\\e[${di:-1;3${FSSH_COL1:-2}}m
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
    elif [[ $FSSH_LS_COLORS == 1 &&
            $ls_patterns &&
            $file_name =~ ($ls_patterns)$ ]]; then
        match=${BASH_REMATCH[0]}
        file_ext=ls_${match//[^a-zA-Z0-9=\\;]/_}
        format+=\\e[${!file_ext:-${fi:-37}}m

    # Color files based on file extension and LS_COLORS.
    # Check if file extension adheres to POSIX naming
    # standard before checking if it's a variable.
    elif [[ $FSSH_LS_COLORS == 1 &&
            $file_ext != "$file_name" &&
            $file_ext =~ ^[a-zA-Z0-9_]*$ ]]; then
        file_ext=ls_${file_ext}
        format+=\\e[${!file_ext:-${fi:-37}}m

    else
        format+=\\e[${fi:-37}m
    fi

    # If the list item is under the cursor.
    (($1 == scroll)) &&
        format+="\\e[1;3${FSSH_COL4:-6};7m"

    # If the list item is marked for operation.
    ! ((helping)) && [[ ${marked_files[$1]} == "${list[$1]:-null}" ]] && {
        format+=\\e[3${FSSH_COL3:-1}m${mark_pre}
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
    printf '\e]2;fs: help\e'\\

    # get the function containing all options
    # trim the `type` output so we're just left with the body
    # de-indent
    options=$(type init_options \
        | sed '1,3d;$d' \
        | sed 's/^[[:space:]]\{1,\}//')
        # TODO: replace '=' with ':  '.
        # Works in shell, not here, probably due to drawing implementation
        # | sed 's/\=/ ')
    readarray -t list <<< $options

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

    cd "$FSSH_TRASH_DIR" || cmd_line "error: Can't cd to trash directory."

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
    if has_program mktemp; then
        rename_file=$(mktemp)
    else
        rename_file="$HOME/.fs_tmp_bulk_rename"
    fi
    # Bulk rename files using '$FSSH_EDITOR'.
    marked_files=("${@:1:$#-1}")

    # Save marked files to a file and open them for editing.
    printf '%s\n' "${marked_files[@]##*/}" > "$rename_file"
    "$FSSH_EDITOR" "$rename_file"

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
        "$FSSH_EDITOR" "$rename_file"

        source "$rename_file"
        rm "$rename_file"
    }

    # Fix terminal settings after '$FSSH_EDITOR'.
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

        # Open all text-based files in '$FSSH_EDITOR'.
        # Everything else goes through 'xdg-open'/'open'.
        # TODO: use all these?
        # html|xml|csv|tex|py|pl|rb|sh|php|js|jsx|css|
        # json|styl|less|scss|sass|md|markdown|ts
        case "$mime_type" in
            text/*|*x-empty*|*json*)
                clear_screen
                reset_terminal
                "${VISUAL:-${FSSH_EDITOR}}" "$1"
                setup_terminal
                redraw
            ;;

            *pdf*|*epub*)
                clear_screen
                reset_terminal
                if has_program mupdf; then mupdf "$1";
                elif has_proram mupdf-gl; then mupdf-gl "$1;"
                fi
                setup_terminal
                redraw
            ;;

            audio/*)
                clear_screen
                reset_terminal
                mpv --vid=no "$1"
                setup_terminal
                redraw
            ;;

            video/*)
                clear_screen
                reset_terminal
                mpv "$1"
                setup_terminal
                redraw
            ;;

            *)
                # 'nohup':  Make the process immune to hangups.
                # '&':      Send it to the background.
                # 'disown': Detach it from the shell.
                nohup "$FSSH_DEFAULT_OPENER" "$1" &>/dev/null &
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
                ! ((helping)) && [[ $2 == search && -d ${list[0]} ]] && ((list_total == 0)) && {
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
        "$FSSH_KEY_HELP")
            redraw help
        ;;

        # Open list item.
        "$FSSH_KEY_RIGHT")
            ((helping)) && return

            open "${list[scroll]}"
        ;;

        # Go to the parent directory.
        "$FSSH_KEY_LEFT")
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

        # Page down
        "$FSSH_KEY_PAGE_DOWN")
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

        # Page up
        "$FSSH_KEY_PAGE_UP")
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
        "$FSSH_KEY_DOWN")
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
        "$FSSH_KEY_UP")
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
        "$FSSH_KEY_TOP")
            ((scroll != 0)) && {
                scroll=0
                redraw
            }
        ;;

        # Go to bottom.
        "$FSSH_KEY_BOTTOM")
            ((scroll != list_total)) && {
                ((scroll=list_total))
                redraw
            }
        ;;

        # Show hidden files.
        "$FSSH_KEY_TOGGLE_HIDDEN")
            ((helping)) && return

            # 'a=a>0?0:++a': Toggle between both values of 'shopt_flags'.
            #                This also works for '3' or more values with
            #                some modification.
            shopt_flags=(u s)
            shopt -"${shopt_flags[((a=${a:=$FSSH_HIDDEN}>0?0:++a))]}" dotglob
            redraw full
        ;;

        # Search.
        "$FSSH_KEY_SEARCH")
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
        "$FSSH_KEY_PASTE")
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
                printf '\e[1mfs\e[m: %s\n' "Running ${file_program[0]}"
                "${file_program[@]}" "${marked_files[@]}" .
                stty -echo

                marked_files=()
                setup_terminal
                redraw full
            }
        ;;

        # Clear all marked files.
        "$FSSH_KEY_CLEAR")
            ((helping)) && return

            [[ ${marked_files[*]} ]] && {
                marked_files=()
                redraw
            }
        ;;

        # Rename list item.
        "$FSSH_KEY_RENAME")
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
        "$FSSH_KEY_MKDIR")
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
        "$FSSH_KEY_MKFILE")
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
        "$FSSH_KEY_ATTRIBUTES")
            ((helping)) && return

            [[ -e "${list[scroll]}" ]] && {
                clear_screen
                status_line "${list[scroll]}"
                "$FSSH_STAT_CMD" "${list[scroll]}"
                read -ern 1
                redraw
            }
        ;;

        ## add ? to display keyboard shortcuts
        "$FSSH_KEY_HELP")
            clear_screen
            # TODO:
            echo "Coming soon: help"
            setup_terminal
            redraw
        ;;


        # Go to dir.
        "$FSSH_KEY_GO_DIR")
            ((helping)) && return

            cmd_line "go to dir: " "dirs"

            # Let 'cd' know about the current directory.
            cd "$PWD" &>/dev/null ||:

            [[ $cmd_reply ]] &&
                cd "${cmd_reply/\~/$HOME}" &>/dev/null &&
                    open "$PWD"
        ;;

        # Go to '$HOME'.
        "$FSSH_KEY_GO_HOME")
            ((helping)) && return

            open ~
        ;;

        # Refresh current dir.
        "$FSSH_KEY_REFRESH")
            ((helping)) && {
                list=("${cur_list[@]}")
                redraw
                return
            }

            open "$PWD"
        ;;

        # Goodbye
        "$FSSH_KEY_QUIT")
            ((helping)) && {
                redraw full
                return
            }

            exit
        ;;
    esac
}

main() {
    init_options
    # Handle a directory as the first argument.
    # 'cd' is a cheap way of finding the full path to a directory.
    # It updates the '$PWD' variable on successful execution.
    # It handles relative paths as well as '../../../'.
    #
    # '||:': Do nothing if 'cd' fails. We don't care.
    cd "${2:-$1}" &>/dev/null ||:

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

    (("$FSSH_LS_COLORS" == 1)) &&
        get_ls_colors

    (("$FSSH_HIDDEN" == 1)) &&
        shopt -s dotglob

    # Create the trash directory if it doesn't exist
    mkdir -p "$FSSH_TRASH_DIR"

    # 'nocaseglob': Glob case insensitively (Used for case insensitive search).
    # 'nullglob':   Don't expand non-matching globs to themselves.
    shopt -s nocaseglob nullglob

    # Trap the exit signal (we need to reset the terminal to a useable state.)
    trap 'reset_terminal' EXIT

    # Trap the window resize signal (handle window resize events).
    trap 'get_term_size; redraw' WINCH

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
