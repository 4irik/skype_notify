#!/bin/sh

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
# Зависимосоти:
#  - sqlite3
#  - libnotify-bin
#  - notify-osd
# 
################################################################################

# директория пользователя
USER_HOME_PATH="/home/$USER"

# директория с
SKYPE_DB_PATH="$USER_HOME_PATH/.Skype/overdosefire/main.db"

CONTACT_SKYPENAME=$1
CONTACT_USERNAME=$2
CONTACT_MESSAGE=$3     # usaly message contain contact name

# генерирует название файла с аватаром пользователя
generate_avatar_image_name ()
{
	echo "$1.jpg"
}

# получает аватар пользователя из БД и сохораняет его 
fetch_contact_avatar_image ()
{
	AVATAR_NAME=$(generate_avatar_image_name $1)
	sqlite3 $SKYPE_DB_PATH "SELECT writefile('$AVATAR_NAME', avatar_image) FROM contacts WHERE skypename='$1' AND avatar_image NOT NULL"
}

fetch_contact_avatar_image $1

#`notify-send "$1 $2 $3" -i skype`
