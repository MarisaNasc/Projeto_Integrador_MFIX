CREATE OR REPLACE PROCEDURE sp_movimentacao_filtro_v2(
    IN p_produto TEXT,
    IN p_fornecedor TEXT,
    IN p_movimentacao INTEGER,
    IN p_data_inicial DATE,
    IN p_data_final DATE,
    INOUT p_cursor REFCURSOR
)
LANGUAGE plpgsql
AS
$$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := '
        SELECT
            dp.descricao_prod,
            dp.categoria_prod,
            dp.procedencia_prod,
            COALESCE(df.nome_forn, ''Não informado'') AS nome_forn,
            tm.descricao_mov,
            COALESCE(dt.nome_transp, ''Não informado'') AS nome_transp,
            dl.numero_lote,
            dl.data_validade_lote,
            fm.quantidade,
            fm.valor_total,
            TO_CHAR(fm.data, ''DD/MM/YYYY'') AS data,
            (
                SELECT MAX(f2.quantidade)
                FROM fato_movimentacao f2
                WHERE f2.id_produto = fm.id_produto
                  AND f2.id_tipo_mov = 2
            ) AS melhor_venda
        FROM fato_movimentacao fm
        LEFT JOIN dim_produto dp ON fm.id_produto = dp.id_produto
        LEFT JOIN dim_fornecedor df ON fm.id_fornecedor = df.id_fornecedor
        LEFT JOIN dim_tipo_mov tm ON fm.id_tipo_mov = tm.id_tipo_mov
        LEFT JOIN dim_transportadora dt ON fm.id_transp = dt.id_transp
        LEFT JOIN dim_lote dl ON fm.id_lote = dl.id_lote
        WHERE 1=1
    ';

    IF p_produto IS NOT NULL AND TRIM(p_produto) <> '' THEN
        v_sql := v_sql || format(
            ' AND dp.descricao_prod ILIKE %L',
            '%' || TRIM(p_produto) || '%'
        );
    END IF;

    IF p_fornecedor IS NOT NULL AND TRIM(p_fornecedor) <> '' THEN
        v_sql := v_sql || format(
            ' AND df.nome_forn ILIKE %L',
            '%' || TRIM(p_fornecedor) || '%'
        );
    END IF;

    IF p_movimentacao IS NOT NULL THEN
        v_sql := v_sql || format(
            ' AND fm.id_tipo_mov = %s',
            p_movimentacao
        );
    END IF;

    IF p_data_inicial IS NOT NULL THEN
        v_sql := v_sql || format(
            ' AND fm.data >= %L',
            p_data_inicial
        );
    END IF;

    IF p_data_final IS NOT NULL THEN
        v_sql := v_sql || format(
            ' AND fm.data <= %L',
            p_data_final
        );
    END IF;

    v_sql := v_sql || '
        ORDER BY fm.data DESC
        LIMIT 200
    ';

    RAISE NOTICE 'SQL FINAL: %', v_sql;

    OPEN p_cursor FOR EXECUTE v_sql;
END;
$$;
$$;
BEGIN;

CALL sp_movimentacao_filtro(
    '',
    '',
    'cursor_mov'
);

FETCH ALL FROM cursor_mov;
COMMIT;

-- ======================================================
-- PROCEDURE ESTATÍSTICA DE MOVIMENTAÇÃO PBDI
-- ======================================================
CREATE OR REPLACE PROCEDURE sp_estatistica_produtos(
    p_cursor REFCURSOR
)
LANGUAGE plpgsql
AS
$$
BEGIN
    OPEN p_cursor FOR
    SELECT
        dp.descricao_prod,
        SUM(fm.quantidade) AS total_vendido,
        ROUND(SUM(fm.valor_total),2) AS faturamento
    FROM fato_movimentacao fm
    JOIN dim_produto dp
        ON dp.id_produto = fm.id_produto
    WHERE fm.id_tipo_mov = 2
    GROUP BY dp.descricao_prod
    ORDER BY total_vendido DESC;
END;
$$;

CREATE TABLE log_movimentacao (
    id_log SERIAL PRIMARY KEY,
    data_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operacao VARCHAR(20),
    produto_id INTEGER,
    quantidade NUMERIC(10,2)
);

CREATE OR REPLACE FUNCTION fn_log_movimentacao()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
BEGIN

    INSERT INTO log_movimentacao(
        operacao,
        produto_id,
        quantidade
    )
    VALUES(
        TG_OP,
        NEW.id_produto,
        NEW.quantidade
    );

    RETURN NEW;

END;
$$;

CREATE TRIGGER trg_log_movimentacao
AFTER INSERT
ON fato_movimentacao
FOR EACH ROW
EXECUTE FUNCTION fn_log_movimentacao();
