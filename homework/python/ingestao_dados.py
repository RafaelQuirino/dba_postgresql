# -*- coding: utf-8 -*-
import os
import sys
import psycopg2
import multiprocessing as mp
from tqdm import tqdm
import re
import time
from psycopg2 import pool

CHUNK_SIZE = 15000
N_WORKERS = max(1, mp.cpu_count() - 1)

db_config = {
	'host': os.getenv('HOST', 'postgresql'),
	'port': os.getenv('PGPORT', '5432'),
	'dbname': os.getenv('PGDATABASE', 'cinetech_productions'),
	'user': os.getenv('PGUSER', 'postgres'),
	'password': os.getenv('PGPASSWORD', 'postgres123')
}

data_dir = os.path.join(os.path.dirname(__file__), '../bd_producao_artistica')
files = {
	'producao': os.path.join(data_dir, 'producao.txt'),
	'pessoa': os.path.join(data_dir, 'pessoa.txt'),
	'equipe': os.path.join(data_dir, 'equipe.txt'),
}

def get_pg_pool():
    # Always create a new pool in each process (multiprocessing safe)
    if not hasattr(get_pg_pool, "_pg_pool"):
        get_pg_pool._pg_pool = pool.ThreadedConnectionPool(
            minconn=1,
            maxconn=10000,  # Set to a reasonable value for each process
            **db_config
        )
    return get_pg_pool._pg_pool

def get_connection():
    return psycopg2.connect(**db_config)
    # return get_pg_pool().getconn()

def release_connection(conn):
    conn.close()
    # get_pg_pool().putconn(conn)

def parse_line_producao(line):
    match = re.match(r'^\b(\d+)\b##(.*?)##\b(\d+)\b##\b(\d+)\b$', line.strip(), re.IGNORECASE)
    if not match:
        return None
    producao_id, titulo, ano_producao, producao_tipo_id = match.groups()
    if titulo.lower() == 'null':
        titulo = ''  # campo NOT NULL
    if ano_producao == '0' or ano_producao.lower() == 'null':
        ano_producao = None
    if producao_tipo_id.lower() == 'null':
        producao_tipo_id = None
    return (
        int(producao_id),
        titulo,
        int(ano_producao) if ano_producao else None,
        int(producao_tipo_id) if producao_tipo_id else None
    )

def parse_line_pessoa(line):
	parts = line.strip().split('##')
	if len(parts) != 2:
		return None
	pessoa_id, nome = parts
	if nome.lower() == 'null':
		nome = ''  # campo NOT NULL
	return (int(pessoa_id), nome)

def parse_line_equipe(line):
	parts = line.strip().split('##')
	if len(parts) != 3:
		return None
	pessoa_id, producao_id, papel = parts
	if papel.lower() == 'null':
		papel = None
	return (int(pessoa_id), int(producao_id), papel)

def insert_data_bulk(table, cur, data, chunk_index=None, start_line=None, lines=None):
    max_retries = 5
    attempt = 0
    while attempt < max_retries:
        try:
            if table == 'producao':
                cur.executemany(
                    'INSERT INTO raw_data.producao (producao_id, titulo, ano_producao, producao_tipo_id)'
                    'VALUES (%s, %s, %s, %s)',
                    data
                )
            elif table == 'pessoa':
                cur.executemany('INSERT INTO raw_data.pessoa (pessoa_id, nome) VALUES (%s, %s) ON CONFLICT DO NOTHING', data)
            elif table == 'equipe':
                cur.executemany(
                    '''
                    INSERT INTO raw_data.equipe (pessoa_id, producao_id, papel) VALUES (%s, %s, %s) 
                    ON CONFLICT (pessoa_id, producao_id) 
                    DO UPDATE SET papel = EXCLUDED.papel where EXCLUDED.papel IS NOT NULL
                    ''',
                    data
                )
            cur.connection.commit()
            return  # Sucesso, sai da função
        except psycopg2.Error as e:
            if getattr(e, 'pgcode', None) == '40P01':  # Deadlock detected
                attempt += 1
                wait = 2 ** attempt
                print(f"[DEADLOCK] Chunk {chunk_index} (linhas {start_line}-{start_line+len(lines)-1 if start_line is not None and lines is not None else '?'}) - Tentativa {attempt}/{max_retries}. Retentando em {wait}s...")
                time.sleep(wait)
                cur.connection.rollback()
            else:
                endline = start_line+len(lines)-1 if start_line is not None and lines is not None else '?'
                print(f"[SQL ERROR] Chunk {chunk_index} (linhas {start_line}-{endline}) {e}")
                break
    else:
        print(f"[DEADLOCK] Chunk {chunk_index} (linhas {start_line}-{start_line+len(lines)-1 if start_line is not None and lines is not None else '?'}) - Falha após {max_retries} tentativas.")

