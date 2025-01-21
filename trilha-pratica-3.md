---

# TRILHA PRÁTICA II

### Discentes: Norma Oliveira do Espírito Santo e Ian Felix Santos de Jesus

## 1. VIEWS

- - B1: Quais são os produtos e seus respectivos preços de venda?
    SELECT p.nm_prod, f.preco_venda
    FROM tbl_produto p
    JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto;
- - B2: Quantos estabelecimentos existem em cada estado?
    SELECT UF_estab, COUNT(\*) as total_estabelecimentos
    FROM tbl_estabelecimento
    GROUP BY UF_estab;
- - B3: Qual a distribuição de funcionários por função?
    SELECT funcao_func, COUNT(\*) as total_funcionarios
    FROM tbl_funcionario
    GROUP BY funcao_func;
- - B4: Quantos produtos existem em cada categoria?
    SELECT c.nm_categoria, COUNT(\*) as total_produtos
    FROM tbl_produto p
    JOIN tbl_categoria c ON p.ce_categoria_principal = c.cp_cod_categoria
    GROUP BY c.nm_categoria;
- - B5: Qual o estoque total de cada produto?
    SELECT p.nm_prod, SUM(vd.quantidade) as estoque_total
    FROM tbl_produto p
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    GROUP BY p.nm_prod;
- - B6: Quais produtos não possuem categoria secundária?
    SELECT nm_prod
    FROM tbl_produto
    WHERE ce_categoria_secundaria IS NULL;
- - B7: Quantos RFIDs estão disponíveis para venda?
    SELECT COUNT(\*) as total_disponiveis
    FROM tbl_rfid
    WHERE ind_venda_dispositivo = true;
- - B8: Quais são os produtos com preço acima da média?
    SELECT p.nm_prod, f.preco_venda
    FROM tbl_produto p
    JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
    WHERE f.preco_venda > (SELECT AVG(preco_venda) FROM fornecer);
- - B9: Quantos fornecedores existem em cada estado?
    SELECT UF_forn, COUNT(\*) as total_fornecedores
    FROM tbl_fornecedor
    GROUP BY UF_forn;
- - B10: Quais produtos estão com estoque zerado?
    SELECT p.nm_prod, vd.quantidade
    FROM tbl_produto p
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    WHERE vd.quantidade = 0;
- - B11: Qual o preço médio dos produtos por categoria?
    SELECT c.nm_categoria, AVG(f.preco_venda) as preco_medio
    FROM tbl_categoria c
    JOIN tbl_produto p ON c.cp_cod_categoria = p.ce_categoria_principal
    JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
    GROUP BY c.nm_categoria;
- - B12: Quais são os produtos mais caros?
    SELECT p.nm_prod, f.preco_venda
    FROM tbl_produto p
    JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
    ORDER BY f.preco_venda DESC
    LIMIT 10;
- - B13: Quais estabelecimentos têm mais de 100 produtos?
    SELECT e.nm_estab, COUNT(vd.idtbl_produto) as total_produtos
    FROM tbl_estabelecimento e
    JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
    GROUP BY e.nm_estab
    HAVING COUNT(vd.idtbl_produto) > 100;
- - B14: Quais produtos não têm fornecedor?
    SELECT nm_prod
    FROM tbl_produto p
    LEFT JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
    WHERE f.idtbl_produto IS NULL;
- - B15: Qual a quantidade média de produtos por estabelecimento?
    SELECT e.nm_estab, AVG(vd.quantidade) as media_produtos
    FROM tbl_estabelecimento e
    JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
    GROUP BY e.nm_estab;
- - B16: Quais são os produtos com estoque abaixo do mínimo?
    SELECT p.nm_prod, vd.quantidade, vd.estoque_minimo
    FROM tbl_produto p
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    WHERE vd.quantidade < vd.estoque_minimo;
- - B17: Qual o valor total em estoque por produto?
    SELECT p.nm_prod, SUM(vd.quantidade \* f.preco_venda) as valor_total
    FROM tbl_produto p
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
    GROUP BY p.nm_prod;
