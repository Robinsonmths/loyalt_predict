-- curioso -> idade < 7
-- fiel -> recência < 7 e recência anterior < 15
-- turista -> 7 <= recência <= 14
-- desencantado -> 14 < recência <= 28
-- zumbi -> recência > 28
-- reconquistado -> recência < 7 e 14 <= recencia anterior <= 28
-- reborn -> recência < 7 e recencia anterior > 28
WITH
    -- 1. CTE para isolar e limpar as datas
    tb_daily AS (
        SELECT DISTINCT
            IdCliente,
            substr (DtCriacao, 0, 11) AS dtDia -- Extrai apenas a parte da data
        FROM
            transacoes
        WHERE
            DtCriacao <= '{date}'
    ),
    tb_idade AS (
        SELECT
            IdCliente,
            CAST(
                MAX(julianday ('{date}') - julianday (dtDia)) AS INT
            ) AS qtdeDiasPrimTransacao,
            CAST(
                MIN(julianday ('{date}') - julianday (dtDia)) AS INT
            ) AS qtdeDiasUltTransacao
        FROM
            tb_daily
        GROUP BY
            IdCliente
    ),
    tb_rn AS (
        -- 4. CTE para numerar e ordenar os dias de transação de cada cliente
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY
                    IdCliente
                ORDER BY
                    dtDia DESC
            ) AS rnDia
        FROM
            tb_daily
    ),
    tb_penultima_ativacao AS (
        SELECT
            *,
            CAST(julianday ('{date}') - julianday (dtDia) AS INT) AS qtdeDiasPenultimaAtivacao
        FROM
            tb_rn
        WHERE
            rnDia = 2
    ),
    tb_lifeCycle AS (
        SELECT
            t1.*,
            t2.qtdeDiasPenultimaAtivacao,
            -- Classificação de clientes com precedência correta
            CASE
            -- Clientes inativos a mais de 28 dias
                WHEN t1.qtdeDiasUltTransacao > 28 THEN '05-Zumbi'
                -- Clientes em faixas intermediárias de recência
                WHEN t1.qtdeDiasUltTransacao > 14
                AND t1.qtdeDiasUltTransacao <= 28 THEN '04-Desencantado'
                WHEN t1.qtdeDiasUltTransacao >= 7
                AND t1.qtdeDiasUltTransacao <= 14 THEN '03-Turista'
                -- Clientes ativos nos últimos 7 dias (com histórico de penúltima compra)
                WHEN t1.qtdeDiasUltTransacao < 7
                AND t2.qtdeDiasPenultimaAtivacao > 28 THEN '07-Reborn'
                WHEN t1.qtdeDiasUltTransacao < 7
                AND t2.qtdeDiasPenultimaAtivacao >= 14
                AND t2.qtdeDiasPenultimaAtivacao <= 28 THEN '06-Reconquistado'
                WHEN t1.qtdeDiasUltTransacao < 7
                AND t2.qtdeDiasPenultimaAtivacao < 15 THEN '02-Fiel'
                -- Novos clientes (Primeira compra há menos de 7 dias)
                WHEN t1.qtdeDiasPrimTransacao < 7 THEN '01-Curioso'
                ELSE '08-Outros'
            END AS descLifeCycle
        FROM
            tb_idade AS t1
            LEFT JOIN tb_penultima_ativacao AS t2 ON t1.IdCliente = t2.IdCliente
    )
SELECT
    date ('{date}', '-1 day') AS dtRef,
    *
FROM
    tb_lifeCycle;

-- SELECT
--     descLifeCycle,
--     COUNT(*) AS qtdClientes
-- FROM
--     tb_lifeCycle
-- GROUP BY
--     descLifeCycle
-- ORDER BY
--     descLifeCycle;