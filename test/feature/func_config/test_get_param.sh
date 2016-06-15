#!/bin/bash

# Получение параметра из конфигурационного файла

. "../../../func_common.sh"
. "../../../func_config.sh"

CONFIG_FILE_PATH=/tmp/cf

cat > $CONFIG_FILE_PATH <<EOF
skype-name=vasia
white-list=off
EOF

[ $(get_config_param_by_name skype-name) != "vasia" ] && { echo "$0: FAIL" ; exit 1; }

[ $(get_config_param_by_name white-list) != "off" ] && { echo "$0: FAIL" ; exit 1; }

rm -f $CONFIG_FILE_PATH

echo "$0: OK"
