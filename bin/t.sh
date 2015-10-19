#!/bin/bash

die() {
    echo -e $1; exit 1
}

depend() {
    for COMMAND in $@; do
        which $COMMAND &> /dev/null || die "FATAL ERROR: Required command '$COMMAND' is missing."
    done
}

is_integer() {
    [[ ! -z "$1" ]] || return 1
    [[ -z "$(echo $1 | tr -d 0-9)" ]] || return 1
}

is_valid_task_num() {
    is_integer "$2" || return 1
    [[ "$2" -le "$(read_tasks "$1" | wc -l)" ]] || return 1
}

sha1sum_lines() {
    while IFS= read -r line
    do
        echo $(echo -n $line | sha1sum | awk '{ print $1 }') $line
    done
}

sort_by_sha1() {
    sha1sum_lines | sort | cut -s -d' ' -f2-
}

read_tasks() {
    [[ -e "$1" ]] || touch "$1"
    sort_by_sha1 < "$1"
}

write_tasks() {
    [[ -e "$1" ]] || touch "$1"
    sort_by_sha1 > "$1"
}

list_tasks() {
    nl -ba <(read_tasks "$1")
}

finished_task() {
    NEW_TASKS=$(read_tasks "$1" | sed -e "${2}d")
    echo "${NEW_TASKS}" | write_tasks "$1"
}

add_task() {
    NEW_TASKS=$(read_tasks "$1" ; echo "${@:2}")
    echo "${NEW_TASKS}" | write_tasks "$1"
}

edit_task() {
    NEW_TASKS=$(read_tasks "$1" | sed -e "${2}d" ; echo "${@:3}")
    echo "${NEW_TASKS}" | write_tasks "$1"
}

usage() {
        echo "USAGE: $(basename $0) [-f NUM|-e NUM DESC|-h|--help|DESC|<no arguments>]"
        echo "A task list for people who want to finish tasks."
        echo
        echo "  -f NUM                Finish (remove from list) task number NUM."
        echo "  -e NUM DESC           Replace task number NUM with a new task, DESC."
        echo "  -h, --help            Show this usage message."
        echo "  DESC                  Add a task, described by DESC."
        echo "  <no arguments>        List current tasks."
        echo
        echo "Tasks are stored in the file named in \$T_TASK_FILE, which defaults to \$HOME/.ttasks. The file will be created if nonexistent."
        echo
        echo "Aside: This tool very consciously mimics the interface of Steve Losh's t: http://stevelosh.com/projects/t/"
        exit 1
}


depend sha1sum sed


T_TASK_FILE=${T_TASK_FILE:-$HOME/.ttasks}


case $1 in
    '')
        [[ $# -gt 0 ]] && die "Too many arguments."
        list_tasks "$T_TASK_FILE"
        ;;
    -f)
        [[ $# -le 1 ]] && die "Too few arguments."
        [[ $# -ge 3 ]] && die "Too many arguments."
        is_valid_task_num "$T_TASK_FILE" "$2" || die "That's not a valid task number."
        finished_task "$T_TASK_FILE" "$2"
        ;;
    -e)
        [[ $# -le 2 ]] && die "Too few arguments."
        is_valid_task_num "$T_TASK_FILE" "$2" || die "That's not a valid task number."
        [[ ! -z "${@:3}" ]] || die "Task description cannot be blank."
        edit_task "$T_TASK_FILE" "$2" "${@:3}"
        ;;
    -h) ;&
    --help)
        [[ $# -eq 1 ]] || die "Too many arguments."
        usage
        ;;
    *)
        add_task "$T_TASK_FILE" "$@"
        ;;
esac
