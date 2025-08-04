# from flask.cli import with_appcontext # Não é mais necessário aqui, vamos usar o app context de outra forma
from flask import current_app
import click
import os
from sqlalchemy import create_engine, text
from sqlalchemy.schema import CreateSchema
from sqlalchemy.exc import ProgrammingError
from urllib.parse import urlparse, urlunparse

# Local
from database.db_instance import db
import models  # importa os modelos para registrar metadata


def get_db_info():
    """Extrai informações do URI do banco de dados da configuração do Flask."""
    uri = current_app.config['SQLALCHEMY_DATABASE_URI']
    if not uri.startswith("postgresql"):
        raise ValueError("Este script foi projetado apenas para PostgreSQL.")
    
    parsed_uri = urlparse(uri)
    db_name = parsed_uri.path.lstrip('/')
    # Constrói um URI para conectar ao banco de dados 'postgres' padrão
    postgres_db_uri = urlunparse(parsed_uri._replace(path='/postgres'))
    
    return db_name, postgres_db_uri

@click.command("init-db")
@click.confirmation_option(prompt="Tem certeza que deseja RECRIAR o banco e todas as tabelas?")
def init_db():
    """
    Cria o database, o schema e todas as tabelas para a aplicação.
    
    Este comando irá:
    1. Conectar ao servidor PostgreSQL.
    2. Criar o DATABASE se ele não existir.
    3. Conectar ao database recém-criado.
    4. Criar o SCHEMA se ele não existir.
    5. Apagar TODAS as tabelas existentes no schema (se houver).
    6. Criar todas as tabelas definidas nos seus modelos.
    """
    try:
        db_name, postgres_db_uri = get_db_info()
        schema_name = current_app.config.get('DB_SCHEMA', 'public') # Use um nome de schema da sua config ou 'public'
        
        # --- Passo 1: Criar o Database ---
        engine_postgres_db = create_engine(postgres_db_uri, isolation_level='AUTOCOMMIT')
        
        with engine_postgres_db.connect() as conn:
            click.echo(f"Verificando se o banco de dados '{db_name}' existe...")
            # Usamos 'text()' para evitar SQL Injection, embora aqui o db_name venha da config.
            result = conn.execute(text(f"SELECT 1 FROM pg_database WHERE datname = '{db_name}'"))
            database_exists = result.scalar() == 1

            if not database_exists:
                click.echo(f"Banco de dados '{db_name}' não encontrado. Criando...")
                conn.execute(text(f'CREATE DATABASE "{db_name}"'))
                click.secho(f"Banco de dados '{db_name}' criado com sucesso.", fg="green")
            else:
                click.secho(f"Banco de dados '{db_name}' já existe.", fg="yellow")

        engine_postgres_db.dispose()

        # --- Agora usamos o engine da aplicação, que já aponta para o DB correto ---
        app_engine = db.get_engine()

        # --- Passo 2: Criar o Schema ---
        with app_engine.connect() as conn:
            click.echo(f"Verificando se o schema '{schema_name}' existe...")
            result = conn.execute(text(f"SELECT 1 FROM information_schema.schemata WHERE schema_name = '{schema_name}'"))
            schema_exists = result.scalar() == 1
            
            if not schema_exists:
                click.echo(f"Schema '{schema_name}' não encontrado. Criando...")
                conn.execute(CreateSchema(schema_name, if_not_exists=True))
                conn.commit() # Necessário para DDL como CREATE SCHEMA
                click.secho(f"Schema '{schema_name}' criado com sucesso.", fg="green")
            else:
                click.secho(f"Schema '{schema_name}' já existe.", fg="yellow")


        # --- Passo 3: Apagar e Criar as Tabelas ---
        click.echo("Apagando todas as tabelas antigas (se existirem)...")
        # O drop_all() e create_all() usarão o schema definido nos modelos
        db.drop_all()
        
        click.echo("Criando todas as tabelas...")
        db.create_all()

        click.secho("Tabelas criadas com sucesso!", fg="green")
        click.secho("Banco de dados inicializado!", fg="cyan", bold=True)

    except ValueError as e:
        click.secho(f"Erro de Configuração: {e}", fg="red")
    except ProgrammingError as e:
        click.secho(f"Erro de SQL: Verifique suas credenciais e permissões no PostgreSQL. Detalhes: {e}", fg="red")
    except Exception as e:
        click.secho(f"Ocorreu um erro inesperado: {e}", fg="red")

# Função para registrar o comando no Flask app
def init_app(app):
    app.cli.add_command(init_db)