# Базовий образ Python
FROM python:3.9-slim

# Встановлюємо системні залежності
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Встановлюємо робочу директорію
WORKDIR /app

# Копіюємо файли проекту та встановлюємо залежності
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Виставляємо порт, на якому Django слухає
EXPOSE 8000

# Команда для запуску Django
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
