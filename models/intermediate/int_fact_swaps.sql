{{ config(materialized='view') }}

SELECT
    TRIM(t.TRANSACTION_HASH) AS hash,
    n.network_id AS network_id,
    t.FROM_TOKEN_CONTRACT as from_token,
    t.TO_TOKEN_CONTRACT as to_token,
    t.FROM_ADDRESS as from_address,
    t.TO_ADDRESS as to_address,
    t.FROM_QUANTITY as from_quantity,
    t.TO_QUANTITY as to_quantity,
    t.GAS_COST as gas_cost,
    t.date_id as date_id,
    t.time_id as time_id
    
FROM {{ ref('stg_fact_transactions') }} AS t
INNER JOIN {{ ref('stg_dim_networks') }} AS n ON n.network_code = t.NETWORK_CODE
WHERE HASH IS NOT NULL AND TRANSACTION_TYPE = 'S'
