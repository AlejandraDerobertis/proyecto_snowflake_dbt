{{ config(materialized='view') }}

WITH live_data_base AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY prices.ID, prices.INGEST_TIMESTAMP) AS id,
        CAST(TRIM(prices.SYMBOL) AS VARCHAR(256)) AS symbol, 
        CAST(TRIM(prices.NAME) AS VARCHAR(256)) AS token_name,
        CAST(prices.CURRENT_PRICE AS FLOAT) AS price_usd,          -- Precio actual
        CAST(prices.MARKET_CAP AS FLOAT) AS market_capitalization, -- Capitalización de mercado
        CAST(DATE(prices.INGEST_TIMESTAMP) AS DATE) AS live_date,  
        CAST(TIME(prices.INGEST_TIMESTAMP) AS TIME) AS live_time   
    FROM {{ source('crypto', 'crypto_prices') }} AS prices
    WHERE prices.CURRENT_PRICE IS NOT NULL 
),

mapped_data AS (
    SELECT
        live_data_base.id,
        live_data_base.symbol,
        live_data_base.token_name,
        live_data_base.price_usd,
        live_data_base.market_capitalization,
        (live_data_base.market_capitalization / live_data_base.price_usd) as circulating_supply,
        dates.date_id,
        times.time_id
    FROM live_data_base
    LEFT JOIN {{ ref('stg_dim_dates') }} AS dates
        ON live_data_base.live_date = dates.date
    LEFT JOIN {{ ref('stg_dim_times') }} AS times
        ON CAST(SUBSTR(CAST(live_data_base.live_time AS STRING), 1, 8) AS TIME) = times.time
)

SELECT *
FROM mapped_data
