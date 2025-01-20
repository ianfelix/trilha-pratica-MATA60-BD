# TRILHA PRÁTICA II

## Discentes: Norma Oliveira do Espírito Santo e Ian Felix Santos de Jesus

## Queries SQL

### Queries Básicas (20)

Consultas simples envolvendo SELECT, WHERE, ORDER BY e GROUP BY básicos:

```sql
-- B1: Quais são os produtos e seus respectivos preços de venda?
SELECT p.nm_prod, f.preco_venda
FROM tbl_produto p
JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto;

-- B2: Quantos estabelecimentos existem em cada estado?
SELECT UF_estab, COUNT(*) as total_estabelecimentos
FROM tbl_estabelecimento
GROUP BY UF_estab;

-- B3: Qual a distribuição de funcionários por função?
SELECT funcao_func, COUNT(*) as total_funcionarios
FROM tbl_funcionario
GROUP BY funcao_func;

-- B4: Quantos produtos existem em cada categoria?
SELECT c.nm_categoria, COUNT(*) as total_produtos
FROM tbl_produto p
JOIN tbl_categoria c ON p.ce_categoria_principal = c.cp_cod_categoria
GROUP BY c.nm_categoria;

-- B5: Qual o estoque total de cada produto?
SELECT p.nm_prod, SUM(vd.quantidade) as estoque_total
FROM tbl_produto p
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
GROUP BY p.nm_prod;

-- B6: Quais produtos não possuem categoria secundária?
SELECT nm_prod
FROM tbl_produto
WHERE ce_categoria_secundaria IS NULL;

-- B7: Quantos RFIDs estão disponíveis para venda?
SELECT COUNT(*) as total_disponiveis
FROM tbl_rfid
WHERE ind_venda_dispositivo = true;

-- B8: Quais são os produtos com preço acima da média?
SELECT p.nm_prod, f.preco_venda
FROM tbl_produto p
JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
WHERE f.preco_venda > (SELECT AVG(preco_venda) FROM fornecer);

-- B9: Quantos fornecedores existem em cada estado?
SELECT UF_forn, COUNT(*) as total_fornecedores
FROM tbl_fornecedor
GROUP BY UF_forn;

-- B10: Quais produtos estão com estoque zerado?
SELECT p.nm_prod, vd.quantidade
FROM tbl_produto p
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
WHERE vd.quantidade = 0;

-- B11: Qual o preço médio dos produtos por categoria?
SELECT c.nm_categoria, AVG(f.preco_venda) as preco_medio
FROM tbl_categoria c
JOIN tbl_produto p ON c.cp_cod_categoria = p.ce_categoria_principal
JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
GROUP BY c.nm_categoria;

-- B12: Quais são os produtos mais caros?
SELECT p.nm_prod, f.preco_venda
FROM tbl_produto p
JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
ORDER BY f.preco_venda DESC
LIMIT 10;

-- B13: Quais estabelecimentos têm mais de 100 produtos?
SELECT e.nm_estab, COUNT(vd.idtbl_produto) as total_produtos
FROM tbl_estabelecimento e
JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
GROUP BY e.nm_estab
HAVING COUNT(vd.idtbl_produto) > 100;

-- B14: Quais produtos não têm fornecedor?
SELECT nm_prod
FROM tbl_produto p
LEFT JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
WHERE f.idtbl_produto IS NULL;

-- B15: Qual a quantidade média de produtos por estabelecimento?
SELECT e.nm_estab, AVG(vd.quantidade) as media_produtos
FROM tbl_estabelecimento e
JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
GROUP BY e.nm_estab;

-- B16: Quais são os produtos com estoque abaixo do mínimo?
SELECT p.nm_prod, vd.quantidade, vd.estoque_minimo
FROM tbl_produto p
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
WHERE vd.quantidade < vd.estoque_minimo;

-- B17: Qual o valor total em estoque por produto?
SELECT p.nm_prod, SUM(vd.quantidade * f.preco_venda) as valor_total
FROM tbl_produto p
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
GROUP BY p.nm_prod;

-- B18: Quais são os RFIDs associados a cada produto?
SELECT p.nm_prod, r.cp_id_dispositivo
FROM tbl_produto p
JOIN tbl_rfid r ON p.ce_rfid = r.cp_id_dispositivo;

-- B19: Quais categorias têm mais produtos?
SELECT c.nm_categoria, COUNT(*) as total_produtos
FROM tbl_categoria c
JOIN tbl_produto p ON c.cp_cod_categoria = p.ce_categoria_principal
GROUP BY c.nm_categoria
ORDER BY total_produtos DESC;

-- B20: Quais produtos têm estoque acima da média?
SELECT p.nm_prod, vd.quantidade
FROM tbl_produto p
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
WHERE vd.quantidade > (
    SELECT AVG(quantidade)
    FROM vender_distribuir
);

-- ... (mais 17 queries básicas)
```

### Queries Intermediárias (15)

Consultas com JOINs múltiplos, subqueries e funções de agregação:

