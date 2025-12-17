# Миграции базы данных через Liquibase

Проект использует Liquibase для применения SQL миграций и EF Core Migrations для их автогенерации.

## Структура

- `changelog.xml` - главный файл миграций Liquibase (использует `<includeAll path="change-sets" />`)
- `change-sets/` - папка с XML файлами changeset'ов
- `sql/` - папка с SQL скриптами миграций
- `Migrations/` - папка с EF Core миграциями (для автогенерации)

## Автогенерация миграций

### Быстрый способ (скрипт)

```bash
./PracDocker/scripts/generate-migration.sh <MigrationName>
```

Например:
```bash
./PracDocker/scripts/generate-migration.sh AddCategoryToProduct
```

Скрипт автоматически:
1. Создаст EF Core миграцию
2. Сгенерирует SQL скрипт
3. Сохранит его в `sql/` с правильным номером
4. Покажет инструкцию для добавления в `change-sets/`

### Ручной способ

#### 1. Создание миграции через EF Core

```bash
dotnet ef migrations add <MigrationName> --project PracDocker
```

#### 2. Генерация SQL скрипта из миграции

```bash
# Получить номер следующей миграции (последний файл в sql/)
# Затем сгенерировать SQL:
dotnet ef migrations script --project PracDocker --output Liquibase/sql/XXX_migration_name.sql --idempotent
```

#### 3. Создание changeset файла

Создайте файл `change-sets/XXX_migration_name.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
        xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="
        http://www.liquibase.org/xml/ns/dbchangelog
        http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-4.20.xsd">

    <changeSet id="XXX" author="student">
        <sqlFile path="../sql/XXX_migration_name.sql" relativeToChangelogFile="true"/>
    </changeSet>

</databaseChangeLog>
```

**Важно:** `changelog.xml` использует `<includeAll path="change-sets" />`, поэтому все файлы из папки `change-sets/` будут автоматически включены.

## Применение миграций

Миграции применяются автоматически через Liquibase при запуске `docker compose up`.

Для ручного применения:
```bash
docker compose up migrations
```

## Формат именования

### SQL файлы:
- `001_create_products_table.sql`
- `002_add_category_to_products.sql`
- `003_create_orders_table.sql`

### Changeset файлы:
- `001_create_products_table.xml`
- `002_add_category_to_products.xml`
- `003_create_orders_table.xml`

Номера должны совпадать для соответствия SQL и XML файлов.

