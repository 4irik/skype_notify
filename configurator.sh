#!/bin/bash

################################################################################
# Конфигуратор. Предназначен для установки параметров скрипта.
################################################################################

# импортируем функции
. params_common.sh
. func_common.sh
. func_config.sh
. func_white_list.sh

case $1 in
	"S" | "s" )
		echo "Введите скайп-имя своего аккаунта:"
		read USER_SKYPE_NAME
		
	    USER_SKYPE_NAME=$(trim $USER_SKYPE_NAME)
		if [ "$USER_SKYPE_NAME" = "" ]; then
		   	echo "Скайп-имя пользвоателя не может быть пустым"
			exit 1
		fi
		set_config_param_by_name skype_name $USER_SKYPE_NAME;;

	
	"C" | "c" )
		echo
		echo "Содержание конфигурационного файла \"$CONFIG_FILE_PATH\":"
		echo "================================================================================"
		cat $CONFIG_FILE_PATH | grep -v "#"
		echo "================================================================================"
		echo;;

	
	"A" | "a" )
		echo
		echo "Введите полный путь до файла:"
		read NEW_DEFAULT_AVATAR_PATH
		NEW_DEFAULT_AVATAR_PATH=$(trim $NEW_DEFAULT_AVATAR_PATH)
		if [ "$NEW_DEFAULT_AVATAR_PATH" = "" ]; then
			echo "Путь до файла не может быть пустым"
			exit 1
		fi
		if [ ! -f "$NEW_DEFAULT_AVATAR_PATH" ]; then
			echo "Файл \"$NEW_DEFAULT_AVATAR_PATH\" не найден"
			exit 1
		fi
		cp $NEW_DEFAULT_AVATAR_PATH $AVATAR_IMAGE_PATH/$DEFAULT_AVATAR_NAME".jpg"
		if [ ! -f "$NEW_DEFAULT_AVATAR_PATH" ]; then
			echo "Файл $NEW_DEFAULT_AVATAR_PATH не удалось скопировать"
			exit 1
		fi
		echo "Аватар по-умолчанию установлен."
		echo;;
	
		
	"U" | "u" )
		echo
		echo "Введите скайп-имя пользователя:"
		read USER_NAME
		USER_NAME=$(trim $USER_NAME)
		if [ "$USER_NAME" = "" ];then
			echo "Скайп-имя пользователя не может быть пустым"
			exit 1
		fi
		echo "Введите полный путь до файла:"
		read USER_AVATAR_PATH
		USER_AVATAR_PATH=$(trim $USER_AVATAR_PATH)
		if [ "$USER_AVATAR_PATH" = "" ]; then
			echo "Путь до файла не может быть пустым"
			exit 1
		fi
		if [ ! -f "$USER_AVATAR_PATH" ]; then
			echo "Файл \"$USER_AVATAR_PATH\" не найден"
			exit 1
		fi
		cp $USER_AVATAR_PATH $AVATAR_IMAGE_PATH/$USER_NAME".jpg"
		if [ ! -f "$USER_AVATAR_PATH" ]; then
			echo "Файл $USER_AVATAR_PATH не удалось скопировать"
			exit 1
		fi
		echo "Аватар для пользователя \"$USER_NAME\" установлен."
		echo;;
	

	"W" | "w" )
		echo
		echo "Введите скайп-имя пользователя:"
		read USER_NAME
		USER_NAME=$(trim $USER_NAME)
		if [ "$USER_NAME" = "" ];then
			echo "Скайп-имя пользователя не может быть пустым"
			exit 1
		fi
		# todo: проверка наличия пользователя в контактах
		wl_include_user $USER_NAME
		echo "Пользователь \"$USER_NAME\" добавлен в белый список."
		echo;;


	"D" | "d" )
		echo
		echo "Введите скайп-имя пользователя:"
		read USER_NAME
		USER_NAME=$(trim $USER_NAME)
		if [ "$USER_NAME" = "" ];then
			echo "Скайп-имя пользователя не может быть пустым"
			exit 1
		fi
		wl_exclude_user $USER_NAME
		echo "Пользователь \"$USER_NAME\" удалён из белого списока."
		echo;;


	"swl" )
		echo
		echo "Состав белого списка:"
		wl_show
		echo;;


	"ewl" )
		echo
		set_config_param_by_name white_list on
		echo "Белый список включён"
		echo;;

	
	"dwl" )
		echo
	    delete_config_param_by_name white_list
		echo "Белый список выключен"
		echo;;
		
		
	* )
		echo
		echo "Скрипт конфигурации для скрипта SkypeNotifer"
		echo
		echo "Доступные операции:"
		echo "    [S]et skype-name         установить скайп-имя аккаунта"
		echo "    Show [C]onfig            просмотреть конфигурацию"
		echo "    Set default [A]vatar     установить аватар контакта по-умолчанию"
		echo "    Set avatar for [U]ser    установить аватар для контакта"
		echo "    Add to [W]hite-list      добавить пользователя в белый список"
		echo "    [D]elte from white-list  добавить пользователя в белый список"
		echo "    Show white-list [swl]    просмотр белого списка"
		echo "    Enable white-list [ewl]  включение белого списка"
		echo "    Disable white-list [dwl] выключение белого списка"
		echo;;
esac

exit 0

