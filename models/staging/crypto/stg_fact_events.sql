{{ config( materialized='view' ) }}

WITH cleaned_data AS (
    SELECT
        CONCAT(TRIM(SOURCE), '_', CAST (DATE AS VARCHAR)) AS ID_EVENTS,
        TRIM(SOURCE) AS source,
        TRIM(EVENT) AS event,
        TRIM(SENTIMENT) AS sentiment,
        CAST(SCORE AS FLOAT) AS score,
        CAST(DATE AS DATE) AS event_date,
        CAST(DATE AS TIME) AS event_time
    FROM {{ source('crypto', 'crypto_events') }}
    
),
mapped_events AS (
    SELECT 
        id_events,
        source,
        event,
        sentiment,
        score,
        dates.date_id,
        times.time_id
    FROM cleaned_data
    LEFT JOIN {{ ref('stg_dim_dates') }} AS dates
        ON cleaned_data.event_date = dates.date 
    LEFT JOIN {{ ref('stg_dim_times') }} AS times
        ON CAST(SUBSTR(CAST(cleaned_data.event_time AS STRING), 1, 8) AS TIME) = times.time 
)
SELECT *
FROM mapped_events
