/*
Steam Market Intelligence
SQL Case Study - Historical Analysis

Business Questions:
    1. How many snapshots were collected on each date?
    2. How did the total number of reviews change over time?
    3. How did average player reception change over time?
    4. How did average game price change over time?
    5. How did average discount change over time?
    6. Which games experienced the largest increase in reviews?
    7. Which games experienced the largest change in player reception?

Historical analysis uses all available snapshots.
*/

-- 1. Number of games/snapshots collected per day
SELECT 
	snapshot_date,
    COUNT(*) AS snapshots_records,
    COUNT(DISTINCT game_id) AS 	unique_games
FROM fact_game_metrics
GROUP BY snapshot_date
ORDER BY snapshot_date;

-- 2. Total reviews over time
SELECT 
	snapshot_date,
    SUM(review_count) AS total_reviews,
    ROUND(AVG(review_count), 2) AS avg_reviews_per_game
FROM fact_game_metrics 
GROUP BY snapshot_date
ORDER BY snapshot_date;

-- 3. Average player reception over time
SELECT
    snapshot_date,

    ROUND(AVG(positive_percent), 2)
        AS avg_positive_percent,

    COUNT(positive_percent)
        AS games_with_review_data

FROM fact_game_metrics
WHERE positive_percent IS NOT NULL
GROUP BY snapshot_date
ORDER BY snapshot_date;

-- 4. Average price over time
SELECT 
	snapshot_date,
    ROUND(AVG(price), 2) AS "avg_price",
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM fact_game_metrics
WHERE price IS NOT NULL
GROUP BY snapshot_date
ORDER BY snapshot_date;

-- 5. Average discount over time
SELECT 
	snapshot_date,
    ROUND(
		AVG(
			CASE
				WHEN discount_percent IS NOT NULL THEN discount_percent
                ELSE 0
			END 
		), 2
    ) AS avg_discount_price,
    COUNT(
		CASE
			WHEN discount_percent > 0 THEN 1
		END
    ) AS discounted_games
FROM fact_game_metrics
GROUP BY snapshot_date
ORDER BY snapshot_date;

-- 6. Games with the largest increase in review count
SELECT
    g.game_name,

    MIN(m.review_count) AS first_review_count,

    MAX(m.review_count) AS latest_review_count,

    MAX(m.review_count) - MIN(m.review_count)
        AS review_growth

FROM dim_games AS g

JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.review_count IS NOT NULL

GROUP BY
    g.game_id,
    g.game_name

HAVING COUNT(DISTINCT m.snapshot_date) >= 2

ORDER BY review_growth DESC LIMIT 20;

-- 7. Games with largest change in player reception
SELECT
    g.game_name,

    MIN(m.positive_percent) AS lowest_positive_percent,

    MAX(m.positive_percent) AS highest_positive_percent,

    ROUND(
        MAX(m.positive_percent) - MIN(m.positive_percent), 2) AS reception_change

FROM dim_games AS g

JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.positive_percent IS NOT NULL

GROUP BY
    g.game_id,
    g.game_name

HAVING COUNT(DISTINCT m.snapshot_date) >= 2

ORDER BY reception_change DESC LIMIT 20;

-- 8. Game-level historical timeline
SELECT
    g.game_name,

    m.snapshot_date,

    m.review_count,

    m.positive_percent,

    m.price,

    m.discount_percent

FROM dim_games AS g

JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.game_id IN (
    SELECT game_id
    FROM fact_game_metrics
    GROUP BY game_id
    HAVING COUNT(DISTINCT snapshot_date) >= 2
)

ORDER BY
    g.game_name,
    m.snapshot_date;