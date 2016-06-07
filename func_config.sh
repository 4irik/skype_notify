#!/bin/bash

################################################################################
# Набор функций для работы с конфигурационным файлом.
################################################################################

##
# Возвращет значение параметра из конфигурационного файла
# 
# @param string название параметра в конфигурационном файле
# @Stdout string
##
get_config_param_by_name ()
{
    PARAM_VALUE=$(grep "$1=" $CONFIG_FILE_PATH | cut -f 2 -d "=")
	PARAM_VALUE=$(trim $PARAM_VALUE)
  
	echo $PARAM_VALUE
}

##
# Удаляет параметра из конфигурационного файла
#
# @param string название параметра
##
delete_config_param_by_name ()
{
	CONFIG=$(cat $CONFIG_FILE_PATH | grep -v $1)
	echo $CONFIG > $CONFIG_FILE_PATH
}

##
# Устанавливает значение параметра в конфигурационный файл
#
# @param string название параметра
# @param string значение параметра
##
set_config_param_by_name ()
{
	delete_config_param_by_name $1
	echo "$1=$2" >> $CONFIG_FILE_PATH
}
