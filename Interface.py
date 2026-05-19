from flask import Flask, render_template, request, jsonify
from sqlalchemy import create_engine, text
import pandas as pd

app = Flask(__name__)

# =========================================================
# CONEXÃO
# =========================================================

engine = create_engine(
    "postgresql+psycopg2://postgres:23062006@localhost:5432/Mfix_BD"
)

# =========================================================
# QUERY
# =========================================================

def query_db(query, params={}):

    with engine.connect() as conn:

        result = conn.execute(
            text(query),
            params
        )

        df = pd.DataFrame(
            result.fetchall(),
            columns=result.keys()
        )

    return df.to_dict(orient="records")

# =========================================================
# HOME
# =========================================================

@app.route("/", methods=["GET", "POST"])
def home():

    produto = request.form.get(
        "produto", ""
    ).strip()

    fornecedor = request.form.get(
        "fornecedor", ""
    ).strip()

    movimentacao = request.form.get(
        "movimentacao", ""
    ).strip()

    data_inicial = request.form.get(
        "data_inicial", ""
    ).strip()

    data_final = request.form.get(
        "data_final", ""
    ).strip()

    query = """

        SELECT

            dp.descricao_prod,
            dp.categoria_prod,
            dp.procedencia_prod,

            df.nome_forn,

            tm.descricao_mov,

            dt.nome_transp,

            dl.numero_lote,
            dl.data_validade_lote,

            fm.quantidade,
            fm.valor_total,

            fm.data,

            (

                SELECT MAX(f2.quantidade)

                FROM fato_movimentacao f2

                WHERE
                    f2.id_produto = fm.id_produto
                    AND f2.id_tipo_mov = 2

            ) AS melhor_venda

        FROM fato_movimentacao fm

        JOIN dim_produto dp
        ON fm.id_produto = dp.id_produto

        JOIN dim_fornecedor df
        ON fm.id_fornecedor = df.id_fornecedor

        JOIN dim_tipo_mov tm
        ON fm.id_tipo_mov = tm.id_tipo_mov

        JOIN dim_transportadora dt
        ON fm.id_transp = dt.id_transp

        JOIN dim_lote dl
        ON fm.id_lote = dl.id_lote

        WHERE 1=1

    """

    params = {}

    # =====================================================
    # PRODUTO
    # =====================================================

    if produto != "":

        query += """

            AND LOWER(dp.descricao_prod)

            LIKE LOWER(:produto)

        """

        params["produto"] = f"%{produto}%"

    # =====================================================
    # FORNECEDOR
    # =====================================================

    if fornecedor != "":

        query += """

            AND LOWER(df.nome_forn)

            LIKE LOWER(:fornecedor)

        """

        params["fornecedor"] = f"%{fornecedor}%"

    # =====================================================
    # MOVIMENTAÇÃO
    # =====================================================

    if movimentacao != "":

        query += """

            AND CAST(fm.id_tipo_mov AS TEXT)
            = :movimentacao

        """

        params["movimentacao"] = str(movimentacao)

    # =====================================================
    # DATA INICIAL
    # =====================================================

    if data_inicial != "":

        query += """

            AND fm.data >= :data_inicial

        """

        params["data_inicial"] = data_inicial

    # =====================================================
    # DATA FINAL
    # =====================================================

    if data_final != "":

        query += """

            AND fm.data <= :data_final

        """

        params["data_final"] = data_final

    # =====================================================
    # FINAL QUERY
    # =====================================================

    query += """

        ORDER BY fm.data DESC

        LIMIT 60

    """

    dados = query_db(
        query,
        params
    )

    return render_template(
        "index.html",
        dados=dados
    )

# =========================================================
# AUTOCOMPLETE PRODUTO
# =========================================================

@app.route("/autocomplete_produto")
def autocomplete_produto():

    termo = request.args.get(
        "term", ""
    )

    produtos = query_db("""

        SELECT DISTINCT

            descricao_prod

        FROM dim_produto

        WHERE LOWER(descricao_prod)

        LIKE LOWER(:termo)

        ORDER BY descricao_prod

        LIMIT 10

    """, {

        "termo": f"%{termo}%"

    })

    return jsonify(produtos)

# =========================================================
# AUTOCOMPLETE FORNECEDOR
# =========================================================

@app.route("/autocomplete_fornecedor")
def autocomplete_fornecedor():

    termo = request.args.get(
        "term", ""
    )

    fornecedores = query_db("""

        SELECT DISTINCT

            nome_forn

        FROM dim_fornecedor

        WHERE LOWER(nome_forn)

        LIKE LOWER(:termo)

        ORDER BY nome_forn

        LIMIT 10

    """, {

        "termo": f"%{termo}%"

    })

    return jsonify(fornecedores)

# =========================================================
# DASHBOARD
# =========================================================

@app.route("/dashboard")
def dashboard():

    kpis = query_db("""

        SELECT

            COALESCE(
                SUM(valor_total),0
            ) AS valor_total,

            COALESCE(
                SUM(quantidade),0
            ) AS quantidade_total,

            COUNT(*) FILTER(
                WHERE id_tipo_mov = 1
            ) AS entradas,

            COUNT(*) FILTER(
                WHERE id_tipo_mov = 2
            ) AS saidas,

            COUNT(*) FILTER(
                WHERE id_tipo_mov = 3
            ) AS ajustes,

            ROUND(
                AVG(valor_total),2
            ) AS ticket_medio,

            COUNT(DISTINCT id_produto)
            AS produtos_ativos,

            SUM(quantidade)
            AS estoque_atual,

            COUNT(*)
            AS total_movimentacoes,

            COUNT(DISTINCT id_fornecedor)
            AS total_fornecedores

        FROM fato_movimentacao

    """)

    return render_template(
        "dashboard.html",
        kpis=kpis
    )

# =========================================================
# START
# =========================================================

if __name__ == "__main__":

    app.run(debug=True)