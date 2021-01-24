makelist() {
    make -rpn | \
        sed -n -e '/^$/ { n ; /^[^ .#][^ ]*:/p ; }' | \
        sort | \
        egrep --color '^[^ ]*:'
}
