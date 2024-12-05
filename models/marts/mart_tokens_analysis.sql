{{ config(materialized='incremental') }}

WITH base_metrics AS (
    SELECT *
    FROM {{ ref('int_tokens_usage_metrics') }} 
),

ranked_tokens AS (
    SELECT
        token_symbol,
        transaction_type,
        total_transactions,
        total_volume,
        RANK() OVER (PARTITION BY transaction_type ORDER BY total_transactions DESC) AS transaction_rank,  
        RANK() OVER (PARTITION BY transaction_type ORDER BY total_volume DESC) AS volume_rank              
    FROM base_metrics
)

SELECT *
FROM ranked_tokens
WHERE transaction_rank <= 3 OR volume_rank <= 3  -- Las 3 monedas más usadas por tipo de transacción
{% if is_incremental() %}
AND token_symbol > (SELECT MAX(token_symbol) FROM {{ this }})
{% endif %}
