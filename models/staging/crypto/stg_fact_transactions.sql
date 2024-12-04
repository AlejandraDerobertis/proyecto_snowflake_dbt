{{ config(materialized='view') }}

WITH transactions_base AS (
    SELECT DISTINCT
        TRIM(HASH) AS transaction_hash,                    
        CASE 
            WHEN TRANSACTION_TYPE = 0 THEN 'T' 
            WHEN TRANSACTION_TYPE = 1 THEN 'S' 
            ELSE NULL 
        END AS transaction_type,
        CAST(TRIM(NETWORK) AS VARCHAR(255)) AS network_code,
        CASE 
            WHEN TRANSACTION_TYPE = 0 THEN CAST(TRIM(TOKEN) AS VARCHAR(255)) 
            ELSE NULL 
        END AS token_contract,
        CASE 
            WHEN TRANSACTION_TYPE = 0 THEN CAST(QUANTITY AS FLOAT) 
            ELSE NULL 
        END AS quantity,
        CASE 
            WHEN TRANSACTION_TYPE = 1 THEN CAST(TRIM(FROM_TOKEN) AS VARCHAR(255)) 
            ELSE NULL 
        END AS from_token_contract,
        CASE 
            WHEN TRANSACTION_TYPE = 1 THEN CAST(TRIM(TO_TOKEN) AS VARCHAR(255)) 
            ELSE NULL 
        END AS to_token_contract,
        CASE 
            WHEN TRANSACTION_TYPE = 1 THEN CAST(FROM_QUANTITY AS FLOAT) 
            ELSE NULL 
        END AS from_quantity,
        CASE 
            WHEN TRANSACTION_TYPE = 1 THEN CAST(TO_QUANTITY AS FLOAT) 
            ELSE NULL 
        END AS to_quantity,
        TRIM(FROM_ADDRESS) AS from_address,
        TRIM(TO_ADDRESS) AS to_address,
        TO_DATE(CAST(DATE AS STRING), 'YYYYMMDD') AS transaction_date, 
        CAST(TIME AS TIME) AS transaction_time,
        CAST(GAS AS FLOAT) AS gas_cost
    FROM {{ source('crypto', 'crypto_transactions') }}
    WHERE HASH IS NOT NULL
),

mapped_transactions AS (
    SELECT
        transaction_hash,
        transaction_type,
        network_code,
        token_contract,
        quantity,
        from_token_contract,
        to_token_contract,
        from_quantity,
        to_quantity,
        from_address,
        to_address,
        transaction_date,
        transaction_time,
        gas_cost,
        dates.date_id,
        times.time_id
    FROM transactions_base
    LEFT JOIN {{ ref('stg_dim_dates') }} AS dates
        ON transactions_base.transaction_date = dates.date
    LEFT JOIN {{ ref('stg_dim_times') }} AS times
       ON CAST(SUBSTR(CAST(transactions_base.transaction_time AS STRING), 1, 8) AS TIME) = times.time
)

SELECT *
FROM mapped_transactions
