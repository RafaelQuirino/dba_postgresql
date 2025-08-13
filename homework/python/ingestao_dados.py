# Bibliotecas
import os
import time
from pathlib import Path
from typing import Optional, List, Tulpe, Dict
from dotenv import load_dotenv
import chardet
import psycopg2
from psycopg2.extras import execute_values
from tqdm import tqdm

# Carrega variáveis de ambiente
load_dotenv(override=False)

# Configuração do banco de dados
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'postgresql'),
    'port': os.getenv('DB_PORT', '5432'),
    'database': os.getenv('DB_NAME', ''),
    'user': os.getenv('DB_USER', ''),
    'password': os.getenv('DB_PASSWORD', '')
}

# Configuração de runtime parametrizada por variáveis de ambiente
DATA_DIR = Path(os.getenv('DATA_DIR', '/data'))
SEP = os.getenv('SEP', '##')
PAGE_SIZE = int(os.getenv('PAGE_SIZE', '1000'))
LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO').upper()

logging.basicConfig(level=getattr(logging, LOG_LEVEL, logging.INFO),
                    format='%(asctime)s %(levelname)s %(message)s')
logger = logging.getLogger(__name__)

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

def _ler_linhas(arquivo: Path) -> List[str]:
    enc = detectar_encoding(arquivo)
    texto = arquivo.read_text(encoding=enc, errors='replace')
    return [l.strip() for l in texto.splitlines() if l.strip()]

# Conexão com retry (útil quando Postgres ainda está subindo)
def conectar_com_retry(max_tentativas: int = 20, intervalo: float = 2.0) -> psycopg2.extensions.connection:
    ultima = None
    for tentativa in range(1, max_tentativas + 1):
        try:
            logger.info("Conectando ao banco (tentativa %d/%d)...", tentativa, max_tentativas)
            conn = psycopg2.connect(**DB_CONFIG)
            logger.info("Conexão estabelecida.")
            return conn
        except Exception as exc:  # noqa: BLE001
            ultima = exc
            time.sleep(intervalo)
    raise RuntimeError(f"Falha ao conectar após {max_tentativas} tentativas: {ultima}")

# Processamento
def processar_producao(conn, arquivo: Path) -> Dict[str, int]:
    linhas = _ler_linhas(arquivo)
    logger.info("Processando %d linhas de producao...", len(linhas))

    registros: List[Tuple[Optional[int], str, Optional[int], Optional[int]]] = []
    ignoradas = 0

    for linha in tqdm(linhas, desc='producao'):
        dados = linha.split(SEP)
        if len(dados) < 4:
            ignoradas += 1
            continue
        registros.append((
            to_int(dados[0], default=None), 
            dados[1],                        
            ano_para_db(dados[2]),           
            to_int(dados[3], default=None)   
        ))
    
    with conn.cursor() as cur:
        sql = """
            "INSERT INTO producao (producaoID, titulo, ano_producao, tipo_ID) "
            "VALUES %s ON CONFLICT (producaoID) DO NOTHING"
        """
        if registros:
            execute_values(cur, sql, registros, template='(%s,%s,%s,%s)', page_size=PAGE_SIZE)
    return {"lidas": len(linhas), "inseridas": len(registros), "ignoradas": ignoradas}

def processar_pessoa(conn, arquivo: Path) -> Dict[str, int]:
    linhas = _ler_linhas(arquivo)
    logger.info("Processando %d linhas de pessoa...", len(linhas))

    registros: List[Tuple[Optional[int], str]] = []
    ignoradas = 0

    for linha in tqdm(linhas, desc='pessoa'):
        dados = linha.split(SEP)
        if len(dados) < 2:
            ignoradas += 1
            continue
        registros.append((to_int(dados[0], default=None), dados[1]))

    with conn.cursor() as cur:
        sql = (
            "INSERT INTO pessoa (pessoaID, nome) "
            "VALUES %s ON CONFLICT (pessoaID) DO NOTHING"
        )
        if registros:
            execute_values(cur, sql, registros, template='(%s,%s)', page_size=PAGE_SIZE)

    return {"lidas": len(linhas), "inseridas": len(registros), "ignoradas": ignoradas}

def processar_equipe(conn, arquivo: Path) -> Dict[str, int]:
    linhas = _ler_linhas(arquivo)
    logger.info("Processando %d linhas de equipe...", len(linhas))

    registros: List[Tuple[Optional[int], Optional[int], str]] = []
    ignoradas = 0

    for linha in tqdm(linhas, desc='equipe'):
        dados = linha.split(SEP)
        if len(dados) < 3:
            ignoradas += 1
            continue
        registros.append((to_int(dados[0], default=None), to_int(dados[1], default=None), dados[2]))

    with conn.cursor() as cur:
        sql = (
            "INSERT INTO equipe (pessoaID, producaoID, papel) "
            "VALUES %s ON CONFLICT (pessoaID, producaoID) DO NOTHING"
        )
        if registros:
            execute_values(cur, sql, registros, template='(%s,%s,%s)', page_size=PAGE_SIZE)

    return {"lidas": len(linhas), "inseridas": len(registros), "ignoradas": ignoradas}

# Main
def main() -> None:
    print("=== INICIANDO INGESTÃO DE DADOS ===")
    print(f"DATA_DIR: {DATA_DIR}")

    # Verificações mínimas de env para evitar surpresas
    faltantes = [k for k in ("DB_NAME", "DB_USER", "DB_PASSWORD") if not os.getenv(k)]
    if faltantes:
        raise SystemExit(f"Variáveis ausentes no ambiente/.env: {', '.join(faltantes)}")

    try:
        with conectar_com_retry() as conn:
            conn.autocommit = False

            stats: Dict[str, Dict[str, int]] = {}
            stats['producao'] = processar_producao(conn, DATA_DIR / 'producao.txt')
            stats['pessoa']   = processar_pessoa(conn,   DATA_DIR / 'pessoa.txt')
            stats['equipe']   = processar_equipe(conn,   DATA_DIR / 'equipe.txt')

            conn.commit()
            print("Transação confirmada.\n")

            print("Resumo da ingestão:")
            for nome, s in stats.items():
                print(f" - {nome:9s} | lidas={s['lidas']:6d} | inseridas={s['inseridas']:6d} | ignoradas={s['ignoradas']:6d}")

    except Exception as exc:  # noqa: BLE001
        print(f"Erro durante a ingestão: {exc}")
        try:
            if 'conn' in locals() and conn:
                conn.rollback()
                print("Rollback efetuado.")
        except Exception:
            pass
    finally:
        print("Processo concluído.")

if __name__ == "__main__":
    main()