{{ config(materialized='view') }}

WITH unique_networks AS (
    SELECT DISTINCT
        TRIM(CODE) AS network_code,
        INITCAP(TRIM(NAME)) AS network_name,
        TRIM(EXPLORER) AS explorer_url,
        CASE 
            WHEN HEX_ID IS NOT NULL THEN CAST(HEX_ID AS INT) 
            ELSE NULL 
        END AS hex_id,
        TRIM(RPC_URL) AS rpc_url,
        INITCAP(TRIM(BLOCKCHAIN_TYPE)) AS blockchain_type 
    FROM {{ source('crypto', 'crypto_redes') }}
),

transformed_networks AS (
    SELECT
        MD5(CONCAT(
        TRIM(network_code), 
        INITCAP(TRIM(network_name)),  
        TRIM(RPC_URL), 
        INITCAP(TRIM(BLOCKCHAIN_TYPE))
        )) AS network_id,  -- ID determinístico
        network_code,
        network_name,
        explorer_url,
        hex_id,
        rpc_url,
        blockchain_type
    FROM unique_networks
)

SELECT *
FROM transformed_networks
