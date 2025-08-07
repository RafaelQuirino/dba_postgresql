import pandas as pd
import os

# Caminho da pasta dos arquivos
pasta = "/data"

# Dataset → colunas esperadas
arquivos = {
    "producao_filtrado": ["id_producao", "titulo", "ano", "tipo_id"],
    "pessoa": ["id_pessoa", "nome"],
    "equipe": ["id_producao", "id_pessoa", "papel"]
}

# Dataset → colunas usadas para verificar duplicação
colunas_chave = {
    "producao_filtrado": ["id_producao"],
    "pessoa": ["id_pessoa", "nome"],
    "equipe": ["id_producao", "id_pessoa"]
}

# Pasta de saída
os.makedirs("output", exist_ok=True)

def validar_df(nome, df, colunas_esperadas):
    print(f"\nValidando: {nome.upper()}")
    erros = False

    # Verifica colunas
    if list(df.columns) != colunas_esperadas:
        print(f"ERRO: Colunas incorretas. Esperado: {colunas_esperadas}, Encontrado: {list(df.columns)}")
        erros = True

    # Verifica nulos
    nulos = df.isnull().sum()
    if nulos.any():
        print("Nulos detectados:")
        print(nulos[nulos > 0])
        df[df.isnull().any(axis=1)].to_json(f"output/{nome}_nulos.json", orient="records", indent=2, force_ascii=False)

    # Regras específicas para produção
    if nome == "producao_filtrado":
        if not pd.api.types.is_integer_dtype(df["ano"]):
            print("ERRO: Coluna 'ano' não está como inteiro.")
            erros = True

        anos_invalidos = df["ano"][(df["ano"] < 1500) | (df["ano"] > 2100)]
        if not anos_invalidos.empty:
            print("Anos fora do intervalo esperado:")
            print(df[df["ano"].isin(anos_invalidos)].drop_duplicates("ano"))
            erros = True

    # Verifica duplicatas com base nas chaves definidas
    if nome in colunas_chave:
        chaves = colunas_chave[nome]
        duplicatas = df[df.duplicated(subset=chaves, keep=False)]
        if not duplicatas.empty:
            print(f"Atenção: {len(duplicatas)} linhas duplicadas detectadas com base em {chaves}.")
            duplicatas.to_json(f"output/{nome}_duplicadas.json", orient="records", indent=2, force_ascii=False)

    if not erros:
        print("Validação concluída sem erros críticos.")

# Loop pelos arquivos
for nome, colunas in arquivos.items():
    caminho = os.path.join(pasta, f"{nome}.parquet")
    try:
        df = pd.read_parquet(caminho)
        validar_df(nome, df, colunas)
    except Exception as e:
        print(f"Erro ao ler {nome}: {e}")
