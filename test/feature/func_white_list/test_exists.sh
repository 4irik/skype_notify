#!/bin/bash

# Тест проверки наличия пользователя в списке

. "../../../func_white_list.sh"

FAIL_COUNTER=0

WHITE_LIST_FILE=/tmp/wl

cat > $WHITE_LIST_FILE <<EOF
user1
user2
EOF

wl_user_exists user1
[ $? -ne 1 ] && { echo "$0: FAIL" ; exit 1; }

wl_user_exists user4
[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 1; }

rm -f $WHITE_LIST_FILE

echo "$0: OK"
