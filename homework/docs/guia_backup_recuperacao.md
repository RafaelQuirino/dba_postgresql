
# Backup e Recuperação no PostgreSQL

## Objetivo

Garantir a segurança e a persistência dos dados do banco `cinetech`, permitindo a criação de cópias de segurança (backups) e a restauração do banco em caso de falhas.

---

## Comandos para Backup com `pg_dump`

### Backup completo do banco de dados `cinetech`

```bash
pg_dump -U postgres -F c -b -v -f backup_cinetech.dump cinetech
```

- `-U postgres`: Usuário do banco.
- `-F c`: Formato custom (compactado).
- `-b`: Inclui blobs.
- `-v`: Modo verboso.
- `-f`: Nome do arquivo de saída.
- `cinetech`: Nome do banco de dados.

---

### Backup apenas do schema `analytics`

```bash
pg_dump -U postgres -n analytics -F c -f backup_analytics.dump cinetech
```

- `-n analytics`: Especifica o schema a ser exportado.

---

## Comando para Restauração com `pg_restore`

### Restaurar o dump completo

```bash
pg_restore -U postgres -d cinetech -v backup_cinetech.dump
```

- `-d cinetech`: Banco de dados onde será feita a restauração.

---

## Testando a Restauração (boa prática)

1. Criar um banco de testes:
```bash
createdb cinetech_restore_test
```

2. Restaurar no banco de testes:
```bash
pg_restore -U postgres -d cinetech_restore_test -v backup_cinetech.dump
```

---

## Considerações

- O comando `pg_dump` não bloqueia a leitura, e pode ser executado em produção.
- É recomendado agendar backups regulares via `cron` no Linux ou Agendador de Tarefas no Windows.
- Mantenha os arquivos de dump fora do servidor do banco, em storage seguro.

