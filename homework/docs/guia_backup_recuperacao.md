# Passo 9: Estratégia de Backup e Recuperação

## Objetivo
Garantir a segurança e a disponibilidade dos dados do banco de dados `cinetech_productions` por meio de rotinas de backup e procedimentos claros de recuperação.

---

## 1. Estratégia de Backup

### a) Tipos de Backup
- **Backup Completo (Full):** Cópia integral do banco de dados.
- **Backup Incremental:** Apenas as alterações desde o último backup.
- **Backup de Arquivos de WAL:** Permite recuperação ponto-a-ponto (PITR).

### b) Ferramentas Utilizadas
- `pg_dump` para backups lógicos (estruturas e dados).
- `pg_basebackup` para backups físicos.
- Cópia dos arquivos de WAL para backup contínuo.

### c) Frequência Recomendada
- **Backup Completo:** Diário (preferencialmente fora do horário de pico).
- **Backup Incremental/WAL:** A cada 15 minutos.
- **Testes de restauração:** Semanalmente.

### d) Exemplo de Comandos

#### Backup Lógico Completo
```bash
pg_dump -U postgres -F c -b -v -f /backups/cinetech_productions_$(date +%F).backup cinetech_productions
```

#### Backup Físico Completo
```bash
pg_basebackup -U postgres -D /backups/base/ -F tar -z -P
```

#### Backup dos WALs
Configure o parâmetro `archive_mode = on` e `archive_command` no postgresql.conf:
```conf
archive_mode = on
archive_command = 'cp %p /backups/wal/%f'
```

---

## 2. Procedimentos de Recuperação

### a) Recuperação de Backup Lógico
```bash
pg_restore -U postgres -d cinetech_productions /backups/cinetech_productions_YYYY-MM-DD.backup
```

### b) Recuperação de Backup Físico
1. Pare o serviço do PostgreSQL.
2. Restaure os arquivos do backup físico no diretório de dados.
3. Restaure os arquivos de WAL, se necessário.
4. Inicie o serviço do PostgreSQL.

### c) Recuperação Ponto-a-Ponto (PITR)
1. Restaure o backup físico.
2. Copie os arquivos de WAL para o diretório `pg_wal`.
3. Crie um arquivo `recovery.signal` e configure `recovery_target_time` no `postgresql.conf`.
4. Inicie o PostgreSQL para aplicar os WALs até o ponto desejado.

---

## 3. Boas Práticas
- Armazene backups em local seguro e, preferencialmente, fora do servidor principal.
- Automatize e monitore os processos de backup.
- Realize testes periódicos de restauração.
- Documente cada etapa e mantenha logs dos backups e recuperações.
- Proteja os arquivos de backup com permissões adequadas.

---

## 4. Referências
- [Documentação Oficial PostgreSQL - Backup and Restore](https://www.postgresql.org/docs/current/backup.html)
- [PostgreSQL PITR](https://www.postgresql.org/docs/current/continuous-archiving.html)

---

**Em caso de desastre, siga rigorosamente os procedimentos acima para garantir a integridade e a disponibilidade dos dados.**
