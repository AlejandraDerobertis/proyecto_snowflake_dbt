{{ config(materialized='incremental') }}

WITH base_metrics AS (
    SELECT *
    FROM {{ ref('int_time_transactions_metrics') }} 
),

ranked_metrics AS (
    SELECT
        d.date,
        t.time,
        bm.transaction_type,
        bm.total_transactions,
        bm.total_volume,
        RANK() OVER (PARTITION BY bm.transaction_type ORDER BY bm.total_transactions DESC) AS transaction_rank,  -- Ranking por transacciones
        RANK() OVER (PARTITION BY bm.transaction_type ORDER BY bm.total_volume DESC) AS volume_rank               -- Ranking por volumen
    FROM base_metrics AS bm
    LEFT JOIN {{ ref('stg_dim_dates') }} AS d ON bm.date_id = d.date_id
    LEFT JOIN {{ ref('stg_dim_times') }} AS t ON bm.time_id = t.time_id
)

SELECT *
FROM ranked_metrics
WHERE transaction_rank <= 5 OR volume_rank <= 5  -- Top 3 días/horas más activos por tipo de transacción
{% if is_incremental() %}
AND date > (SELECT MAX(date) FROM {{ this }})
{% endif %}