- - B18: Quais são os RFIDs associados a cada produto?
    SELECT p.nm_prod, r.cp_id_dispositivo
    FROM tbl_produto p
    JOIN tbl_rfid r ON p.ce_rfid = r.cp_id_dispositivo;
- - B19: Quais categorias têm mais produtos?
    SELECT c.nm_categoria, COUNT(\*) as total_produtos
    FROM tbl_categoria c
    JOIN tbl_produto p ON c.cp_cod_categoria = p.ce_categoria_principal
    GROUP BY c.nm_categoria
    ORDER BY total_produtos DESC;
- - B20: Quais produtos têm estoque acima da média?
    SELECT p.nm_prod, vd.quantidade
    FROM tbl_produto p
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    WHERE vd.quantidade > (
    SELECT AVG(quantidade)
    FROM vender_distribuir
    );

```sql
-- A1: Centraliza o estoque de cada produto por localização e permite monitorar estoques mínimos e máximos, ajudando no controle e reposição.
-- Requisito Atendido: RF1 e RF5.I
CREATE OR REPLACE VIEW vw_estoque_por_localizacao AS
SELECT
    e.nm_estab AS nome_estabelecimento,
    e.UF_estab AS estado,
    e.cidade_estab AS cidade,
    v.idtbl_produto AS id_produto,
    p.nm_prod AS nome_produto,
    v.quantidade AS estoque_atual,
    v.estoque_minimo,
    v.estoque_maximo
FROM vender_distribuir v
INNER JOIN tbl_estabelecimento e ON v.idtbl_estabelecimento = e.cp_cod_estab
INNER JOIN tbl_produto p ON v.idtbl_produto = p.cp_id_produto;

-- A2: Verifica quais produtos estão tendo o maior volume de vendas, possibilitando otimizar o gerenciamento de estoque e estratégia de vendas.
CREATE OR REPLACE VIEW vw_produtos_mais_vendidos AS
SELECT
    e.nm_estab AS nome_estabelecimento,
    p.nm_prod AS nome_produto,
    SUM(v.quantidade) AS total_vendido,
    AVG(f.preco_venda) AS preco_medio_venda
FROM vender_distribuir v
INNER JOIN tbl_estabelecimento e ON v.idtbl_estabelecimento = e.cp_cod_estab
INNER JOIN tbl_produto p ON v.idtbl_produto = p.cp_id_produto
INNER JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
WHERE v.quantidade > 0
GROUP BY e.nm_estab, p.nm_prod
ORDER BY total_vendido DESC;

```

## 2. STORED PROCEDURES

