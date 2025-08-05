import os
from dotenv import load_dotenv
import psycopg2
from tqdm import tqdm
import chardet

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

def detectar_encoding(arquivo):
    """Detecta o encoding do arquivo"""
    with open(arquivo, 'rb') as f:
        resultado = chardet.detect(f.read(10000))  # Lê apenas os primeiros 10kb para análise
    return resultado['encoding'] or 'utf-8'

def processar_arquivos():
    """Função principal para processar todos os arquivos"""
    # Caminhos relativos aos arquivos
    base_dir = os.path.dirname(os.path.abspath(__file__))
    producao_path = os.path.join(base_dir, 'app', 'producao.txt')
    pessoa_path = os.path.join(base_dir, 'app', 'pessoa.txt')
    equipe_path = os.path.join(base_dir, 'app', 'equipe.txt')
    
    # Processa cada arquivo
    processar_producoes(producao_path)
    processar_pessoas(pessoa_path)
    processar_equipes(equipe_path)

def converter_int(valor, padrao=0):
    """Converte para inteiro com tratamento de erros"""
    try:
        return int(valor)
    except (ValueError, TypeError):
        return padrao

def processar_producoes(arquivo):
    """Processa o arquivo de produções"""
    encoding = detectar_encoding(arquivo)
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    with open(arquivo, 'r', encoding=encoding, errors='replace') as f:
        linhas = [linha.strip() for linha in f if linha.strip()]
    
    print(f"\nProcessando {len(linhas)} produções...")
    for linha in tqdm(linhas):
        dados = linha.split('##')
        if len(dados) >= 4:  # Verifica se tem todas as colunas necessárias
            cursor.execute(
                """INSERT INTO Producao (producaoID, titulo, ano_producao, tipo_ID) 
                   VALUES (%s, %s, %s, %s)
                   ON CONFLICT (producaoID) DO NOTHING""",
                (converter_int(dados[0]), dados[1], 
                 converter_int(dados[2]), converter_int(dados[3])))
    
    conn.commit()
    cursor.close()
    conn.close()
    print(f"✔ {len(linhas)} produções processadas!")

def processar_pessoas(arquivo):
    """Processa o arquivo de pessoas"""
    encoding = detectar_encoding(arquivo)
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    with open(arquivo, 'r', encoding=encoding, errors='replace') as f:
        linhas = [linha.strip() for linha in f if linha.strip()]
    
    print(f"\nProcessando {len(linhas)} pessoas...")
    for linha in tqdm(linhas):
        dados = linha.split('##')
        if len(dados) >= 2:  # Verifica se tem todas as colunas necessárias
            cursor.execute(
                """INSERT INTO Pessoa (pessoaID, nome) 
                    VALUES (%s, %s)
                    ON CONFLICT (pessoaID) DO NOTHING""",
                (converter_int(dados[0]), dados[1]))
    
    conn.commit()
    cursor.close()
    conn.close()
    print(f"✔ {len(linhas)} pessoas processadas!")

def processar_equipes(arquivo):
    """Processa o arquivo de equipes"""
    encoding = detectar_encoding(arquivo)
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    with open(arquivo, 'r', encoding=encoding, errors='replace') as f:
        linhas = [linha.strip() for linha in f if linha.strip()]
    
    print(f"\nProcessando {len(linhas)} equipes...")
    for linha in tqdm(linhas):
        dados = linha.split('##')
        if len(dados) >= 3:  # Verifica se tem todas as colunas necessárias
            cursor.execute(
                """INSERT INTO Equipe (pessoaID, producaoID, papel) 
                   VALUES (%s, %s, %s)
                   ON CONFLICT (pessoaID, producaoID) DO NOTHING""",
                (converter_int(dados[0]), converter_int(dados[1]), dados[2]))
    
    conn.commit()
    cursor.close()
    conn.close()
    print(f"✔ {len(linhas)} equipes processadas!")

if __name__ == "__main__":
    print("\n=== INICIANDO INGESTÃO DE DADOS ===")
    processar_arquivos()
    print("\nProcesso concluído. Verifique os logs acima.\n")