from flask import Flask, render_template, request, jsonify
from sqlalchemy import create_engine, text
import pandas as pd
from prophet import Prophet

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

    # =====================================================
    # CONSULTA VIA PROCEDURE
    # produto + fornecedor + movimentação
    # =====================================================

    dados = executar_cursor_movimentacao(
    produto,
    fornecedor,
    movimentacao,
    data_inicial,
    data_final
)

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
                AND data = CURRENT_DATE
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
                SUM(valor_total)
                FILTER(
                    WHERE id_tipo_mov = 2
                )::numeric,
                2
            ) AS receita,

            COUNT(DISTINCT id_produto)
            AS produtos

    FROM fato_movimentacao

    WHERE data >= CURRENT_DATE - INTERVAL '2 years'

""")
    # ==========================================
    # FORNECEDORES
    # ==========================================

    fornecedores = query_db("""

       SELECT
            COUNT(DISTINCT id_fornecedor)
            AS fornecedores

        FROM fato_movimentacao

        WHERE data >= CURRENT_DATE - INTERVAL '2 years'

    """)

    # ==========================================
    # ENTRADAS
    # ==========================================

    entradas = query_db("""

      SELECT
        COUNT(*) AS entradas
    FROM fato_movimentacao
    WHERE id_tipo_mov = 1
    AND data >= CURRENT_DATE - INTERVAL '2 years'

    """)

    # ==========================================
    # SAÍDAS
    # ==========================================

    saidas = query_db("""

       SELECT
        COUNT(*) AS saidas
    FROM fato_movimentacao
    WHERE id_tipo_mov = 2
    AND data >= CURRENT_DATE - INTERVAL '2 years'
                      
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

    WHERE id_tipo_mov = 2
    AND data >= CURRENT_DATE - INTERVAL '2 years'

    """)
    # ==========================================
    # CATEGORIAS
    # ==========================================

    categorias = query_db("""

    SELECT

        dp.categoria_prod,
        ROUND(
            SUM(fm.valor_total)::numeric,
            2
        ) AS total

    FROM fato_movimentacao fm

    JOIN dim_produto dp
        ON fm.id_produto = dp.id_produto

    WHERE fm.data >= CURRENT_DATE - INTERVAL '2 years'
    AND fm.id_tipo_mov = 2

    GROUP BY dp.categoria_prod

    ORDER BY total DESC

    """)
    # ==========================================
    # AJUSTES
    # ==========================================

    ajustes = query_db("""

        SELECT
        COUNT(*) AS ajustes
    FROM fato_movimentacao
    WHERE id_tipo_mov = 3
    AND data >= CURRENT_DATE - INTERVAL '2 years'

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

        WHERE fm.id_tipo_mov = 2
          AND fm.data >= CURRENT_DATE - INTERVAL '2 years'

        GROUP BY p.descricao_prod

        ORDER BY total DESC

        LIMIT 5

    """)

    # ==========================================
    # FINANCEIRO
    # ==========================================

    financeiro = query_db("""

       SELECT
            TO_CHAR(data, 'MM/YYYY') AS data,

            ROUND(
                SUM(valor_total)::numeric,
                2
            ) AS total

        FROM fato_movimentacao

        WHERE id_tipo_mov = 2
          AND data >= CURRENT_DATE - INTERVAL '2 years'

        GROUP BY TO_CHAR(data, 'MM/YYYY'),
                DATE_TRUNC('month', data)

        ORDER BY DATE_TRUNC('month', data);
                          
    """)

    # ==========================================
    # CRESCIMENTO
    # ==========================================
    crescimento = query_db("""

         SELECT
    ROUND(
        (
            SUM(
                CASE
                    WHEN EXTRACT(MONTH FROM data) = 12
                    THEN valor_total
                    ELSE 0
                END
            )
            -
            SUM(
                CASE
                    WHEN EXTRACT(MONTH FROM data) = 1
                    THEN valor_total
                    ELSE 0
                END
            )
        ) * 100.0
        /
        NULLIF(
            SUM(
                CASE
                    WHEN EXTRACT(MONTH FROM data) = 1
                    THEN valor_total
                    ELSE 0
                END
            ),
            0
        ),
        2
    ) AS crescimento

FROM fato_movimentacao

