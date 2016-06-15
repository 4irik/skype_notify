#!/bin/bash

# Удаление из белого списка

. "../../../func_white_list.sh"

WHITE_LIST_FILE=/tmp/wl

cat > $WHITE_LIST_FILE <<EOF
user1
user2
user3
user4
EOF

wl_exclude_user user2
wl_exclude_user user3

diff $WHITE_LIST_FILE - <<EOF
user1
user4
EOF

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 1; }

rm -f $WHITE_LIST_FILE

echo "$0: OK"
