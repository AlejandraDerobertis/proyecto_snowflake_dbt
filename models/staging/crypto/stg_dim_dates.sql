{{ config(materialized='view') }}

WITH unique_dates AS (
    SELECT DISTINCT
        TO_DATE(TO_CHAR(DATE), 'YYYYMMDD') AS raw_date
    FROM {{ source('crypto', 'crypto_transactions') }}
),

transformed_dates AS (
    SELECT
        CAST(
            EXTRACT(YEAR FROM raw_date) * 10000 +  -- YYYY
            EXTRACT(MONTH FROM raw_date) * 100 +  -- MM
            EXTRACT(DAY FROM raw_date) AS INT     -- DD
        ) AS date_id,--ID (YYYYMMDD)
        raw_date AS date,
        EXTRACT(YEAR FROM raw_date) AS year,
        EXTRACT(MONTH FROM raw_date) AS month,
        EXTRACT(DAY FROM raw_date) AS day,
        TO_CHAR(raw_date, 'Day') AS day_of_week,
        CASE 
            WHEN TO_CHAR(raw_date, 'DY') IN ('SAT', 'SUN') THEN TRUE
            ELSE FALSE
        END AS is_weekend
    FROM unique_dates
)

SELECT *
FROM transformed_dates

