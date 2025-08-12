import os
import psycopg2
import functools
from flask import Flask, jsonify, render_template, request
from flask_cors import CORS
from psycopg2 import sql # <-- ESTA É A LINHA QUE FALTAVA

app = Flask(__name__)
CORS(app)

DB_HOST = os.getenv("DB_HOST", "postgres")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "cinetech_productions")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres123")

VALID_ROLES = ['postgres', 'analyst_all', 'analyst_movies', 'analyst_tv', 'analyst_games', 'analyst_docs', 'data_scientist']

ROLE_SEARCH_TABLES = {
    'postgres': ['movies', 'tv_shows', 'documentaries', 'video_games', 'videos', 'tv_episodes'],
    'analyst_all': ['movies', 'tv_shows', 'documentaries', 'video_games', 'videos', 'tv_episodes'],
    'data_scientist': ['movies', 'tv_shows', 'documentaries', 'video_games', 'videos', 'tv_episodes'],
    'analyst_movies': ['movies'],
    'analyst_tv': ['tv_shows'],
    'analyst_games': ['video_games'],
    'analyst_docs': ['documentaries'],
}

def get_db_connection():
    return psycopg2.connect(host=DB_HOST, port=DB_PORT, dbname=DB_NAME, user=DB_USER, password=DB_PASSWORD)

def with_role(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        role = request.args.get('role', 'postgres')
        if role not in VALID_ROLES:
            return jsonify({'error': 'Perfil (role) inválido.'}), 400
        conn = None
        try:
            conn = get_db_connection()
            with conn.cursor() as cur:
                # CORREÇÃO: Usar o 'sql' importado
                cur.execute(sql.SQL("SET ROLE {}").format(sql.Identifier(role)))
                result = func(cur, *args, **kwargs)
                cur.execute("RESET ROLE;")
                conn.commit()
                return result
        except psycopg2.errors.InsufficientPrivilege:
            if conn: conn.rollback()
            return jsonify({'error': 'Acesso negado para este perfil.'}), 403
        except Exception as e:
            if conn: conn.rollback()
            print(f"Internal API Error: {e}", flush=True)
            return jsonify({'error': 'Ocorreu um erro interno na API.'}), 500
        finally:
            if conn: conn.close()
    return wrapper

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/search', methods=['GET'])
@with_role
def search(cur):
    query = request.args.get('q', '')
    role = request.args.get('role', 'postgres')
    if not query or len(query) < 3: return jsonify([])
    
    production_searches = []
    search_params = []
    
    allowed_tables = ROLE_SEARCH_TABLES.get(role, [])
    for table in allowed_tables:
        production_searches.append(f"(SELECT producao_id, titulo, ano_producao, 'movie' AS type FROM analytics.{table} WHERE titulo ILIKE %s LIMIT 5)")
        search_params.append(f"%{query}%")

    person_search = "(SELECT pessoa_id, nome, NULL, 'person' AS type FROM raw_data.pessoa WHERE nome ILIKE %s LIMIT 5)"
    search_params.append(f"%{query}%")
    
    all_searches = production_searches + [person_search]
    if not all_searches: return jsonify([])
    
    final_query = " UNION ALL ".join(all_searches)
    
    cur.execute(final_query, tuple(search_params))
    results = cur.fetchall()
    return jsonify([{'id': r[0], 'name': r[1], 'year': r[2], 'type': r[3]} for r in results])

@app.route('/api/movies/<int:movie_id>', methods=['GET'])
@with_role
def get_movie(cur, movie_id):
    query = "SELECT producao_id, titulo, ano_producao FROM raw_data.producao WHERE producao_id = %s"
    cur.execute(query, (movie_id,))
    movie_data = cur.fetchone()
    if not movie_data: return jsonify({'error': 'Produção não encontrada ou acesso negado.'}), 404
    
    cur.execute("SELECT p.pessoa_id, p.nome, e.papel FROM raw_data.equipe e JOIN raw_data.pessoa p ON e.pessoa_id = p.pessoa_id WHERE e.producao_id = %s LIMIT 20;", (movie_id,))
    cast_data = cur.fetchall()
    
    return jsonify({'id': movie_data[0], 'title': movie_data[1], 'year': movie_data[2], 'cast': [{'id': r[0], 'name': r[1], 'role': r[2]} for r in cast_data]})

@app.route('/api/analytics/summary', methods=['GET'])
@with_role
def get_summary(cur):
    cur.execute("SELECT production_type, total_productions FROM analytics.production_summary ORDER BY total_productions DESC;")
    summary_data = cur.fetchall()
    return jsonify([{'type': row[0], 'total': row[1]} for row in summary_data])

@app.route('/api/analytics/top-actors', methods=['GET'])
@with_role
def get_top_actors(cur):
    cur.execute("SELECT nome, total_roles FROM analytics.top_actors_by_type ORDER BY total_roles DESC LIMIT 10;")
    actors_data = cur.fetchall()
    return jsonify([{'name': row[0], 'productions': row[1]} for row in actors_data])

@app.route('/api/analytics/yearly-trends', methods=['GET'])
@with_role
def get_yearly_trends(cur):
    cur.execute("SELECT ano_producao, total_productions FROM analytics.yearly_production_trends;")
    trends_data = cur.fetchall()
    return jsonify([{'year': row[0], 'total': row[1]} for row in trends_data])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)