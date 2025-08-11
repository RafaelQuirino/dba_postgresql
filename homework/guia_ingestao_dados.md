## Sobre o Script de Ingestão (`ingestao_dados.py`)

O script `ingestao_dados.py` foi desenvolvido para realizar a ingestão eficiente de grandes volumes de dados textuais para o banco PostgreSQL, com as seguintes características:

- Leitura dos arquivos em blocos (chunks) para otimizar o uso de memória e permitir processamento paralelo.
- Uso de múltiplos processos (multiprocessing) para acelerar a inserção dos dados.
- Tratamento de encoding ISO-8859-1, conversão de valores nulos e normalização dos dados.
- Indicador de progresso para acompanhamento visual da carga.
- Registro detalhado de erros de parsing e de inserção, sem interromper a ingestão.
- Inserção dos dados utilizando a política `ON CONFLICT DO NOTHING`.


### Política de Conflito Utilizada

Durante a ingestão, são utilizadas duas políticas de conflito para garantir integridade e flexibilidade:

- Para as tabelas `producao` e `pessoa`, é usada a política `ON CONFLICT DO NOTHING`, que ignora tentativas de inserir registros já existentes (mesma chave primária), evitando falhas e permitindo reprocessamento seguro.

- Para a tabela `equipe`, é usada a política:

   ```sql
   INSERT INTO raw_data.equipe (pessoa_id, producao_id, papel) VALUES (...)
   ON CONFLICT (pessoa_id, producao_id)
   DO UPDATE SET papel = EXCLUDED.papel WHERE EXCLUDED.papel IS NOT NULL;
   ```
  
   Isso significa que, caso já exista um registro para a mesma combinação de pessoa e produção, o campo `papel` será atualizado apenas se o novo valor não for nulo. Assim, é possível complementar ou corrigir informações de papel sem perder dados válidos já existentes.

**Vantagens:**
- Permite reprocessar arquivos ou chunks sem risco de erro por duplicidade.
- Evita que o processo de ingestão pare por causa de registros já existentes.
- Facilita a execução paralela e a recuperação de falhas.
- Garante que o campo `papel` seja atualizado apenas quando houver informação relevante.

**Atenção:**
- Essas políticas não substituem a necessidade de garantir a qualidade dos dados na origem.
- Após a ingestão, recomenda-se validar a integridade e consistência dos dados.

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
   - Inserir os dados nas tabelas correspondentes do esquema `raw_data`, utilizando a política de conflito `ON CONFLICT DO NOTHING` para evitar falhas por duplicidade.
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

