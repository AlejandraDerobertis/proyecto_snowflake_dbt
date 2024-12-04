{{ config(materialized='incremental') }}

WITH base_metrics AS (
    SELECT
        symbol,
        date_id,
        highest_price,
        lowest_price,
        average_price,
        daily_range_percent
    FROM {{ ref('crypto_prices_metrics') }}
)

-- depends_on: {{ ref('stg_dim_dates') }}
SELECT base_metrics.*
FROM base_metrics
{% if is_incremental() %}
INNER JOIN {{ ref('stg_dim_dates') }} as dates ON base_metrics.date_id = dates.date_id
WHERE dates.date > (SELECT MAX(dd.date) FROM {{ this }} bb join {{ ref('stg_dim_dates') }} as dd on bb.date_id = dd.date_id)  -- Solo datos nuevos
{% endif %}


