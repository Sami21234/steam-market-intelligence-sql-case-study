/*
Steam Market Intelligence
SQL Case Study - Developer Analysis

Business Questions:
    1. Which developers have the largest game portfolios?
    2. Which developers have the most total reviews?
    3. Which developers have the highest player reception?
    4. Which developers have the highest average game price?
    5. Which developers have the highest average discount?
    6. Which developers combine popularity with strong reception?
    7. What are the most reviewed games from each developer?

Analysis uses the latest available snapshot.
*/

-- 1. Developers with the largest game portfolios
SELECT 
    d.developer_name,
    COUNT(DISTINCT gd.game_id) AS "game_count"
FROM dim_developers AS d
JOIN bridge_game_developers AS gd
    ON d.developer_id = gd.developer_id
GROUP BY d.developer_name
ORDER BY game_count DESC LIMIT 20;

-- 2. Developers with the most total reviews
SELECT 
	d.developer_name,
    COUNT(DISTINCT g.game_id) AS game_count,
    SUM(f.review_count) AS total_reviews
FROM dim_developers AS d
JOIN bridge_game_developers AS bg
	ON d.developer_id = bg.developer_id
JOIN dim_games AS g
	ON g.game_id = bg.game_id
JOIN fact_game_metrics AS f
	ON g.game_id = f.game_id
WHERE f.snapshot_date = (
	SELECT
		MAX(snapshot_date) 
	FROM fact_game_metrics
)
AND f.review_count IS NOT NULL
GROUP BY d.developer_name
ORDER BY total_reviews DESC LIMIT 20;

-- 3. Developers with highest player reception
SELECT
    d.developer_name,

    COUNT(DISTINCT g.game_id) AS game_count,

    ROUND(AVG(m.positive_percent), 2)
        AS avg_positive_percent

FROM dim_developers AS d

JOIN bridge_game_developers AS gd
    ON d.developer_id = gd.developer_id

JOIN dim_games AS g
    ON gd.game_id = g.game_id

JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)

AND m.positive_percent IS NOT NULL

GROUP BY d.developer_name

HAVING COUNT(DISTINCT g.game_id) >= 3

ORDER BY avg_positive_percent DESC LIMIT 20;

-- 4. Developers with highest average game price
SELECT
    d.developer_name,

    COUNT(DISTINCT g.game_id) AS game_count,

    ROUND(AVG(m.price), 2) AS avg_price

FROM dim_developers AS d

JOIN bridge_game_developers AS gd
    ON d.developer_id = gd.developer_id

JOIN dim_games AS g
    ON gd.game_id = g.game_id

JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)

AND m.price IS NOT NULL

GROUP BY d.developer_name

HAVING COUNT(DISTINCT g.game_id) >= 3

ORDER BY avg_price DESC LIMIT 20;

-- 5. Developers with highest average discounts
SELECT
    d.developer_name,

    COUNT(DISTINCT g.game_id) AS game_count,

    ROUND(AVG(m.discount_percent), 2)
        AS avg_discount_percent

FROM dim_developers AS d

JOIN bridge_game_developers AS gd
    ON d.developer_id = gd.developer_id

JOIN dim_games AS g
    ON gd.game_id = g.game_id

JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)

AND m.discount_percent IS NOT NULL

GROUP BY d.developer_name

HAVING COUNT(DISTINCT g.game_id) >= 3

ORDER BY avg_discount_percent DESC LIMIT 20;

-- 6. Popular developers with strong player reception
SELECT
    d.developer_name,

    COUNT(DISTINCT g.game_id) AS game_count,

    ROUND(AVG(m.review_count), 0)
        AS avg_review_count,

    ROUND(AVG(m.positive_percent), 2)
        AS avg_positive_percent

FROM dim_developers AS d

JOIN bridge_game_developers AS gd
    ON d.developer_id = gd.developer_id

JOIN dim_games AS g
    ON gd.game_id = g.game_id

JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)

AND m.review_count IS NOT NULL
AND m.positive_percent IS NOT NULL

GROUP BY d.developer_name

HAVING COUNT(DISTINCT g.game_id) >= 3
   AND AVG(m.review_count) >= 100

ORDER BY
    avg_positive_percent DESC,
    avg_review_count DESC LIMIT 20;

-- 7. Most reviewed games from developers
SELECT
    d.developer_name,
    g.game_name,
    m.review_count,
    m.positive_percent,
    m.price
FROM dim_developers AS d

JOIN bridge_game_developers AS gd
    ON d.developer_id = gd.developer_id

JOIN dim_games AS g
    ON gd.game_id = g.game_id

JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)

AND m.review_count IS NOT NULL

ORDER BY
    d.developer_name,
    m.review_count DESC;