```sql
-- Pergunta: Quais produtos estão com estoque abaixo do mínimo em cada estabelecimento?
-- I1: Lista produtos críticos por estabelecimento
SELECT p.nm_prod, e.nm_estab, vd.quantidade, vd.estoque_minimo
FROM tbl_produto p
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
WHERE vd.quantidade < vd.estoque_minimo;

-- Pergunta: Qual é o preço médio dos produtos em cada categoria?
-- I2: Análise de preços por categoria
SELECT c.nm_categoria, AVG(f.preco_venda) as preco_medio
FROM tbl_categoria c
JOIN tbl_produto p ON c.cp_cod_categoria = p.ce_categoria_principal
JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
GROUP BY c.nm_categoria;

-- Pergunta: Quais produtos precisam de reposição e quem são seus fornecedores?
-- I3: Produtos críticos e seus fornecedores
SELECT p.nm_prod, e.nm_estab, f.cnpj_forn, vd.quantidade, vd.estoque_minimo,
       f2.preco_compra as ultimo_preco_compra
FROM tbl_produto p
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
JOIN fornecer f2 ON p.cp_id_produto = f2.idtbl_produto
JOIN tbl_fornecedor f ON f2.idtbl_fornecedor = f.cp_cod_forn
WHERE vd.quantidade < vd.estoque_minimo;

-- Pergunta: Quais funcionários atendem a mais de 3 estabelecimentos diferentes?
-- I4: Funcionários com ampla cobertura
SELECT f.nm_func, COUNT(DISTINCT e.cp_cod_estab) as total_estabelecimentos
FROM tbl_funcionario f
JOIN repor r ON f.cp_cod_func = r.idtbl_funcionario
JOIN vender_distribuir vd ON r.idtbl_produto = vd.idtbl_produto
JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
GROUP BY f.nm_func
HAVING COUNT(DISTINCT e.cp_cod_estab) > 3;

-- Pergunta: Quais produtos nunca receberam reposição desde sua inclusão no sistema?
-- I5: Produtos sem histórico de reposição
SELECT p.nm_prod, vd.quantidade, vd.estoque_minimo
FROM tbl_produto p
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
LEFT JOIN repor r ON p.cp_id_produto = r.idtbl_produto
WHERE r.idtbl_produto IS NULL;

-- Pergunta: Quais estabelecimentos têm mais produtos em situação crítica de estoque?
-- I6: Ranking de estabelecimentos por produtos críticos
SELECT e.nm_estab, e.UF_estab,
       COUNT(*) as produtos_criticos
FROM tbl_estabelecimento e
JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
JOIN tbl_produto p ON vd.idtbl_produto = p.cp_id_produto
WHERE vd.quantidade < vd.estoque_minimo
GROUP BY e.nm_estab, e.UF_estab
ORDER BY produtos_criticos DESC;

-- Pergunta: Quais produtos apresentam maior variação de preço entre diferentes fornecedores?
-- I7: Análise de variação de preços
SELECT p.nm_prod,
       MIN(f.preco_venda) as menor_preco,
       MAX(f.preco_venda) as maior_preco,
       MAX(f.preco_venda) - MIN(f.preco_venda) as variacao
FROM tbl_produto p
JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
GROUP BY p.nm_prod
HAVING COUNT(DISTINCT f.idtbl_fornecedor) > 1
ORDER BY variacao DESC;

-- Pergunta: Quais funcionários fazem mais reposições por dia de trabalho?
-- I8: Produtividade diária dos funcionários
SELECT f.nm_func,
       COUNT(*) as total_reposicoes,
       COUNT(DISTINCT DATE(r.dt_reposicao)) as dias_trabalhados,
       COUNT(*)::float / COUNT(DISTINCT DATE(r.dt_reposicao)) as reposicoes_por_dia
FROM tbl_funcionario f
JOIN repor r ON f.cp_cod_func = r.idtbl_funcionario
GROUP BY f.nm_func
ORDER BY reposicoes_por_dia DESC;

-- Pergunta: Qual a margem de segurança do estoque atual em relação ao mínimo por produto?
-- I9: Análise de margem de segurança
SELECT p.nm_prod, e.nm_estab,
       vd.quantidade - vd.estoque_minimo as margem_estoque,
       (vd.quantidade::float / vd.estoque_minimo * 100) as percentual_seguranca
FROM tbl_produto p
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
ORDER BY margem_estoque;

-- Pergunta: Quais fornecedores têm maior volume financeiro em produtos fornecidos?
-- I10: Volume financeiro por fornecedor
SELECT f.cnpj_forn, f.UF_forn,
       COUNT(DISTINCT fr.idtbl_produto) as total_produtos,
       SUM(fr.preco_venda * vd.quantidade) as valor_total_estoque
FROM tbl_fornecedor f
JOIN fornecer fr ON f.cp_cod_forn = fr.idtbl_fornecedor
JOIN vender_distribuir vd ON fr.idtbl_produto = vd.idtbl_produto
GROUP BY f.cnpj_forn, f.UF_forn
ORDER BY valor_total_estoque DESC;

-- Pergunta: Como os produtos e categorias estão distribuídos por região?
-- I11: Distribuição regional de produtos
SELECT e.UF_estab,
       COUNT(DISTINCT p.cp_id_produto) as total_produtos,
       COUNT(DISTINCT p.ce_categoria_principal) as total_categorias,
       AVG(vd.quantidade) as media_estoque
FROM tbl_estabelecimento e
JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
JOIN tbl_produto p ON vd.idtbl_produto = p.cp_id_produto
GROUP BY e.UF_estab;

-- Pergunta: Quais produtos estão com estoque crítico em mais de um estabelecimento?
-- I12: Produtos críticos multi-estabelecimentos
SELECT p.nm_prod,
       COUNT(DISTINCT e.cp_cod_estab) as total_estabelecimentos_criticos
FROM tbl_produto p
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
WHERE vd.quantidade < vd.estoque_minimo
GROUP BY p.nm_prod
HAVING COUNT(DISTINCT e.cp_cod_estab) > 1
ORDER BY total_estabelecimentos_criticos DESC;

-- Pergunta: Quais fornecedores têm melhor desempenho em termos de margem e diversidade?
-- I13: Performance de fornecedores
SELECT f.cnpj_forn,
       AVG(fr.preco_venda - fr.preco_compra) as margem_media,
       COUNT(DISTINCT fr.idtbl_produto) as total_produtos,
       COUNT(DISTINCT p.ce_categoria_principal) as total_categorias
FROM tbl_fornecedor f
JOIN fornecer fr ON f.cp_cod_forn = fr.idtbl_fornecedor
JOIN tbl_produto p ON fr.idtbl_produto = p.cp_id_produto
GROUP BY f.cnpj_forn
ORDER BY margem_media DESC;

-- Pergunta: Quais produtos e categorias estão com estoque abaixo do mínimo?
-- I14: Estoque crítico por categoria
SELECT
    c.nm_categoria,
    p.nm_prod,
    SUM(vd.quantidade) as estoque_total,
    SUM(vd.estoque_minimo) as minimo_total
FROM tbl_categoria c
JOIN tbl_produto p ON c.cp_cod_categoria = p.ce_categoria_principal
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
GROUP BY c.nm_categoria, p.nm_prod
HAVING SUM(vd.quantidade) < SUM(vd.estoque_minimo);

-- Pergunta: Como os funcionários se especializam em diferentes categorias de produtos?
-- I15: Especialização dos funcionários
SELECT
    f.nm_func,
    c.nm_categoria,
    COUNT(*) as total_reposicoes,
    COUNT(DISTINCT e.cp_cod_estab) as estabelecimentos_atendidos
FROM tbl_funcionario f
JOIN repor r ON f.cp_cod_func = r.idtbl_funcionario
JOIN tbl_produto p ON r.idtbl_produto = p.cp_id_produto
JOIN tbl_categoria c ON p.ce_categoria_principal = c.cp_cod_categoria
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
GROUP BY f.nm_func, c.nm_categoria;
```

### Queries Avançadas (10)

Consultas complexas com sub-selects e ordenação:

```sql
-- Pergunta: Quais são os 5 produtos mais repostos em cada mês e qual sua posição no ranking?
-- A1: Ranking mensal de produtos por reposição
WITH RankingMensal AS (
    SELECT
        p.nm_prod,
        DATE_TRUNC('month', r.dt_reposicao) as mes,
        COUNT(*) as total_reposicoes,
        RANK() OVER (PARTITION BY DATE_TRUNC('month', r.dt_reposicao)
                     ORDER BY COUNT(*) DESC) as ranking
    FROM tbl_produto p
    JOIN repor r ON p.cp_id_produto = r.idtbl_produto
    GROUP BY p.nm_prod, DATE_TRUNC('month', r.dt_reposicao)
)
SELECT *
FROM RankingMensal
WHERE ranking <= 5;

-- Pergunta: Quais produtos geram maior lucro em cada categoria, considerando a média da categoria?
-- A2: Análise de lucratividade por categoria
SELECT
    c.nm_categoria,
    p.nm_prod,
    f.preco_venda - f.preco_compra as lucro_unitario,
    vd.quantidade * (f.preco_venda - f.preco_compra) as lucro_total
FROM tbl_produto p
JOIN tbl_categoria c ON p.ce_categoria_principal = c.cp_cod_categoria
JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
WHERE (f.preco_venda - f.preco_compra) > (
    SELECT AVG(preco_venda - preco_compra)
    FROM fornecer
    WHERE idtbl_produto IN (
        SELECT cp_id_produto
        FROM tbl_produto
        WHERE ce_categoria_principal = c.cp_cod_categoria
    )
)
ORDER BY lucro_total DESC;

-- Pergunta: Qual o percentual de produtos em estado crítico em cada estabelecimento por região?
-- A3: Análise regional de estoque crítico
SELECT
    e.UF_estab,
    e.nm_estab,
    COUNT(*) as produtos_criticos,
    ROUND(COUNT(*) * 100.0 / (
        SELECT COUNT(DISTINCT p2.cp_id_produto)
        FROM tbl_produto p2
        JOIN vender_distribuir vd2 ON p2.cp_id_produto = vd2.idtbl_produto
        WHERE vd2.idtbl_estabelecimento = e.cp_cod_estab
    )) as percentual_critico
FROM tbl_estabelecimento e
JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
JOIN tbl_produto p ON vd.idtbl_produto = p.cp_id_produto
WHERE vd.quantidade < vd.estoque_minimo
GROUP BY e.UF_estab, e.nm_estab, e.cp_cod_estab
HAVING COUNT(*) > 5
ORDER BY percentual_critico DESC;

-- Pergunta: Como os fornecedores se comparam em termos de produtos, margens e situações críticas?
-- A4: Análise comparativa de fornecedores
SELECT
    f.cnpj_forn,
    COUNT(DISTINCT p.cp_id_produto) as total_produtos,
    AVG(fr.preco_venda - fr.preco_compra) as margem_media,
    (SELECT COUNT(*)
     FROM vender_distribuir vd2
     WHERE vd2.quantidade < vd2.estoque_minimo
     AND vd2.idtbl_produto IN (
         SELECT idtbl_produto
         FROM fornecer
         WHERE idtbl_fornecedor = f.cp_cod_forn
     )) as produtos_criticos
FROM tbl_fornecedor f
JOIN fornecer fr ON f.cp_cod_forn = fr.idtbl_fornecedor
JOIN tbl_produto p ON fr.idtbl_produto = p.cp_id_produto
GROUP BY f.cnpj_forn, f.cp_cod_forn
HAVING COUNT(DISTINCT p.cp_id_produto) > 5
ORDER BY margem_media DESC;

-- Pergunta: Quais categorias têm maior rotatividade de produtos em relação ao seu total de itens?
-- A5: Índice de rotatividade por categoria
SELECT
    c.nm_categoria,
    COUNT(r.idtbl_produto) as total_reposicoes,
    (SELECT COUNT(DISTINCT p2.cp_id_produto)
     FROM tbl_produto p2
     WHERE p2.ce_categoria_principal = c.cp_cod_categoria) as total_produtos,
    ROUND(COUNT(r.idtbl_produto) * 1.0 / (
        SELECT COUNT(DISTINCT p2.cp_id_produto)
        FROM tbl_produto p2
        WHERE p2.ce_categoria_principal = c.cp_cod_categoria
    ), 2) as indice_rotatividade
FROM tbl_categoria c
JOIN tbl_produto p ON c.cp_cod_categoria = p.ce_categoria_principal
LEFT JOIN repor r ON p.cp_id_produto = r.idtbl_produto
GROUP BY c.nm_categoria, c.cp_cod_categoria
HAVING COUNT(r.idtbl_produto) > 0
ORDER BY indice_rotatividade DESC;

-- Pergunta: Quais funcionários são mais produtivos em cada região, considerando diversidade de categorias?
-- A6: Produtividade regional dos funcionários
SELECT
    e.UF_estab,
    f.nm_func,
    COUNT(*) as total_reposicoes,
    COUNT(DISTINCT p.ce_categoria_principal) as categorias_atendidas,
    ROUND(COUNT(*) * 1.0 / (
        SELECT COUNT(DISTINCT DATE(r2.dt_reposicao))
        FROM repor r2
        WHERE r2.idtbl_funcionario = f.cp_cod_func
    ), 2) as media_diaria
FROM tbl_funcionario f
JOIN repor r ON f.cp_cod_func = r.idtbl_funcionario
JOIN tbl_produto p ON r.idtbl_produto = p.cp_id_produto
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
GROUP BY e.UF_estab, f.nm_func, f.cp_cod_func
HAVING COUNT(*) > 10
ORDER BY media_diaria DESC;

-- Pergunta: Quais produtos apresentam variação significativa de preço entre diferentes regiões?
-- A7: Análise de variação regional de preços
SELECT
    p.nm_prod,
    COUNT(DISTINCT e.UF_estab) as total_estados,
    MIN(f.preco_venda) as menor_preco,
    MAX(f.preco_venda) as maior_preco,
    MAX(f.preco_venda) - MIN(f.preco_venda) as variacao_preco
FROM tbl_produto p
JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
GROUP BY p.nm_prod
HAVING COUNT(DISTINCT e.UF_estab) > 1
    AND (MAX(f.preco_venda) - MIN(f.preco_venda)) > (
        SELECT AVG(preco_venda) * 0.2
        FROM fornecer
    )
ORDER BY variacao_preco DESC;

-- Pergunta: Como está a situação de estoque nas diferentes regiões em relação ao mínimo necessário?
-- A8: Cobertura regional de estoque
SELECT
    e.UF_estab,
    COUNT(DISTINCT p.cp_id_produto) as total_produtos,
    ROUND(AVG(vd.quantidade * 1.0 / NULLIF(vd.estoque_minimo, 0)), 2) as cobertura_media,
    (SELECT COUNT(*)
     FROM vender_distribuir vd2
     JOIN tbl_estabelecimento e2 ON vd2.idtbl_estabelecimento = e2.cp_cod_estab
     WHERE e2.UF_estab = e.UF_estab
     AND vd2.quantidade < vd2.estoque_minimo) as produtos_criticos
FROM tbl_estabelecimento e
JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
JOIN tbl_produto p ON vd.idtbl_produto = p.cp_id_produto
GROUP BY e.UF_estab
HAVING COUNT(DISTINCT p.cp_id_produto) > 10
ORDER BY cobertura_media;

-- Pergunta: Quais produtos demandam reposição mais frequente em relação à média geral?
-- A9: Análise de demanda de reposição
SELECT
    p.nm_prod,
    COUNT(*) as total_reposicoes,
    COUNT(DISTINCT e.cp_cod_estab) as total_estabelecimentos,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT e.cp_cod_estab), 2) as media_reposicoes_por_estabelecimento
FROM tbl_produto p
JOIN repor r ON p.cp_id_produto = r.idtbl_produto
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
GROUP BY p.nm_prod
HAVING COUNT(DISTINCT e.cp_cod_estab) > 1
    AND COUNT(*) > (
        SELECT AVG(reposicoes)
        FROM (
            SELECT COUNT(*) as reposicoes
            FROM repor
            GROUP BY idtbl_produto
        ) t
    )
ORDER BY media_reposicoes_por_estabelecimento DESC;

-- Pergunta: Como as categorias se comparam em termos de eficiência operacional e situação de estoque?
-- A10: Performance comparativa de categorias
SELECT
    c.nm_categoria,
    COUNT(DISTINCT p.cp_id_produto) as total_produtos,
    ROUND(AVG(f.preco_venda - f.preco_compra), 2) as margem_media,
    (SELECT COUNT(*)
     FROM vender_distribuir vd2
     JOIN tbl_produto p2 ON vd2.idtbl_produto = p2.cp_id_produto
     WHERE p2.ce_categoria_principal = c.cp_cod_categoria
     AND vd2.quantidade < vd2.estoque_minimo) as produtos_criticos
FROM tbl_categoria c
JOIN tbl_produto p ON c.cp_cod_categoria = p.ce_categoria_principal
JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
GROUP BY c.nm_categoria, c.cp_cod_categoria
HAVING COUNT(DISTINCT p.cp_id_produto) > 5
ORDER BY margem_media DESC;
```

