#!/bin/sh
# Author: Andreas Louv <andreas@louv.dk>
# Show combined git log of multiply repos for the last 24 hours.
# Repos are hardcoded but could easily come from arguments, same goes for the
# date.

for parent in "$SITEMULE_ROOT/.." "$EXT_ROOT/.."; do
    cd "$parent" || exit 5
    for f in *; do
        cd "$f" > /dev/null 2>&1 || continue

        git log --author "$(git config user.email)" \
            --since "$(date -d '24 hours ago' +'%Y-%m-%d')"

        cd ".." >/dev/null 2>&1 || exit 5
    done
done | perl -n0e 'print sort {
    ($a_d) = $a =~ /(?<=Date: )([^\n]+)/g;
    ($b_d) = $b =~ /(?<=Date: )([^\n]+)/g;

    $a_d =~ s/\D//g;
    $b_d =~ s/\D//g;

    return $b_d cmp $a_d;
} split(/(?=^commit )/m, $_)' | less
