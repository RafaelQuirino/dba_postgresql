# Guia de Acesso de Usuários

## Matriz de Permissões

| Usuário           | movies | tv_shows | video_games | documentaries | ... | pessoa | equipe | views analytics | Escrita |
|-------------------|--------|----------|-------------|---------------|-----|--------|--------|----------------|---------|
| analyst_movies    | R      | -        | -           | -             | ... | R      | R      | R              | -       |
| analyst_tv        | -      | R        | -           | -             | ... | R      | R      | R              | -       |
| analyst_games     | -      | -        | R           | -             | ... | R      | R      | R              | -       |
| analyst_docs      | -      | -        | -           | R             | ... | R      | R      | R              | -       |
| analyst_all       | R      | R        | R           | R             | ... | R      | R      | R              | -       |
| data_scientist    | RW     | RW       | RW          | RW            | ... | RW     | RW     | RW             | RW      |

R = Read, W = Write, - = Sem acesso

## Scripts de Criação de Usuários
Consulte o arquivo `sql/05_gerenciamento_usuarios.sql`.

## Procedimentos de Teste de Acesso
- Testar SELECT, INSERT, UPDATE, DELETE conforme permissões.
- Validar acesso negado para operações não permitidas.
- Exemplos de teste no final do arquivo de gerenciamento de usuários.
