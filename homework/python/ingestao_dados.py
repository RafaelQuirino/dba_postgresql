# -*- coding: utf-8 -*-
import os
import sys
import psycopg2
import multiprocessing as mp
from tqdm import tqdm
import re

CHUNK_SIZE = 10000
N_WORKERS = max(1, mp.cpu_count() - 1)

db_config = {
	'host': os.getenv('PGHOST', 'postgresql'),
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

def get_connection():
	return psycopg2.connect(**db_config)

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
	conn.close()

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
        except Exception as e:
            file_line = (start_line + idx) if start_line is not None else f'?+{idx}'
            print(f"\n[PARSE ERROR] Linha {file_line}: {e}")

    # Execução SQL com tratamento de erro
    try:
        if table == 'producao':
            cur.executemany(
                'INSERT INTO raw_data.producao (producao_id, titulo, ano_producao, producao_tipo_id) VALUES (%s, %s, %s, %s) ON CONFLICT DO NOTHING',
                data
            )
        elif table == 'pessoa':
            cur.executemany(
                'INSERT INTO raw_data.pessoa (pessoa_id, nome) VALUES (%s, %s) ON CONFLICT DO NOTHING',
                data
            )
        elif table == 'equipe':
            cur.executemany(
                'INSERT INTO raw_data.equipe (pessoa_id, producao_id, papel) VALUES (%s, %s, %s) ON CONFLICT DO NOTHING',
                data
            )
        conn.commit()
    except Exception as e:
        print(f"[SQL ERROR] Chunk {chunk_index} (linhas {start_line}-{start_line+len(lines)-1 if start_line is not None else '?'}) {e}")
        # Não interrompe ingestão
    cur.close()
    conn.close()
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