## Plano de Indexação

### Índices Propostos

1. Índices em chaves estrangeiras
2. Índices em colunas frequentemente filtradas
3. Índices compostos para queries comuns

```sql
CREATE INDEX idx_vender_distribuir_produto ON vender_distribuir(idtbl_produto);
CREATE INDEX idx_vender_distribuir_estabelecimento ON vender_distribuir(idtbl_estabelecimento);
CREATE INDEX idx_fornecer_produto ON fornecer(idtbl_produto);
CREATE INDEX idx_fornecer_fornecedor ON fornecer(idtbl_fornecedor);
CREATE INDEX idx_vender_distribuir_estoque ON vender_distribuir(quantidade, estoque_minimo);
```

## Plano de Tuning

### Otimizações Propostas

1. Particionamento de tabelas grandes
2. Materialização de views comuns
3. Ajustes em parâmetros do PostgreSQL

```sql
-- Exemplo de view materializada
CREATE MATERIALIZED VIEW mv_estoque_critico AS
SELECT p.nm_prod, e.nm_estab, vd.quantidade, vd.estoque_minimo
FROM tbl_produto p
JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
WHERE vd.quantidade < vd.estoque_minimo;
```

## Análise de Desempenho

### 2. Configurações Iniciais (Baseline)

#### 2.1 Tabela para Coleta de Dados

