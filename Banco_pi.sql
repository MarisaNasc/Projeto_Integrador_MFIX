-- Active: 1773179145047@@127.0.0.1@5432@Projeto_Mfix
-- Active: 1772540718967@@127.0.0.1@5432@3 Sem - projetoI3
-- TABELA PRODUTO ____________________________________________________________________________________________
DROP TABLE IF EXISTS produto CASCADE;
CREATE TABLE produto (
    id_produto        SERIAL PRIMARY KEY NOT NULL,
    descricao_prod    VARCHAR(200)       NOT NULL,
    categoria_prod    VARCHAR(50)        NOT NULL, -- categoria do produto
    procedencia_prod  VARCHAR(50)        NOT NULL, -- de onde veio esse trem
    unidade_base      VARCHAR(10)        NOT NULL, -- pro controle interno de estoque
    u_fator_conversao DECIMAL(10,2)                -- as diversas unidades que podem ser convertidas para venda
                                                    );
-- A unidade de medida da movimentação é apenas operacional,
-- o controle real é feito na unidade base.

-- TABELA LOTE ______________________________________________________________________________________________

DROP TABLE IF EXISTS lote CASCADE;
CREATE TABLE lote (
    id_lote            SERIAL PRIMARY KEY NOT NULL,  --controle interno do banco
    numero_lote        VARCHAR(50)        NOT NULL,  --controle operacional do usuário
    data_validade_lote DATE                          -- rastreabilidade e integridade do lote
                                                    );


-- TABELA TIPO MOVIMENTO _____________________________________________________________________________________

DROP TABLE IF EXISTS tipo_movimento CASCADE;
CREATE TABLE tipo_movimento (
    id_tipo_mov   SERIAL PRIMARY KEY NOT NULL, 
    descricao_mov VARCHAR(50)        NOT NULL --entrada, saída, em processamento
                                                );

-- TABELA TRANSPORTADORA _____________________________________________________________________________________
DROP TABLE IF EXISTS transportadora CASCADE;
CREATE TABLE transportadora (
    id_transp   SERIAL PRIMARY KEY  NOT NULL,
    nome_transp VARCHAR (100)       NOT NULL,
    CNPJ_transp VARCHAR (20) UNIQUE NOT NULL
                                                );

-- TABELA FORNECEDOR __________________________________________________________________________________________

DROP TABLE IF EXISTS fornecedor CASCADE;
CREATE TABLE fornecedor (
    id_fornecedor SERIAL    PRIMARY KEY NOT NULL,
    nome_forn     VARCHAR (150)         NOT NULL,
    CNPJ_forn     VARCHAR (20) UNIQUE   NOT NULL,
    cidade_forn   VARCHAR (50)          NOT NULL,
    estado_forn   VARCHAR (2)           NOT NULL
                                                    );


-- MOVIMENTAÇÃO ESTOQUE (TABELA FILHA) _________________________________________________________________________

DROP TABLE IF EXISTS movimentacao_estoque CASCADE;
CREATE TABLE movimentacao_estoque (
    id_movimento SERIAL PRIMARY KEY NOT NULL, 
    id_produto INT NOT NULL,-- fk
    id_lote INT NOT NULL, --fk
    id_tipo_mov INT NOT NULL, --fk
    id_fornecedor INT, --fk
    id_transp INT, --fk
    data_mov DATE NOT NULL,
    quantidade_prod DECIMAL(12,3) NOT NULL, --qtd de item/produto
    unidade_movimentada VARCHAR(10), -- em que unidade de medida esse prod saiu
    preco_compra DECIMAL(10,2),
    preco_venda DECIMAL(10,2),

    FOREIGN KEY (id_produto) REFERENCES produto(id_produto),
    FOREIGN KEY (id_lote) REFERENCES lote(id_lote),
    FOREIGN KEY (id_tipo_mov) REFERENCES tipo_movimento(id_tipo_mov),
    FOREIGN KEY (id_transp) REFERENCES transportadora(id_transp),
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedor(id_fornecedor)
);

