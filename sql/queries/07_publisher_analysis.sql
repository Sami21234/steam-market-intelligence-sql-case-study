/*
Steam Market Intelligence
SQL Case Study - Publisher Analysis

Business Questions:
    1. Which publishers have the largest game portfolios?
    2. Which publishers have the most reviewed games?
    3. Which publishers have the highest player reception?
    4. Which publishers have the highest average game price?
    5. Which publishers have the highest average discount?
    6. Which publishers combine popularity with strong reception?

Analysis uses the latest available snapshot.
*/

-- 1. Publishers with the largest game portfolios
SELECT 
	p.publisher_name,
    COUNT(DISTINCT gp.game_id) AS "game_count"
FROM dim_publishers AS p
JOIN bridge_game_publishers AS gp
	ON p.publisher_id = gp.publisher_id
GROUP BY p.publisher_name
ORDER BY game_count DESC LIMIT 20;

-- 2. Publishers with the most total reviews
SELECT 
	p.publisher_name,
    COUNT(DISTINCT g.game_id) AS "game_count",
    SUM(f.review_count) AS "total_reviews"
FROM dim_publishers AS p
JOIN bridge_game_publishers AS gp
	ON p.publisher_id = gp.publisher_id
JOIN dim_games AS g
	ON g.game_id = gp.game_id
JOIN fact_game_metrics AS f
	ON g.game_id = f.game_id
WHERE f.snapshot_date = (
	SELECT
		MAX(snapshot_date)
	FROM fact_game_metrics
)
AND f.review_count IS NOT NULL
GROUP BY publisher_name
ORDER BY total_reviews DESC LIMIT 20;

-- 3. Publishers with highest player reception
SELECT
    p.publisher_name,

    COUNT(DISTINCT g.game_id) AS game_count,

    ROUND(AVG(m.positive_percent), 2)
        AS avg_positive_percent

FROM dim_publishers AS p

JOIN bridge_game_publishers AS gp
    ON p.publisher_id = gp.publisher_id

JOIN dim_games AS g
    ON gp.game_id = g.game_id

JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)

AND m.positive_percent IS NOT NULL

GROUP BY p.publisher_name

HAVING COUNT(DISTINCT g.game_id) >= 3

ORDER BY avg_positive_percent DESC
LIMIT 20;

-- 4. Publishers with highest average game price
SELECT
    p.publisher_name,

    COUNT(DISTINCT g.game_id) AS game_count,

    ROUND(AVG(m.price), 2) AS avg_price

FROM dim_publishers AS p

JOIN bridge_game_publishers AS gp
    ON p.publisher_id = gp.publisher_id

JOIN dim_games AS g
    ON gp.game_id = g.game_id

JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)

AND m.price IS NOT NULL

GROUP BY p.publisher_name

HAVING COUNT(DISTINCT g.game_id) >= 3

ORDER BY avg_price DESC
LIMIT 20;

-- 5. Publishers with highest average discounts
SELECT 
	p.publisher_name,
    COUNT(DISTINCT g.game_id) AS game_count,
    ROUND(AVG(f.discount_percent), 2) AS avg_discount
FROM dim_publishers AS p
JOIN bridge_game_publishers AS gp
	ON p.publisher_id = gp.publisher_id
JOIN dim_games AS g
	ON g.game_id = gp.game_id
JOIN fact_game_metrics AS f
	ON g.game_id = f.game_id
WHERE f.snapshot_date = (
	SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND f.discount_percent IS NOT NULL
GROUP BY publisher_name
HAVING COUNT(DISTINCT g.game_id) >= 3
ORDER BY avg_discount DESC LIMIT 20;

-- 6. Publishers with popular games and strong reception
SELECT
    p.publisher_name,

    COUNT(DISTINCT g.game_id) AS game_count,

    ROUND(AVG(m.review_count), 0)
        AS avg_review_count,

    ROUND(AVG(m.positive_percent), 2)
        AS avg_positive_percent

FROM dim_publishers AS p

JOIN bridge_game_publishers AS gp
    ON p.publisher_id = gp.publisher_id

JOIN dim_games AS g
    ON gp.game_id = g.game_id

JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)

AND m.review_count IS NOT NULL
AND m.positive_percent IS NOT NULL

GROUP BY p.publisher_name

HAVING COUNT(DISTINCT g.game_id) >= 3
   AND AVG(m.review_count) >= 100

ORDER BY
    avg_positive_percent DESC,
    avg_review_count DESC LIMIT 20;

-- 7. Most reviewed game for each publisher
SELECT
    p.publisher_name,
    g.game_name,
    m.review_count,
    m.positive_percent,
    m.price
FROM dim_publishers AS p

JOIN bridge_game_publishers AS gp
    ON p.publisher_id = gp.publisher_id

JOIN dim_games AS g
    ON gp.game_id = g.game_id

JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)

AND m.review_count IS NOT NULL

ORDER BY
    p.publisher_name,
    m.review_count DESC;