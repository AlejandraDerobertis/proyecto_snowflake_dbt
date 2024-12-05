{{ config(materialized='view') }}

WITH swaps_base AS (
    SELECT
        date_id,
        time_id,
        'S' AS transaction_type,
        COUNT(hash) AS total_transactions,          -- Total de swaps
        SUM(to_quantity) AS total_volume           -- Volumen total basado en 'to_quantity'
    FROM {{ ref('int_fact_swaps') }}
    GROUP BY date_id, time_id
),

transactions_base AS (
    SELECT
        date_id,
        time_id,
        'T' AS transaction_type,
        COUNT(hash) AS total_transactions,         -- Total de transacciones normales
        SUM(quantity) AS total_volume              -- Volumen total basado en 'quantity'
    FROM {{ ref('int_fact_transactions') }}
    GROUP BY date_id, time_id
)

SELECT *
FROM (
    SELECT
        date_id,
        time_id,
        transaction_type,
        total_transactions,
        total_volume
    FROM swaps_base
    UNION ALL
    SELECT
        date_id,
        time_id,
        transaction_type,
        total_transactions,
        total_volume
    FROM transactions_base
) AS combined_data




