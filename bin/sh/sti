#!/bin/bash
# sti --- Stupid Tool Installer
# Copyright (C) 2014  Tom Willemse <tom@ryuslash.org>

# sti is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your
# option) any later version.

# sti is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
# License for more details.

# You should have received a copy of the GNU General Public License
# along with sti.  If not, see <http://www.gnu.org/licenses/>.

_sti_executable="$(basename $0)"
data_home="${XDG_DATA_HOME:-${HOME}/.local/share}/sti"
bin_home="${HOME}/usr/bin"

function fold () { /usr/bin/fold -s -w $(tput cols); }
function find-executables ()
{
    find "$1" -type f -executable \! -wholename "${data_home}/*/.*"
}

function tool-version
{
    cd "${data_home}/tools/$1" \
        && git log -n1 --pretty=format:%cd --date=iso \
           | sed -e 's/-//g' -e 's/ /./' -e 's/://' -e 's/:.*//'
}

function init
{
    for exe in $(find-executables "$1"); do
        local executable_name=$(basename "$exe")
        local destination="${bin_home}/${executable_name}"

        if [[ ! -e "$destination" ]]; then
            ln -s "$exe" "$destination"
        elif [[ "$(readlink $destination)" == "$exe" ]]; then
            echo "Executable ${executable_name} already installed"
        else
            echo "Executable ${executable_name} already exists in \
${bin_home}"
        fi
    done
}

function uninit
{
    for exe in $(find-executables "$1"); do
        local real_path=$(realpath "$exe")
        local base_name=$(basename "$exe")
        local link_path="${bin_home}/${base_name}"
        local linked_path=$(readlink "$link_path")

        if [[ -e "$link_path" ]] \
           && [[ "$linked_path" == "$real_path" ]]; then
            rm "$link_path"
        else
            echo "Executable ${base_name} is not part of $1"
        fi
    done
}

function help_help { cmd_help "$@"; }
function cmd_help
{
    if [[ -n "$1" ]]; then
        local prefix="help"
        dispatch "$@"
    else
        echo "Usage: ${_sti_executable} <command> ARG"
        echo
        echo "Commands include: "
        echo "  help     Show this help message"
        echo "  install  Install a tool from a git repository"
        echo "  list     List downloaded tools"
        echo "  reinit   Retry installing the executables of a tool"
        echo "  remove   Remove an installed tool"
        echo "  update   Update an installed tool"
        echo
        echo "You can use \`${_sti_executable} help <command>' to get \
more information about a command." | fold
    fi
}

function help_list ()
{
    echo "Usage: ${_sti_executable} list"
    echo
    echo "List all downloaded (possibly installed) tools." | fold
}

function cmd_list
{
    for tool in $(/bin/ls -1 "${data_home}/tools/"); do
        printf '%-20s %s\n' $tool $(tool-version "$tool")
    done
}

function help_reinit ()
{
    echo "Usage: ${_sti_executable} reinit TOOL"
    echo
    echo "TOOL should be the name of a tool installed previously with \
\`${_sti_executable} install'. This name is the base name of the URL \
used to install the tool, with the \`.git' suffix removed." | fold
    echo
    echo "Each executable file found in the tool's directory is checked \
to see if it exists in ${bin_home}, it reports whether it is already \
installed or doesn't belong to the tool. If it doesn't exist a symlink \
is created in ${bin_home}." | fold
}

function cmd_reinit ()
{
    local tool_home="${data_home}/tools/$1"

    if [[ -d "$tool_home" ]]; then
        init "$tool_home"
    fi
}

function help_install ()
{
    echo "Usage: ${_sti_executable} install URL"
    echo
    echo "URL should be a valid argument to \`git clone'."
    echo
    echo "URL is cloned and for each executable file found in the \
resulting directory a symlink is created in ${bin_home}. If there is \
already a file with the same name, no symlink is created and a message \
is displayed." | fold
}

function cmd_install ()
{
    tool_name=$(basename $1 .git)
    tool_home="${data_home}/tools/${tool_name}"

    # Ensure the bin directory exists.
    if [[ ! -d "$bin_home" ]]; then
        echo "Creating directory ${bin_home}"
        mkdir -p "$bin_home"
    fi

    if [[ ! -d "$tool_home" ]]; then
        git clone $1 "$tool_home"

        if [[ $? -eq 0 ]]; then
            init "$tool_home" \
                && printf "Tool %s v%s succesfully installed\n" \
                          "$tool_name" $(tool-version "$tool_name")
        else
            echo "Couldn't clone git repository $1, are you sure it's a \
git repository? sti doesn't support anything else at the moment." | fold
        fi
    else
        echo "Tool ${tool_name} already installed"
        exit 2
    fi
}

function help_remove ()
{
    echo "Usage: ${_sti_executable} remove TOOL"
    echo
    echo "TOOL should be the name of a tool installed previously with \
\`${_sti_executable} install'. This name is the base name of the URL \
used to install the tool, with the \`.git' suffix removed." | fold
    echo
    echo "Any executable files found in the directory of TOOL will have \
their symlinks in ${bin_home} removed. If a file exists with the same \
name as one of the symlinks should have and it is not a symlink to one \
of TOOL's executables, it is not removed and a message is displayed." \
    | fold
}

function cmd_remove ()
{
    tool_home="${data_home}/tools/$1"

    if [[ -d "$tool_home" ]]; then
        local tool_version=$(tool-version "$1")
        uninit "$tool_home"
        rm -rf "$tool_home" \
            && printf "Succesfully removed %s v%s\n" \
                      "$1" $tool_version
    else
        echo "Tool $1 is not installed"
        exit 2
    fi
}

function help_update
{
    echo "Usage: ${_sti_executable} update TOOL"
    echo
    echo "TOOL should be the name of a tool installed previously with \
\`${_sti_executable} install'. This name is the base name of the URL \
used to install the tool, with the \`.git' suffix removed." | fold
    echo
    echo "This command removes all the executables from \`${data_home}' \
just as \`${_sti_executable} remove' would, calls \`git pull' in TOOL's \
directory and then reinstalls the executables as \`${_sti_executable} \
reinit' would." | fold
}

function cmd_update
{
    tool_home="${data_home}/tools/$1"

    if [[ -d "$tool_home" ]]; then
        local old_version=$(tool-version "$1")
        uninit "$tool_home"
        cd $tool_home && git pull
        init "$tool_home" \
            && printf "Updated %s v%s -> v%s\n" \
                      "$1" "$old_version" $(tool-version "$1")
    else
        echo "Tool $1 is not installed"
        exit 2
    fi
}

function dispatch
{
    local name="${prefix-cmd}_$1"

    if [[ $(type -t "$name") == "function" ]]; then
        shift
        "$name" "$@"
    else
        echo "Unknown command: $1"
        exit 1
    fi
}

if [[ ${#@} -lt 1 ]]; then
    cmd_help "$@"
    exit 1
else
    dispatch "$@"
fi
