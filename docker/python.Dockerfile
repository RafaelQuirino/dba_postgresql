FROM python:3.11-slim

# Instala dependências do SO para compilar o psycopg2
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY ./python/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt