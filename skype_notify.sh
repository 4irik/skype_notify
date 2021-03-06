#!/bin/bash

################################################################################
# ========= Скрип вывода всплывающих уведомлений по событиям в Skype. ==========
#
# Использование:
#  Откройте главное окно Skype, выбирите пункт меню "Skype\Настройки" далее
#  перейдите в пункт меню "Уведомления", в правом блоке окна выбирите тип
#  события на которое хотите повесить скрипт, затем нажмите кнопку
#  "Больше настроек" внизу окна выбирите пункт "Запускать следующий скрипт:"
#  и в поле ввода введите следующую строку:
#  "/path/to/script/skype_notify.sh %sskype %sname %smessage"
#  где строку "/path/to/script" следует заменить на путь до скрипта
#  "skype_notify.sh" в вашей системе.
#
# Зависимости:
#  - sqlite3
#  - libnotify-bin
#  - notify-osd
#
# Ссылки:
#  https://gist.github.com/OpenCode/7044348 - получение картинки из SqLite БД
#                                             скайпа
#
# TODO:
#  - файл конфигурации (имя skype-аккаунта);
#  - удаление имени пользователя из сообщения;
#  - аватары контактов\групп во всплывающих уведомлениях;
#  - установка собственных аватаров для контактов\групп;
#  - чёрные списки для контактов\групп;
#  - серые списки - сообщения из этого списка показываются при наступлении
#    определённого события;
#  - события для "серых" списков:
#    - стоп слова;
#    - определённые контакты из группы;
#  - показ прочих уведомлений кроме сообщений в чат.
# 
################################################################################


#каталог скрипта
SCRIPT_PATH=$(dirname $0)

# импортируем функции
. $SCRIPT_PATH/params_common.sh
. $SCRIPT_PATH/exit_codes.sh
. $SCRIPT_PATH/func_common.sh
. $SCRIPT_PATH/func_config.sh
. $SCRIPT_PATH/func_white_list.sh

CONTACT_SKYPENAME=$1
CONTACT_USERNAME=$2
CONTACT_MESSAGE=$3

##
# Генерирует название файла с аватаром пользователя по никнейму.
#
# @param string никнейм контакта
# @Stdout string имя файла с аватаром
##
generate_avatar_image_name ()
{
	echo "$1.jpg"
}

##
# Генерирует полный путь до аватара контакта по его нику.
#
# @param string никнейм контакта
# @Stdout string полный путь до аватара контакта
##
generate_avatar_path_name ()
{
	echo "$AVATAR_IMAGE_PATH/"$(generate_avatar_image_name $1)
}

##
# Сохраняет аватар контакта из БД на диск
#
# @param string никнейм контакта
##
save_avatar_image_from_db_by_skypename ()
{
	AVATAR_PATH_NAME=$(generate_avatar_path_name $1)
	# todo избавиться от вывода сообщения
	sqlite3 $SKYPE_DB_PATH "SELECT writefile('$AVATAR_PATH_NAME', avatar_image) FROM contacts WHERE skypename='$1' AND avatar_image NOT NULL;"
	if [ -f "$AVATAR_PATH_NAME" ]; then
		# удаляем первые два байта - почему-то первые 2-а байта в получаемом
		# файле портят файл-изображение
		tail -c +2 $AVATAR_PATH_NAME > "/tmp/tmp_avatar"
		mv "/tmp/tmp_avatar" $AVATAR_PATH_NAME
	fi
}

##
# Устанавливаем картинку уведомления. Порядок:
#  - получаем полный путь до аватара контакта;
#  - если файл не существует пытаемся взять его из БД скайпа;
#  - если в БД скайпа нет аватара то ставим по-умолчанию.
##
set_notify_image()
{
	CONTACT_AVATAR=$(generate_avatar_path_name $CONTACT_SKYPENAME) # получаем путь до аватара
	NOTIFY_IMAGE=$CONTACT_AVATAR
	if [ ! -f "$CONTACT_AVATAR" ]; then
		# ищем и сохраняем на диск аватар контакта из БД скайпа
		save_avatar_image_from_db_by_skypename $CONTACT_SKYPENAME
		if [ ! -f "$CONTACT_AVATAR" ]; then
			# у контакта нет аватара, ищем картинку по-умолчанию
			CONTACT_AVATAR=$(generate_avatar_path_name $DEFAULT_AVATAR_NAME)
			if [ -f "$CONTACT_AVATAR" ]; then
				NOTIFY_IMAGE=$CONTACT_AVATAR
			else
				# ставим иконку скайпа
				NOTIFY_IMAGE=$DEFAULT_NOTIFY_IMAGE
			fi
		fi	
	fi
}

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
# Удаление из сообщения имени отправителя.
#
# @param string имя отправителя
# @param string сообщение
##
delete_name_from_message ()
{
	CONTACT_MESSAGE=${CONTACT_MESSAGE/"$CONTACT_USERNAME:"/""}
}

##
# Инициализация скрипта
##
init ()
{	
	# читаем конфигурацию
	if [ ! -f "$CONFIG_FILE_PATH" ]; then
		echo "Не обнаружен файл конфигурации $CONFIG_FILE_PATH" >> $ERROR_LOG # todo выводить в поток ошибок

		exit 1
	else
		# получаем skype-имя пользователя
		SKYPE_NAME=$(get_config_param_by_name "skype_name")
		if [ "$SKYPE_NAME" = "" ]; then
			echo "В конфигурационном файле не установлено Skype-имя пользователя." >> $ERROR_LOG
			
			exit 1
		fi
		# устанавливаем путь до БД скайпа
		SKYPE_DB_PATH=${SKYPE_DB_PATH/"_SKYPE_NAME_"/$SKYPE_NAME}
	fi

	# если не существует создаём каталог для хранения файлов скрипта
	if [ ! -d "$CONFIG_DIR_PATH" ];then
		if [ ! -L "$CONFIG_DIR_PATH" ]; then
			mkdir -p $CONFIG_DIR_PATH
		fi
	fi
	
	# создаём, если не существует, каталог для хранения аватаров
	if [ ! -d "$AVATAR_IMAGE_PATH" ]; then
		if [ ! -L "$AVATAR_IMAGE_PATH" ]; then
			mkdir -p $AVATAR_IMAGE_PATH
		fi
	fi
}

# проводим инициализацию скрипта
init

# проверяем, включен ли белый список, если включен то ищем
# пользвателя в нём
if [ $(get_config_param_by_name white_list) = "on" ]; then
	if wl_user_exists $CONTACT_SKYPENAME
	then
		exit 0
	fi
fi

# удаление из сообщения имени отправителя
delete_name_from_message
# устанавливаем картинку сообщения
set_notify_image

#           имя контакта        сообщение             картинка
notify-send "$CONTACT_USERNAME" "$CONTACT_MESSAGE" -i $NOTIFY_IMAGE 2>>$ERROR_LOG

