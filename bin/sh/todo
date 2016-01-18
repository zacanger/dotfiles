#! /bin/bash

source "kv-bash"

# Initialize ID
COUNT=`kvget count`
if [[ -z $COUNT ]]
then
    kvset count 1
fi

# Add thing with a unique ID
function add_thing() {
    thing_to_add="$@"
    id=`kvget count`
    kvset $id "$thing_to_add"
    let "id+=1"
    kvset count $id
}

# Delete thing based on ID
function del_thing() {
    echo "What've you done, ol' (wo)man?"
    echo "-------"
    kvlist
    echo "-------"
    read ID
    kvdel $ID
}

# Reorder
function reorder_things() {
    id=1
    for i in "$KV_USER_DIR/"*; do
        if [ -f "$i" ]; then
            key="$(basename "$i")"
            value=$(kvget "$key")
            if((key!="count"))
            then
                 kvdel $key 
                 kvset $id "$value"
                 let "id+=1"
             fi
        fi
	done 
    kvset count $id
}

function show_help() {
    echo "This is what I can do: "
    echo "todo add <Thing to do> : Adds your thing with a Unique ID"
    echo "todo del: Asks for the unique ID of your thing and removes it"
    echo "todo: Displays your todos"
    echo "todo clear: Clears your todos"
}

if(($# > 0))
then
  case $1 in
    add)
        shift
        add_thing $@
        exit 0
        ;;
    del)
        del_thing
        reorder_things
        exit 0
        ;;
    help)
        show_help
        exit 0
        ;;
    clear)
        kvclear
        exit 0
        ;;
    *)
        echo "Invalid option: $1" >&2
        exit 1
        ;;
   esac
else
 kvlist
fi
