import click
import os
from flask import current_app
from database.db_instance import db

@click.command('build-trusted-layer')
def build_trusted_layer_command():
    """
    Cria a camada Silver (trusted_data) executando um script SQL para criar as views.
    """
    sql_file_path = os.path.join(current_app.root_path, '..', 'sql', 'build_trusted_layer.sql')
    
    if not os.path.exists(sql_file_path):
        click.secho(f"Erro: Arquivo SQL '{sql_file_path}' não encontrado.", fg="red")
        return

    click.echo("Construindo a camada Silver (trusted_data) a partir de build_trusted_layer.sql...")
    
    try:
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql_script = f.read()
            
            with db.engine.connect() as connection:
                # Executa o script inteiro. Para scripts DDL, é melhor não ter uma transação em volta.
                # A conexão em modo "autocommit" lida com isso.
                connection.execution_options(isolation_level="AUTOCOMMIT").execute(db.text(sql_script))

        click.secho("Camada Silver (trusted_data) construída com sucesso!", fg="green")

    except Exception as e:
        click.secho(f"Ocorreu um erro ao construir a camada Silver: {e}", fg="red")

# Função para registrar o comando
def init_app(app):
    app.cli.add_command(build_trusted_layer_command)