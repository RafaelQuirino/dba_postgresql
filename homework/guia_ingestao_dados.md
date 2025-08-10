# Guia de Ingestão de Dados

Este documento descreve o passo a passo para realizar a ingestão dos dados brutos no banco de dados do projeto.

## 1. Preparação do Ambiente

1. Certifique-se de que o banco de dados PostgreSQL está em execução e acessível.
2. Crie o banco de dados e o esquema inicial executando os scripts:
   - `01_criacao_banco.sql`
   - `02_projeto_esquema.sql`

## 2. Carregamento das Categorias

1. O script Python (`ingestao_dados.py`) irá identificar todos os tipos de produção presentes no arquivo `producao.txt` e popular a tabela `producao_tipo` automaticamente.

## 3. Ingestão dos Dados

1. Execute o script Python de ingestão:

   ```bash
   python homework/python/ingestao_dados.py
   ```

2. O script irá:
   - Ler os arquivos `producao.txt`, `pessoa.txt` e `equipe.txt` em blocos (chunks) para otimizar a performance.
   - Tratar encoding ISO-8859-1 e valores nulos ("null" ou ano igual a zero).
   - Inserir os dados nas tabelas correspondentes do esquema `raw_data`.
   - Exibir uma barra de progresso para cada tabela.
   - Registrar no console eventuais erros de parsing ou inserção, indicando o bloco e a linha do arquivo.

## 4. Ativação das Constraints

1. Após a ingestão dos dados, execute o script:
   - `03_constraints.sql`

   Isso irá adicionar as restrições de integridade referencial (chaves estrangeiras) às tabelas.

## 5. Recomendações

- Para grandes volumes de dados, recomenda-se executar a ingestão com as constraints desativadas e ativá-las apenas ao final.
- Em caso de deadlock ou lentidão, reduza o número de workers ou o tamanho dos chunks no script Python.
- Consulte os logs do console para identificar e corrigir eventuais problemas de dados.

---

**Resumo dos arquivos:**
- `01_criacao_banco.sql`: Criação do banco de dados
- `02_projeto_esquema.sql`: Criação das tabelas (sem constraints)
- `03_constraints.sql`: Adição das constraints
- `python/ingestao_dados.py`: Script de ingestão dos dados

