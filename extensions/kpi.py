import click
import os
from flask import current_app
from database.db_instance import db

@click.command('create-kpi-views')
def create_kpi_views_command():
    """Cria as views finais de KPI a partir de um script SQL."""
    sql_file_path = os.path.join(current_app.root_path, '..', 'sql', 'create_kpi_view.sql')
    
    if not os.path.exists(sql_file_path):
        click.secho(f"Erro: Arquivo SQL '{sql_file_path}' não encontrado.", fg="red")
        return

    click.echo("Criando views de KPI a partir de create_kpi_view.sql...")
    
    try:
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql_script = f.read()
            with db.engine.connect() as connection:
                connection.execution_options(isolation_level="AUTOCOMMIT").execute(db.text(sql_script))
        click.secho("Views de KPI criadas com sucesso!", fg="green")
    except Exception as e:
        click.secho(f"Ocorreu um erro ao criar as views de KPI: {e}", fg="red")

def init_app(app):
    app.cli.add_command(create_kpi_views_command)