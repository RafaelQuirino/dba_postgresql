Claro, aqui está a documentação completa em formato Markdown.

---

## Documentação de Ingestão de Dados

Este documento descreve o processo de ingestão de dados para o projeto, detalhando os scripts envolvidos, as verificações de qualidade aplicadas e os procedimentos de tratamento de erros. O processo é orquestrado via `docker-compose.yml` e executado por comandos Flask.

### Scripts e Orquestração

O pipeline de dados é executado em uma sequência definida de serviços no `docker-compose.yml`. A ingestão em si é responsabilidade de dois serviços principais que executam comandos Flask.

**1. Inicialização do Banco de Dados (`db-migrator`)**
* **Comando:** `flask init-db`
* **Script:** `commands.py`
* **Objetivo:** Preparar o ambiente do banco de dados **antes** da ingestão.
* **Ações:**
    * Conecta-se ao servidor PostgreSQL.
    * Cria o banco de dados `cinetech_productions` se ele não existir.
    * Cria o schema definido na configuração (ex: `public`).
    * **Importante:** Executa `db.drop_all()`, que **apaga todas as tabelas existentes** no schema.
    * Executa `db.create_all()`, que recria as tabelas a partir dos `models` do SQLAlchemy.
    * Este passo garante que a ingestão sempre ocorra em um ambiente limpo e com a estrutura correta.

**2. Ingestão de Dados (`data-ingestor`)**
* **Comando:** `flask ingest-data`
* **Script:** `ingestion.py`
* **Objetivo:** Ler os arquivos de texto (`.txt`) e popular as tabelas recém-criadas.
* **Ordem de Execução:** A ingestão segue uma ordem específica para respeitar as chaves estrangeiras (foreign keys):
    1.  `producao.txt` -> Tabela `producao`
    2.  `pessoa.txt` -> Tabela `pessoa`
    3.  `equipe.txt` -> Tabela `equipe` (depende de `producao` e `pessoa`)
* **Principais Características:**
    * **Idempotência:** Antes de iniciar a ingestão de um arquivo, o script verifica se a tabela de destino já contém dados (`session.query(model).first()`). Se a tabela não estiver vazia, a ingestão para aquele arquivo é **pulada**. Isso previne a duplicação de dados em reexecuções.
    * **Processamento em Lotes (Batching):** Para otimizar o desempenho e o uso de memória, os dados são inseridos no banco de dados em lotes de `10000` registros (`batch_size=10000`).
    * **Feedback Visual:** Uma barra de progresso é exibida no terminal para cada arquivo, informando o status da ingestão em tempo real.

---

### Verificações de Qualidade dos Dados

Diversas verificações de qualidade são aplicadas em tempo real, linha por linha, durante a leitura dos arquivos de origem dentro da função `ingest_file`.

1.  **Validade Estrutural da Linha:**
    * **Verificação:** O script checa se o número de colunas na linha, após ser dividida pelo delimitador `##`, corresponde ao número de colunas esperado para o modelo (`len(parts) != len(columns)`).
    * **Ação:** Linhas com estrutura incorreta são descartadas e contabilizadas como um erro.

2.  **Prevenção de Chaves Primárias Duplicadas (no Arquivo):**
    * **Verificação:** Um conjunto (`set`) chamado `processed_ids` armazena os IDs de chave primária que já foram lidos do arquivo atual. Antes de processar uma nova linha, o script verifica se o ID já está nesse conjunto (`if pk_value in processed_ids`).
    * **Ação:** Se o ID já foi visto, a linha é considerada uma duplicata, descartada e contabilizada no contador `duplicates`.

3.  **Formato da Chave Primária:**
    * **Verificação:** O script garante que o valor da chave primária (primeira coluna) é um número inteiro (`if not pk_value_str.isdigit()`).
    * **Ação:** Se o valor não for numérico, a linha é descartada e contabilizada como um erro.

4.  **Limpeza e Conversão de Tipos:**
    * **Verificação:** Para colunas que devem ser numéricas (como as que terminam em `ID` ou `ano_producao`), o script tenta converter o valor para inteiro.
    * **Ação:** Se a conversão for bem-sucedida, o valor é armazenado como `int`. Se o valor não for um dígito válido (ex: `''` ou `NULL`), ele é convertido para `None` (`NULL` no banco de dados), garantindo a integridade do tipo de dado.

---

### Procedimentos de Tratamento de Erros

O sistema é projetado para ser resiliente e fornecer feedback claro sobre os problemas encontrados.

**Erros em Nível de Linha (Não-Críticos)**
* **Gatilho:** Ocorrem dentro do loop de leitura do arquivo, encapsulado por um bloco `try...except (ValueError, IntegrityError)`.
* **Causas Comuns:**
    * `ValueError`: Falha ao tentar converter um dado para o tipo esperado (ex: converter "abc" para um inteiro).
    * `IntegrityError`: Erro reportado pelo banco de dados, geralmente por violação de uma restrição (ex: chave estrangeira inexistente).
* **Ação Automática:**
    1.  A transação atual é revertida com `session.rollback()`.
    2.  O contador `errors` é incrementado.
    3.  O script **continua a execução** a partir da próxima linha, garantindo que um erro pontual não interrompa a ingestão de todo o arquivo.

**Relatórios e Alertas no Final**
* Após a conclusão da ingestão de cada arquivo, o script imprime um resumo:
    * Uma mensagem de **sucesso** em *verde* com o tempo total de execução.
    * Se `errors > 0`, uma mensagem de **aviso** em *amarelo* é exibida, informando quantas linhas foram puladas.
    * Se `duplicates > 0`, uma mensagem de **informação** em *azul* é exibida, notificando sobre as duplicatas que foram ignoradas.

**Erros Críticos (Fatais)**
* **Gatilho:** Ocorrem fora do loop de processamento de linhas, capturados pelo `try...except Exception as e` na função principal `ingest_data_command`.
* **Causas Comuns:**
    * Arquivo de dados (`.txt`) não encontrado.
    * Falha na conexão com o banco de dados.
    * Outros erros inesperados que impedem a continuação do processo.
* **Ação Automática:**
    1.  O processo de ingestão é **imediatamente interrompido**.
    2.  Uma mensagem de **erro crítico** em *vermelho* é exibida no console com os detalhes da exceção.
    3.  Qualquer transação pendente é revertida com `session.rollback()`.
    4.  O contêiner `data-ingestor` termina com falha, impedindo a execução dos próximos serviços do pipeline.