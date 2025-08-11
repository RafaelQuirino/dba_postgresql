#!/usr/bin/env python3
"""
fetch_genres_omdb.py

- Lê amostra de raw_data.producao (30 aleatórios por producao_tipo_id)
- Consulta OMDb (por título+ano; fallback: busca e lookup por imdbID)
- Insere/atualiza analytics.producao_genero
- Imprime tabela final com coluna 'genero' à direita
"""

import psycopg2
from psycopg2.extras import execute_values
import urllib.request
import urllib.parse
import time
import unicodedata
import re
import logging
import sys
import os

import classificacao_por_tipo

# ---------- CONFIGURAÇÃO ----------
DB_CONFIG = {
	'host': os.getenv('PGHOST', 'postgresql'),
	'port': os.getenv('PGPORT', '5432'),
	'dbname': os.getenv('PGDATABASE', 'cinetech_productions'),
	'user': os.getenv('PGUSER', 'postgres'),
	'password': os.getenv('PGPASSWORD', 'postgres123')
}

OMDB_API_KEY =  os.getenv('OMDB_API_KEY', 'SUA_CHAVE_OMDB')  # <-- coloque sua chave aqui
OMDB_URL = "http://www.omdbapi.com/"

SAMPLE_SIZE_PER_TYPE = 10
REQUEST_SLEEP = 0.5   # segundos entre requisições à OMDb (ajuste conforme limite)
BATCH_COMMIT = True
# -----------------------------------

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s: %(message)s")


def normalize_title(s):
    if not s:
        return ""
    s = unicodedata.normalize("NFKD", s)
    s = "".join(ch for ch in s if not unicodedata.combining(ch))
    s = re.sub(r"[^A-Za-z0-9 ]+", "", s)
    return s.strip().lower()


def fetch_genre_omdb(title, year, max_retries=3):
    """
    Tenta obter Genre via OMDb:
      1) request by title+year (t, y)
      2) fallback: search (s) -> pick best match -> request by imdbID (i)
    Retorna (genre_string_or_None, imdb_id_or_None)
    """
    title = title or ""
    year_str = str(year) if year else None

    # 1) por título+ano
    params = {"t": title, "apikey": OMDB_API_KEY}
    if year_str:
        params["y"] = year_str

    for attempt in range(1, max_retries + 1):
        try:
            url = OMDB_URL + "?" + urllib.parse.urlencode(params)
            with urllib.request.urlopen(url, timeout=10) as response:
                if response.status == 200:
                    import json
                    j = json.load(response)
                    if j.get("Response") == "True" and j.get("Genre"):
                        return j.get("Genre"), j.get("imdbID")
                    break
                else:
                    logging.warning(f"OMDb status {response.status} for {title} ({year}). Retrying...")
        except Exception as ex:
            logging.warning(f"Erro na requisição OMDb (t): {ex}")
        time.sleep(attempt)  # backoff

    # 2) fallback: search
    try:
        sparams = {"s": title, "apikey": OMDB_API_KEY}
        if year_str:
            sparams["y"] = year_str
        url = OMDB_URL + "?" + urllib.parse.urlencode(sparams)
        with urllib.request.urlopen(url, timeout=10) as response:
            if response.status == 200:
                import json
                sj = json.load(response)
                if sj.get("Response") == "True" and "Search" in sj:
                    norm_target = normalize_title(title)
                    for item in sj["Search"]:
                        if normalize_title(item.get("Title", "")) == norm_target and \
                           (not year_str or str(item.get("Year","")).startswith(year_str)):
                            iid = item["imdbID"]
                            url2 = OMDB_URL + "?" + urllib.parse.urlencode({"i": iid, "apikey": OMDB_API_KEY})
                            with urllib.request.urlopen(url2, timeout=10) as r2:
                                if r2.status == 200:
                                    d2 = json.load(r2)
                                    if d2.get("Response") == "True" and d2.get("Genre"):
                                        return d2.get("Genre"), d2.get("imdbID")
                    # se não achou exato, pega primeiro resultado e busca por imdbID
                    first = sj["Search"][0]
                    iid = first["imdbID"]
                    url2 = OMDB_URL + "?" + urllib.parse.urlencode({"i": iid, "apikey": OMDB_API_KEY})
                    with urllib.request.urlopen(url2, timeout=10) as r2:
                        if r2.status == 200:
                            d2 = json.load(r2)
                            if d2.get("Response") == "True" and d2.get("Genre"):
                                return d2.get("Genre"), d2.get("imdbID")
    except Exception as ex:
        logging.warning(f"Erro na busca OMDb (s): {ex}")

    return None, None


def get_sample_from_db(conn, sample_size=SAMPLE_SIZE_PER_TYPE):
    query = f"""
    SELECT producao_tipo_id, titulo, ano_producao
    FROM (
        SELECT producao_tipo_id, titulo, ano_producao,
               ROW_NUMBER() OVER (PARTITION BY producao_tipo_id ORDER BY RANDOM()) AS rn
        FROM raw_data.producao
        WHERE ano_producao IS NOT NULL
    ) sub
    WHERE rn <= %s
    ORDER BY producao_tipo_id, rn;
    """
    with conn.cursor() as cur:
        cur.execute(query, (sample_size,))
        rows = cur.fetchall()
    return rows


def pretty_print_table(rows):
    """
    rows: list of tuples (producao_tipo_id, titulo, ano_producao, genero)
    """
    headers = ["producao_tipo_id", "titulo", "ano_producao", "genero"]
    # calcula larguras
    col_widths = [len(h) for h in headers]
    for r in rows:
        for i, v in enumerate(r):
            l = len(str(v)) if v is not None else 0
            if l > col_widths[i]:
                col_widths[i] = min(l, 120)  # limita título longo
    # print header
    fmt = " | ".join("{:<" + str(w) + "}" for w in col_widths)
    print(fmt.format(*headers))
    print("-" * (sum(col_widths) + 3 * (len(headers)-1)))
    for r in rows:
        # corta título se muito grande
        r_list = list(r)
        if len(str(r_list[1])) > 100:
            r_list[1] = str(r_list[1])[:97] + "..."
        print(fmt.format(*[("" if x is None else str(x)) for x in r_list]))


def main():
    if OMDB_API_KEY == "SUA_CHAVE_OMDB":
        logging.error("Coloque sua OMDB_API_KEY no script antes de rodar.")
        sys.exit(1)

    # conecta no DB
    conn = psycopg2.connect(**DB_CONFIG)

    try:
        sample = get_sample_from_db(conn, SAMPLE_SIZE_PER_TYPE)
        logging.info(f"Amostra obtida: {len(sample)} linhas.")

        output_rows = []

        for idx, (ptype, title, year) in enumerate(sample, start=1):
            logging.info(f"[{idx}/{len(sample)}] {title} ({year}) - buscando gênero...")
            genre, imdb_id = fetch_genre_omdb(title, year)
            if genre:
                logging.info(f"  => {genre} (imdb: {imdb_id})")
            else:
                logging.info("  => gênero não encontrado")
            output_rows.append((ptype, title, year, genre))
            time.sleep(REQUEST_SLEEP)

        # imprime tabela final
        pretty_print_table(output_rows)
        classificacao_por_tipo.classify_producao(output_rows)

    finally:
        conn.close()


if __name__ == "__main__":
    main()
