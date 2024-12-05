{{ config(materialized='view') }}

SELECT
    TRIM(t.TRANSACTION_HASH) AS hash,
    n.network_id AS network_id,
    t.TOKEN_CONTRACT as token,
    t.FROM_ADDRESS as from_address,
    t.TO_ADDRESS as to_address,
    t.QUANTITY as quantity,
    t.GAS_COST as gas_cost,
    t.date_id as date_id,
    t.time_id as time_id
    
FROM {{ ref('stg_fact_transactions') }} AS t
INNER JOIN {{ ref('stg_dim_networks') }} AS n ON n.network_code = t.NETWORK_CODE
WHERE HASH IS NOT NULL AND TRANSACTION_TYPE = 'T'


