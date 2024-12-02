{{ config(materialized='view') }}

WITH live_data_base AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY prices.ID, prices.INGEST_TIMESTAMP) AS id,
        CAST(TRIM(prices.SYMBOL) AS VARCHAR(256)) AS symbol, 
        CAST(TRIM(prices.NAME) AS VARCHAR(256)) AS token_name,
        CAST(prices.CURRENT_PRICE AS FLOAT) AS price,          -- Precio actual
        CAST(prices.MARKET_CAP AS FLOAT) AS market_capitalization, -- Capitalización de mercado
        CAST(prices.TOTAL_VOLUMES AS FLOAT) AS circulating_supply, -- Volumen circulante
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
        live_data_base.price,
        live_data_base.market_capitalization,
        live_data_base.circulating_supply,
        dates.date_id,        -- Mapeamos la dimensión de fechas
        times.time_id         -- Mapeamos la dimensión de tiempos
    FROM live_data_base
    LEFT JOIN {{ ref('stg_dim_dates') }} AS dates
        ON live_data_base.live_date = dates.date
    LEFT JOIN {{ ref('stg_dim_times') }} AS times
        ON live_data_base.live_time = times.time
)

SELECT *
FROM mapped_data
