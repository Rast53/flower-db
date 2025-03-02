#!/bin/bash

# Проверка наличия аргумента
if [ "$#" -ne 1 ]; then
    echo "Использование: $0 <путь_к_файлу_бэкапа>"
    exit 1
fi

BACKUP_FILE=$1

# Проверка существования файла
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Ошибка: Файл бэкапа \"$BACKUP_FILE\" не найден!"
    exit 1
fi

# Настройки для подключения
DB_USER=${POSTGRES_USER:-floweruser}
DB_NAME=${POSTGRES_DB:-flowerdb}
CONTAINER_NAME="flower-postgres"

echo "Внимание! Это действие заменит текущие данные в базе данных $DB_NAME!"
read -p "Вы уверены, что хотите восстановить данные из бэкапа? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Операция отменена."
    exit 0
fi

# Восстановление базы данных
echo "Восстановление базы данных $DB_NAME из файла $BACKUP_FILE..."
cat $BACKUP_FILE | docker exec -i $CONTAINER_NAME psql -U $DB_USER $DB_NAME

# Проверка результата
if [ $? -eq 0 ]; then
    echo "База данных успешно восстановлена!"
else
    echo "Ошибка при восстановлении базы данных!"
    exit 1
fi 