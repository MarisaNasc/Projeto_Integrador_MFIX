-- Active: 1773179145047@@127.0.0.1@5432@Mfix_BD
DROP TABLE IF EXISTS dim_produto;
CREATE TABLE dim_produto (
    id_produto INT PRIMARY KEY,
    descricao_prod VARCHAR(200),
    categoria_prod VARCHAR(50),
    procedencia_prod VARCHAR(50)
);
DROP TABLE IF EXISTS dim_tempo;
CREATE TABLE dim_tempo (
    data DATE PRIMARY KEY,
    dia INT,
    mes INT,
    ano INT,
    nome_mes VARCHAR(20)
);

DROP TABLE IF EXISTS dim_tipo_mov;
CREATE TABLE dim_tipo_mov (
    id_tipo_mov INT PRIMARY KEY,
    descricao_mov VARCHAR(50)
);
DROP TABLE IF EXISTS dim_fornecedor;
CREATE TABLE dim_fornecedor (
    id_fornecedor INT PRIMARY KEY,
    nome_forn VARCHAR(150),
    cidade_forn VARCHAR(50),
    estado_forn VARCHAR(2)
);
DROP TABLE IF EXISTS dim_transportadora;
CREATE TABLE dim_transportadora (
    id_transp INT PRIMARY KEY,
    nome_transp VARCHAR(100)
);
DROP TABLE IF EXISTS dim_lote;
CREATE TABLE dim_lote (
    id_lote INT PRIMARY KEY,
    numero_lote VARCHAR(50),
    data_validade_lote DATE
);
DROP TABLE IF EXISTS fato_movimentacao;
CREATE TABLE fato_movimentacao (
    id_produto INT,
    data DATE,
    id_tipo_mov INT,
    id_fornecedor INT,
    id_transp INT,
    id_lote INT,

    quantidade DECIMAL(12,3),
    valor_total DECIMAL(12,2),

    FOREIGN KEY (id_produto) REFERENCES dim_produto(id_produto),
    FOREIGN KEY (data) REFERENCES dim_tempo(data),
    FOREIGN KEY (id_tipo_mov) REFERENCES dim_tipo_mov(id_tipo_mov),
    FOREIGN KEY (id_fornecedor) REFERENCES dim_fornecedor(id_fornecedor),
    FOREIGN KEY (id_transp) REFERENCES dim_transportadora(id_transp),
    FOREIGN KEY (id_lote) REFERENCES dim_lote(id_lote)
);

-- ETL DATAWAREHOUSE
INSERT INTO dim_produto SELECT id, descricao_prod, categoria_prod, procedencia_prod FROM produto; 

INSERT INTO dim_tempo SELECT DISTINCT data,
    EXTRACT(DAY FROM data),
    EXTRACT(MONTH FROM data),
    EXTRACT(YEAR FROM data),
    TO_CHAR(data, 'Month')
FROM mov_estoque;

INSERT INTO dim_tipo_mov SELECT id, descricao_mov FROM tipo_mov;

INSERT INTO dim_fornecedor SELECT id, nome_forn, cidade_forn, uf_forn FROM fornecedor;

INSERT INTO dim_transportadora SELECT id, nome_transp FROM transportadora;

INSERT INTO dim_lote SELECT id, numero_lote, data_validade FROM lotes;

INSERT INTO fato_movimentacao
SELECT
    m.produto_id,
    m.data,
    m.tipo_mov_id,
    m.fornecedor_id,
    m.transportadora_id,
    m.lote_id,
    m.qtde_prod,
    (m.qtde_prod * COALESCE(m.preco_venda, 0))
FROM mov_estoque m;


SELECT * FROM fato_movimentacao