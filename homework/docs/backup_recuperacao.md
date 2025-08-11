# 💾 Guia de Backup e Restauração do Banco da Cinethec Studios com Docker

[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/compose/)

Este guia reúne procedimentos e boas práticas para **gerar backups consistentes** do banco PostgreSQL da Cinethec Studios em ambientes Docker e **restaurá-los com segurança** — seja para recuperação de desastre, migrações ou testes. Você encontrará comandos prontos com `docker exec` usando `pg_dump/pg_restore`, orientações de **armazenamento e versionamento** dos arquivos (`.dump`), criação de um banco de **restauração/homologação** para validação, checagens de **integridade e consistência** (contagem de registros, constraints e amostragem), além de dicas de **retenção, automação** e solução de problemas comuns.

## Passo 1: Gerar o Backup no Container

- Acessar o container e gerar o arquivo `.dump`:
```bash
docker exec -it postgresql bash -c "pg_dump -U postgres -F c -b -v -f /tmp/backup_cinetech.dump cinetech_productions"
```
- Verificar se o arquivo foi gerado e possui tamanho maior que zero:
```bash
docker exec -it postgresql ls -lh /tmp/backup_cinetech.dump
```

## Passo 2: Criar o Banco de Teste e Realizar a Restauração

_ Antes de prosseguir, remova o banco de teste (se existir) e recrie-o:
```bash
docker exec -it postgresql dropdb -U postgres --if-exists cinetech_restore_test
docker exec -it postgresql createdb -U postgres cinetech_restore_test
```

- Agora, restaure o backup para o banco de teste:
```bash
docker exec -it postgresql pg_restore -U postgres -d cinetech_restore_test --clean --if-exists -v /tmp/backup_cinetech.dump
```

## Passo 3: Validação da Estrutura

- Listar os esquemas no banco teste:
```bash
docker exec -it postgresql psql -U postgres -d cinetech_restore_test -c "\dn"
```

- Listar as tabelas de um esquema:
```bash
docker exec -it postgresql psql -U postgres -d cinetech_restore_test -c "\dt raw_data.*"
```

## Passo 4: Validação dos Dados

- Verificar a quantidade de registros em uma tabela:
```bash
docker exec -it postgresql psql -U postgres -d cinetech_restore_test -c "SELECT COUNT(*) FROM raw_data.producao;"
```

- Saída esperada:
```bash
 count
---------
 8450867
(1 row)
```
## Passo 5: Copiar o Backup para o Host (Opcional)

- Armazenar o backup no host (máquina local):
```bash
docker cp postgresql:/tmp/backup_cinetech.dump .
```

- Dessa forma, o arquivo será copiado para o diretório atual

## Observações:

- `cinetech_productions`: banco de dados original (produção).

- `cinetech_restore_test`: banco de teste para validar a restauração.

- O backup foi gerado no formato *custom* (-F c), compactado e compatível com `pg_restore`.

- Valide sempre a **estrutura** (schemas e tabelas) e o **conteúdo** (quantidade de registros).

- Mantenha os backups em local seguro, de preferência fora do servidor.