def insert_producao_tipo():
	"""Cria e popula a tabela producao_tipo com todos os tipos encontrados."""
	conn = get_connection()
	cur = conn.cursor()
	tipo_set = set()
	with open(files['producao'], encoding='ISO-8859-1') as producao_file:
		for line in producao_file:
			parts = line.strip().split('##')
			if len(parts) == 4 and parts[3].lower() != 'null':
				tipo_set.add(int(parts[3]))
	for tipo_id in tipo_set:
		cur.execute(
			'INSERT INTO raw_data.producao_tipo (producao_tipo_id, nome) VALUES (%s, %s) ON CONFLICT DO NOTHING',
			(tipo_id, f'Categoria {tipo_id}')
		)
	conn.commit()
	cur.close()
	release_connection(conn)

def process_chunk(args):
    # Suporte a chamada antiga e nova (com chunk_index e start_line)
    if len(args) == 2:
        table, lines = args
        chunk_index = None
        start_line = None
    else:
        table, lines, chunk_index, start_line = args
    conn = get_connection()
    cur = conn.cursor()
    data = []
    parse_func = None
    if table == 'producao':
        parse_func = parse_line_producao
    elif table == 'pessoa':
        parse_func = parse_line_pessoa
    elif table == 'equipe':
        parse_func = parse_line_equipe
    else:
        print(f"[ERRO] Tabela desconhecida: {table}")
        return len(lines)

    # Parsing com tratamento de erro
    for idx, line in enumerate(lines):
        try:
            parsed = parse_func(line)
            if parsed:
                 data.append(parsed)
            else:
                 print(f"[PARSE WARNING] Linha {(start_line + idx) if start_line is not None else f'?+{idx}'}: Formato inválido ou dados insuficientes.")
            # if parsed:
            #     try:
            #         affected = insert_func(cur, parsed)
            #         if affected == 0:
            #             file_line = (start_line + idx) if start_line is not None else f'?+{idx}'
            #             print(f"[NO INSERT] Linha {file_line}: Nenhum registro alterado.")
            #     except Exception as e:
            #         file_line = (start_line + idx) if start_line is not None else f'?+{idx}'
            #         print(f"[SQL ERROR] Linha {file_line}: {e}")
        except Exception as e:
            file_line = (start_line + idx) if start_line is not None else f'?+{idx}'
            print(f"\n[PARSE ERROR] Linha {file_line}: {e}")

    insert_data_bulk(table, cur, data, chunk_index, start_line, lines)
    conn.commit()
    cur.close()
    release_connection(conn)
    return len(lines)

def ingest_file(table):
    file_path = files[table]
    total_lines = sum(1 for _ in open(file_path, encoding='ISO-8859-1'))
    with open(file_path, encoding='ISO-8859-1') as file_in:
        pool = mp.Pool(N_WORKERS)
        progress_bar = tqdm(total=total_lines, desc=f'Ingest {table}', ncols=80)
        chunk = []
        results = []
        chunk_index = 0
        start_line = 1
        for line in file_in:
            chunk.append(line)
            if len(chunk) >= CHUNK_SIZE:
                results.append(pool.apply_async(process_chunk, ((table, chunk, chunk_index, start_line),)))
                start_line += len(chunk)
                chunk_index += 1
                chunk = []
            if len(results) > N_WORKERS * 2:
                for result in results:
                    progress_bar.update(result.get())
                results = []
        if chunk:
            results.append(pool.apply_async(process_chunk, ((table, chunk, chunk_index, start_line),)))
        for result in results:
            progress_bar.update(result.get())
        pool.close()
        pool.join()
        progress_bar.close()

def main():
	print('Criando e populando producao_tipo...')
	insert_producao_tipo()
	
	for table in ['pessoa', 'producao', 'equipe']:
		print(f'Iniciando ingestão de {table}...')
		ingest_file(table)
	print('Ingestão concluída.')

if __name__ == '__main__':
	main()

