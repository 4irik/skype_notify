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

# директория пользователя
USER_HOME_PATH="/home/$USER"
# файл конфигурации
CONFIG_FILE_PATH="$USER_HOME_PATH/.skype_notify"
# директория с аватарами контактов
AVATAR_IMAGE_PATH="$USER_HOME_PATH/.skype_notify.d/avatars"
# никнейм пользователя в скайпе
SKYPE_NAME=""
# директория с БД скайпа
SKYPE_DB_PATH="$USER_HOME_PATH/.Skype/_SKYPE_NAME_/main.db"

# картинка уведомления по-умолчанию
DEFAULT_NOTIFY_IMAGE="skype"

CONTACT_SKYPENAME=$1
CONTACT_USERNAME=$2
CONTACT_MESSAGE=$3     # зачастую содержит ещё и имя = $CONTACT_USERNAME

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
	sqlite3 $SKYPE_DB_PATH "SELECT writefile('$AVATAR_PATH_NAME', avatar_image) FROM contacts WHERE skypename='$1' AND avatar_image NOT NULL;"
	if [ -f "$AVATAR_PATH_NAME" ]; then
		# удаляем первые двай байта - почему-то первые 2-а байта в получаемом
		# файле портят файл-изображения
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
			# у контакта нет аватара
			NOTIFY_IMAGE=$DEFAULT_NOTIFY_IMAGE
		fi
	fi
}

##
# Удаляет у строки слева и справа пробелы или переданный в качестве второго аргумента символ
#
# @param string исходная строка
# @param string|null символ, который нужно удалить, если ничего не передано будут удалены пробелы
# @Stdout string 
##
trim ()
{
	SOURCE_STRING=$1
	DELETED_CHAR=$2
	if [ "$DELETED_CHAR" = "" ]; then
		DELETED_CHAR=" "
	fi
	
	TMP_VALUE=${SOURCE_STRING##*($DELETED_CHAR)}
	TMP_VALUE=${TMP_VALUE%%*($DELETED_CHAR)}
	echo $TMP_VALUE
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
# Инициализация скрипта
##
init ()
{
	# читаем конфигурацию
	if [ ! -f "$CONFIG_FILE_PATH" ]; then
		echo "Не обнаружен файл конфигурации $CONFIG_FILE_PATH" # todo выводить в поток ошибок
		
		exit 1
	else
		# получаем skype-имя пользователя
		SKYPE_NAME=$(get_config_param_by_name "skype_name")
		if [ "$SKYPE_NAME" = "" ]; then
			echo "В конфигурационном файле не установлено Skype-имя пользователя."
			
			exit 1
		fi
		# устанавливаем путь до БД скайпа
		SKYPE_DB_PATH=${SKYPE_DB_PATH/"_SKYPE_NAME_"/$SKYPE_NAME}
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

echo $CONTACT_MESSAGE
# удаляем из сообщения имя отправителя
CONTACT_MESSAGE=${CONTACT_MESSAGE/"$CONTACT_USERNAME:"/""}
# устанавливаем картинку сообщения
set_notify_image

#           имя контакта        сообщение             картинка
notify-send "$CONTACT_USERNAME" "$CONTACT_MESSAGE" -i $NOTIFY_IMAGE

