from flask import Flask, render_template, request
import sqlite3
import pandas as pd

app = Flask(__name__)

def query_db(query):
    conn = sqlite3.connect('banco.db')
    df = pd.read_sql(query, conn)
    conn.close()
    return df.to_dict(orient='records')

@app.route("/", methods=["GET", "POST"])
def home():

    filtro = "WHERE 1=1"

    if request.method == "POST":
        data = request.form.get("data")
        mes = request.form.get("mes")
        produto = request.form.get("produto")
        tipo = request.form.get("tipo")

        if data:
            filtro += f" AND t.data = '{data}'"
        if mes:
            filtro += f" AND t.mes = {mes}"
        if produto:
            filtro += f" AND p.nome = '{produto}'"
        if tipo:
            filtro += f" AND tm.descricao = '{tipo}'"

    # KPI
    kpi = query_db(f"""
    SELECT SUM(f.quantidade) as total, SUM(f.valor_total) as valor
    FROM fato_movimentacao f
    JOIN dim_tempo t ON f.id_tempo = t.id_tempo
    JOIN dim_produto p ON f.id_produto = p.id_produto
    JOIN dim_tipo_movimentacao tm ON f.id_tipo_movimentacao = tm.id_tipo_movimentacao
    {filtro}
    """)

    # Evolução
    tempo = query_db(f"""
    SELECT t.data, SUM(f.quantidade) as total
    FROM fato_movimentacao f
    JOIN dim_tempo t ON f.id_tempo = t.id_tempo
    {filtro}
    GROUP BY t.data
    """)

    # Produtos
    produtos = query_db(f"""
    SELECT p.nome, SUM(f.quantidade) as total
    FROM fato_movimentacao f
    JOIN dim_produto p ON f.id_produto = p.id_produto
    {filtro}
    GROUP BY p.nome
    ORDER BY total DESC
    """)

    # Tipo
    tipo_dados = query_db(f"""
    SELECT tm.descricao, SUM(f.quantidade) as total
    FROM fato_movimentacao f
    JOIN dim_tipo_movimentacao tm ON f.id_tipo_movimentacao = tm.id_tipo_movimentacao
    {filtro}
    GROUP BY tm.descricao
    """)

    return render_template(
        "index.html",
        kpi=kpi,
        tempo=tempo,
        produtos=produtos,
        tipo=tipo_dados
    )

if __name__ == "__main__":
    app.run(debug=True)