```sql
-- Criação das tabelas de baseline
DROP TABLE IF EXISTS baseline_results;
CREATE TABLE baseline_results (
    id SERIAL PRIMARY KEY,
    query_id INT,
    query_name VARCHAR(100),
    query_type VARCHAR(20),
    run_number INT,
    execution_time FLOAT,
    execution_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (query_id, run_number)
);

DROP TABLE IF EXISTS queries_to_run;
CREATE TABLE queries_to_run (
    query_id INT PRIMARY KEY,
    query_name VARCHAR(100),
    query_type VARCHAR(20),
    query_text TEXT
);

-- Função para executar os testes de performance
CREATE OR REPLACE FUNCTION run_performance_test()
RETURNS void AS $$
DECLARE
    q RECORD;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    duration FLOAT;
    run INT;
BEGIN
    FOR q IN SELECT * FROM queries_to_run ORDER BY query_id LOOP
        FOR run IN 1..50 LOOP
            start_time := clock_timestamp();
            EXECUTE q.query_text;
            end_time := clock_timestamp();

            duration := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;

            INSERT INTO baseline_results (query_id, query_name, query_type, run_number, execution_time)
            VALUES (q.query_id, q.query_name, q.query_type, run, duration);
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Limpar dados existentes
TRUNCATE TABLE baseline_results;
TRUNCATE TABLE queries_to_run;

-- Inserir todas as queries (1-20)
INSERT INTO queries_to_run (query_id, query_name, query_type, query_text) VALUES
-- Queries Básicas (1-10)
(1, 'Produtos com Estoque Crítico', 'basic',
'SELECT COUNT(*) FROM (
    SELECT p.nm_prod, e.nm_estab, f.cnpj_forn, vd.quantidade, vd.estoque_minimo
    FROM tbl_produto p
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
    JOIN fornecer f2 ON p.cp_id_produto = f2.idtbl_produto
    JOIN tbl_fornecedor f ON f2.idtbl_fornecedor = f.cp_cod_forn
    WHERE vd.quantidade < vd.estoque_minimo
) subq'),

(2, 'Estabelecimentos Críticos', 'basic',
'SELECT COUNT(*) FROM (
    SELECT e.nm_estab, e.UF_estab, COUNT(*) as produtos_criticos
    FROM tbl_estabelecimento e
    JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
    WHERE vd.quantidade < vd.estoque_minimo
    GROUP BY e.nm_estab, e.UF_estab
) subq'),

(3, 'Preço Médio por Categoria', 'basic',
'SELECT COUNT(*) FROM (
    SELECT c.nm_categoria, AVG(f.preco_venda) as preco_medio
    FROM tbl_categoria c
    JOIN tbl_produto p ON c.cp_cod_categoria = p.ce_categoria_principal
    JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
    GROUP BY c.nm_categoria
) subq'),

(4, 'Funcionários por Estabelecimento', 'basic',
'SELECT COUNT(*) FROM (
    SELECT f.nm_func, COUNT(DISTINCT e.cp_cod_estab) as total_estabelecimentos
    FROM tbl_funcionario f
    JOIN repor r ON f.cp_cod_func = r.idtbl_funcionario
    JOIN vender_distribuir vd ON r.idtbl_produto = vd.idtbl_produto
    JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
    GROUP BY f.nm_func
) subq'),

(5, 'Produtos sem Reposição', 'basic',
'SELECT COUNT(*) FROM (
    SELECT p.nm_prod, vd.quantidade, vd.estoque_minimo
    FROM tbl_produto p
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    LEFT JOIN repor r ON p.cp_id_produto = r.idtbl_produto
    WHERE r.idtbl_produto IS NULL
) subq'),

(6, 'Ranking Estabelecimentos', 'basic',
'SELECT COUNT(*) FROM (
    SELECT e.nm_estab, COUNT(*) as total_produtos
    FROM tbl_estabelecimento e
    JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
    GROUP BY e.nm_estab
    ORDER BY total_produtos DESC
) subq'),

(7, 'Variação de Preços', 'basic',
'SELECT COUNT(*) FROM (
    SELECT p.nm_prod,
           MIN(f.preco_venda) as menor_preco,
           MAX(f.preco_venda) as maior_preco,
           MAX(f.preco_venda) - MIN(f.preco_venda) as variacao
    FROM tbl_produto p
    JOIN fornecer f ON p.cp_id_produto = f.idtbl_produto
    GROUP BY p.nm_prod
) subq'),

(8, 'Reposições por Dia', 'basic',
'SELECT COUNT(*) FROM (
    SELECT DATE(r.dt_reposicao) as data, COUNT(*) as total_reposicoes
    FROM repor r
    GROUP BY DATE(r.dt_reposicao)
    ORDER BY data
) subq'),

(9, 'Margem de Segurança', 'basic',
'SELECT COUNT(*) FROM (
    SELECT p.nm_prod,
           vd.quantidade - vd.estoque_minimo as margem_estoque
    FROM tbl_produto p
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    ORDER BY margem_estoque
) subq'),

(10, 'Volume por Fornecedor', 'basic',
'SELECT COUNT(*) FROM (
    SELECT f.cnpj_forn,
           COUNT(DISTINCT fr.idtbl_produto) as total_produtos,
           SUM(fr.preco_venda * vd.quantidade) as valor_total_estoque
    FROM tbl_fornecedor f
    JOIN fornecer fr ON f.cp_cod_forn = fr.idtbl_fornecedor
    JOIN vender_distribuir vd ON fr.idtbl_produto = vd.idtbl_produto
    GROUP BY f.cnpj_forn
) subq'),

-- Queries Básicas (11-20)
(11, 'Distribuição Regional', 'basic',
'SELECT COUNT(*) FROM (
    SELECT e.UF_estab,
           COUNT(DISTINCT p.cp_id_produto) as total_produtos,
           COUNT(DISTINCT p.ce_categoria_principal) as total_categorias
    FROM tbl_estabelecimento e
    JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
    JOIN tbl_produto p ON vd.idtbl_produto = p.cp_id_produto
    GROUP BY e.UF_estab
) subq'),

(12, 'Produtos Críticos Multi-Estabelecimentos', 'basic',
'SELECT COUNT(*) FROM (
    SELECT p.nm_prod,
           COUNT(DISTINCT e.cp_cod_estab) as total_estabelecimentos_criticos
    FROM tbl_produto p
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
    WHERE vd.quantidade < vd.estoque_minimo
    GROUP BY p.nm_prod
    HAVING COUNT(DISTINCT e.cp_cod_estab) > 1
) subq'),

(13, 'Performance Fornecedores', 'basic',
'SELECT COUNT(*) FROM (
    SELECT f.cnpj_forn,
           AVG(fr.preco_venda - fr.preco_compra) as margem_media,
           COUNT(DISTINCT fr.idtbl_produto) as total_produtos
    FROM tbl_fornecedor f
    JOIN fornecer fr ON f.cp_cod_forn = fr.idtbl_fornecedor
    JOIN tbl_produto p ON fr.idtbl_produto = p.cp_id_produto
    GROUP BY f.cnpj_forn
) subq'),

(14, 'Estoque Crítico Categorias', 'basic',
'SELECT COUNT(*) FROM (
    SELECT c.nm_categoria,
           COUNT(*) as produtos_criticos
    FROM tbl_categoria c
    JOIN tbl_produto p ON c.cp_cod_categoria = p.ce_categoria_principal
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    WHERE vd.quantidade < vd.estoque_minimo
    GROUP BY c.nm_categoria
) subq'),

(15, 'Especialização Funcionários', 'basic',
'SELECT COUNT(*) FROM (
    SELECT f.nm_func,
           COUNT(DISTINCT p.ce_categoria_principal) as categorias_atendidas
    FROM tbl_funcionario f
    JOIN repor r ON f.cp_cod_func = r.idtbl_funcionario
    JOIN tbl_produto p ON r.idtbl_produto = p.cp_id_produto
    GROUP BY f.nm_func
) subq'),

(16, 'Fornecedores por Região', 'basic',
'SELECT COUNT(*) FROM (
    SELECT f.UF_forn,
           COUNT(DISTINCT f.cp_cod_forn) as total_fornecedores,
           COUNT(DISTINCT fr.idtbl_produto) as total_produtos
    FROM tbl_fornecedor f
    JOIN fornecer fr ON f.cp_cod_forn = fr.idtbl_fornecedor
    GROUP BY f.UF_forn
) subq'),

(17, 'Produtos Alta Rotatividade', 'basic',
'SELECT COUNT(*) FROM (
    SELECT p.nm_prod,
           COUNT(*) as total_reposicoes
    FROM tbl_produto p
    JOIN repor r ON p.cp_id_produto = r.idtbl_produto
    GROUP BY p.nm_prod
    HAVING COUNT(*) > 5
) subq'),

(18, 'Estabelecimentos Eficientes', 'basic',
'SELECT COUNT(*) FROM (
    SELECT e.nm_estab,
           COUNT(*) as total_produtos,
           SUM(CASE WHEN vd.quantidade < vd.estoque_minimo THEN 1 ELSE 0 END) as produtos_criticos
    FROM tbl_estabelecimento e
    JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
    GROUP BY e.nm_estab
    HAVING SUM(CASE WHEN vd.quantidade < vd.estoque_minimo THEN 1 ELSE 0 END) = 0
) subq'),

(19, 'Categorias Lucrativas', 'basic',
'SELECT COUNT(*) FROM (
    SELECT c.nm_categoria,
           AVG(fr.preco_venda - fr.preco_compra) as margem_media
    FROM tbl_categoria c
    JOIN tbl_produto p ON c.cp_cod_categoria = p.ce_categoria_principal
    JOIN fornecer fr ON p.cp_id_produto = fr.idtbl_produto
    GROUP BY c.nm_categoria
    ORDER BY margem_media DESC
) subq'),

(20, 'Funcionários Produtivos', 'basic',
'SELECT COUNT(*) FROM (
    SELECT f.nm_func,
           COUNT(*) as total_reposicoes,
           COUNT(DISTINCT DATE(r.dt_reposicao)) as dias_trabalhados
    FROM tbl_funcionario f
    JOIN repor r ON f.cp_cod_func = r.idtbl_funcionario
    GROUP BY f.nm_func
    HAVING COUNT(*) / COUNT(DISTINCT DATE(r.dt_reposicao)) > 2
) subq');

-- Queries Intermediárias (21-30)
INSERT INTO queries_to_run (query_id, query_name, query_type, query_text) VALUES
(21, 'Análise Temporal Reposições', 'intermediate',
'SELECT COUNT(*) FROM (
    SELECT DATE_TRUNC(''month'', r.dt_reposicao) as mes,
           COUNT(*) as total_reposicoes,
           COUNT(DISTINCT p.cp_id_produto) as produtos_distintos,
           COUNT(DISTINCT f.cp_cod_func) as funcionarios_ativos
    FROM repor r
    JOIN tbl_produto p ON r.idtbl_produto = p.cp_id_produto
    JOIN tbl_funcionario f ON r.idtbl_funcionario = f.cp_cod_func
    GROUP BY DATE_TRUNC(''month'', r.dt_reposicao)
) subq'),

(22, 'Eficiência Fornecedores', 'intermediate',
'SELECT COUNT(*) FROM (
    SELECT f.cnpj_forn,
           COUNT(DISTINCT p.ce_categoria_principal) as categorias_atendidas,
           AVG(fr.preco_venda - fr.preco_compra) as margem_media
    FROM tbl_fornecedor f
    JOIN fornecer fr ON f.cp_cod_forn = fr.idtbl_fornecedor
    JOIN tbl_produto p ON fr.idtbl_produto = p.cp_id_produto
    GROUP BY f.cnpj_forn
    HAVING COUNT(DISTINCT p.ce_categoria_principal) > 2
) subq'),

(23, 'Análise Regional Estabelecimentos', 'intermediate',
'SELECT COUNT(*) FROM (
    SELECT e.UF_estab,
           COUNT(DISTINCT e.cp_cod_estab) as total_estabelecimentos,
           COUNT(DISTINCT p.ce_categoria_principal) as categorias_presentes,
           SUM(CASE WHEN vd.quantidade < vd.estoque_minimo THEN 1 ELSE 0 END) as total_produtos_criticos
    FROM tbl_estabelecimento e
    JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
    JOIN tbl_produto p ON vd.idtbl_produto = p.cp_id_produto
    GROUP BY e.UF_estab
) subq'),

(24, 'Produtos Sem Movimento', 'intermediate',
'SELECT COUNT(*) FROM (
    SELECT p.nm_prod,
           MAX(r.dt_reposicao) as ultima_reposicao,
           NOW() - MAX(r.dt_reposicao) as tempo_sem_reposicao
    FROM tbl_produto p
    LEFT JOIN repor r ON p.cp_id_produto = r.idtbl_produto
    GROUP BY p.nm_prod
    HAVING MAX(r.dt_reposicao) < NOW() - INTERVAL ''30 days''
       OR MAX(r.dt_reposicao) IS NULL
) subq'),

(25, 'Análise Categorias Críticas', 'intermediate',
'SELECT COUNT(*) FROM (
    SELECT c.nm_categoria,
           COUNT(DISTINCT p.cp_id_produto) as total_produtos,
           COUNT(DISTINCT CASE WHEN vd.quantidade < vd.estoque_minimo
                              THEN p.cp_id_produto END) as produtos_criticos,
           ROUND(COUNT(DISTINCT CASE WHEN vd.quantidade < vd.estoque_minimo
                                   THEN p.cp_id_produto END) * 100.0 /
                 COUNT(DISTINCT p.cp_id_produto), 2) as percentual_critico
    FROM tbl_categoria c
    JOIN tbl_produto p ON c.cp_cod_categoria = p.ce_categoria_principal
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    GROUP BY c.nm_categoria
    HAVING COUNT(DISTINCT p.cp_id_produto) > 5
) subq'),

(26, 'Performance Funcionários', 'intermediate',
'SELECT COUNT(*) FROM (
    SELECT f.nm_func,
           COUNT(*) as total_reposicoes,
           COUNT(DISTINCT p.ce_categoria_principal) as categorias_atendidas,
           COUNT(*) * 1.0 / COUNT(DISTINCT DATE(r.dt_reposicao)) as media_diaria
    FROM tbl_funcionario f
    JOIN repor r ON f.cp_cod_func = r.idtbl_funcionario
    JOIN tbl_produto p ON r.idtbl_produto = p.cp_id_produto
    GROUP BY f.nm_func
    HAVING COUNT(DISTINCT DATE(r.dt_reposicao)) >= 5
) subq'),

(27, 'Análise Fornecimento Regional', 'intermediate',
'SELECT COUNT(*) FROM (
    SELECT f.UF_forn,
           COUNT(DISTINCT e.UF_estab) as estados_atendidos,
           COUNT(DISTINCT p.cp_id_produto) as produtos_fornecidos
    FROM tbl_fornecedor f
    JOIN fornecer fr ON f.cp_cod_forn = fr.idtbl_fornecedor
    JOIN tbl_produto p ON fr.idtbl_produto = p.cp_id_produto
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
    GROUP BY f.UF_forn
) subq'),

(28, 'Diversidade Produtos', 'intermediate',
'SELECT COUNT(*) FROM (
    SELECT p.ce_categoria_principal,
           COUNT(DISTINCT p.cp_id_produto) as total_produtos,
           COUNT(DISTINCT f.cp_cod_forn) as total_fornecedores,
           COUNT(DISTINCT e.cp_cod_estab) as total_estabelecimentos
    FROM tbl_produto p
    JOIN fornecer fr ON p.cp_id_produto = fr.idtbl_produto
    JOIN tbl_fornecedor f ON fr.idtbl_fornecedor = f.cp_cod_forn
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
    GROUP BY p.ce_categoria_principal
) subq'),

(29, 'Análise Preços Regionais', 'intermediate',
'SELECT COUNT(*) FROM (
    SELECT e.UF_estab,
           p.ce_categoria_principal,
           AVG(fr.preco_venda) as preco_medio,
           STDDEV(fr.preco_venda) as variacao_preco
    FROM tbl_estabelecimento e
    JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
    JOIN tbl_produto p ON vd.idtbl_produto = p.cp_id_produto
    JOIN fornecer fr ON p.cp_id_produto = fr.idtbl_produto
    GROUP BY e.UF_estab, p.ce_categoria_principal
    HAVING COUNT(*) > 5
) subq'),

(30, 'Eficiência Estabelecimentos', 'intermediate',
'SELECT COUNT(*) FROM (
    SELECT e.nm_estab,
           COUNT(DISTINCT p.cp_id_produto) as total_produtos,
           COUNT(DISTINCT p.ce_categoria_principal) as total_categorias,
           COUNT(DISTINCT f.cp_cod_func) as total_funcionarios,
           SUM(CASE WHEN vd.quantidade < vd.estoque_minimo THEN 1 ELSE 0 END) as produtos_criticos
    FROM tbl_estabelecimento e
    JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
    JOIN tbl_produto p ON vd.idtbl_produto = p.cp_id_produto
    LEFT JOIN repor r ON p.cp_id_produto = r.idtbl_produto
    LEFT JOIN tbl_funcionario f ON r.idtbl_funcionario = f.cp_cod_func
    GROUP BY e.nm_estab
) subq');

-- Queries Intermediárias (31-35)
INSERT INTO queries_to_run (query_id, query_name, query_type, query_text) VALUES
(31, 'Sazonalidade Reposições', 'intermediate',
'SELECT COUNT(*) FROM (
    SELECT EXTRACT(DOW FROM r.dt_reposicao) as dia_semana,
           EXTRACT(HOUR FROM r.dt_reposicao) as hora_dia,
           COUNT(*) as total_reposicoes,
           COUNT(DISTINCT f.cp_cod_func) as funcionarios_ativos
    FROM repor r
    JOIN tbl_funcionario f ON r.idtbl_funcionario = f.cp_cod_func
    GROUP BY EXTRACT(DOW FROM r.dt_reposicao), EXTRACT(HOUR FROM r.dt_reposicao)
) subq'),

(32, 'Correlação Preço-Demanda', 'intermediate',
'SELECT COUNT(*) FROM (
    SELECT p.cp_id_produto,
           AVG(fr.preco_venda) as preco_medio,
           COUNT(r.idtbl_produto) as total_reposicoes,
           COUNT(r.idtbl_produto) * 1.0 / COUNT(DISTINCT DATE(r.dt_reposicao)) as reposicoes_por_dia
    FROM tbl_produto p
    JOIN fornecer fr ON p.cp_id_produto = fr.idtbl_produto
    LEFT JOIN repor r ON p.cp_id_produto = r.idtbl_produto
    GROUP BY p.cp_id_produto
    HAVING COUNT(DISTINCT DATE(r.dt_reposicao)) > 0
) subq'),

(33, 'Eficiência Cadeia Fornecimento', 'intermediate',
'SELECT COUNT(*) FROM (
    SELECT f.UF_forn,
           e.UF_estab,
           AVG(fr.preco_venda - fr.preco_compra) as margem_media,
           COUNT(DISTINCT p.cp_id_produto) as total_produtos,
           COUNT(DISTINCT p.ce_categoria_principal) as total_categorias
    FROM tbl_fornecedor f
    JOIN fornecer fr ON f.cp_cod_forn = fr.idtbl_fornecedor
    JOIN tbl_produto p ON fr.idtbl_produto = p.cp_id_produto
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
    GROUP BY f.UF_forn, e.UF_estab
) subq'),

(34, 'Análise Complexidade Operacional', 'intermediate',
'SELECT COUNT(*) FROM (
    SELECT e.nm_estab,
           COUNT(DISTINCT p.ce_categoria_principal) as total_categorias,
           COUNT(DISTINCT f.cp_cod_forn) as total_fornecedores,
           COUNT(DISTINCT func.cp_cod_func) as total_funcionarios,
           COUNT(DISTINCT DATE(r.dt_reposicao)) as dias_operacao
    FROM tbl_estabelecimento e
    JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
    JOIN tbl_produto p ON vd.idtbl_produto = p.cp_id_produto
    JOIN fornecer fr ON p.cp_id_produto = fr.idtbl_produto
    JOIN tbl_fornecedor f ON fr.idtbl_fornecedor = f.cp_cod_forn
    LEFT JOIN repor r ON p.cp_id_produto = r.idtbl_produto
    LEFT JOIN tbl_funcionario func ON r.idtbl_funcionario = func.cp_cod_func
    GROUP BY e.nm_estab
) subq'),

(35, 'Análise Gargalos Operacionais', 'intermediate',
'SELECT COUNT(*) FROM (
    SELECT e.nm_estab,
           COUNT(DISTINCT CASE WHEN vd.quantidade < vd.estoque_minimo
                              THEN p.cp_id_produto END) as produtos_criticos,
           COUNT(DISTINCT CASE WHEN r.dt_reposicao > NOW() - INTERVAL ''7 days''
                              THEN f.cp_cod_func END) as funcionarios_ativos_7d,
           COUNT(DISTINCT CASE WHEN fr.preco_venda - fr.preco_compra < 0
                              THEN p.cp_id_produto END) as produtos_prejuizo
    FROM tbl_estabelecimento e
    JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
    JOIN tbl_produto p ON vd.idtbl_produto = p.cp_id_produto
    LEFT JOIN repor r ON p.cp_id_produto = r.idtbl_produto
    LEFT JOIN tbl_funcionario f ON r.idtbl_funcionario = f.cp_cod_func
    JOIN fornecer fr ON p.cp_id_produto = fr.idtbl_produto
    GROUP BY e.nm_estab
) subq');

-- Queries Avançadas (36-45)
INSERT INTO queries_to_run (query_id, query_name, query_type, query_text) VALUES
(36, 'Análise Multidimensional Estoque', 'advanced',
'SELECT COUNT(*) FROM (
    SELECT e.UF_estab,
           p.ce_categoria_principal,
           COUNT(DISTINCT p.cp_id_produto) as total_produtos,
           SUM(CASE WHEN vd.quantidade < vd.estoque_minimo THEN 1 ELSE 0 END) as produtos_criticos,
           AVG(vd.quantidade::float / NULLIF(vd.estoque_minimo, 0)) as media_ocupacao,
           COUNT(DISTINCT f.cp_cod_forn) as total_fornecedores
    FROM tbl_estabelecimento e
    JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
    JOIN tbl_produto p ON vd.idtbl_produto = p.cp_id_produto
    JOIN fornecer fr ON p.cp_id_produto = fr.idtbl_produto
    JOIN tbl_fornecedor f ON fr.idtbl_fornecedor = f.cp_cod_forn
    GROUP BY e.UF_estab, p.ce_categoria_principal
    HAVING COUNT(DISTINCT p.cp_id_produto) > 5
) subq'),

(37, 'Análise Temporal Complexa', 'advanced',
'SELECT COUNT(*) FROM (
    SELECT DATE_TRUNC(''week'', r.dt_reposicao) as semana,
           p.ce_categoria_principal,
           COUNT(*) as total_reposicoes,
           COUNT(DISTINCT p.cp_id_produto) as produtos_distintos,
           COUNT(DISTINCT f.cp_cod_func) as funcionarios_ativos,
           AVG(vd.quantidade::float / NULLIF(vd.estoque_minimo, 0)) as media_ocupacao
    FROM repor r
    JOIN tbl_produto p ON r.idtbl_produto = p.cp_id_produto
    JOIN tbl_funcionario f ON r.idtbl_funcionario = f.cp_cod_func
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    GROUP BY DATE_TRUNC(''week'', r.dt_reposicao), p.ce_categoria_principal
    HAVING COUNT(*) > 3
) subq'),

(38, 'Eficiência Operacional Integrada', 'advanced',
'SELECT COUNT(*) FROM (
    SELECT e.nm_estab,
           COUNT(DISTINCT p.cp_id_produto) as total_produtos,
           COUNT(DISTINCT f.cp_cod_func) as total_funcionarios,
           AVG(fr.preco_venda - fr.preco_compra) as margem_media,
           COUNT(DISTINCT CASE WHEN vd.quantidade < vd.estoque_minimo
                              THEN p.cp_id_produto END)::float /
           NULLIF(COUNT(DISTINCT p.cp_id_produto), 0) * 100 as perc_produtos_criticos,
           COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT f.cp_cod_func), 0) as reposicoes_por_funcionario
    FROM tbl_estabelecimento e
    JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
    JOIN tbl_produto p ON vd.idtbl_produto = p.cp_id_produto
    JOIN fornecer fr ON p.cp_id_produto = fr.idtbl_produto
    LEFT JOIN repor r ON p.cp_id_produto = r.idtbl_produto
    LEFT JOIN tbl_funcionario f ON r.idtbl_funcionario = f.cp_cod_func
    GROUP BY e.nm_estab
    HAVING COUNT(DISTINCT p.cp_id_produto) > 10
) subq'),

(39, 'Análise Cadeia Suprimentos', 'advanced',
'SELECT COUNT(*) FROM (
    SELECT f.UF_forn,
           e.UF_estab,
           COUNT(DISTINCT p.cp_id_produto) as total_produtos,
           AVG(fr.preco_venda - fr.preco_compra) as margem_media,
           COUNT(DISTINCT CASE WHEN vd.quantidade < vd.estoque_minimo
                              THEN p.cp_id_produto END) as produtos_criticos,
           COUNT(DISTINCT p.ce_categoria_principal) as total_categorias,
           AVG(vd.quantidade::float / NULLIF(vd.estoque_minimo, 0)) as media_ocupacao
    FROM tbl_fornecedor f
    JOIN fornecer fr ON f.cp_cod_forn = fr.idtbl_fornecedor
    JOIN tbl_produto p ON fr.idtbl_produto = p.cp_id_produto
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
    GROUP BY f.UF_forn, e.UF_estab
    HAVING COUNT(DISTINCT p.cp_id_produto) > 5
) subq'),

(40, 'Performance Categorias Detalhada', 'advanced',
'SELECT COUNT(*) FROM (
    SELECT c.nm_categoria,
           COUNT(DISTINCT p.cp_id_produto) as total_produtos,
           COUNT(DISTINCT f.cp_cod_forn) as total_fornecedores,
           AVG(fr.preco_venda - fr.preco_compra) as margem_media,
           COUNT(DISTINCT CASE WHEN vd.quantidade < vd.estoque_minimo
                              THEN p.cp_id_produto END) as produtos_criticos,
           COUNT(DISTINCT e.cp_cod_estab) as total_estabelecimentos,
           AVG(vd.quantidade::float / NULLIF(vd.estoque_minimo, 0)) as media_ocupacao
    FROM tbl_categoria c
    JOIN tbl_produto p ON c.cp_cod_categoria = p.ce_categoria_principal
    JOIN fornecer fr ON p.cp_id_produto = fr.idtbl_produto
    JOIN tbl_fornecedor f ON fr.idtbl_fornecedor = f.cp_cod_forn
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
    GROUP BY c.nm_categoria
    HAVING COUNT(DISTINCT p.cp_id_produto) > 5
) subq'),

(41, 'Análise Reposição Complexa', 'advanced',
'SELECT COUNT(*) FROM (
    SELECT f.nm_func,
           COUNT(*) as total_reposicoes,
           COUNT(DISTINCT p.ce_categoria_principal) as categorias_atendidas,
           COUNT(DISTINCT e.cp_cod_estab) as estabelecimentos_atendidos,
           AVG(vd.quantidade::float / NULLIF(vd.estoque_minimo, 0)) as media_ocupacao_pos_reposicao,
           COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT DATE(r.dt_reposicao)), 0) as media_diaria,
           COUNT(DISTINCT CASE WHEN vd.quantidade < vd.estoque_minimo
                              THEN p.cp_id_produto END) as produtos_criticos_atendidos
    FROM tbl_funcionario f
    JOIN repor r ON f.cp_cod_func = r.idtbl_funcionario
    JOIN tbl_produto p ON r.idtbl_produto = p.cp_id_produto
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
    GROUP BY f.nm_func
    HAVING COUNT(DISTINCT DATE(r.dt_reposicao)) >= 5
) subq'),

(42, 'Análise Fornecimento Detalhada', 'advanced',
'SELECT COUNT(*) FROM (
    SELECT f.cnpj_forn,
           COUNT(DISTINCT p.cp_id_produto) as total_produtos,
           COUNT(DISTINCT p.ce_categoria_principal) as total_categorias,
           AVG(fr.preco_venda - fr.preco_compra) as margem_media,
           COUNT(DISTINCT e.UF_estab) as estados_atendidos,
           SUM(CASE WHEN vd.quantidade < vd.estoque_minimo THEN 1 ELSE 0 END) as total_produtos_criticos,
           AVG(vd.quantidade::float / NULLIF(vd.estoque_minimo, 0)) as media_ocupacao
    FROM tbl_fornecedor f
    JOIN fornecer fr ON f.cp_cod_forn = fr.idtbl_fornecedor
    JOIN tbl_produto p ON fr.idtbl_produto = p.cp_id_produto
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    JOIN tbl_estabelecimento e ON vd.idtbl_estabelecimento = e.cp_cod_estab
    GROUP BY f.cnpj_forn
    HAVING COUNT(DISTINCT p.cp_id_produto) > 5
) subq'),

(43, 'Análise Regional Integrada', 'advanced',
'SELECT COUNT(*) FROM (
    SELECT e.UF_estab,
           COUNT(DISTINCT e.cp_cod_estab) as total_estabelecimentos,
           COUNT(DISTINCT p.cp_id_produto) as total_produtos,
           COUNT(DISTINCT f.cp_cod_forn) as total_fornecedores,
           AVG(fr.preco_venda - fr.preco_compra) as margem_media,
           COUNT(DISTINCT CASE WHEN vd.quantidade < vd.estoque_minimo
                              THEN p.cp_id_produto END) as produtos_criticos,
           COUNT(DISTINCT func.cp_cod_func) as total_funcionarios,
           AVG(vd.quantidade::float / NULLIF(vd.estoque_minimo, 0)) as media_ocupacao
    FROM tbl_estabelecimento e
    JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
    JOIN tbl_produto p ON vd.idtbl_produto = p.cp_id_produto
    JOIN fornecer fr ON p.cp_id_produto = fr.idtbl_produto
    JOIN tbl_fornecedor f ON fr.idtbl_fornecedor = f.cp_cod_forn
    LEFT JOIN repor r ON p.cp_id_produto = r.idtbl_produto
    LEFT JOIN tbl_funcionario func ON r.idtbl_funcionario = func.cp_cod_func
    GROUP BY e.UF_estab
) subq'),

(44, 'Análise Temporal Integrada', 'advanced',
'SELECT COUNT(*) FROM (
    SELECT DATE_TRUNC(''month'', r.dt_reposicao) as mes,
           p.ce_categoria_principal,
           COUNT(*) as total_reposicoes,
           COUNT(DISTINCT p.cp_id_produto) as produtos_distintos,
           COUNT(DISTINCT f.cp_cod_func) as funcionarios_ativos,
           AVG(fr.preco_venda - fr.preco_compra) as margem_media,
           COUNT(DISTINCT CASE WHEN vd.quantidade < vd.estoque_minimo
                              THEN p.cp_id_produto END) as produtos_criticos,
           AVG(vd.quantidade::float / NULLIF(vd.estoque_minimo, 0)) as media_ocupacao
    FROM repor r
    JOIN tbl_produto p ON r.idtbl_produto = p.cp_id_produto
    JOIN tbl_funcionario f ON r.idtbl_funcionario = f.cp_cod_func
    JOIN fornecer fr ON p.cp_id_produto = fr.idtbl_produto
    JOIN vender_distribuir vd ON p.cp_id_produto = vd.idtbl_produto
    GROUP BY DATE_TRUNC(''month'', r.dt_reposicao), p.ce_categoria_principal
    HAVING COUNT(*) > 3
) subq'),

(45, 'Análise Eficiência Global', 'advanced',
'SELECT COUNT(*) FROM (
    SELECT e.nm_estab,
           COUNT(DISTINCT p.cp_id_produto) as total_produtos,
           COUNT(DISTINCT f.cp_cod_forn) as total_fornecedores,
           COUNT(DISTINCT func.cp_cod_func) as total_funcionarios,
           AVG(fr.preco_venda - fr.preco_compra) as margem_media,
           COUNT(DISTINCT CASE WHEN vd.quantidade < vd.estoque_minimo
                              THEN p.cp_id_produto END) as produtos_criticos,
           COUNT(DISTINCT p.ce_categoria_principal) as total_categorias,
           AVG(vd.quantidade::float / NULLIF(vd.estoque_minimo, 0)) as media_ocupacao,
           COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT func.cp_cod_func), 0) as reposicoes_por_funcionario
    FROM tbl_estabelecimento e
    JOIN vender_distribuir vd ON e.cp_cod_estab = vd.idtbl_estabelecimento
    JOIN tbl_produto p ON vd.idtbl_produto = p.cp_id_produto
    JOIN fornecer fr ON p.cp_id_produto = fr.idtbl_produto
    JOIN tbl_fornecedor f ON fr.idtbl_fornecedor = f.cp_cod_forn
    LEFT JOIN repor r ON p.cp_id_produto = r.idtbl_produto
    LEFT JOIN tbl_funcionario func ON r.idtbl_funcionario = func.cp_cod_func
    GROUP BY e.nm_estab
    HAVING COUNT(DISTINCT p.cp_id_produto) > 10
) subq');


-- Executar o teste
SELECT run_performance_test();

-- Visualizar resultados
SELECT
    query_id,
    query_name,
    query_type,
    COUNT(*) as total_runs,
    ROUND(AVG(execution_time)::numeric, 2) as avg_time_ms,
    ROUND(MIN(execution_time)::numeric, 2) as min_time_ms,
    ROUND(MAX(execution_time)::numeric, 2) as max_time_ms,
    ROUND(stddev(execution_time)::numeric, 2) as stddev_ms
FROM baseline_results
GROUP BY query_id, query_name, query_type
ORDER BY query_id;

-- Criar tabela baseline_data com os resultados do primeiro teste
-- Criar baseline_data direto da query de resultados
CREATE TABLE baseline_data AS
SELECT
    query_id::text,
    query_name,
    query_type,
    ROUND(AVG(execution_time)::numeric, 2) as avg_time_ms
FROM baseline_results
GROUP BY query_id, query_name, query_type
ORDER BY query_id;
```

