import click
import os
from flask import current_app
from database.db_instance import db

@click.command('setup-permissions')
def setup_permissions_command():
    """
    Cria usuários e concede permissões a partir do script SQL.
    """
    sql_file_path = os.path.join(current_app.root_path, '..', 'sql', 'setup_permissions.sql')
    
    if not os.path.exists(sql_file_path):
        click.secho(f"Erro: Arquivo SQL '{sql_file_path}' não encontrado.", fg="red")
        return

    click.echo("Aplicando script de usuários e permissões...")
    
    try:
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql_script = f.read()
            
            with db.engine.connect() as connection:
                connection.execution_options(isolation_level="AUTOCOMMIT").execute(db.text(sql_script))

        click.secho("Usuários e permissões configurados com sucesso!", fg="green")

    except Exception as e:
        click.secho(f"Ocorreu um erro ao configurar permissões: {e}", fg="red")

# Função para registrar o comando
def init_app(app):
    app.cli.add_command(setup_permissions_command)