{{ config(materialized='view') }}

-- Métricas para transacciones 'T' (transactions)
WITH transactions_metrics AS (
    SELECT
        t.token AS token_symbol,
        COUNT(t.hash) AS total_transactions,
        SUM(t.quantity) AS total_volume,
        'T' AS transaction_type
    FROM {{ ref('int_fact_transactions') }} AS t
    WHERE t.token IS NOT NULL
    GROUP BY t.token
),

-- Métricas para transacciones 'S' (swaps)
swaps_metrics AS (
    SELECT
        s.from_token AS token_symbol,
        COUNT(s.hash) AS total_transactions,
        SUM(s.from_quantity) AS total_volume,
        'S' AS transaction_type
    FROM {{ ref('int_fact_swaps') }} AS s
    WHERE s.from_token IS NOT NULL
    GROUP BY s.from_token
),

-- Unión de ambas métricas
combined_metrics AS (
    SELECT * FROM transactions_metrics
    UNION ALL
    SELECT * FROM swaps_metrics
)

SELECT
    token_symbol,
    transaction_type,
    SUM(total_transactions) AS total_transactions,
    SUM(total_volume) AS total_volume
FROM combined_metrics
GROUP BY token_symbol, transaction_type
