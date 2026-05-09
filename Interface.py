from flask import Flask, render_template, request, jsonify
from sqlalchemy import create_engine, text
import pandas as pd

app = Flask(__name__)

engine = create_engine(
    "postgresql+psycopg2://postgres:23062006@localhost:5432/Mfix_BD"
)

def consultar(query, params={}):
    with engine.connect() as conn:
        result = conn.execute(text(query), params)
        df = pd.DataFrame(result.fetchall(), columns=result.keys())
    return df.to_dict(orient="records")


# =========================
# INTERFACE DW
# =========================

@app.route("/", methods=["GET"])
def interface_dw():

    produto = request.args.get("produto", "")
    tipo = request.args.get("tipo", "")
    fornecedor = request.args.get("fornecedor", "")

    filtros = []
    params = {}

    if produto:
        filtros.append("p.descricao_prod ILIKE :produto")
        params["produto"] = f"%{produto}%"

    if tipo:
        filtros.append("tm.descricao_mov = :tipo")
        params["tipo"] = tipo

    if fornecedor:
        filtros.append("forn.nome_forn ILIKE :fornecedor")
        params["fornecedor"] = f"%{fornecedor}%"

    where = ""

    if filtros:
        where = "WHERE " + " AND ".join(filtros)

    query = f"""
    SELECT
        p.descricao_prod,
        p.categoria_prod,
        p.procedencia_prod,

        forn.nome_forn,

        l.numero_lote,
        l.data_validade_lote,

        tm.descricao_mov,

        fm.quantidade,
        fm.valor_total,

        t.data,

        tr.nome_transp

    FROM fato_movimentacao fm

    JOIN dim_produto p
    ON fm.id_produto = p.id_produto

    JOIN dim_fornecedor forn
    ON fm.id_fornecedor = forn.id_fornecedor

    JOIN dim_lote l
    ON fm.id_lote = l.id_lote

    JOIN dim_tipo_mov tm
    ON fm.id_tipo_mov = tm.id_tipo_mov

    JOIN dim_tempo t
    ON fm.data = t.data

    JOIN dim_transportadora tr
    ON fm.id_transp = tr.id_transp

    {where}

    ORDER BY t.data DESC
    LIMIT 50
    """

    dados = consultar(query, params)

    return render_template("index.html", dados=dados)


# =========================
# DASHBOARD
# =========================

@app.route("/dashboard")
def dashboard():

    kpis = consultar("""
    SELECT
        COUNT(*) AS total_mov,
        SUM(valor_total) AS receita,
        SUM(quantidade) AS quantidade_total,
        COUNT(DISTINCT id_produto) AS produtos
    FROM fato_movimentacao
    """)

    top_produtos = consultar("""
    SELECT
        p.descricao_prod,
        SUM(fm.quantidade) AS total

    FROM fato_movimentacao fm

    JOIN dim_produto p
    ON fm.id_produto = p.id_produto

    GROUP BY p.descricao_prod

    ORDER BY total DESC
    LIMIT 5
    """)

    entrada_saida = consultar("""
    SELECT
        tm.descricao_mov,
        SUM(fm.quantidade) AS total

    FROM fato_movimentacao fm

    JOIN dim_tipo_mov tm
    ON fm.id_tipo_mov = tm.id_tipo_mov

    GROUP BY tm.descricao_mov
    """)

    return render_template(
        "dashboard.html",
        kpis=kpis,
        top_produtos=top_produtos,
        entrada_saida=entrada_saida
    )


# =========================
# MODAL DASHBOARD
# =========================

@app.route("/produto/<nome>")
def detalhes_produto(nome):

    query = """
    SELECT
        p.descricao_prod,
        p.categoria_prod,
        p.procedencia_prod,

        forn.nome_forn,

        l.numero_lote,
        l.data_validade_lote,

        tm.descricao_mov,

        fm.quantidade,
        fm.valor_total,

        t.data,

        tr.nome_transp

    FROM fato_movimentacao fm

    JOIN dim_produto p
    ON fm.id_produto = p.id_produto

    JOIN dim_fornecedor forn
    ON fm.id_fornecedor = forn.id_fornecedor

    JOIN dim_lote l
    ON fm.id_lote = l.id_lote

    JOIN dim_tipo_mov tm
    ON fm.id_tipo_mov = tm.id_tipo_mov

    JOIN dim_tempo t
    ON fm.data = t.data

    JOIN dim_transportadora tr
    ON fm.id_transp = tr.id_transp

    WHERE p.descricao_prod = :nome

    ORDER BY t.data DESC
    """

    dados = consultar(query, {"nome": nome})

    return jsonify(dados)


if __name__ == "__main__":
    app.run(debug=True)