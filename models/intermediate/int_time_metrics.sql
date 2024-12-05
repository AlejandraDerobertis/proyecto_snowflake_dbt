{{ config(materialized='view') }}

WITH base_transactions AS (
    SELECT
        t.date_id,
        t.time_id,
        COUNT(t.transaction_hash) AS total_transactions,  -- Número total de transacciones
        SUM(t.quantity) AS total_volume                  -- Volumen total
    FROM {{ ref('stg_fact_transactions') }} AS t
    WHERE t.transaction_hash IS NOT NULL
    GROUP BY t.date_id, t.time_id
),

joined_dimensions AS (
    SELECT
        bt.date_id,
        bt.time_id,
        d.date,
        t.time,
        bt.total_transactions,
        bt.total_volume
    FROM base_transactions AS bt
    LEFT JOIN {{ ref('stg_dim_dates') }} AS d
        ON bt.date_id = d.date_id
    LEFT JOIN {{ ref('stg_dim_times') }} AS t
        ON bt.time_id = t.time_id
)

SELECT
    date_id,
    time_id,
    date,
    time,
    total_transactions,
    total_volume
FROM joined_dimensions
