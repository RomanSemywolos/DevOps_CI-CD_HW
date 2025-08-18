#!/bin/sh
set -e

DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-5432}

echo "Waiting for PostgreSQL at $DB_HOST:$DB_PORT..."

# Перевірка TCP-з'єднання
until nc -z $DB_HOST $DB_PORT; do
  sleep 1
done

echo "PostgreSQL is available. Running migrations..."

python manage.py migrate
echo "Starting Django server..."
exec python manage.py runserver 0.0.0.0:8000
