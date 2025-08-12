from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from database.db_instance import db

class Equipe(db.Model):
    __tablename__ = 'equipe'
    # Adiciona a configuração do schema
    __table_args__ = {'schema': 'raw_data'}

    # As ForeignKeys precisam saber o caminho completo, incluindo o schema
    producaoID = Column(Integer, ForeignKey('raw_data.producao.producaoID'), primary_key=True)
    pessoaID = Column(Integer, ForeignKey('raw_data.pessoa.pessoaID'), primary_key=True)

    papel = Column(db.Text, nullable=True)

    pessoa = relationship("Pessoa", back_populates="equipes")
    producao = relationship("Producao", back_populates="equipes")