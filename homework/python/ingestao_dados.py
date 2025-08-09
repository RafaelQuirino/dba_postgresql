# Bibliotecas
import os
from pathlib import Path
from typing import Optional
from dotenv import load_dotenv
import chardet
import psycopg2
from psycopg2.extras import execute_batch
from tqdm import tqdm

# Carrega variáveis de ambiente
load_dotenv()

# Configuração do banco de dados
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': os.getenv('DB_PORT', '5432'),
    'database': os.getenv('DB_NAME', 'postgres'),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', '')
}

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"

# Utilidades de parsing/normalização
def detectar_encoding(arquivo: Path) -> str:
    with arquivo.open("rb") as f:
        return chardet.detect(f.read(10_000)).get("encoding") or "utf-8"

def to_int(valor: str | None, default: int | None = 0) -> Optional[int]:
    try:
        return int(valor) if valor is not None else default
    except (ValueError, TypeError):
        return default

def ano_para_db(valor: str | None) -> Optional[int]:
    ano = to_int(valor, default=None)
    return None if ano == 0 else ano

# Processamento
def processar_producao(conn, arquivo: Path) -> None:
    enc     = detectar_encoding(arquivo)
    linhas  = [l.strip() for l in arquivo.read_text(encoding=enc, errors="replace").splitlines() if l.strip()]

    print(f"Processando {len(linhas)} produções...")
    with conn.cursor() as cur, tqdm(total=len(linhas), desc="producao") as bar:
        registros = []
        for linha in linhas:
            dados = linha.split("##")
            if len(dados) < 4:
                bar.update();  continue
            registros.append((
                to_int(dados[0]),
                dados[1],
                ano_para_db(dados[2]),
                to_int(dados[3])
            ))
            bar.update()

        sql = """
            INSERT INTO producao (producaoID, titulo, ano_producao, tipo_ID)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (producaoID) DO NOTHING;
        """
        execute_batch(cur, sql, registros, page_size=1_000)
    print("✔ produções concluídas.")

def processar_pessoa(conn, arquivo: Path) -> None:
    enc     = detectar_encoding(arquivo)
    linhas  = [l.strip() for l in arquivo.read_text(encoding=enc, errors="replace").splitlines() if l.strip()]

    print(f"Processando {len(linhas)} pessoas...")
    with conn.cursor() as cur, tqdm(total=len(linhas), desc="pessoa") as bar:
        registros = []
        for linha in linhas:
            dados = linha.split("##")
            if len(dados) < 2:
                bar.update();  continue
            registros.append((to_int(dados[0]), dados[1]))
            bar.update()

        sql = """
            INSERT INTO pessoa (pessoaID, nome)
            VALUES (%s, %s)
            ON CONFLICT (pessoaID) DO NOTHING;
        """
        execute_batch(cur, sql, registros, page_size=1_000)
    print("✔ pessoas concluídas.")

def processar_equipe(conn, arquivo: Path) -> None:
    enc     = detectar_encoding(arquivo)
    linhas  = [l.strip() for l in arquivo.read_text(encoding=enc, errors="replace").splitlines() if l.strip()]

    print(f"Processando {len(linhas)} equipes...")
    with conn.cursor() as cur, tqdm(total=len(linhas), desc="equipe") as bar:
        registros = []
        for linha in linhas:
            dados = linha.split("##")
            if len(dados) < 3:
                bar.update();  continue
            registros.append((to_int(dados[0]), to_int(dados[1]), dados[2]))
            bar.update()

        sql = """
            INSERT INTO equipe (pessoaID, producaoID, papel)
            VALUES (%s, %s, %s)
            ON CONFLICT (pessoaID, producaoID) DO NOTHING;
        """
        execute_batch(cur, sql, registros, page_size=1_000)
    print("✔ equipes concluídas.")

# Main
def main() -> None:
    print("=== INICIANDO INGESTÃO DE DADOS ===")
    try:
        with psycopg2.connect(**DB_CONFIG) as conn:
            conn.autocommit = False
            processar_producao(conn, DATA_DIR / "producao.txt")
            processar_pessoa(conn,   DATA_DIR / "pessoa.txt")
            processar_equipe(conn,   DATA_DIR / "equipe.txt")
            conn.commit()
            print("Transação confirmada.")
    except Exception as exc:
        print(f"Erro durante a ingestão: {exc}")
        if "conn" in locals() and conn:
            conn.rollback()
            print("Rollback efetuado.")
    finally:
        print("Processo concluído.")

if __name__ == "__main__":
    main()