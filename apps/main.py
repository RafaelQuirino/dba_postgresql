import os
from flask import Flask

# Assumindo que suas pastas 'database', 'extensions' e 'models' 
# estão na raiz do projeto (um nível acima da pasta 'apps').
# O Python conseguirá encontrá-las por causa de como o Docker é configurado.
from database.db_instance import db
from extensions import commands

def create_app():
    """
    Cria e configura uma instância da aplicação Flask (Padrão App Factory).
    """
    app = Flask(__name__)

    # --- CONFIGURAÇÃO DA APLICAÇÃO ---
    # Pega a URL do banco da variável de ambiente definida no docker-compose.yml
    db_url = os.getenv('DATABASE_URL')
    if not db_url:
        raise RuntimeError("A variável de ambiente DATABASE_URL não foi definida.")
    
    app.config['SQLALCHEMY_DATABASE_URI'] = db_url
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['DB_SCHEMA'] = 'raw_data'  # Defina o schema padrão se necessário

    # --- INICIALIZAÇÃO DAS EXTENSÕES ---
    # Conecta as extensões com a instância da aplicação.
    db.init_app(app)
    commands.init_app(app)

    # --- REGISTRO DE MODELOS E ROTAS (BLUEPRINTS) ---
    with app.app_context():
        # Importar os modelos aqui garante que o SQLAlchemy os reconheça.
        import models

        # Aqui é onde você registraria suas rotas/blueprints no futuro
        # from .routes import seu_blueprint
        # app.register_blueprint(seu_blueprint)

    return app

# Esta linha permite que o Gunicorn ou o 'flask run' encontrem a aplicação
app = create_app()