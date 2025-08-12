import psycopg2
import json
import sys
import os

DB_CONFIG = {
    'host': os.environ['DB_HOST'],
    'port': os.environ['DB_PORT'],
    'database': os.environ['DB_NAME'],
    'user': os.environ['DB_USER'],
    'password': os.environ['DB_PASSWORD']
}

def main():
    if len(sys.argv) != 2:
        print("Usage: python load_staging.py <path_to_pubs.json>")
        sys.exit(1)

    json_path = sys.argv[1]

    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    cur.execute("TRUNCATE TABLE pubs_staging;")
    cur.execute("INSERT INTO pubs_staging (data) VALUES (%s)", [json.dumps(data)])
    conn.commit()
    cur.close()
    conn.close()
    print("Dados do arquivo pubs.json carregados na tabela pubs_staging.")

if __name__ == "__main__":
    main() 