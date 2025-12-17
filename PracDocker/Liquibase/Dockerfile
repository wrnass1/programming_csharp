FROM liquibase/liquibase:latest

# Копируем драйвер PostgreSQL
COPY liquibase-drivers/postgresql.jar /liquibase/lib/

# Копируем changelog и SQL скрипты
COPY PracDocker/Liquibase/changelog.xml /liquibase/changelog/
COPY PracDocker/Liquibase/change-sets/ /liquibase/changelog/change-sets/
COPY PracDocker/Liquibase/sql/ /liquibase/changelog/sql/

WORKDIR /liquibase/changelog

# Команда по умолчанию - применение миграций
CMD ["--driver=org.postgresql.Driver", \
     "--classpath=/liquibase/lib/postgresql.jar", \
     "--url=jdbc:postgresql://db:5432/test_db", \
     "--username=test_user", \
     "--password=test_password", \
     "--changeLogFile=changelog.xml", \
     "update"]

