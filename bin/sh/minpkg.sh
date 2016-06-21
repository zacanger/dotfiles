#! /bin/sh

help () {
    printf "usage: $0 COMMAND [ARGS]\n"
    printf "available commands:\n"
    printf "  init list add del pack raise to from match\n"
}

fail () {
    printf "$1\n" >&2
    exit 1
}

assert_readable () {
    if [ ! -r "$1" ]
    then
        fail "you don't have read permissions on $1"
    fi
}

assert_writable () {
    if [ ! -w "$1" ]
    then
        fail "you don't have write permissions on $1"
    fi
}

pkg_init () {
    if [ "$#" -ne 0 ]
    then
        fail "usage: $0 init"
    fi

    if [ ! -d "$MINPKG_ROOT" ]
    then
        fail "$MINPKG_ROOT not a directory"
    fi

    assert_writable "$MINPKG_ROOT"

    if [ -d "$MINPKG_ROOT/etc/pkg/list" ]
    then
        fail "$MINPKG_ROOT is already initialized"
    fi

    mkdir -p "$MINPKG_ROOT/etc/pkg/list"
    touch "$MINPKG_ROOT/etc/pkg/PACKAGES"
    touch "$MINPKG_ROOT/etc/pkg/CONFLICT"
    mkdir -p "$MINPKG_ROOT/bin"
    cp "$0" "$MINPKG_ROOT/bin/"
}

pkg_list () {
    if [ "$#" -ne 0 ]
    then
        fail "usage: $0 list"
    fi

    plist="$MINPKG_ROOT/etc/pkg/PACKAGES"

    assert_readable "$MINPKG_ROOT"

    if [ -f "$plist" ]
    then
        cat "$plist"
        return 0
    else
        fail "unable to find package information on $MINPKG_ROOT"
    fi
}

pkg_add () {
    if [ "$#" -ne 1 ]
    then
        fail "usage: $0 add PKGFILE"
    fi

    assert_writable "$MINPKG_ROOT"

    if [ ! -f "$1" ]
    then
        fail "file not found: $1"
    fi

    pkgid=`basename "$1" .tgz`
    flist="$MINPKG_ROOT/etc/pkg/list/$pkgid"

    if [ -f "$flist" ]
    then
        fail "$pkgid is already installed on $MINPKG_ROOT"
    fi

    plist="$MINPKG_ROOT/etc/pkg/PACKAGES"
    confl="$MINPKG_ROOT/etc/pkg/CONFLICT"

    pkg_to "$1" > "$flist"

    add=0
    mod=0
    while read path
    do
        if [ -e "$MINPKG_ROOT/$path" ]
        then
            from=`pkg_from "$path" 2> /dev/null`
            if [ $? -eq 0 ]
            then
                mv "$MINPKG_ROOT/$path" "$MINPKG_ROOT/$path.$from"
                if ! grep -qF "$path" "$confl"
                then
                    printf "$path\n" >> "$confl"
                fi
                printf "masked %s %s\n" "$from" "$path" >&2
                mod=$((mod+1))
            else
                add=$((add+1))
            fi
        else
            add=$((add+1))
        fi
    done < "$flist"

    tar -x -z -C "$MINPKG_ROOT" -f "$1"

    printf "$pkgid\n" >> "$plist"

    printf "added %d new files\n" "$add"
    if [ $mod -ne 0 ]
    then
        printf "modified %d files\n" "$mod"
    fi
}

pkg_del () {
    if [ "$#" -ne 1 ]
    then
        fail "usage: $0 del PKGID"
    fi

    assert_writable "$MINPKG_ROOT"

    pkgid=`basename "$1" .tgz`
    flist="$MINPKG_ROOT/etc/pkg/list/$pkgid"

    if [ ! -f "$flist" ]
    then
        fail "$pkgid is not installed on $MINPKG_ROOT"
    fi

    plist="$MINPKG_ROOT/etc/pkg/PACKAGES"
    confl="$MINPKG_ROOT/etc/pkg/CONFLICT"

    sub=0
    mod=0
    hid=0
    match="$MINPKG_ROOT/etc/pkg/MATCH"
    while read path
    do
        if grep -qF "$path" "$confl"
        then
            pkg_match "$path" > "$match"
            count=`wc -l < "$match"`
            if [ $count -le 2 ]
            then
                sed "\\:^$path\$:d" "$confl" > "$confl.tmp"
                mv "$confl.tmp" "$confl"
            fi
            from=`sed -n '1p' "$match"`
            if [ "$from" = "$pkgid" ]
            then
                below=`sed -n '2p' "$match"`
                mv "$MINPKG_ROOT/$path.$below" "$MINPKG_ROOT/$path"
                printf "unmasked %s %s\n" "$below" "$path" >&2
                mod=$((mod+1))
            else
                rm "$MINPKG_ROOT/$path.$pkgid"
                hid=$((hid+1))
            fi
        else
            rm "$MINPKG_ROOT/$path"
            dirpath=`dirname "$MINPKG_ROOT/$path"`
            while rmdir "$dirpath" 2> /dev/null
            do
                dirpath=`dirname "$dirpath"`
            done
            sub=$((sub+1))
        fi
    done < "$flist"
    rm -f "$match"

    rm "$flist"

    sed -n "/^$pkgid\$/!p" "$plist" > "$plist.tmp"
    mv "$plist.tmp" "$plist"

    printf "removed %d files\n" "$sub"
    if [ $hid -ne 0 ]
    then
        printf "removed %d masked files\n" "$hid"
    fi
    if [ $mod -ne 0 ]
    then
        printf "unmasked %d files\n" "$mod"
    fi
}

