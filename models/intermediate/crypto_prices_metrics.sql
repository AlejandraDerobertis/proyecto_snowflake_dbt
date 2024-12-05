WITH base_prices AS (
    SELECT
        symbol,
        date_id,
        time_id,
        CAST(price_usd AS DECIMAL(18, 9)) AS closing_price,
        market_capitalization
    FROM {{ ref('stg_fact_live_data') }}
    WHERE price_usd IS NOT NULL
),
aggregated_prices AS (
    SELECT
        symbol,
        date_id,
        MAX(closing_price) AS highest_price,
        MIN(closing_price) AS lowest_price,
        AVG(closing_price) AS average_price,
        COALESCE(STDDEV(closing_price), 0) AS price_volatility
    FROM base_prices
    GROUP BY symbol, date_id
)

SELECT
    symbol,
    date_id,
    highest_price,
    lowest_price,
    average_price,
    price_volatility,
    CASE
        WHEN average_price > 0 AND highest_price != lowest_price THEN
            CAST(((highest_price - lowest_price) / average_price * 100) AS DECIMAL(18,2))
        ELSE 0
    END AS daily_range_percent
FROM aggregated_prices