-- ==========================================================================================================================
--                                                     POPULANDO O BD
-- ==========================================================================================================================
-- PRODUTOS
INSERT INTO produto 
(descricao_prod, categoria_prod, procedencia_prod, unidade_base,  u_fator_conversao) VALUES
('RESERV P/SABONET 800ML PREMI CREM',                               'Higiene',      'PRODUTO NACIONAL - REV.', 'CX', 24),
('TOALHEIRO 2/3D PREMISSE INVOQ PRETO',                             'Dispensers',   'PRODUTO NACIONAL - REV.', 'CX', 12),
('SABONETEIRA C/RESER 800ML TRILHA BR SUST',                        'Higiene',      'PRODUTO NACIONAL - REV.', 'CX', 12),
('SUPORTE DE PAREDE PARA EXTINTOR',                                 'Segurança',    'PRODUTO NACIONAL - REV.', 'CX', 50),
('CADEIRA C/ ESPUMA INJETADA, BRACO REGULAVEL',                     'Mobiliário',   'PRODUTO NACIONAL - REV.', 'UN', 1),
('ARRUELA SERRILHADA NAS DUAS FACES 25.4X3.4MM ',                   'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 100),
('ARRUELA PLANA TIPO A ASTM A325 10.3X20.62X1.6',                   'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 100),
('ARRUELA LISA SA45 5/16 TIPO B 22.2X8.8X1.6',                      'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 100),
('ARRUELA LISA SA46 M-06 17089 12X6.4X1.5',                         'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 100),
('PINO ELASTICO DUREZA 420 - 520 HV 10X40',                         'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 200),
('PINO ELASTICO M10 X 60',                                          'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 200),
('PF PTA BROCA #4 SEXT FL A.VULC BW ZINC 12-14X4 CH5/16',           'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 12),
('PARAFUSO GALVANIZADO SEXTAVADO 3/4 X 4 POL C/ PORCA E ARRUELAS',  'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 6),
('PARAFUSO GALVANIZADO SEXTAVADO 3/4 X 3 POL C/ PORCA E ARRUELAS',  'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 48),
('PARAF.PORC.AR G.FOGO 1 X 6 AL',                                   'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 36),
('PARAF.PORC.AR G.FOGO 1.1/8 X 5 AL',                               'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 20),
('CABO DE ACO 3/8 - 6 X 19 + AF TRD GALV.',                         'Equipamentos', 'PRODUTO NACIONAL - REV.', 'CX', 15),
('PREGO C/ CABECA 17 X 27 PCT',                                     'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 100),
('PREGO C/ CABECA 18 X 24 PCT',                                     'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 25),
('PINO ELASTICO M4 X 36',                                           'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 40),
('BUCHA PLASTICA N.6',                                              'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 40),
('BUCHA PLASTICA N.10 ',                                            'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 50),
('ANILHAS 5/8 16MM GALV.',                                          'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 60),
('SAPATILHA 3/4 19MM GALV.',                                        'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 50),
('GRAMPO DIN 741 5/16 8MM GALV.   ',                                'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 100),
('MOSQUETAO C/ TRAVA 10 X 100MM GALV.',                             'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 150),
('BROCA ACO RAPIDO DIN 338 3.00MM',                                 'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 100),
('CORRENTE 1/8 INOX A4',                                            'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 110),
('DISCO FLAP RETO 4-1/2 - GRAO 80',                                 'Equipamentos', 'PRODUTO NACIONAL - REV.', 'CX', 120),
('DISCO DE CORTE STANDARD 115 X 1.0 X 22.23MM',                     'Equipamentos', 'PRODUTO NACIONAL - REV.', 'CX', 130),
('FIXAD WOODCON M6X70MM DUH 5/16" PONTA 17 EPDM ECOSEAL 20K',       'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 100),
('ABRACADEIRA NYLON 7.6 X 500MM   ',                                'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 150),
('BARRA ROSCADA 1M. 3-8UN B7 EN',                                   'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 160),
('MANGUEIRA DE BORRACHA CONVENCIONAL P/ JARDIM 3/4',                'Equipamentos', 'PRODUTO NACIONAL - REV.', 'CX', 5),
('MASSA MADEIRA F12 MOGNO 400G',                                    'Equipamentos', 'PRODUTO NACIONAL - REV.', 'CX', 180),
('BUCHA MB 23 BRONZE',                                              'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 12),
('VEDA ROSCA LÍQUIDO 204 100G',                                     'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 14),
('MARTELO UNHA 23MM POLIDO',                                        'Ferramentas',  'PRODUTO NACIONAL - REV.', 'CX', 16),
('MICROFONE COM FIO DINÂMICO PROFISSIONAL 5MTS SM-58 COR PRETO',    'Equipamentos', 'PRODUTO NACIONAL - REV.', 'CX', 18),
('ARAME P/ SOLDA MIG 1.00',                                         'Equipamentos', 'PRODUTO NACIONAL - REV.', 'CX', 20),
('NIVELADOR CHAPA 1/4 X 1 (22MM) ZB B. PRETO',                      'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 22),
('CHUMBADOR OMEGA 3/8-16UNC X 75MM ZB',                             'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 24),
('ANEL O RING 11.00MM X 2.00MM BOR. NITRILICA',                     'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 26),
('PARAF. ALLEN DIN 912 M6 X 35 8.8 ZINCADO',                        'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 28),
('PARAF. BORBOLETA M6-1.00MA X 16 FE. ZB',                          'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 30),
('REBITE POP REPUXO ALUMINIO 312 1/8 X 12MM',                       'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 32),
('REBITE CAB. CHATA M8 X 65 8.8 PL',                                'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 20),
('OLEO SINTETICO POLIOLESTER JOMO FREOL UX-300 2L',                 'Equipamentos', 'PRODUTO NACIONAL - REV.', 'CX', 8),
('VERGALHAO SEXT. 3/4 X 3000MM LATAO',                              'Fixadores',    'PRODUTO NACIONAL - REV.', 'CX', 6),
('ROLAMENTO RIGIDO DE ESFERAS 6307-ZZ 35mm x 80mm x 21mm',          'Equipamentos', 'PRODUTO NACIONAL - REV.', 'CX', 20);

-- LOTES
-- 2026
INSERT INTO lote (numero_lote, data_validade_lote) VALUES
('L2026-001', '2029-01-10'),('L2026-002', '2029-02-15'),
('L2026-003', '2029-03-20'),('L2026-004', '2029-04-25'),
('L2026-005', '2029-05-30'),('L2026-006', '2029-06-15'),
('L2026-007', '2029-07-20'),('L2026-008', '2029-08-25'),
('L2026-009', '2030-01-10'),('L2026-010', '2030-02-15'),
('L2026-011', '2030-03-20'),('L2026-012', '2030-04-25'),
('L2026-013', '2030-05-30'),('L2026-014', '2030-06-15'),
('L2026-015', '2030-07-20'),('L2026-016', '2030-08-25'),
('L2026-017', '2031-01-10'),('L2026-018', '2031-02-15'),
('L2026-019', '2031-03-20'),('L2026-020', '2031-04-25'),
('L2026-021', '2031-05-30'),('L2026-022', '2031-06-15'),
('L2026-023', '2031-07-20'),('L2026-024', '2031-08-25'),
('L2026-025', '2029-09-10'),('L2026-026', '2030-09-15'),
('L2026-027', '2031-09-20'),('L2026-028', '2029-10-25'),
('L2026-029', '2026-11-30'),('L2026-030', '2026-12-15');
-- 2025
INSERT INTO lote (numero_lote, data_validade_lote) VALUES
('L2025-031', '2027-01-10'),('L2025-032', '2027-02-15'),
('L2025-033', '2027-03-20'),('L2025-034', '2027-04-25'),
('L2025-035', '2027-05-30'),('L2025-036', '2027-06-15'),
('L2025-037', '2027-07-20'),('L2025-038', '2027-08-25'),
('L2025-039', '2032-01-10'),('L2025-040', '2032-02-15'),
('L2025-041', '2032-03-20'),('L2025-042', '2032-04-25'),
('L2025-043', '2032-05-30'),('L2025-044', '2032-06-15'),
('L2025-045', '2032-07-20'),('L2025-046', '2032-08-25'),
('L2025-047', '2033-01-10'),('L2025-048', '2033-02-15'),
('L2025-049', '2033-03-20'),('L2025-050', '2033-04-25'),
('L2025-051', '2033-05-30'),('L2025-052', '2033-06-15'),
('L2025-053', '2033-07-20'),('L2025-054', '2033-08-25'),
('L2025-055', '2034-01-10'),('L2025-056', '2034-02-15'),
('L2025-057', '2034-03-20'),('L2025-058', '2034-04-25'),
('L2025-059', '2034-05-30'),('L2025-060', '2034-06-15'),
('L2025-061', '2034-07-20'),('L2025-062', '2034-08-25'),
('L2025-063', '2035-01-10'),('L2025-064', '2035-02-15'),
('L2025-065', '2035-03-20'),('L2025-066', '2035-04-25'),
('L2025-067', '2035-05-30'),('L2025-068', '2035-06-15'),
('L2025-069', '2035-07-20'),('L2025-070', '2035-08-25');

-- FORNECEDOR
INSERT INTO fornecedor (nome_forn, CNPJ_forn, cidade_forn, estado_forn) VALUES
('Alfa Distribuidora Ltda',     '12.345.678/0001-01', 'São Paulo',          'SP'),
('Beta Alimentos SA',           '23.456.789/0001-02', 'Campinas',           'SP'),
('Gamma Logística Ltda',        '34.567.890/0001-03', 'Rio de Janeiro',     'RJ'),
('Delta Construções Ltda',      '45.678.901/0001-04', 'Belo Horizonte',     'MG'),
('Epsilon Tecnologia Ltda',     '56.789.012/0001-05', 'Curitiba',           'PR'),
('Theta Indústria Ltda',        '89.012.345/0001-08', 'Salvador',           'BA'),
('Iota Transportes Ltda',       '90.123.456/0001-09', 'Fortaleza',          'CE'),
('Kappa Produtos Ltda',         '11.234.567/0001-10', 'Recife',             'PE'),
('Lambda Distribuição Ltda',    '22.345.678/0001-11', 'Natal',              'RN'),
('Mu Equipamentos Ltda',        '33.456.789/0001-12', 'João Pessoa',        'PB'),
('Nu Agropecuária Ltda',        '44.567.890/0001-13', 'Goiânia',            'GO'),
('Norte Sul Comércio Ltda',     '87.890.123/0001-26', 'Teresina',           'PI'),
('Central Atacadista Ltda',     '98.901.234/0001-27', 'Vitória',            'ES'),
('União Industrial Ltda',       '19.012.345/0001-28', 'Santos',             'SP'),
('Nova Era Logística Ltda',     '20.123.456/0001-29', 'Sorocaba',           'SP'),
('Prime Distribuição Ltda',     '31.234.567/0001-30', 'Ribeirão Preto',     'SP'),
('Maxxi Fornecimentos Ltda',    '42.345.678/0001-31', 'Uberlândia',         'MG'),
('Total Supply Ltda',           '53.456.789/0001-32', 'Juiz de Fora',       'MG'),
('Viva Comércio Ltda',          '64.567.890/0001-33', 'Niterói',            'RJ'),
('Flex Indústria Ltda',         '75.678.901/0001-34', 'Duque de Caxias',    'RJ'),
('Mega Distribuidora Ltda',     '86.789.012/0001-35', 'Londrina',           'PR'),
('Top Serviços Ltda',           '97.890.123/0001-36', 'Maringá',            'PR'),
('Sul Brasil Ltda',             '18.901.234/0001-37', 'Caxias do Sul',      'RS'),
('Verde Vale Ltda',             '29.012.345/0001-38', 'Pelotas',            'RS'),
('Horizonte Ltda',              '30.123.456/0001-39', 'Blumenau',           'SC'),
('Oceano Azul Ltda',            '41.234.567/0001-40', 'Joinville',          'SC'),
('Tech Brasil Ltda',            '73.456.789/0001-52', 'Barueri',            'SP'),
('Digital Supply Ltda',         '84.567.890/0001-53', 'Osasco',             'SP'),
('Inova Tech Ltda',             '95.678.901/0001-54', 'São José dos Campos','SP'),
('Vale Distribuição Ltda',      '16.789.012/0001-55', 'Taubaté',            'SP'),
('Serra Indústria Ltda',        '27.890.123/0001-56', 'Petrópolis',         'RJ'),
('Montanha Supply Ltda',        '38.901.234/0001-57', 'Teresópolis',        'RJ'),
('Interior Comércio Ltda',      '49.012.345/0001-58', 'Bauru',              'SP'),
('Capital Fornecimentos Ltda',  '50.123.456/0001-59', 'Brasília',           'DF'),
('Planalto Distribuição Ltda',  '61.234.567/0001-60', 'Brasília',           'DF'),
('Global Brasil Ltda',          '72.345.678/0001-61', 'São Paulo',          'SP');

-- TRANSPORTADORAS
INSERT INTO transportadora (nome_transp, CNPJ_transp) VALUES
('TransLog Brasil Ltda',            '12.345.678/0001-01'),
('Rápido Sul Transportes',          '29.456.789/0001-12'),
('Expresso Nacional Cargas',        '34.567.890/0003-23'),
('Logística Ágil Transportadora',   '45.678.901/0003-34'),
('Transporte Sigma Ltda',           '56.245.678/0001-21'),
('LogMais Brasil Ltda',             '02.356.789/0001-22'),
('Rota Livre Logística',            '53.467.890/0001-23'),
('Expresso Nova Era',               '58.578.901/0001-24'),
('Carga Master Transportes',        '65.689.012/0001-22'),
('Ômega Transporte Ltda',           '56.790.123/0001-26'),
('Logística Estrada Real',          '14.801.234/0001-27'),
('Rodocarga Brasil Sul',            '58.912.345/0001-28'),
('Vanguarda Express',               '59.023.456/0001-45'),
('Transporte Ideal Ltda',           '62.134.567/0002-30'),
('Carga Brasil Logística',          '23.245.678/0001-31'),
('Expresso Forte Sul',              '62.356.789/0001-95'),
('TransLog Integração',             '88.467.890/0001-33'),
('Logística Impacto Ltda',          '64.578.901/0003-34'),
('Rodocarga Ágil',                  '99.689.012/0001-35'),
('Transporte Horizonte Sul',        '66.790.123/0001-36');

-- TIPO_MOVIMENTO
INSERT INTO tipo_movimento (descricao_mov) VALUES
('Entrada'),
('Saída'),
('Ajuste');  -- Ele ocorre quando há divergência entre o estoque registrado no sistema e o estoque real, 
             -- podendo ser causado por erros operacionais, perdas ou inconsistências.”


-- MOVIMENTAÇÃO DE ESTOQUE
INSERT INTO movimentacao_estoque 
(id_produto, id_lote, id_tipo_mov, id_fornecedor, id_transp, data_mov, quantidade_prod, unidade_movimentada, preco_compra, preco_venda)
VALUES
(10,    5,  1, NULL, NULL,  '2026-03-18', 480.25,       'UN', 22.91, 36.73),
(1,     1,  1, NULL, 3,      '2025-11-23', 272.08,       'UN', 12.68, 23.84),
(14,    5,  3, NULL, 3,     '2026-02-14', 76.66,        'UN', 55.37, 110.7),
(8,     2,  3, NULL, NULL,   '2025-09-21', 47.01,        'UN', 37.13, 72.21),
(7,     2,  1, NULL, NULL,   '2026-04-21', 438.24,       'UN', 79.07, 140.57),
(12,    4,  1, 2, NULL,     '2026-06-17', 365.56,       'UN', 14.69, 27.98),
(3,     5,  1, 3, NULL,      '2026-05-18', 340.97,       'UN', 79.91, 97.53),
(13,    6,  3, NULL, 3,     '2025-08-21', 105.7,        'UN', 94.25, 163.83),
(6,     3,  1, NULL, 1,      '2026-01-25', 37.84,        'UN', 99.35, 139.23),
(7,     5,  1, 3, NULL,      '2026-04-11', 366.57,       'UN', 56.98, 110.91),
(8,     4,  2, NULL, 2,      '2025-08-11', 52.55,        'UN', 63.88, 119.83),
(4,     3,  1, 1, NULL,      '2026-06-26', 272.27,       'UN', 71.69, 97.39),
(16,    2,  1, 4, 2,        '2025-07-06', 206.07,       'UN', 23.96, 42.63),
(2,     6,  1, NULL, 2,      '2025-09-24', 100.69,       'UN', 78.34, 125.94),
(11,    2,  1, 2, 3,        '2026-06-16', 482.06,       'UN', 12.56, 24.12),
(9,     4,  2, 5, 1,         '2026-04-27', 147.27,       'UN', 15.23, 18.39),
(12,    5,  1, 5, 3,        '2026-03-10', 335.66,       'UN', 32.99, 39.67),
(12,    5,  1, 4, 2,        '2025-12-05', 166.42,       'UN', 5.87, 7.95),
(16,    4,  1, 2, NULL,     '2025-11-19', 218.96,       'UN', 72.18, 95.44),
(9,     3,  2, NULL, NULL,   '2025-09-18', 450.29,       'UN', 32.84, 56.82),
(10,    4,  1, 1, 3,        '2025-10-14', 451.6,        'UN', 98.92, 130.46),
(15,    1,  1, NULL, 3,     '2025-09-08', 290.52,       'UN', 49.18, 76.11),
(3,     2,  1, 3, 1,         '2025-07-18', 239.11,       'UN', 17.19, 31.53),
(7,     1,  1, NULL, 2,      '2025-09-12', 444.71,       'UN', 89.29, 136.36),
(16,    5,  1, NULL, NULL,  '2025-08-01', 402.44,       'UN', 66.66, 86.15),
(13,    2,  3, NULL, 2,     '2026-01-19', 189.78,       'UN', 75.57, 95.19),
(14,    2,  3, NULL, 1,     '2026-06-14', 304.46,       'UN', 40.41, 65.99),
(11,    3,  1, 4, 2,        '2026-01-04', 446.91,       'UN', 42.07, 53.5),
(1,     6,  1, 5, NULL,      '2025-07-16', 173.88,       'UN', 8.68, 11.07),
(5,     3,  2, NULL, 2,      '2025-11-21', 343.3,        'UN', 50.96, 90.92),
(3,     3,  1, 5, 2,         '2025-11-03', 470.8,        'UN', 2.18, 2.83),
(5,     3,  2, NULL, 2,      '2025-08-13', 121.19,       'UN', 28.45, 36.28),
(13,    2,  1, NULL, 2,     '2026-05-31', 123.78,       'UN', 87.2, 117.22),
(15,    4,  1, NULL, 2,     '2026-03-16', 289.27,       'UN', 94.71, 159.82),
(15,    5,  2, 2, 3,        '2025-09-07', 361.3,        'UN', 62.5, 104.11),
(15,    6,  2, 4, 1,        '2026-04-03', 114.26,       'UN', 33.4, 64.87),
(15,    2,  1, 1, 3,        '2026-06-24', 252.04,       'UN', 71.84, 135.36),
(14,    2,  1, 5, 3,        '2026-04-24', 489.92,       'UN', 30.62, 39.9),
(4,     3,  1, 1, 1,         '2025-08-30', 196.1,        'UN', 67.66, 114.42),
(4,     5,  1, NULL, 1,      '2026-05-23', 94.89,        'UN', 18.96, 30.71),
(16,    1,  3, 1, 2,        '2025-10-24', 111.97,       'UN', 16.48, 23.26),
(8,     6,  1, NULL, NULL,   '2026-02-10', 240.42,       'UN', 16.43, 27.43),
(2,     5,  1, NULL, 3,      '2026-05-21', 439.82,       'UN', 50.72, 96.16),
(16,    5,  1, 4, 2,        '2025-08-02', 24.85,        'UN', 88.96, 125.62),
(1,     3,  1, NULL, NULL,   '2026-01-19', 226.96,       'UN', 72.93, 114.16),
(10,    3,  1, NULL, 1,     '2025-12-12', 21.15,        'UN', 33.67, 53.0),
(12,    3,  2, 1, NULL,     '2026-02-02', 77.33,        'UN', 5.16, 8.83),
(15,    3,  1, NULL, 1,     '2025-11-18', 287.73,       'UN', 0.92, 1.62),
(12,    3,  2, NULL, 2,     '2026-06-13', 309.08,       'UN', 74.8, 101.06),
(9,     3,  1, 3, 2,         '2025-07-05', 463.85,       'UN', 95.74, 174.59),
(9,     3,  1, 1, 3,         '2025-07-05', 271.0,        'UN', 8.91, 15.64),
(12,    4,  1, 5, NULL,     '2026-06-07', 474.65,       'UN', 72.18, 142.77),
(8,     2,  1, NULL, NULL,   '2026-02-25', 282.02,       'UN', 82.95, 162.02),
(14,    6,  1, NULL, NULL,  '2026-05-03', 315.0,        'UN', 26.99, 39.44),
(13,    5,  1, 3, 3,        '2025-09-28', 483.99,       'UN', 8.16, 14.47),
(4,     2,  2, 2, NULL,      '2026-06-05', 155.3,        'UN', 12.76, 22.04),
(2,     5,  1, NULL, NULL,   '2025-07-25', 270.27,       'UN', 27.64, 49.54),
(10,    2,  3, NULL, 3,     '2025-10-30', 55.28,        'UN', 20.86, 35.7),
(6,     4,  1, 3, NULL,      '2026-04-06', 118.75,       'UN', 42.99, 57.89),
(15,    2,  1, 4, NULL,     '2026-01-21', 422.56,       'UN', 73.81, 118.05),
(6,     2,  1, 5, NULL,      '2026-03-03', 294.01,       'UN', 9.83, 13.09),
(11,    1,  2, 4, 2,        '2026-06-14', 55.74,        'UN', 17.32, 30.09),
(8,     6,  1, 1, NULL,      '2026-02-13', 94.59,        'UN', 52.27, 102.45),
(6,     1,  1, NULL, NULL,   '2025-10-07', 210.7,        'UN', 24.37, 34.07),
(6,     4,  1, 1, NULL,      '2026-05-21', 60.15,        'UN', 99.9, 170.45),
(8,     4,  1, 1, 1,         '2026-06-30', 211.66,       'UN', 60.57, 93.68),
(12,    2,  2, 4, 2,        '2025-09-30', 364.17,       'UN', 58.7, 96.81),
(7,     2,  2, NULL, NULL,   '2025-12-22', 265.16,       'UN', 75.56, 132.58),
(15,    4,  1, 2, 2,        '2025-08-18', 44.11,        'UN', 70.7, 121.91),
(14,    2,  3, 3, 3,        '2025-07-19', 444.99,       'UN', 56.23, 88.27),
(9,     6,  1, NULL, NULL,   '2025-11-28', 457.49,       'UN', 99.53, 161.7),
(8,     1,  2, NULL, NULL,   '2026-04-25', 143.14,       'UN', 32.82, 41.44),
(9,     2,  1, NULL, 3,      '2026-02-03', 414.67,       'UN', 49.57, 89.33),
(15,    2,  1, 5, NULL,     '2025-10-17', 385.06,       'UN', 97.86, 181.38),
(12,    6,  1, 4, NULL,     '2026-03-21', 463.89,       'UN', 4.54, 8.95),
(2,     2,  1, NULL, 1,      '2025-12-20', 357.27,       'UN', 39.14, 71.76),
(2,     6,  1, NULL, NULL,   '2025-08-28', 399.69,       'UN', 77.06, 153.11),
(5,     4,  1, NULL, NULL,   '2026-02-20', 61.06,        'UN', 22.04, 28.63),
(4,     1,  3, 2, NULL,      '2025-09-18', 137.59,       'UN', 82.21, 105.39),
(16,    3,  1, 4, NULL,     '2026-04-13', 135.82,       'UN', 71.86, 111.18),
(1,     3,  1, NULL, NULL,   '2026-06-04', 150.81,       'UN', 36.51, 70.87),
(15,    6,  2, 3, 3,        '2025-10-14', 258.53,       'UN', 71.6, 125.2),
(2,     1,  2, 4, NULL,      '2026-06-20', 433.52,       'UN', 86.62, 123.1),
(11,    6,  1, NULL, NULL,  '2026-02-06', 466.79,       'UN', 55.44, 89.34),
(5,     3,  1, NULL, NULL,   '2026-06-08', 410.13,       'UN', 50.25, 72.86),
(15,    6,  2, NULL, NULL,  '2026-06-27', 254.62,       'UN', 15.52, 27.78),
(16,    4,  1, 4, 3,        '2025-08-16', 395.66,       'UN', 39.06, 51.6),
(12,    3,  1, 1, NULL,     '2026-06-01', 84.19,        'UN', 77.94, 138.35),
(5,     2,  1, 5, NULL,      '2025-10-21', 78.97,        'UN', 33.52, 61.16),
(9,     6,  1, NULL, 3,      '2026-03-07', 201.26,       'UN', 89.04, 142.6),
(3,     1,  1, NULL, 3,      '2025-08-26', 160.91,       'UN', 87.77, 108.66),
(6,     6,  1, 5, NULL,      '2026-01-07', 109.36,       'UN', 46.89, 67.84),
(8,     1,  3, 3, NULL,      '2025-11-19', 239.82,       'UN', 11.84, 18.01),
(13,    4,  2, NULL, 2,     '2026-04-26', 98.95,        'UN', 90.1, 127.25),
(1,     6,  1, NULL, 1,      '2025-12-22', 235.69,       'UN', 59.45, 102.92),
(16,    4,  2, NULL, NULL,  '2025-08-14', 454.57,       'UN', 94.58, 115.18),
(13,    1,  1, NULL, NULL,  '2026-03-20', 18.07,        'UN', 98.14, 195.74),
(1,     5,  2, NULL, NULL,   '2025-10-30', 373.64,       'UN', 4.0, 6.23),
(11,    6,  1, NULL, NULL,  '2026-02-14', 368.48,       'UN', 32.31, 41.95),
(13,    5,  3, 5, 2,        '2026-05-25', 176.1,        'UN', 96.58, 133.08);