Execução de 45 queries, 50 vezes cada, com coleta de tempos:

| Query ID | Nome                             | Tipo         | Média (ms) | Mínimo (ms) | Máximo (ms) | Desvio Padrão |
| -------- | -------------------------------- | ------------ | ---------- | ----------- | ----------- | ------------- |
| 1        | Produtos com Estoque Crítico     | basic        | 0.95       | 0.77        | 4.74        | 0.56          |
| 2        | Estabelecimentos Críticos        | basic        | 0.22       | 0.19        | 0.66        | 0.07          |
| 3        | Preço Médio por Categoria        | basic        | 0.38       | 0.33        | 0.73        | 0.06          |
| 4        | Funcionários por Estabelecimento | basic        | 0.71       | 0.47        | 8.74        | 1.17          |
| 5        | Produtos sem Reposição           | basic        | 0.28       | 0.25        | 0.33        | 0.02          |
| 6        | Ranking Estabelecimentos         | basic        | 0.27       | 0.24        | 0.36        | 0.03          |
| 7        | Variação de Preços               | basic        | 0.28       | 0.24        | 0.54        | 0.05          |
| 8        | Reposições por Dia               | basic        | 0.12       | 0.09        | 0.46        | 0.05          |
| 9        | Margem de Segurança              | basic        | 0.24       | 0.21        | 0.42        | 0.04          |
| 10       | Volume por Fornecedor            | basic        | 0.67       | 0.36        | 12.70       | 1.74          |
| 11       | Distribuição Regional            | basic        | 0.37       | 0.33        | 0.53        | 0.05          |
| 12       | Produtos Críticos Multi-Estab.   | basic        | 0.34       | 0.29        | 0.50        | 0.05          |
| 13       | Performance Fornecedores         | basic        | 0.47       | 0.38        | 0.59        | 0.04          |
| 14       | Estoque Crítico Categorias       | basic        | 0.57       | 0.25        | 12.56       | 1.73          |
| 15       | Especialização Funcionários      | basic        | 0.39       | 0.34        | 0.53        | 0.05          |
| 16       | Fornecedores por Região          | basic        | 0.27       | 0.22        | 0.36        | 0.04          |
| 17       | Produtos Alta Rotatividade       | basic        | 0.27       | 0.23        | 0.36        | 0.04          |
| 18       | Estabelecimentos Eficientes      | basic        | 0.31       | 0.25        | 0.45        | 0.04          |
| 19       | Categorias Lucrativas            | basic        | 0.78       | 0.44        | 12.96       | 1.76          |
| 20       | Funcionários Produtivos          | basic        | 0.95       | 0.63        | 1.36        | 0.25          |
| 21       | Análise Temporal Reposições      | intermediate | 0.72       | 0.35        | 12.75       | 1.74          |
| 22       | Eficiência Fornecedores          | intermediate | 0.62       | 0.52        | 0.82        | 0.06          |
| 23       | Análise Regional Estab.          | intermediate | 0.41       | 0.36        | 0.52        | 0.03          |
| 24       | Produtos Sem Movimento           | intermediate | 0.35       | 0.31        | 0.80        | 0.07          |
| 25       | Análise Categorias Críticas      | intermediate | 0.92       | 0.58        | 12.94       | 1.74          |
| 26       | Performance Funcionários         | intermediate | 1.07       | 0.76        | 1.54        | 0.29          |
| 27       | Análise Fornecimento Regional    | intermediate | 1.52       | 0.85        | 22.42       | 3.02          |
| 28       | Diversidade Produtos             | intermediate | 1.22       | 0.86        | 13.06       | 1.71          |
| 29       | Análise Preços Regionais         | intermediate | 0.71       | 0.65        | 0.86        | 0.04          |
| 30       | Eficiência Estabelecimentos      | intermediate | 0.60       | 0.51        | 0.70        | 0.03          |
| 31       | Sazonalidade Reposições          | intermediate | 0.52       | 0.30        | 8.49        | 1.15          |
| 32       | Correlação Preço-Demanda         | intermediate | 0.49       | 0.45        | 0.61        | 0.03          |
| 33       | Eficiência Cadeia Fornecimento   | intermediate | 0.95       | 0.84        | 1.10        | 0.05          |
| 34       | Análise Complexidade Operacional | intermediate | 1.39       | 1.17        | 5.51        | 0.60          |
| 35       | Análise Gargalos Operacionais    | intermediate | 1.13       | 0.84        | 9.21        | 1.17          |
| 36       | Análise Multidimensional Estoque | advanced     | 1.12       | 1.00        | 1.63        | 0.12          |
| 37       | Análise Temporal Complexa        | advanced     | 0.96       | 0.65        | 12.84       | 1.72          |
| 38       | Eficiência Operacional Integrada | advanced     | 1.63       | 1.12        | 13.48       | 1.73          |
| 39       | Análise Cadeia Suprimentos       | advanced     | 1.18       | 1.03        | 1.82        | 0.12          |
| 40       | Performance Categorias Detalhada | advanced     | 1.64       | 1.25        | 13.62       | 1.73          |
| 41       | Análise Reposição Complexa       | advanced     | 1.37       | 1.09        | 9.68        | 1.20          |
| 42       | Análise Fornecimento Detalhada   | advanced     | 1.06       | 0.99        | 1.75        | 0.12          |
| 43       | Análise Regional Integrada       | advanced     | 1.67       | 1.15        | 13.95       | 1.80          |
| 44       | Análise Temporal Integrada       | advanced     | 1.52       | 1.16        | 13.44       | 1.72          |
| 45       | Análise Eficiência Global        | advanced     | 2.00       | 1.57        | 14.61       | 1.83          |

