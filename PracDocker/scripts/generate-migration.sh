#!/bin/bash

# Скрипт для автогенерации миграций
# Использование: ./scripts/generate-migration.sh <MigrationName>

if [ -z "$1" ]; then
    echo "Ошибка: Укажите имя миграции"
    echo "Использование: ./scripts/generate-migration.sh <MigrationName>"
    exit 1
fi

MIGRATION_NAME=$1
PROJECT_DIR="PracDocker"
MIGRATIONS_DIR="$PROJECT_DIR/Migrations"
LIQUIBASE_SQL_DIR="$PROJECT_DIR/Liquibase/sql"
LIQUIBASE_CHANGESETS_DIR="$PROJECT_DIR/Liquibase/change-sets"

# Получаем номер следующей миграции
LAST_MIGRATION=$(ls -1 $LIQUIBASE_SQL_DIR/*.sql 2>/dev/null | sort -V | tail -1)
if [ -z "$LAST_MIGRATION" ]; then
    NEXT_NUM="001"
else
    LAST_NUM=$(basename "$LAST_MIGRATION" | cut -d'_' -f1)
    NEXT_NUM=$(printf "%03d" $((10#$LAST_NUM + 1)))
fi

SQL_FILE_NAME="${NEXT_NUM}_${MIGRATION_NAME}.sql"
SQL_FILE_PATH="$LIQUIBASE_SQL_DIR/$SQL_FILE_NAME"

# Проверяем, доступен ли dotnet ef локально
if ! dotnet ef --version > /dev/null 2>&1; then
    echo "⚠️  dotnet ef недоступен локально. Используем Docker..."
    USE_DOCKER=true
else
    USE_DOCKER=false
fi

if [ "$USE_DOCKER" = true ]; then
    echo "Восстановление пакетов через Docker..."
    docker run --rm -v "$(pwd):/workspace" -w /workspace mcr.microsoft.com/dotnet/sdk:8.0 dotnet restore "$PROJECT_DIR"
    
    echo "Создание EF Core миграции: $MIGRATION_NAME (через Docker)..."
    docker run --rm -v "$(pwd):/workspace" -w /workspace mcr.microsoft.com/dotnet/sdk:8.0 dotnet ef migrations add "$MIGRATION_NAME" --project "$PROJECT_DIR"
else
    echo "Восстановление пакетов..."
    dotnet restore "$PROJECT_DIR"
    
    echo "Создание EF Core миграции: $MIGRATION_NAME..."
    dotnet ef migrations add "$MIGRATION_NAME" --project "$PROJECT_DIR"
fi

if [ $? -ne 0 ]; then
    echo "Ошибка при создании миграции EF Core"
    exit 1
fi

# Находим последнюю созданную миграцию
LAST_EF_MIGRATION=$(ls -1t "$MIGRATIONS_DIR"/*.cs 2>/dev/null | grep -v "AppDbContextModelSnapshot" | head -1)

if [ -z "$LAST_EF_MIGRATION" ]; then
    echo "Ошибка: Не найдена созданная миграция EF Core"
    exit 1
fi

echo "Генерация SQL скрипта из миграции..."
# Получаем имя миграции из имени файла
MIGRATION_CLASS_NAME=$(basename "$LAST_EF_MIGRATION" .cs)

# Генерируем SQL скрипт
if [ "$USE_DOCKER" = true ]; then
    docker run --rm -v "$(pwd):/workspace" -w /workspace mcr.microsoft.com/dotnet/sdk:8.0 dotnet ef migrations script --project "$PROJECT_DIR" --output "$SQL_FILE_PATH" --idempotent
else
    dotnet ef migrations script --project "$PROJECT_DIR" --output "$SQL_FILE_PATH" --idempotent
fi

if [ $? -ne 0 ]; then
    echo "Ошибка при генерации SQL скрипта"
    exit 1
fi

echo "SQL скрипт создан: $SQL_FILE_PATH"

# Добавляем комментарий в начало SQL файла
sed -i.bak "1i\\
-- Migration: $SQL_FILE_NAME\\
-- Generated from EF Core migration: $MIGRATION_CLASS_NAME\\
-- Author: student\\
\\
" "$SQL_FILE_PATH"
rm -f "${SQL_FILE_PATH}.bak"

# Создаем changeset файл
CHANGESET_FILE_NAME="${NEXT_NUM}_${MIGRATION_NAME}.xml"
CHANGESET_FILE_PATH="$LIQUIBASE_CHANGESETS_DIR/$CHANGESET_FILE_NAME"

cat > "$CHANGESET_FILE_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
        xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="
        http://www.liquibase.org/xml/ns/dbchangelog
        http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-4.20.xsd">

    <changeSet id="$NEXT_NUM" author="student">
        <sqlFile path="../sql/$SQL_FILE_NAME" relativeToChangelogFile="true"/>
    </changeSet>

</databaseChangeLog>
EOF

echo "Changeset файл создан: $CHANGESET_FILE_PATH"

echo ""
echo "✅ Миграция создана успешно!"
echo ""
echo "Созданные файлы:"
echo "1. SQL скрипт: $SQL_FILE_PATH"
echo "2. Changeset: $CHANGESET_FILE_PATH"
echo ""
echo "⚠️  ВАЖНО: Changeset автоматически включен через <includeAll path=\"change-sets\" /> в changelog.xml"
echo ""