WHERE id_tipo_mov = 2
AND data >= CURRENT_DATE - INTERVAL '2 years'

            """)
#------------------------------------------------------#
    return render_template(

        "dashboard.html",

        kpis=kpis,

        fornecedores=fornecedores,

        entradas=entradas,

        saidas=saidas,

        ajustes=ajustes,

        ticket_medio=ticket_medio,

        top_produtos=top_produtos,

        financeiro=financeiro,
        
        categorias=categorias,
        
        crescimento=crescimento


    )
    # ==========================================
    # IA
    # ==========================================

@app.route("/ia")
def ia():
        
        df_ia = pd.read_sql("""

            SELECT
                data,
                valor_total

            FROM fato_movimentacao

            WHERE id_tipo_mov = 2

        """, engine)

        df_ia["data"] = pd.to_datetime(
            df_ia["data"]
        )

        dados_diarios = (

            df_ia.groupby("data")["valor_total"]
            .sum()
            .reset_index()

        )

        # COM OUTLIERS

        media_preco = round(
                dados_diarios["valor_total"].mean(),
                2
            )

        mediana_preco = round(
                dados_diarios["valor_total"].median(),
                2
            )

        desvio_padrao = round(
                dados_diarios["valor_total"].std(),
                2
            )

        Q1 = dados_diarios["valor_total"].quantile(0.25)

        Q3 = dados_diarios["valor_total"].quantile(0.75)

        IQR = Q3 - Q1

        limite_inferior = Q1 - (1.5 * IQR)

        limite_superior = Q3 + (1.5 * IQR)


        prophet_df = dados_diarios.rename(
            columns={
                "data": "ds",
                "valor_total": "y"
            }
        )


        modelo = Prophet(
            daily_seasonality=True,
            weekly_seasonality=True,
            yearly_seasonality=False
        )

        modelo.fit(prophet_df)


        future = modelo.make_future_dataframe(
            periods=56
        )

        forecast = modelo.predict(future)

        previsao_8_semanas = forecast.tail(56)

        media_futura = round(
            previsao_8_semanas["yhat"].mean(),
            2
        )

        maximo_previsto = round(
            previsao_8_semanas["yhat"].max(),
            2
        )

        minimo_previsto = round(
            previsao_8_semanas["yhat"].min(),
            2
        )


        if media_futura > media_preco:
            tendencia = "CRESCIMENTO"
        elif media_futura < media_preco:
            tendencia = "QUEDA"
        else:
            tendencia = "ESTÁVEL"

        insight = f"""
                A previsão para as próximas 8 semanas
                indica faturamento médio estimado de
                R$ {str(f"{media_futura:,.2f}").replace(',', 'X').replace('.', ',').replace('X', '.')}.

                O maior valor previsto é
                R$ {str(f"{maximo_previsto:,.2f}").replace(',', 'X').replace('.', ',').replace('X', '.')}.

                O menor valor previsto é
                R$ {str(f"{minimo_previsto:,.2f}").replace(',', 'X').replace('.', ',').replace('X', '.')}.

                Tendência: {tendencia}.
                """


        outliers = dados_diarios[

            (
                dados_diarios["valor_total"]
                < limite_inferior
            )

            |

            (
                dados_diarios["valor_total"]
                > limite_superior
            )

        ]

        dados_sem_outliers = dados_diarios[

            (
                dados_diarios["valor_total"]
                >= limite_inferior
            )

            &

            (
                dados_diarios["valor_total"]
                <= limite_superior
            )

        ]

                # SEM OUTLIERS

        media_limpa = round(
            dados_sem_outliers["valor_total"].mean(),
            2
        )

        mediana_limpa = round(
            dados_sem_outliers["valor_total"].median(),
            2
        )

        desvio_limpo = round(
            dados_sem_outliers["valor_total"].std(),
            2
        )

        return render_template(

            "ia.html",

            media=media_preco,

            mediana=mediana_preco,

            desvio=desvio_padrao,

            media_limpa=media_limpa,
            mediana_limpa=mediana_limpa,
            desvio_limpo=desvio_limpo,

            qtd_outliers=len(outliers),

            dados_ia=dados_diarios.to_dict(
                orient="records"
            ),

            dados_limpos=dados_sem_outliers.to_dict(
                orient="records"
            ),
             previsao=previsao_8_semanas.to_dict(
                orient="records"
            ),
                    
            media_futura=media_futura,
            maximo_previsto=maximo_previsto,
            minimo_previsto=minimo_previsto,
            tendencia=tendencia,
            insight=insight

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
            TO_CHAR(
                fm.data,
                'DD/MM/YYYY'
            ) AS data
                     
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
# PROCEDURE CURSOR PARA FAZER FILTROS
# =========================================================

def executar_cursor_movimentacao(
    produto,
    fornecedor,
    movimentacao,
    data_inicial,
    data_final
):

    mov_id = None

    if movimentacao != "":
        mov_id = int(movimentacao)

    data_ini = None

    if data_inicial != "":
        data_ini = data_inicial

    data_fim = None

    if data_final != "":
        data_fim = data_final

    with engine.connect() as conn:

        trans = conn.begin()

        try:

            conn.execute(text("""

                CALL sp_movimentacao_filtro_v2(
                    CAST(:produto AS TEXT),
                    CAST(:fornecedor AS TEXT),
                    CAST(:movimentacao AS INTEGER),
                    CAST(:data_inicial AS DATE),
                    CAST(:data_final AS DATE),
                    CAST('cursor_mov' AS REFCURSOR)
                )

            """), {
                "produto": produto,
                "fornecedor": fornecedor,
                "movimentacao": mov_id,
                "data_inicial": data_ini,
                "data_final": data_fim
            })

            result = conn.execute(
                text("FETCH ALL FROM cursor_mov")
            )

            df = pd.DataFrame(
                result.fetchall(),
                columns=result.keys()
            )

            trans.commit()

        except Exception as erro:

            trans.rollback()
            raise erro

    return df.to_dict(
        orient="records"
    )
# =========================================================
# START
# =========================================================

if __name__ == "__main__":
    app.run(debug=True)