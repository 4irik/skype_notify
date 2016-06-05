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
# директория с аватарами контактов
AVATAR_IMAGE_PATH="$USER_HOME_PATH/.skype_notify/avatars"
# директория с БД скайпа
SKYPE_DB_PATH="$USER_HOME_PATH/.Skype/overdosefire/main.db"

# картинка уведомления по-умолчанию
DEFAULT_NOTIFY_IMAGE="skype"

CONTACT_SKYPENAME=$1
CONTACT_USERNAME=$2
CONTACT_MESSAGE=$3     # зачастую содержит ещё и имя = $CONTACT_USERNAME

# генерирует название файла с аватаром пользователя по никнейму пользователя
generate_avatar_image_name ()
{
	echo "$1.jpg"
}

# возвращает полный путь до аватара
generate_avatar_path_name ()
{
	echo "$AVATAR_IMAGE_PATH/"$(generate_avatar_image_name $1)
}

# сохраняет аватар пользователя из БД 
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

# проверяем что все директории и файлы созданы
if [ ! -d "$AVATAR_IMAGE_PATH" ]; then
	if [ ! -L "$AVATAR_IMAGE_PATH" ]; then
		mkdir -p $AVATAR_IMAGE_PATH
	fi
fi

##
# Устанавливаем картинку уведомления. Порядок:
#  - получаем полный путь до аватара контакта;
#  - если файл не существует пытаемся взять его из БД скайпа;
#  - если в БД скайпа нет аватара то ставим по-умолчанию.
##
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

#           имя контакта        сообщение             картинка
notify-send "$CONTACT_USERNAME" "$CONTACT_MESSAGE" -i $NOTIFY_IMAGE

