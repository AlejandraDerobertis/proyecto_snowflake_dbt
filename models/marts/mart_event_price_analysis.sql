{{ config(materialized='incremental') }}

WITH price_analysis AS (
    SELECT
        epv.id_events,
        d.date,
        t.time,
        epv.symbol,
        epv.daily_price,
        epv.daily_variation,
        epv.cumulative_variation,
        e.sentiment,
        CASE
            WHEN epv.daily_variation > 0 AND e.sentiment = 'positive' THEN 'aligned_positive'
            WHEN epv.daily_variation < 0 AND e.sentiment = 'negative' THEN 'aligned_negative'
            ELSE 'misaligned'
        END AS sentiment_alignment
    FROM {{ ref('int_event_price_variation') }} AS epv
    LEFT JOIN {{ ref('stg_fact_events') }} AS e
        ON epv.id_events = e.id_events
    LEFT JOIN {{ ref('stg_dim_dates') }} AS d
        ON epv.date_id = d.date_id
    LEFT JOIN {{ ref('stg_dim_times') }} AS t
        ON epv.event_time = t.time
)

SELECT *
FROM price_analysis
WHERE sentiment_alignment != 'misaligned'  -- Filtrar eventos relevantes
{% if is_incremental() %}
AND id_events > (SELECT MAX(id_events) FROM {{ this }})
{% endif %}
