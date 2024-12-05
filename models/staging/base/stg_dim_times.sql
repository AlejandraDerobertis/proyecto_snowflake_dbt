{{ config(  materialized='table',
            schema='core'
) }}

WITH base_times AS (
    SELECT
        time_id,
        time AS TIME,
        CAST(hour AS INT) AS hour,
        CAST(minute AS INT) AS minute,
        CAST(second AS INT) AS second
    FROM {{ source('crypto', 'rank_time') }} 
)
SELECT *
FROM base_times
