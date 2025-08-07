
# Guia de Funcionalidades Bônus

Este documento descreve as funcionalidades bônus implementadas no projeto de Banco de Dados PostgreSQL para a empresa fictícia **CineTech Studios**.

---

## Implementar Testes Automatizados para o Banco de Dados

Foram criados scripts de **validação automática de dados** que verificam:
- Valores nulos em campos obrigatórios
- Registros duplicados com base em chaves lógicas
- Formatos inconsistentes
- Resultados salvos em arquivos JSON para auditoria

**Scripts utilizados:** `validador_dados.py`  
**Saída gerada:** arquivos `.json` contendo registros problemáticos no diretório `homework/python/output/`.

**Exemplo de execução:**
```bash
python3 homework/python/validador_dados.py
```

---

## Criar um Dashboard de Monitoramento

Foi criado um **dashboard interativo** (exemplo com Power BI / Metabase) conectado ao banco PostgreSQL para monitorar:
- Quantidade de registros por tabela
- Volume de dados arquivados
- Evolução de inserções ao longo do tempo
- Anomalias e erros detectados

O dashboard pode ser alimentado com consultas SQL diretas ou via exportação para `.csv`.

---

## Implementar Procedimentos de Validação de Dados

Procedimentos de validação aplicados diretamente no banco de dados:
- **Triggers** para evitar inserção de valores nulos em campos obrigatórios
- **Constraints** de unicidade para impedir duplicação
- **Relatórios automáticos** de inconsistências exportados em JSON

**Exemplo de trigger para evitar inserção nula no campo `titulo`:**
```sql
ALTER TABLE producao_filtrado
ADD CONSTRAINT titulo_nao_nulo CHECK (titulo IS NOT NULL);
```

---

## Adicionar Estratégias de Arquivamento de Dados

Foi criada a tabela `archive_data.equipe` para armazenar dados antigos ou inativos.

**Criação da tabela de arquivamento:**
```sql
CREATE SCHEMA IF NOT EXISTS archive_data;

CREATE TABLE IF NOT EXISTS archive_data.equipe AS
SELECT * FROM raw_data.equipe WHERE 1=0;
```

**Exemplo de arquivamento:**
```sql
INSERT INTO archive_data.equipe
SELECT * FROM raw_data.equipe
WHERE data_fim < CURRENT_DATE - INTERVAL '2 years';
```

---

## Criar um Plano de Recuperação de Desastres

O **DRP** (Disaster Recovery Plan) define como realizar backups e restaurações do banco.

### Backup
Script `backup.sh` para gerar backups completos:
```bash
#!/bin/bash
BACKUP_DIR="/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="backup_${TIMESTAMP}.sql"
mkdir -p $BACKUP_DIR
PGPASSWORD=postgres pg_dump -h localhost -U postgres -d dba_postgres -n public -n archive_data -F p -f "${BACKUP_DIR}/${FILENAME}"
echo "Backup concluído: ${FILENAME}"
```

### Restauração
Script `restore.sh` para restaurar um backup existente:
```bash
#!/bin/bash
BACKUP_FILE="/backups/backup_YYYYMMDD_HHMMSS.sql"
PGPASSWORD=postgres psql -h localhost -U postgres -d dba_postgres -f "$BACKUP_FILE"
echo "Restauração concluída!"
```

---

## Observações Finais
- Os arquivos `.json` com inconsistências ficam no diretório `homework/python/output/`.
- O dashboard pode ser integrado a ferramentas como **Metabase, Power BI ou Grafana**.
- Os scripts de backup e restauração podem ser agendados via `cron`.

---

