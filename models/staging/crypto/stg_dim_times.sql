{{ config(materialized='view') }}

WITH unique_times AS (
    SELECT DISTINCT
        CAST(TIME AS TIME) AS raw_time
    FROM {{ source('crypto', 'crypto_transactions') }}
),

transformed_times AS (
    SELECT
        CAST(
            EXTRACT(HOUR FROM raw_time) * 10000 +  -- HH
            EXTRACT(MINUTE FROM raw_time) * 100 +  -- MM
            EXTRACT(SECOND FROM raw_time) AS INT   -- SS
        ) AS time_id,           -- id(HHMMSS)
        raw_time AS time,       
        EXTRACT(HOUR FROM raw_time) AS hour,      -- Extrae hora directamente
        EXTRACT(MINUTE FROM raw_time) AS minute,  -- Extrae minuto directamente
        EXTRACT(SECOND FROM raw_time) AS second   -- Extrae segundo directamente
    FROM unique_times
)

SELECT *
FROM transformed_times
