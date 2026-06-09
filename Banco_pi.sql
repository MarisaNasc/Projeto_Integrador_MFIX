-- Active: 1773179145047@@127.0.0.1@5432@Mfix_BD
-- LIMPA
DROP TABLE IF EXISTS mov_estoque;
DROP TABLE IF EXISTS lotes;
DROP TABLE IF EXISTS transportadora;
DROP TABLE IF EXISTS produto;
DROP TABLE IF EXISTS fornecedor;
DROP TABLE IF EXISTS tipo_mov;

-- FORNECEDOR
CREATE TABLE fornecedor (
    id SERIAL PRIMARY KEY,
    nome_forn VARCHAR(150),
    cnpj_forn VARCHAR(20),
    cidade_forn VARCHAR(100),
    uf_forn CHAR(2)
);

-- PRODUTO
CREATE TABLE produto (
    id SERIAL PRIMARY KEY,
    descricao_prod VARCHAR(200),
    preco_compra NUMERIC(10,2),
    preco_venda NUMERIC(10,2),
    lucro NUMERIC(10,2),
    qtdep_caixa INTEGER,
    lote_prod VARCHAR(50),
    data_saida DATE,
    data_entrada DATE,
    procedencia_prod VARCHAR(40),
    categoria_prod VARCHAR(100)
);

-- TRANSPORTADORA
CREATE TABLE transportadora (
    id SERIAL PRIMARY KEY,
    nome_transp VARCHAR(150),
    cnpj_transp VARCHAR(20)
);

-- LOTES
CREATE TABLE lotes (
    id SERIAL PRIMARY KEY,
    numero_lote VARCHAR(50),
    data_validade DATE
);

-- TIPO MOVIMENTAÇÃO
CREATE TABLE tipo_mov (
    id SERIAL PRIMARY KEY,
    descricao_mov VARCHAR(20)
); 

-- MOVIMENTAÇÃO
CREATE TABLE mov_estoque (
    id SERIAL PRIMARY KEY,
    produto_id INTEGER,
    fornecedor_id INTEGER,
    transportadora_id INTEGER,
    lote_id INTEGER,
    tipo_mov_id INTEGER,
     data DATE,
    qtde_prod NUMERIC(10,2),
    preco_venda NUMERIC(10,2),
    unidade_medida VARCHAR(20),

    FOREIGN KEY (produto_id) REFERENCES produto(id),
    FOREIGN KEY (fornecedor_id) REFERENCES fornecedor(id),
    FOREIGN KEY (transportadora_id) REFERENCES transportadora(id),
    FOREIGN KEY (lote_id) REFERENCES lotes(id),
    FOREIGN KEY (tipo_mov_id) REFERENCES tipo_mov(id)
);

INSERT INTO tipo_mov (id, descricao_mov)
VALUES
(1, 'ENTRADA'),
(2, 'SAÍDA'),
(3, 'AJUSTE');


SELECT * FROM mov_estoque;

SELECT * FROM fornecedor;

SELECT * FROM produto;

SELECT * FROM transportadora;

SELECT * FROM lotes;
SELECT * FROM tipo_mov

SELECT  id_produto, descricao_prod, categoria_prod FROM dim_produto;

SELECT
    MAX(valor_total),
    MIN(valor_total),
    AVG(valor_total)
FROM fato_movimentacao;


SELECT
    fm.data,
    dp.descricao_prod,
    fm.quantidade,
    fm.valor_total
FROM fato_movimentacao fm
JOIN dim_produto dp
    ON fm.id_produto = dp.id_produto
ORDER BY fm.valor_total DESC
LIMIT 20;


SELECT
    id_tipo_mov,
    id_fornecedor,
    COUNT(*)
FROM fato_movimentacao
GROUP BY id_tipo_mov, id_fornecedor
ORDER BY id_tipo_mov;

    fm.data,
    dp.descricao_prod,
    fm.quantidade,
    fm.valor_total
FROM fato_movimentacao fm
JOIN dim_produto dp
    ON fm.id_produto = dp.id_produto
ORDER BY fm.valor_total DESC
LIMIT 20;


SELECT * FROM fato_movimentacao;

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'fato_movimentacao'
AND column_name = 'data';


TRUNCATE TABLE mov_estoque RESTART IDENTITY CASCADE;


