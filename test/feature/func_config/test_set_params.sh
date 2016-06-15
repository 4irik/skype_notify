#!/bin/bash

# Установка параметра в конфигурационном файле

. "../../../func_common.sh"
. "../../../func_config.sh"

CONFIG_FILE_PATH=/tmp/cf

cat > $CONFIG_FILE_PATH <<EOF
param1=value1
param2=value2
param3=value3
param4=value4
EOF

set_config_param_by_name param2 value2*2
set_config_param_by_name param5 value5

diff $CONFIG_FILE_PATH - <<EOF
param1=value1
param3=value3
param4=value4
param2=value2*2
param5=value5
EOF

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 1; }

rm -f $CONFIG_FILE_PATH

echo "$0: OK"
