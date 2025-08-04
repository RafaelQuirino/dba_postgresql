from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from database.db_instance import db

class Pessoa(db.Model):
    __tablename__ = 'pessoa'
    # Adiciona a configuração do schema
    __table_args__ = {'schema': 'raw_data'}

    pessoaID = Column(Integer, primary_key=True)
    nome = Column(String(255), nullable=False)

    equipes = relationship("Equipe", back_populates="pessoa")