CREATE TABLE tbl_categoria (
    cp_cod_categoria SERIAL PRIMARY KEY,
    nm_categoria VARCHAR(20) NOT NULL
);

CREATE TABLE tbl_rfid (
    cp_id_dispositivo SERIAL PRIMARY KEY,
    ind_venda_dispositivo BOOLEAN NOT NULL
);

CREATE TABLE tbl_estabelecimento (
    cp_cod_estab SERIAL PRIMARY KEY,
    nm_estab VARCHAR(60) NOT NULL,
    cnpj_estab VARCHAR(60) NOT NULL,
    localizacao_estab FLOAT[] NOT NULL,
    endereco_estab VARCHAR(200) NOT NULL,
    UF_estab CHAR(2) NOT NULL,
    cidade_estab CHAR(5) NOT NULL,
    telefone_estab VARCHAR(15)
);

CREATE TABLE tbl_funcionario (
    cp_cod_func SERIAL PRIMARY KEY,
    nm_func VARCHAR(200) NOT NULL,
    cpf_func CHAR(11) NOT NULL,
    funcao_func VARCHAR(40) NOT NULL,
    dt_contratacao DATE,
    email_func VARCHAR(100)
);

CREATE TABLE tbl_fornecedor (
    cp_cod_forn SERIAL PRIMARY KEY,
    cnpj_forn CHAR(14) NOT NULL,
    localizacao_forn FLOAT[] NOT NULL,
    endereco_forn VARCHAR(200) NOT NULL,
    UF_forn CHAR(2) NOT NULL,
    cidade_forn CHAR(5) NOT NULL,
    telefone_forn VARCHAR(15),
    email_forn VARCHAR(100)
);

-- Depois as tabelas com dependências
CREATE TABLE tbl_produto (
    cp_id_produto SERIAL PRIMARY KEY,
    nm_prod VARCHAR(60) NOT NULL,
    cd_ean_prod CHAR(12) NOT NULL,
    ce_rfid BIGINT NOT NULL,
    ce_categoria_principal BIGINT NOT NULL,
    ce_categoria_secundaria BIGINT,
    dt_inclusao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ce_rfid) REFERENCES tbl_rfid(cp_id_dispositivo),
    FOREIGN KEY (ce_categoria_principal) REFERENCES tbl_categoria(cp_cod_categoria),
    FOREIGN KEY (ce_categoria_secundaria) REFERENCES tbl_categoria(cp_cod_categoria)
);

-- Por fim as tabelas de relacionamento
CREATE TABLE fornecer (
    idtbl_produto BIGINT,
    idtbl_fornecedor BIGINT,
    preco_venda DECIMAL(10,2),
    dt_venda TIMESTAMP,
    dt_compra TIMESTAMP,
    preco_compra DECIMAL(10,2),
    PRIMARY KEY (idtbl_produto, idtbl_fornecedor),
    FOREIGN KEY (idtbl_produto) REFERENCES tbl_produto(cp_id_produto),
    FOREIGN KEY (idtbl_fornecedor) REFERENCES tbl_fornecedor(cp_cod_forn)
);

CREATE TABLE vender_distribuir (
    idtbl_produto BIGINT,
    idtbl_estabelecimento BIGINT,
    quantidade INT NOT NULL,
    estoque_minimo INT NOT NULL,
    estoque_maximo INT NOT NULL,
    PRIMARY KEY (idtbl_produto, idtbl_estabelecimento),
    FOREIGN KEY (idtbl_produto) REFERENCES tbl_produto(cp_id_produto),
    FOREIGN KEY (idtbl_estabelecimento) REFERENCES tbl_estabelecimento(cp_cod_estab)
);

CREATE TABLE repor (
    idtbl_funcionario BIGINT,
    idtbl_produto BIGINT,
    dt_reposicao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (idtbl_funcionario, idtbl_produto, dt_reposicao),
    FOREIGN KEY (idtbl_funcionario) REFERENCES tbl_funcionario(cp_cod_func),
    FOREIGN KEY (idtbl_produto) REFERENCES tbl_produto(cp_id_produto)
);

