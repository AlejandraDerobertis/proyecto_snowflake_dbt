{{ config(materialized='view') }}

WITH base_dates AS (
    SELECT
        date_id,
        CAST(date as DATE) as date,
        DAYOFWEEKISO(date) AS day_of_week,
        CASE
            WHEN  DAYOFWEEKISO(date) IN (6, 7) THEN TRUE
            ELSE FALSE
        END AS is_weekend
    FROM {{ source('crypto', 'rank_date') }}
)

SELECT *
FROM base_dates