pkg_pack () {
    if [ "$#" -ne 1 ]
    then
        fail "usage: $0 pack PKGID"
    fi

    assert_readable "$MINPKG_ROOT"

    pkgid=`basename "$1" .tgz`
    flist="$MINPKG_ROOT/etc/pkg/list/$pkgid"

    if [ ! -f "$flist" ]
    then
        fail "$pkgid is not installed on $MINPKG_ROOT"
    fi

    fname="$1.tgz"
    tar -c -z -C "$MINPKG_ROOT" -f "$fname" -T "$flist"
    du -h "$fname"
}

pkg_to () {
    if [ "$#" -ne 1 ]
    then
        fail "usage: $0 to PKGFILE"
    fi

    if [ ! -f "$1" ]
    then
        fail "file not found: $1"
    fi

    tar -t -z -f "$1" | grep -v '/$'
}

pkg_from () {
    if [ "$#" -ne 1 ]
    then
        fail "usage: $0 from PATH"
    fi

    assert_readable "$MINPKG_ROOT"

    plist="$MINPKG_ROOT/etc/pkg/PACKAGES"

    if [ ! -f "$plist" ]
    then
        fail "unable to find package information on $MINPKG_ROOT"
    fi

    if [ ! -e "$MINPKG_ROOT/$1" ]
    then
        fail "$1 does not exist on $MINPKG_ROOT"
    fi

    tac "$plist" | while read pkg
    do
        if grep -qF "$1" "$MINPKG_ROOT/etc/pkg/list/$pkg"
        then
            printf "$pkg\n"
            exit 1
        fi
    done

    if [ $? -eq 0 ]
    then
        fail "$1 was not installed from package"
    fi
}

pkg_match () {
    if [ "$#" -ne 1 ]
    then
        fail "usage: $0 match PATH"
    fi

    assert_readable "$MINPKG_ROOT"

    plist="$MINPKG_ROOT/etc/pkg/PACKAGES"

    if [ ! -f "$plist" ]
    then
        fail "unable to find package information on $MINPKG_ROOT"
    fi

    # the shortcut below is not working from del for unknown reasons
    #~ if [ ! -e "$MINPKG_ROOT/$1" ]
    #~ then
        #~ fail "$MINPKG_ROOT/$1 does not seem to exist"
    #~ fi

    tac "$plist" | while read pkg
    do
        if grep -qF "$1" "$MINPKG_ROOT/etc/pkg/list/$pkg"
        then
            printf "$pkg\n"
        fi
    done
}

pkg_raise () {
    if [ "$#" -ne 1 ]
    then
        fail "usage: $0 raise PKGID" >&2
    fi

    assert_writable "$MINPKG_ROOT"

    pkgid=`basename "$1" .tgz`
    flist="$MINPKG_ROOT/etc/pkg/list/$pkgid"

    if [ ! -f "$flist" ]
    then
        fail "$pkgid is not installed on $MINPKG_ROOT"
    fi

    plist="$MINPKG_ROOT/etc/pkg/PACKAGES"
    confl="$MINPKG_ROOT/etc/pkg/CONFLICT"

    mod=0
    raise="$MINPKG_ROOT/etc/pkg/RAISE"
    cat "$flist" "$confl" | sort | uniq -d > "$raise"
    while read path
    do
        from=`pkg_from "$path"`
        if [ "$from" != "$pkgid" ]
        then
            mv "$MINPKG_ROOT/$path" "$MINPKG_ROOT/$path.$from"
            printf "masked %s %s\n" "$from" "$path" >&2
            mv "$MINPKG_ROOT/$path.$pkgid" "$MINPKG_ROOT/$path"
            mod=$((mod+1))
        fi
    done < "$raise"
    rm "$raise"

    sed -n "/^$pkgid\$/!p" "$plist" > "$plist.tmp"
    mv "$plist.tmp" "$plist"
    printf "$pkgid\n" >> "$plist"

    printf "modified %d files\n" "$mod"
}

if [ ! -d "$MINPKG_ROOT" ]
then
    MINPKG_ROOT="$PWD"
fi

if [ "$1" = "-r" ]
then
    MINPKG_ROOT="$2"
    shift 2
fi

cmd="$1"
shift

case "$cmd" in
    i|init)   pkg_init $@ ;;
    l|list)   pkg_list $@ ;;
    a|add)    pkg_add $@ ;;
    d|del)    pkg_del $@ ;;
    p|pack)   pkg_pack $@ ;;
    r|raise)  pkg_raise $@ ;;
    t|to)     pkg_to $@ ;;
    f|from)   pkg_from $@ ;;
    m|match)  pkg_match $@ ;;
    *)        help >&2 && exit 1
esac

