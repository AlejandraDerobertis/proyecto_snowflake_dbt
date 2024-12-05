{{ config(materialized='incremental') }}

WITH base_metrics AS (
    SELECT *
    FROM {{ ref('int_networks_usage_metrics') }} 
),

most_used_network AS (
    SELECT
        network_id,
        network_name,
        network_code,
        total_transactions,
        total_volume_network,
        RANK() OVER (ORDER BY total_transactions DESC) AS transaction_rank,  
        RANK() OVER (ORDER BY total_volume_network DESC) AS volume_rank              
    FROM base_metrics
)

SELECT *
FROM most_used_network
WHERE transaction_rank <= 3 OR volume_rank <= 1  --las 3 redes más utilizadas
{% if is_incremental() %}
AND network_id > (SELECT MAX(network_id) FROM {{ this }})
{% endif %}
