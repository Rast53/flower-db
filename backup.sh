#!/bin/bash

# Настройки для подключения
DB_USER=${POSTGRES_USER:-floweruser}
DB_NAME=${POSTGRES_DB:-flowerdb}
CONTAINER_NAME="flower-postgres"
BACKUP_DIR="/volume1/backups/flower-db"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="${BACKUP_DIR}/flower-db_${DATE}.sql"

# Проверка директории для бэкапов
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Создание директории для бэкапов ${BACKUP_DIR}..."
    mkdir -p "$BACKUP_DIR"
fi

# Выполнение бэкапа
echo "Создание бэкапа базы данных ${DB_NAME} в файл ${BACKUP_FILE}..."
docker exec -t $CONTAINER_NAME pg_dump -U $DB_USER $DB_NAME > $BACKUP_FILE

# Проверка результата
if [ $? -eq 0 ]; then
    echo "Бэкап успешно создан!"
    echo "Удаление старых бэкапов (оставляем последние 5)..."
    ls -t ${BACKUP_DIR}/flower-db_*.sql | tail -n +6 | xargs rm -f
    echo "Готово!"
else
    echo "Ошибка при создании бэкапа!"
    exit 1
fi 