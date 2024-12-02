{{ config(materialized='view') }}

WITH tokens_base AS (
    SELECT DISTINCT
        CAST(TRIM(SYMBOL) AS VARCHAR(255)) AS token_symbol,
        CAST(INITCAP(TRIM(NAME)) AS VARCHAR(255)) AS token_name,
        CAST(TRIM(CONTRACT) AS VARCHAR(255)) AS contract_address,
        CAST(TRIM(NETWORK) AS VARCHAR(255)) AS network_code 
    FROM {{ source('crypto', 'crypto_tokens') }}
    WHERE SYMBOL IS NOT NULL AND LEN(SYMBOL)>0
      AND NETWORK IS NOT NULL AND LEN(NETWORK)>0
),

mapped_tokens AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY token_symbol) AS token_id, 
        token_symbol,
        token_name,
        contract_address,
        tokens_base.network_code,
        networks.network_id AS network_id
        FROM tokens_base
    INNER JOIN {{ ref('stg_dim_networks') }} AS networks
    ON tokens_base.network_code = networks.network_code
)

SELECT *
FROM mapped_tokens