### 2.2 Resumo do Baseline

- **Queries Básicas (1-20)**: Média geral de 0.43ms
- **Queries Intermediárias (21-35)**: Média geral de 0.84ms
- **Queries Avançadas (36-45)**: Média geral de 1.42ms

## 3. Plano de Indexação

### 3.1. Primeiro, vamos criar os índices iniciais:

```sql
-- Índices para melhorar performance
CREATE INDEX idx_vd_estoque ON vender_distribuir (quantidade, estoque_minimo);
CREATE INDEX idx_produto_categoria ON tbl_produto (ce_categoria_principal);
CREATE INDEX idx_fornecer_fornecedor ON fornecer (idtbl_fornecedor);
CREATE INDEX idx_repor_data_produto ON repor (dt_reposicao, idtbl_produto);
CREATE INDEX idx_repor_func_data ON repor (idtbl_funcionario, dt_reposicao);
```

### 3.2 Coleta de Tempos de Execução

```sql
CREATE OR REPLACE FUNCTION run_performance_test_with_indexes()
RETURNS void AS $$
DECLARE
    q RECORD;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    duration FLOAT;
    run INT;
BEGIN
    FOR q IN SELECT * FROM queries_to_run ORDER BY query_id LOOP
        FOR run IN 1..50 LOOP
            start_time := clock_timestamp();
            EXECUTE q.query_text;
            end_time := clock_timestamp();

            duration := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
            INSERT INTO performance_results (query_id, run_number, execution_time)
            VALUES (q.query_id, run, duration);
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Criar tabela performance_results com colunas mínimas
CREATE TABLE performance_results (
    query_id text,
    run_number integer,
    execution_time numeric,
    PRIMARY KEY (query_id, run_number)
);

-- Limpar resultados anteriores
TRUNCATE TABLE baseline_results;
TRUNCATE TABLE performance_results;

-- Executar os testes
SELECT run_performance_test_with_indexes();

-- Resultados
-- Agora podemos ver os resultados com speedup
SELECT
    r.query_id,
    q.query_name,
    q.query_type,
    COUNT(*) as total_runs,
    AVG(r.execution_time)::numeric(10,2) as avg_time_ms,
    MIN(r.execution_time)::numeric(10,2) as min_time_ms,
    MAX(r.execution_time)::numeric(10,2) as max_time_ms,
    stddev(r.execution_time)::numeric(10,2) as stddev_ms,
    (b.avg_time_ms / AVG(r.execution_time))::numeric(10,2) as speedup
FROM performance_results r
JOIN queries_to_run q ON r.query_id = q.query_id::text
JOIN baseline_data b ON b.query_id = r.query_id
GROUP BY r.query_id, q.query_name, q.query_type, b.avg_time_ms
ORDER BY r.query_id::int;
```

