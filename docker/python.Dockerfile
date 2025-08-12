FROM python:3.11-slim

# Instala dependências do SO para compilar o psycopg2 e para o psql
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev postgresql-client && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY ./python/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copia todo o código da pasta python para o container
COPY ./python /app

# Comando para iniciar o servidor Flask
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]