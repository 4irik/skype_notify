# SkypeNotify

Вывод Skype-уведомлений через notify-osd.

## Использование

Скачайте скрипт. Установите права доступа на испольнение для файла `skype_notify.sh`:

```bash
$ chmod +x skype_notify.sh
```

Откройте настройки скайпа и установите параметры для пунктов
"Первое сообщение получено" и "Сообщение получено" в:

```bash
~\path\to\skype-notify\skype_notify.sh %sskype %sname %smessage
```

как паказано на картинке:

![Окно настроек уведомлений](найстройка_скайпа.jpg)

Вместо `~\path\to\skype-notify\` установите ваш путь до файла `skype_notify.sh`.

## Зависимости

 - sqlite3
 - notify-osd
 - libnotify-bin

## TODO

 - [ ] проверка наличия необходимых программ
 - [ ] отказ от использования утилиты sqlite3 (?)
 - [x] файл конфигурации
 - [ ] установка собственного аватара для контакта
 - [ ] чёрный список контактов (не показывать уведомления от них)
 - [ ] условия показа уведомлений для контактов из чёрного списка
 - [ ] показ уведомлений для других событий (звонок, передача файла)
 - [ ] собственные звуки уведомлений

