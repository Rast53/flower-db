#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Функция для проверки наличия .env файла
check_env_file() {
    if [ ! -f .env ]; then
        echo -e "${YELLOW}Файл .env не найден. Создаю шаблон...${NC}"
        cat > .env << EOF
POSTGRES_USER=floweruser
POSTGRES_PASSWORD=flowerpass
POSTGRES_DB=flowerdb
EOF
        echo -e "${GREEN}Файл .env создан. Пожалуйста, отредактируйте его при необходимости.${NC}"
    fi
}

# Функция для проверки создания директории данных
check_data_directory() {
    DATA_DIR="/volume1/docker/flower-db/data"
    
    if [ ! -d "$DATA_DIR" ]; then
        echo -e "${YELLOW}Директория для данных не найдена. Создаю...${NC}"
        sudo mkdir -p "$DATA_DIR"
        sudo chmod -R 777 "$DATA_DIR"
        echo -e "${GREEN}Директория для данных создана: $DATA_DIR${NC}"
    fi
}

# Функция для запуска базы данных
start_database() {
    echo -e "${GREEN}Запуск базы данных...${NC}"
    docker-compose up -d
    echo -e "${GREEN}База данных запущена!${NC}"
}

# Функция для остановки базы данных
stop_database() {
    echo -e "${YELLOW}Остановка базы данных...${NC}"
    docker-compose down
    echo -e "${GREEN}База данных остановлена.${NC}"
}

# Функция для перезапуска базы данных
restart_database() {
    echo -e "${YELLOW}Перезапуск базы данных...${NC}"
    docker-compose restart
    echo -e "${GREEN}База данных перезапущена.${NC}"
}

# Функция для просмотра статуса базы данных
status_database() {
    echo -e "${GREEN}Статус базы данных:${NC}"
    docker-compose ps
    echo -e "${GREEN}Использование ресурсов:${NC}"
    docker stats --no-stream flower-postgres
}

# Функция для выполнения запроса к базе данных
exec_query() {
    if [ "$#" -ne 1 ]; then
        echo -e "${RED}Ошибка: Требуется запрос SQL.${NC}"
        echo "Использование: $0 query \"SQL ЗАПРОС\""
        exit 1
    fi
    
    DB_USER=$(grep POSTGRES_USER .env | cut -d= -f2)
    DB_NAME=$(grep POSTGRES_DB .env | cut -d= -f2)
    
    echo -e "${GREEN}Выполнение запроса...${NC}"
    docker exec -it flower-postgres psql -U $DB_USER -d $DB_NAME -c "$1"
}

# Функция для подключения к psql
connect_psql() {
    DB_USER=$(grep POSTGRES_USER .env | cut -d= -f2)
    DB_NAME=$(grep POSTGRES_DB .env | cut -d= -f2)
    
    echo -e "${GREEN}Подключение к psql...${NC}"
    docker exec -it flower-postgres psql -U $DB_USER -d $DB_NAME
}

# Проверка аргументов
case "$1" in
    start)
        check_env_file
        check_data_directory
        start_database
        ;;
    stop)
        stop_database
        ;;
    restart)
        restart_database
        ;;
    status)
        status_database
        ;;
    backup)
        ./backup.sh
        ;;
    restore)
        if [ "$#" -ne 2 ]; then
            echo -e "${RED}Ошибка: Требуется путь к файлу бэкапа.${NC}"
            echo "Использование: $0 restore <путь_к_файлу_бэкапа>"
            exit 1
        fi
        ./restore.sh "$2"
        ;;
    query)
        shift
        exec_query "$*"
        ;;
    connect)
        connect_psql
        ;;
    *)
        echo -e "${GREEN}Управление базой данных цветочного магазина${NC}"
        echo "Использование: $0 КОМАНДА"
        echo ""
        echo "Доступные команды:"
        echo "  start       - Запуск базы данных"
        echo "  stop        - Остановка базы данных"
        echo "  restart     - Перезапуск базы данных"
        echo "  status      - Статус базы данных"
        echo "  backup      - Создание бэкапа базы данных"
        echo "  restore PATH - Восстановление базы данных из бэкапа"
        echo "  query SQL   - Выполнение SQL запроса"
        echo "  connect     - Подключение к консоли psql"
        exit 1
        ;;
esac

exit 0 