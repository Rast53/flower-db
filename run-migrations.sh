#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Проверка наличия .env файла
if [ ! -f .env ]; then
    echo -e "${RED}Файл .env не найден!${NC}"
    exit 1
fi

# Загрузка переменных окружения
source .env

# Настройки для подключения
DB_USER=${POSTGRES_USER:-floweruser}
DB_NAME=${POSTGRES_DB:-flowerdb}
CONTAINER_NAME="flower-postgres"
MIGRATIONS_DIR="./migrations"

# Проверка наличия директории миграций
if [ ! -d "$MIGRATIONS_DIR" ]; then
    echo -e "${RED}Директория миграций не найдена!${NC}"
    exit 1
fi

# Создание таблицы для отслеживания миграций (если не существует)
echo -e "${YELLOW}Проверка таблицы миграций...${NC}"
docker exec -i $CONTAINER_NAME psql -U $DB_USER $DB_NAME << EOF
CREATE TABLE IF NOT EXISTS migrations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF

# Получение списка уже применённых миграций
APPLIED_MIGRATIONS=$(docker exec -i $CONTAINER_NAME psql -U $DB_USER $DB_NAME -t -c "SELECT name FROM migrations ORDER BY id;")

# Получение списка всех миграций
ALL_MIGRATIONS=$(find $MIGRATIONS_DIR -name "*.sql" -type f | sort)

# Счётчик применённых миграций
APPLIED_COUNT=0

# Применение миграций
for MIGRATION in $ALL_MIGRATIONS; do
    MIGRATION_NAME=$(basename $MIGRATION)
    
    # Проверка, была ли уже применена миграция
    if echo "$APPLIED_MIGRATIONS" | grep -q "$MIGRATION_NAME"; then
        echo -e "${YELLOW}Миграция $MIGRATION_NAME уже применена, пропускаю...${NC}"
        continue
    fi
    
    echo -e "${GREEN}Применение миграции $MIGRATION_NAME...${NC}"
    
    # Применение миграции
    cat $MIGRATION | docker exec -i $CONTAINER_NAME psql -U $DB_USER $DB_NAME
    
    if [ $? -eq 0 ]; then
        # Запись в таблицу миграций
        docker exec -i $CONTAINER_NAME psql -U $DB_USER $DB_NAME -c "INSERT INTO migrations (name) VALUES ('$MIGRATION_NAME');"
        echo -e "${GREEN}Миграция $MIGRATION_NAME успешно применена!${NC}"
        ((APPLIED_COUNT++))
    else
        echo -e "${RED}Ошибка при применении миграции $MIGRATION_NAME!${NC}"
        exit 1
    fi
done

if [ $APPLIED_COUNT -eq 0 ]; then
    echo -e "${YELLOW}Новых миграций не найдено.${NC}"
else
    echo -e "${GREEN}Успешно применено $APPLIED_COUNT миграций.${NC}"
fi

exit 0 