import click
import os
import time
from flask import current_app
from sqlalchemy.exc import IntegrityError

# Importa a instância do DB e o pacote de modelos inteiro de uma vez
from database.db_instance import db
import models # Graças ao __init__.py, isso importa Pessoa, Producao e Equipe

# --- Função Auxiliar para Barra de Progresso (sem alterações) ---
def print_progress(iteration, total, prefix='', suffix='', decimals=1, length=50, fill='█'):
    percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
    filled_length = int(length * iteration // total)
    bar = fill * filled_length + '-' * (length - filled_length)
    print(f'\r{prefix} |{bar}| {percent}% {suffix}', end='\r')
    if iteration == total:
        print()

# --- Função Principal de Ingestão (sem alterações na lógica) ---
def ingest_file(session, file_path, model, columns, delimiter='##', batch_size=10000):
    if session.query(model).first():
        click.secho(f"A tabela '{model.__tablename__}' já contém dados. Ingestão pulada.", fg="yellow")
        return

    click.echo(f"Iniciando ingestão: {os.path.basename(file_path)} -> '{model.__tablename__}'...")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        total_lines = sum(1 for line in f)

    start_time = time.time()
    errors = 0
    
    with open(file_path, 'r', encoding='utf-8') as f:
        for i, line in enumerate(f):
            try:
                parts = line.strip().split(delimiter)
                if len(parts) != len(columns):
                    errors += 1
                    continue

                data = {}
                for col, part in zip(columns, parts):
                    # Esta lógica de conversão já funciona para seus modelos
                    if col.endswith('ID') or col == 'ano_producao':
                        data[col] = int(part) if part.isdigit() else None
                    else:
                        data[col] = part
                
                record = model(**data)
                session.add(record)

                if (i + 1) % batch_size == 0:
                    session.commit()
                    print_progress(i + 1, total_lines, prefix='Progresso:', suffix='Completo', length=50)

            except (ValueError, IntegrityError):
                session.rollback()
                errors += 1
                continue
        
        session.commit()
        print_progress(total_lines, total_lines, prefix='Progresso:', suffix='Completo', length=50)

    duration = time.time() - start_time
    click.secho(f"Tabela '{model.__tablename__}' concluída em {duration:.2f} segundos.", fg="green")
    if errors > 0:
        click.secho(f"Aviso: {errors} linhas com erros foram puladas.", fg="yellow")

# --- Comando CLI ---
@click.command('ingest-data')
@click.option('--path', default='data/bd_producao_artistica', help='Caminho para a pasta com os arquivos de dados.')
def ingest_data_command(path):
    """Executa a ingestão de dados dos arquivos .txt para o banco de dados."""
    click.secho("--- Iniciando processo de ingestão de dados ---", fg="cyan", bold=True)
    
    # Mapeamento de arquivos para modelos e colunas
    # Agora usando models.Classe em vez de importar cada uma
    files_to_ingest = {
        'producao.txt': (models.Producao, ['producaoID', 'titulo', 'ano_producao', 'tipo_ID']),
        'pessoa.txt': (models.Pessoa, ['pessoaID', 'nome']),
        # A ordem de ingestão importa por causa das chaves estrangeiras.
        # Ingerir Equipe por último garante que todas as Pessoas e Producoes já existam.
        'equipe.txt': (models.Equipe, ['pessoaID', 'producaoID', 'papel'])
    }

    session = db.session
    try:
        # A ordem de ingestão aqui é crucial. Primeiro as tabelas independentes (Pessoa, Producao)
        # e por último a tabela que depende delas (Equipe).
        ingest_file(session, os.path.join(path, 'producao.txt'), *files_to_ingest['producao.txt'])
        ingest_file(session, os.path.join(path, 'pessoa.txt'), *files_to_ingest['pessoa.txt'])
        ingest_file(session, os.path.join(path, 'equipe.txt'), *files_to_ingest['equipe.txt'])
        
        click.secho("--- Processo de ingestão de dados finalizado com sucesso! ---", fg="green", bold=True)
    except Exception as e:
        click.secho(f"Ocorreu um erro crítico durante a ingestão: {e}", fg="red")
        session.rollback()
    finally:
        session.close()

# Função para registrar o comando na aplicação Flask
def init_app(app):
    app.cli.add_command(ingest_data_command)