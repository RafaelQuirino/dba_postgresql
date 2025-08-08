
# Backup, Restauração e Teste de Banco PostgreSQL com Docker

Este guia documenta o procedimento utilizado para criar um backup do banco `cinetech_productions`,
restaurá-lo em um banco de teste (`cinetech_restore_test`) e validar a integridade dos dados,
utilizando PostgreSQL rodando em um container Docker.

---

## 1. Gerar Backup Dentro do Container

Acesse o container e gere o arquivo `.dump` com o comando `pg_dump`:

```bash
docker exec -it postgresql bash -c "pg_dump -U postgres -F c -b -v -f /tmp/backup_cinetech.dump cinetech_productions"
```

Verifique se o arquivo foi criado e possui tamanho maior que zero:

```bash
docker exec -it postgresql ls -lh /tmp/backup_cinetech.dump
```

---

## 2. Criar Banco de Teste e Restaurar

Primeiro, garanta que o banco de teste não exista e crie-o novamente:

```bash
docker exec -it postgresql dropdb -U postgres --if-exists cinetech_restore_test
docker exec -it postgresql createdb -U postgres cinetech_restore_test
```

Em seguida, restaure o backup para o banco de teste:

```bash
docker exec -it postgresql pg_restore -U postgres -d cinetech_restore_test --clean --if-exists -v /tmp/backup_cinetech.dump
```

---

## 3. Validar Estrutura

Liste os schemas presentes no banco de teste:

```bash
docker exec -it postgresql psql -U postgres -d cinetech_restore_test -c "\dn"
```

Liste as tabelas de um schema específico (exemplo: `raw_data`):

```bash
docker exec -it postgresql psql -U postgres -d cinetech_restore_test -c "\dt raw_data.*"
```

---

## 4. Validar Dados

Para verificar a quantidade de registros em uma tabela específica:

```bash
docker exec -it postgresql psql -U postgres -d cinetech_restore_test -c "SELECT COUNT(*) FROM raw_data.producao;"
```

Saída esperada (exemplo):

```
 count
---------
 8450867
(1 row)
```

---

## 5. Copiar Backup Para o Host (Opcional)

Caso queira salvar o backup no computador host:

```bash
docker cp postgresql:/tmp/backup_cinetech.dump .
```

O arquivo será copiado para o diretório atual.

---

## Observações

- `cinetech_productions` é o nome do banco original.
- `cinetech_restore_test` é o banco de testes usado para validar a restauração.
- O backup foi feito no formato **custom** (`-F c`), que é compactado e compatível com `pg_restore`.
- Sempre valide tanto a estrutura (schemas e tabelas) quanto o conteúdo (quantidade de registros).
- Mantenha backups em local seguro fora do servidor.

---
