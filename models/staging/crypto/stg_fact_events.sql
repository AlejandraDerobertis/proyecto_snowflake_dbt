{{ config( materialized='view' ) }}

WITH cleaned_data AS (
    SELECT
        CONCAT(TRIM(SOURCE), '_', CAST (DATE AS VARCHAR)) AS ID_EVENTS,
        TRIM(SOURCE) AS source,
        TRIM(EVENT) AS event,
        TRIM(SENTIMENT) AS sentiment,
        CAST(SCORE AS FLOAT) AS score,
        CAST(DATE AS DATE) AS event_date
    FROM {{ source('crypto', 'crypto_events') }}
)
SELECT *
FROM cleaned_data
