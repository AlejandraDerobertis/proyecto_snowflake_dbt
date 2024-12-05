{{ config(materialized='view') }}

WITH transactions_base AS (
    SELECT
        t.network_code,                                 
        COUNT(t.transaction_hash) AS total_transactions, 
        SUM(t.quantity) AS total_volume_network 
    FROM {{ ref('stg_fact_transactions') }} AS t
    WHERE t.network_code IS NOT NULL
    GROUP BY t.network_code
),

joined_networks AS (
    SELECT
        n.network_id,
        n.network_name,
        tb.network_code,
        tb.total_transactions,
        tb.total_volume_network
    FROM transactions_base AS tb
    INNER JOIN {{ ref('stg_dim_networks') }} AS n
        ON tb.network_code = n.network_code
)

SELECT
    network_id,
    network_name,
    network_code,
    total_transactions,
    total_volume_network
FROM joined_networks
