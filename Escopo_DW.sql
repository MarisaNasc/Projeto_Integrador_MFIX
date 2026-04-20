⭐ TABELA FATO

📌 fato_movimentacao
---Armazena os eventos de movimentação de estoque (entrada e saída de produtos).
CREATE TABLE fato_movimentacao (
   id_movimentacao INTEGER PRIMARY KEY,
   id_produto INTEGER,
   id_tempo INTEGER,
   id_fornecedor INTEGER,
   id_tipo_movimentacao INTEGER,
   quantidade INTEGER,
   valor_total DECIMAL(10,2));

DIMENSÕES
🟦 dim_produto
-- Armazena dados descritivos dos produtos.
CREATE TABLE dim_produto (
   id_produto INTEGER PRIMARY KEY,
   nome VARCHAR(100),
   categoria VARCHAR(50),
   marca VARCHAR(50));

🟩 dim_tempo 
-- Permite análises ao longo do tempo (mês, ano, etc).
CREATE TABLE dim_tempo (
   id_tempo INTEGER PRIMARY KEY,
   data DATE,
   dia INTEGER,
   mes INTEGER,
   ano INTEGER,
   trimestre INTEGER,
   nome_mes VARCHAR(20));

🟨 dim_fornecedor
-- Armazena informações dos fornecedores.
CREATE TABLE dim_fornecedor (
   id_fornecedor INTEGER PRIMARY KEY,
   nome VARCHAR(100),
   cidade VARCHAR(50),
   estado VARCHAR(50));

🟪 dim_tipo_movimentacao 
-- Padroniza os tipos de movimentação (entrada/saída).
CREATE TABLE dim_tipo_movimentacao (
   id_tipo_movimentacao INTEGER PRIMARY KEY,
   descricao VARCHAR(20));