-- Funções auxiliares
CREATE OR REPLACE FUNCTION random_cnpj() RETURNS char(14) AS $$
BEGIN
    RETURN LPAD(FLOOR(RANDOM() * 99999999999999)::TEXT, 14, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION random_cpf() RETURNS char(11) AS $$
BEGIN
    RETURN LPAD(FLOOR(RANDOM() * 99999999999)::TEXT, 11, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION random_ean() RETURNS char(12) AS $$
BEGIN
    RETURN LPAD(FLOOR(RANDOM() * 999999999999)::TEXT, 12, '0');
END;
$$ LANGUAGE plpgsql;

-- Popular categorias (200 categorias)
INSERT INTO tbl_categoria (cp_cod_categoria, nm_categoria)
SELECT 
    s.id,
    CASE
        WHEN s.id <= 50 THEN 'Bebidas ' || s.id
        WHEN s.id <= 100 THEN 'Congelados ' || s.id
        WHEN s.id <= 150 THEN 'Mercearia ' || s.id
        ELSE 'Utilidades ' || s.id
    END
FROM generate_series(1, 200) AS s(id);

-- Popular RFIDs (200 RFIDs)
INSERT INTO tbl_rfid (cp_id_dispositivo, ind_venda_dispositivo)
SELECT 
    s.id,
    (random() > 0.5)
FROM generate_series(1, 200) AS s(id);

-- Popular estabelecimentos (200 estabelecimentos)
INSERT INTO tbl_estabelecimento (cp_cod_estab, nm_estab, cnpj_estab, localizacao_estab, endereco_estab, UF_estab, cidade_estab)
SELECT
    s.id,
    CASE
        WHEN s.id <= 150 THEN 'Loja ' || s.id
        ELSE 'Depósito ' || (s.id - 150)
    END,
    random_cnpj(),
    ARRAY[random(), random(), random(), random(), random(), random(), random(), random()],
    'Rua ' || chr(floor(65 + random() * 26)::int) || ', ' || floor(random() * 1000)::int,
    (ARRAY['SP','RJ','MG','BA','RS','SC','PR','PE','CE','AM'])[floor(random() * 10 + 1)],
    LPAD(floor(random() * 99999)::TEXT, 5, '0')
FROM generate_series(1, 200) AS s(id);

-- Popular funcionários (200 funcionários)
INSERT INTO tbl_funcionario (cp_cod_func, nm_func, cpf_func, funcao_func)
SELECT
    s.id,
    'Funcionário ' || s.id,
    random_cpf(),
    (ARRAY['Repositor','Supervisor','Gerente','Auxiliar','Coordenador','Analista','Operador'])[floor(random() * 7 + 1)]
FROM generate_series(1, 200) AS s(id);

-- Popular fornecedores (200 fornecedores)
INSERT INTO tbl_fornecedor (cp_cod_forn, cnpj_forn, localizacao_forn, endereco_forn, UF_forn, cidade_forn)
SELECT
    s.id,
    random_cnpj(),
    ARRAY[random(), random(), random(), random(), random(), random(), random(), random()],
    'Rua ' || chr(floor(65 + random() * 26)::int) || ', ' || floor(random() * 1000)::int,
    (ARRAY['SP','RJ','MG','BA','RS','SC','PR','PE','CE','AM'])[floor(random() * 10 + 1)],
    LPAD(floor(random() * 99999)::TEXT, 5, '0')
FROM generate_series(1, 200) AS s(id);

-- Popular produtos (200 produtos)
INSERT INTO tbl_produto (cp_id_produto, nm_prod, cd_ean_prod, ce_rfid, ce_categoria_principal, ce_categoria_secundaria)
SELECT
    s.id,
    'Produto ' || s.id,
    random_ean(),
    s.id,
    floor(random() * 200 + 1),
    CASE WHEN random() > 0.5 THEN floor(random() * 200 + 1) ELSE NULL END
FROM generate_series(1, 200) AS s(id);

-- Popular fornecer (200 registros)
INSERT INTO fornecer (idtbl_produto, idtbl_fornecedor, preco_venda, dt_venda, dt_compra, preco_compra)
SELECT
    floor(random() * 200 + 1),
    floor(random() * 200 + 1),
    (random() * 1000)::numeric(10,2),
    NOW() - (random() * 365 || ' days')::interval,
    NOW() - (random() * 365 || ' days')::interval,
    (random() * 800)::numeric(10,2)
FROM generate_series(1, 200);

-- Popular vender_distribuir (200 registros)
INSERT INTO vender_distribuir (idtbl_produto, idtbl_estabelecimento, quantidade, estoque_minimo, estoque_maximo)
SELECT
    floor(random() * 200 + 1),
    floor(random() * 200 + 1),
    floor(random() * 1000 + 1),
    floor(random() * 50 + 10),
    floor(random() * 1000 + 100)
FROM generate_series(1, 200);

-- Popular repor (200 registros)
INSERT INTO repor (idtbl_funcionario, idtbl_produto, dt_reposicao)
SELECT
    floor(random() * 200 + 1),
    floor(random() * 200 + 1),
    NOW() - (random() * 30 || ' days')::interval
FROM generate_series(1, 200);

-- Remover funções auxiliares
DROP FUNCTION IF EXISTS random_cnpj();
DROP FUNCTION IF EXISTS random_cpf();
DROP FUNCTION IF EXISTS random_ean();

