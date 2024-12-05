{{ config(materialized='view') }}

WITH base_events AS (
    SELECT
        e.id_events,
        e.date_id,                 -- Incluir date_id
        d.date AS event_date,      -- Recuperar la fecha usando stg_dim_dates
        t.time AS event_time,      -- Recuperar la hora usando stg_dim_times
        e.sentiment,
        e.score AS relevance_score
    FROM {{ ref('stg_fact_events') }} AS e
    LEFT JOIN {{ ref('stg_dim_dates') }} AS d
        ON e.date_id = d.date_id
    LEFT JOIN {{ ref('stg_dim_times') }} AS t
        ON e.time_id = t.time_id
),

daily_price_variation AS (
    SELECT
        e.id_events,
        e.date_id,
        e.event_time,                 -- Incluir event_time
        p.date_id AS price_date_id,
        p.symbol,
        p.highest_price AS daily_price,  -- Usar highest_price
        (p.highest_price - LAG(p.highest_price) OVER (PARTITION BY p.symbol ORDER BY p.date_id)) AS daily_variation,
        (p.highest_price - FIRST_VALUE(p.highest_price) OVER (PARTITION BY e.id_events, p.symbol ORDER BY p.date_id)) AS cumulative_variation
    FROM base_events AS e
    LEFT JOIN {{ ref('crypto_prices_metrics') }} AS p
        ON ABS(p.date_id - e.date_id) <= 1  -- 1 días antes y después
)

SELECT
    dpv.id_events,
    dpv.date_id,
    dpv.event_time,                -- Incluir event_time en el SELECT final
    dpv.symbol,
    dpv.daily_price,
    dpv.daily_variation,
    dpv.cumulative_variation
FROM daily_price_variation AS dpv

