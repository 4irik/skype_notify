#!/bin/bash

# Тест добавления в белый список

. "../../../func_white_list.sh"

WHITE_LIST_FILE=/tmp/wl

cat > $WHITE_LIST_FILE <<EOF
EOF

wl_include_user user2
wl_include_user user3

diff $WHITE_LIST_FILE - <<EOF
user2
user3
EOF

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 1; }

rm -f $WHITE_LIST_FILE

echo "$0: OK"
