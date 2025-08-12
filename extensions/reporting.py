import click
import os
from flask import current_app
from database.db_instance import db

@click.command('create-reporting-views')
def create_reporting_views_command():
    """
    Cria as views finais de analytics/reporting a partir de um script SQL.
    """
    sql_file_path = os.path.join(current_app.root_path, '..', 'sql', 'create_reporting_view.sql')
    
    if not os.path.exists(sql_file_path):
        click.secho(f"Erro: Arquivo SQL '{sql_file_path}' não encontrado.", fg="red")
        return

    click.echo("Criando views de reporting a partir de create_reporting_view.sql...")
    
    try:
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql_script = f.read()
            
            with db.engine.connect() as connection:
                connection.execution_options(isolation_level="AUTOCOMMIT").execute(db.text(sql_script))

        click.secho("Views de reporting criadas com sucesso!", fg="green")

    except Exception as e:
        click.secho(f"Ocorreu um erro ao criar as views de reporting: {e}", fg="red")

# Função para registrar o comando
def init_app(app):
    app.cli.add_command(create_reporting_views_command)