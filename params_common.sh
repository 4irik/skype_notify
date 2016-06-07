#!/bin/bash

################################################################################
# Общие переменные.
################################################################################

# директория пользователя
USER_HOME_PATH="/home/$USER"
# файл конфигурации
CONFIG_FILE_PATH="$USER_HOME_PATH/.skype_notify"
# директория с файлами
CONFIG_DIR_PATH="$USER_HOME_PATH/.skype_notify.d"
# лог ошибок
ERROR_LOG="$CONFIG_DIR_PATH/error.log"
# директория с аватарами контактов
AVATAR_IMAGE_PATH="$CONFIG_DIR_PATH/avatars"
# никнейм пользователя в скайпе
SKYPE_NAME=""
# директория с БД скайпа
SKYPE_DB_PATH="$USER_HOME_PATH/.Skype/_SKYPE_NAME_/main.db"
# имя файла с аватаром контакта по-умолчанию
DEFAULT_AVATAR_NAME="default"
# картинка уведомления по-умолчанию
DEFAULT_NOTIFY_IMAGE="skype"
