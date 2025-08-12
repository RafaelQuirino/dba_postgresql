import click
import os
import time
from flask import current_app
from sqlalchemy.exc import IntegrityError

from database.db_instance import db
import models

def print_progress(iteration, total, prefix='', suffix='', decimals=1, length=50, fill='█'):
    
    percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
    filled_length = int(length * iteration // total)
    bar = fill * filled_length + '-' * (length - filled_length)
    print(f'\r{prefix} |{bar}| {percent}% {suffix}', end='\r')
    if iteration == total:
        print()

def ingest_file(session, file_path, model, columns, delimiter='##', batch_size=10000):
    if session.query(model).first():
        click.secho(f"A tabela '{model.__tablename__}' já contém dados. Ingestão pulada.", fg="yellow")
        return

    click.echo(f"Iniciando ingestão: {os.path.basename(file_path)} -> '{model.__tablename__}'...")
    
    with open(file_path, 'r', encoding='latin-1') as f:
        total_lines = sum(1 for line in f)

    start_time = time.time()
    errors = 0
    duplicates = 0
    # --- NOVO: Conjunto para guardar IDs já processados ---
    processed_ids = set()

    with open(file_path, 'r', encoding='latin-1') as f:
        for i, line in enumerate(f):
            try:
                parts = line.strip().split(delimiter)
                if len(parts) != len(columns):
                    errors += 1
                    continue

                # --- LÓGICA ANTI-DUPLICATAS ---
                # Pega o ID da primeira coluna
                pk_value_str = parts[0]
                if not pk_value_str.isdigit():
                    errors += 1
                    continue
                pk_value = int(pk_value_str)

                # Se o ID já foi visto, pula esta linha
                if pk_value in processed_ids:
                    duplicates += 1
                    continue
                else:
                    processed_ids.add(pk_value)
                # --- FIM DA LÓGICA ANTI-DUPLICATAS ---

                data = {}
                for col, part in zip(columns, parts):
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
    if duplicates > 0:
        click.secho(f"Info: {duplicates} chaves primárias duplicadas foram encontradas e ignoradas.", fg="blue")


@click.command('ingest-data')
@click.option('--path', default='data/bd_producao_artistica', help='Caminho para a pasta com os arquivos de dados.')
def ingest_data_command(path):
    """Executa a ingestão de dados dos arquivos .txt para o banco de dados."""
    click.secho("--- Iniciando processo de ingestão de dados ---", fg="cyan", bold=True)
    
    files_to_ingest = {
        'producao.txt': (models.Producao, ['producaoID', 'titulo', 'ano_producao', 'tipo_ID']),
        'pessoa.txt': (models.Pessoa, ['pessoaID', 'nome']),
        'equipe.txt': (models.Equipe, ['pessoaID', 'producaoID', 'papel'])
    }

    session = db.session
    try:
        ingest_file(session, os.path.join(path, 'producao.txt'), *files_to_ingest['producao.txt'])
        ingest_file(session, os.path.join(path, 'pessoa.txt'), *files_to_ingest['pessoa.txt'])
        ingest_file(session, os.path.join(path, 'equipe.txt'), *files_to_ingest['equipe.txt'])
        
        click.secho("--- Processo de ingestão de dados finalizado com sucesso! ---", fg="green", bold=True)
    except Exception as e:
        click.secho(f"Ocorreu um erro crítico durante a ingestão: {e}", fg="red")
        session.rollback()
    finally:
        session.close()


def init_app(app):
    app.cli.add_command(ingest_data_command)