from collections import Counter, defaultdict

# Mapeamento simplificado de gêneros livres para categorias fixas (exemplo)
GENRE_TO_CATEGORY = {
    "Filmes": {"Drama", "Comedy", "Action", "Romance", "Sport", "Adventure", "Short", "Biography", "History", "Horror", "Thriller", "Mystery"},
    "Séries de TV": {"Game-Show", "Talk-Show", "News", "Reality-TV", "Adult", "Comedy", "Drama"},
    "Videogames": {"Action", "Adventure", "Sport", "Animation", "Sci-Fi", "Fantasy", "RPG"},
    "Documentários": {"Documentary", "Biography", "History", "News"},
    "Curtas-metragens": {"Short", "Comedy", "Drama", "Family", "Adventure"},
    "Clipes de Música": {"Music"},
    "Produções Teatrais": {"Theater", "Stage", "Play"},
    "Séries Web": {"Web", "Web Series", "Webseries"},
    "Animações": {"Animation", "Animated", "Cartoon", "Anime"}
}

def classify_genre(genero_str):
    if not genero_str:
        return None
    # separa por vírgula, normaliza
    generos = {g.strip().capitalize() for g in genero_str.split(",")}
    # conta correspondências em cada categoria
    counts = defaultdict(int)
    for cat, genre_set in GENRE_TO_CATEGORY.items():
        if generos & genre_set:
            counts[cat] += len(generos & genre_set)
    if not counts:
        return "Desconhecido"
    # retorna categoria com mais matches
    return max(counts.items(), key=lambda x: x[1])[0]


def classify_producao(amostra):
    # Para cada producao_tipo_id, coleto as categorias previstas
    cats_por_tipo = defaultdict(list)
    for p_tipo, titulo, ano, genero in amostra:
        cat = classify_genre(genero)
        cats_por_tipo[p_tipo].append(cat)

    # Para cada tipo, conta a categoria mais frequente
    for p_tipo, cats in cats_por_tipo.items():
        contagem = Counter(cats)
        mais_comuns = contagem.most_common(3)
        print(f"producao_tipo_id={p_tipo}: 3 categorias mais apropriadas:")
        for cat, count in mais_comuns:
            print(f"  - {cat} (ocorreu {count} vezes)")

if __name__ == "__main__":
    # Exemplo: dados de amostra (substitua pelo seu dataset)
    amostra = [
        (1, "Initiation", 2006, "Short, Comedy, Drama"),
        (1, "Wandering Fires", 1925, "Drama, Romance"),
        (2, "Hotel Hotel", 1996, "Comedy"),
        (2, "Haggis Baggis", 1958, "Game-Show"),
        (3, "Herzdamen", 2006, "Comedy"),
        (3, "Rockin New Year's Eve 2002", 2001, "Music"),
        (4, "Full Service Butler", 1993, "Adult"),
        (5, "Napoleon", 2000, "Documentary, Biography, History"),
        (6, "Tony Tough and the Night of Roasted Moths", 2002, "Adventure"),
        (7, "In the Kingdom of the Blind", 1998, ""),
    ]
    classify_producao(amostra)