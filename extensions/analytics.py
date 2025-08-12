import click
import os
from flask import current_app
from database.db_instance import db

@click.command('build-analytics-layer')
def build_analytics_layer_command():
    """
    Cria a camada Gold (analytics) executando um script SQL para criar tabelas materializadas.
    """
    sql_file_path = os.path.join(current_app.root_path, '..', 'sql', 'build_analytics_layer.sql')
    
    if not os.path.exists(sql_file_path):
        click.secho(f"Erro: Arquivo SQL '{sql_file_path}' não encontrado.", fg="red")
        return

    click.echo("Construindo a camada Gold (analytics) a partir de build_analytics_layer.sql...")
    
    try:
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql_script = f.read()
            
            with db.engine.connect() as connection:
                connection.execution_options(isolation_level="AUTOCOMMIT").execute(db.text(sql_script))

        click.secho("Camada Gold (analytics) construída com sucesso!", fg="green")

    except Exception as e:
        click.secho(f"Ocorreu um erro ao construir a camada Gold: {e}", fg="red")

# Função para registrar o comando
def init_app(app):
    app.cli.add_command(build_analytics_layer_command)