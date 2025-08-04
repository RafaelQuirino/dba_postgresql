from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from database.db_instance import db

class Producao(db.Model):
    __tablename__ = 'producao'
    # Adiciona a configuração do schema
    __table_args__ = {'schema': 'raw_data'}

    producaoID = Column(Integer, primary_key=True)
    titulo = Column(String(255), nullable=False)
    ano_producao = Column(Integer)
    tipo_ID = Column(Integer)

    equipes = relationship("Equipe", back_populates="producao")