```sql
-- A1: Atualiza o estoque de um produto após uma venda e notifica quando o estoque está abaixo do nível mínimo.
-- Automatiza a atualização e verificação de estoque.
-- Requisito Atendido: RF3 e RF6.
CREATE OR REPLACE PROCEDURE sp_atualizar_estoque(
    IN produto_id BIGINT,
    IN estabelecimento_id BIGINT,
    IN quantidade_vendida INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Atualizar o estoque
    UPDATE vender_distribuir
    SET quantidade = quantidade - quantidade_vendida
    WHERE idtbl_produto = produto_id AND idtbl_estabelecimento = estabelecimento_id;

    -- Verificar se o estoque está abaixo do mínimo
    IF EXISTS (
        SELECT 1
        FROM vender_distribuir
        WHERE idtbl_produto = produto_id AND idtbl_estabelecimento = estabelecimento_id
        AND quantidade < estoque_minimo
    ) THEN
        RAISE NOTICE 'Estoque abaixo do mínimo para o produto % no estabelecimento %', produto_id, estabelecimento_id;
    END IF;
END;
$$;

-- A2: Fornece informações sobre quais lojas tiveram maior vazão de produtos em um período.
-- Ajuda a planejar reposições e priorizar locais de maior demanda.
CREATE OR REPLACE PROCEDURE sp_relatorio_vazao(
    IN data_inicio DATE,
    IN data_fim DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Gerar relatório de vazão de produtos
    SELECT
        e.nm_estab AS nome_estabelecimento,
        SUM(vd.quantidade) AS quantidade_vendida,
        COUNT(DISTINCT vd.idtbl_produto) AS total_produtos
    FROM vender_distribuir vd
    INNER JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
    WHERE vd.quantidade > 0
    AND vd.idtbl_produto IN (
        SELECT idtbl_produto
        FROM fornecer
        WHERE dt_venda BETWEEN data_inicio AND data_fim
    )
    GROUP BY e.nm_estab
    ORDER BY quantidade_vendida DESC;
END;
$$;

--A3: Simplifica o cadastro de fornecedores e a associação de produtos fornecidos.
-- Automatiza o processo de inserção, facilita a manutenção e melhora o controle de fornecedores e compras no sistema.
CREATE OR REPLACE PROCEDURE sp_registrar_novo_fornecedor(
    p_cnpj_forn CHAR(14),
    p_localizacao_forn FLOAT[],
    p_endereco_forn VARCHAR(200),
    p_uf_forn CHAR(2),
    p_cidade_forn CHAR(5),
    p_telefone_forn VARCHAR(15),
    p_email_forn VARCHAR(100),
    p_produtos_fornecidos BIGINT[],
    p_preco_compra DECIMAL(10,2),
    p_data_compra TIMESTAMP
)
LANGUAGE plpgsql
AS
$$
DECLARE
    v_cod_forn BIGINT;
    prod_id BIGINT;  -- Declara a variável prod_id
BEGIN
    -- Inserir novo fornecedor
    INSERT INTO tbl_fornecedor (cnpj_forn, localizacao_forn, endereco_forn, UF_forn, cidade_forn, telefone_forn, email_forn)
    VALUES (p_cnpj_forn, p_localizacao_forn, p_endereco_forn, p_uf_forn, p_cidade_forn, p_telefone_forn, p_email_forn)
    RETURNING cp_cod_forn INTO v_cod_forn;

    -- Inserir relação de fornecimento entre o fornecedor e os produtos
    FOREACH prod_id IN ARRAY p_produtos_fornecidos
    LOOP
        INSERT INTO fornecer (idtbl_produto, idtbl_fornecedor, preco_compra, dt_compra)
        VALUES (prod_id, v_cod_forn, p_preco_compra, p_data_compra);
    END LOOP;
END;
$$;

```

## 3. TRANSAÇÕES

```sql
-- A1: Reposição de Estoque
-- Registra a reposição e atualiza o estoque de forma transacional. Garante a consistência dos dados em caso de falhas.
-- Requisito Atendido: RF1 e RF3.
BEGIN;

INSERT INTO repor (idtbl_funcionario, idtbl_produto, dt_reposicao)
VALUES (1, 101, NOW());

UPDATE vender_distribuir
SET quantidade = quantidade + 50
WHERE idtbl_produto = 101 AND idtbl_estabelecimento = 1;

COMMIT;

--A2: Registrar Compra de Fornecedor
-- Registra uma nova compra e atualiza o estoque do depósito. Assegura que a compra e o ajuste de estoque sejam realizados juntos.
-- Requisito Atendido: RF4 e RF5.II.

BEGIN;

INSERT INTO fornecer (idtbl_produto, idtbl_fornecedor, preco_compra, dt_compra)
VALUES (101, 5, 10.50, NOW());

UPDATE vender_distribuir
SET quantidade = quantidade + 100
WHERE idtbl_produto = 101 AND idtbl_estabelecimento = 1;

COMMIT;

--A3: Transferência de Produtos Entre Estabelecimentos
-- Uma transação para transferir produtos de um estabelecimento para outro, com a garantia de que a operação seja atômica.

BEGIN;

-- Retirar produtos do estoque de um estabelecimento
UPDATE vender_distribuir
SET quantidade = quantidade - 50
WHERE idtbl_produto = 10 AND idtbl_estabelecimento = 1;

-- Adicionar produtos ao estoque de outro estabelecimento
UPDATE vender_distribuir
SET quantidade = quantidade + 50
WHERE idtbl_produto = 10 AND idtbl_estabelecimento = 2;

COMMIT;

```
