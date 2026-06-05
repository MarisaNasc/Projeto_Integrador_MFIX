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
# QUERY PADRÃO
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
# INTERFACE DW
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

            COALESCE(df.nome_forn, 'Não informado')
            AS nome_forn,

            tm.descricao_mov,

            COALESCE(dt.nome_transp, 'Não informado')
            AS nome_transp,

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

        LEFT JOIN dim_produto dp
        ON fm.id_produto = dp.id_produto

        LEFT JOIN dim_fornecedor df
        ON fm.id_fornecedor = df.id_fornecedor

        LEFT JOIN dim_tipo_mov tm
        ON fm.id_tipo_mov = tm.id_tipo_mov

        LEFT JOIN dim_transportadora dt
        ON fm.id_transp = dt.id_transp

        LEFT JOIN dim_lote dl
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

    query += """

        ORDER BY fm.data DESC

        LIMIT 50

    """

    dados = query_db(query, params)

    # =====================================================
    # KPIs HOME
    # =====================================================

    kpis = query_db("""

        SELECT

            COUNT(*) AS total_mov,

            COUNT(DISTINCT id_fornecedor)
            AS fornecedores,

            COUNT(*) FILTER(
                WHERE id_tipo_mov = 2
            ) AS movimentacoes_hoje

        FROM fato_movimentacao

    """)

    return render_template(
        "index.html",
        dados=dados,
        kpis=kpis
    )

# =========================================================
# AUTOCOMPLETE
# =========================================================

@app.route("/autocomplete_produto")
def autocomplete_produto():

    termo = request.args.get("term", "")

    produtos = query_db("""

        SELECT DISTINCT descricao_prod

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
# DASHBOARD
# =========================================================

@app.route("/dashboard")
def dashboard():

    # ==========================================
    # KPIS PRINCIPAIS
    # ==========================================

    kpis = query_db("""

        SELECT

            COUNT(*) AS total_mov,

            ROUND(
                SUM(valor_total)::numeric,
                2
            ) AS receita,

            COUNT(DISTINCT id_produto)
            AS produtos

        FROM fato_movimentacao

    """)

    # ==========================================
    # FORNECEDORES
    # ==========================================

    fornecedores = query_db("""

        SELECT

            COUNT(DISTINCT id_fornecedor)
            AS fornecedores

        FROM fato_movimentacao

    """)

    # ==========================================
    # ENTRADAS
    # ==========================================

    entradas = query_db("""

        SELECT

            COUNT(*) AS entradas

        FROM fato_movimentacao

        WHERE id_tipo_mov = 1

    """)

    # ==========================================
    # SAÍDAS
    # ==========================================

    saidas = query_db("""

        SELECT

            COUNT(*) AS saidas

        FROM fato_movimentacao

        WHERE id_tipo_mov = 2

    """)

    # ==========================================
    # AJUSTES
    # ==========================================

    ajustes = query_db("""

        SELECT

            COUNT(*) AS ajustes

        FROM fato_movimentacao

        WHERE id_tipo_mov = 3

    """)

    # ==========================================
    # TICKET MÉDIO
    # ==========================================

    ticket_medio = query_db("""

        SELECT

            ROUND(
                AVG(valor_total)::numeric,
                2
            ) AS ticket

        FROM fato_movimentacao

    """)

    # ==========================================
    # TOP PRODUTOS
    # ==========================================

    top_produtos = query_db("""

        SELECT

            p.descricao_prod,

            SUM(fm.quantidade)
            AS total

        FROM fato_movimentacao fm

        JOIN dim_produto p
        ON fm.id_produto = p.id_produto

        GROUP BY p.descricao_prod

        ORDER BY total DESC

        LIMIT 5

    """)

    # ==========================================
    # FINANCEIRO
    # ==========================================

    financeiro = query_db("""

        SELECT

            TO_CHAR(
                data,
                'DD/MM'
            ) AS data,

            ROUND(
                SUM(valor_total)::numeric,
                2
            ) AS total

        FROM fato_movimentacao

        GROUP BY data

        ORDER BY MIN(data)

        LIMIT 10

    """)

    return render_template(

        "dashboard.html",

        kpis=kpis,

        fornecedores=fornecedores,

        entradas=entradas,

        saidas=saidas,

        ajustes=ajustes,

        ticket_medio=ticket_medio,

        top_produtos=top_produtos,

        financeiro=financeiro
    )

# =========================================================
# MODAL PRODUTO
# =========================================================

@app.route("/produto/<nome>")
def produto(nome):

    dados = query_db("""

        SELECT

            dp.descricao_prod,
            df.nome_forn,
            dl.numero_lote,
            dl.data_validade_lote,
            tm.descricao_mov,
            fm.quantidade,
            fm.valor_total,
            dt.nome_transp,
            fm.data

        FROM fato_movimentacao fm

        LEFT JOIN dim_produto dp
        ON fm.id_produto = dp.id_produto

        LEFT JOIN dim_fornecedor df
        ON fm.id_fornecedor = df.id_fornecedor

        LEFT JOIN dim_lote dl
        ON fm.id_lote = dl.id_lote

        LEFT JOIN dim_tipo_mov tm
        ON fm.id_tipo_mov = tm.id_tipo_mov

        LEFT JOIN dim_transportadora dt
        ON fm.id_transp = dt.id_transp

        WHERE LOWER(dp.descricao_prod)
        = LOWER(:nome)

        ORDER BY fm.data DESC

        LIMIT 10

    """, {

        "nome": nome

    })

    return jsonify(dados)

# =========================================================
# START
# =========================================================

if __name__ == "__main__":
    app.run(debug=True)