### 3.3. Resultados

### 3.3 Planilha de Melhoria de Desempenho (Speedup)

[Tabela com comparativo e speedup será adicionada após execução]

## 4. Plano de Tuning

[Em desenvolvimento]

## 3. Análise de Desempenho com Índices

### 3.1 Planilha de Melhoria de Desempenho (Speedup)

| Query ID | Nome                             | Tipo  | Média Original (ms) | Média com Índices (ms) | Speedup | Impacto      |
| -------- | -------------------------------- | ----- | ------------------- | ---------------------- | ------- | ------------ |
| 11       | Distribuição Regional            | basic | 0.74                | 0.36                   | 2.06    | ⬆️ Excelente |
| 14       | Estoque Crítico                  | basic | 0.54                | 0.40                   | 1.36    | ⬆️ Muito Bom |
| 12       | Produtos Críticos                | basic | 0.46                | 0.35                   | 1.30    | ⬆️ Bom       |
| 5        | Produtos sem Reposição           | basic | 0.38                | 0.30                   | 1.27    | ⬆️ Bom       |
| 13       | Performance Fornecedores         | basic | 0.50                | 0.42                   | 1.18    | ⬆️ Positivo  |
| 7        | Variação de Preços               | basic | 0.29                | 0.27                   | 1.09    | ⬆️ Leve      |
| 9        | Margem de Segurança              | basic | 0.26                | 0.24                   | 1.09    | ⬆️ Leve      |
| 3        | Preço Médio por Categoria        | basic | 0.42                | 0.39                   | 1.08    | ⬆️ Leve      |
| 6        | Ranking Estabelecimentos         | basic | 0.29                | 0.28                   | 1.05    | ⬆️ Leve      |
| 17       | Produtos Alta Rotatividade       | basic | 0.30                | 0.29                   | 1.05    | ⬆️ Leve      |
| 18       | Estabelecimentos Eficientes      | basic | 0.83                | 0.81                   | 1.03    | ⬆️ Leve      |
| 4        | Funcionários por Estabelecimento | basic | 0.56                | 0.54                   | 1.03    | ⬆️ Leve      |
| 2        | Estabelecimentos Críticos        | basic | 0.22                | 0.22                   | 1.01    | ➡️ Neutro    |
| 8        | Reposições por Dia               | basic | 0.11                | 0.11                   | 1.01    | ➡️ Neutro    |
| 15       | Especialização Funcionários      | basic | 0.49                | 0.50                   | 0.99    | ⬇️ Leve      |
| 16       | Fornecedores por Região          | basic | 0.30                | 0.32                   | 0.95    | ⬇️ Leve      |
| 1        | Produtos com Estoque Crítico     | basic | 0.84                | 0.94                   | 0.89    | ⬇️ Moderado  |
| 10       | Volume por Fornecedor            | basic | 0.45                | 0.51                   | 0.89    | ⬇️ Moderado  |

### 3.2 Análise dos Resultados

1. **Melhorias Significativas**:

   - Query 11: Melhoria de 106% (2.06x mais rápido)
   - Query 14: Melhoria de 36% (1.36x mais rápido)
   - Query 12: Melhoria de 30% (1.30x mais rápido)
   - Query 5: Melhoria de 27% (1.27x mais rápido)

2. **Impactos Negativos**:

   - Query 1: Degradação de 11% (0.89x mais lento)
   - Query 10: Degradação de 11% (0.89x mais lento)
   - Nenhuma query teve degradação crítica (> 20%)

3. **Efetividade dos Índices**:

   - `idx_vd_estoque`: Manteve efetividade para queries de estoque
   - `idx_produto_categoria`: Bom desempenho em queries de categorização
   - `idx_repor_func_data`: Melhorou significativamente queries de funcionários
   - `idx_fornecer_fornecedor`: Performance estável

4. **Recomendações**:
   - Manter o novo índice composto `idx_repor_func_data`
   - Considerar otimização adicional para Queries 1 e 10
   - Monitorar o desempenho das queries neutras para futuras otimizações
   - O novo conjunto de índices está mais balanceado, sem impactos negativos críticos
