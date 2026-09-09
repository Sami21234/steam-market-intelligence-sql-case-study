/*
Steam Market Intelligence
SQL Case Study - Price Analysis

Business Questions:
    1. What is the average price of games?
    2. What is the minimum and maximum game price?
    3. How many games are free vs paid?
    4. What are the different price segments?
    5. Which are the most expensive games?
    6. What is the relationship between price and reviews?

Analysis uses the latest available snapshot.
*/

-- 1. Overall price statistics
SELECT 
	ROUND(AVG(price), 2) AS "avg_price",
    MIN(price) AS "min_price",
    MAX(price) AS "max_price"
FROM fact_game_metrics
WHERE snapshot_date = (
	SELECT 
		MAX(snapshot_date)
	FROM fact_game_metrics
)
AND price IS NOT NULL;

-- 2. Free vs Paid games
SELECT 
    CASE
		WHEN price = 0 THEN "Free"
        WHEN price > 0 THEN "Paid"
	END AS "pricing_type",
    
    COUNT(*) AS "game_count"
FROM fact_game_metrics AS f
JOIN dim_games AS g
	ON f.game_id = g.game_id

WHERE f.snapshot_date = (
	SELECT
		MAX(snapshot_date)
	FROM fact_game_metrics
)
AND price IS NOT NULL

GROUP BY 
	CASE 
		WHEN price = 0 THEN "Free"
        WHEN price > 0 THEN "Paid"
	END 
ORDER BY game_count DESC;  

-- 3. Games by price segment
SELECT
    CASE
        WHEN price = 0 THEN 'Free'
        WHEN price > 0 AND price <= 500 THEN '₹1 - ₹500'
        WHEN price > 500 AND price <= 1000 THEN '₹501 - ₹1000'
        WHEN price > 1000 AND price <= 2000 THEN '₹1001 - ₹2000'
        WHEN price > 2000 THEN 'Above ₹2000'
    END AS price_segment,

    COUNT(*) AS game_count

FROM fact_game_metrics

WHERE snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND price IS NOT NULL

GROUP BY
    CASE
        WHEN price = 0 THEN 'Free'
        WHEN price > 0 AND price <= 500 THEN '₹1 - ₹500'
        WHEN price > 500 AND price <= 1000 THEN '₹501 - ₹1000'
        WHEN price > 1000 AND price <= 2000 THEN '₹1001 - ₹2000'
        WHEN price > 2000 THEN 'Above ₹2000'
    END

ORDER BY game_count DESC;

-- 4. Top 20 most expensive games
SELECT 
	g.game_id,
    g.game_name,
    f.price,
    f.discount_percent,
    f.review_count,
    f.positive_percent
FROM fact_game_metrics AS f
JOIN dim_games AS g
	ON g.game_id = f.game_id
WHERE snapshot_date = (
	SELECT
		MAX(snapshot_date)
	FROM fact_game_metrics
)
AND f.price IS NOT NULL
ORDER BY price DESC LIMIT 20;

-- 5. Most reviewed FREE games
SELECT
    g.game_name,
    m.review_count,
    m.positive_percent,
    m.price
FROM dim_games AS g
JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND m.price = 0
AND m.review_count IS NOT NULL

ORDER BY m.review_count DESC LIMIT 20;

-- 6. Most reviewed PAID games
SELECT
    g.game_name,
    m.review_count,
    m.positive_percent,
    m.price
FROM dim_games AS g
JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND m.price > 0
AND m.review_count IS NOT NULL

ORDER BY m.review_count DESC LIMIT 20;

-- 7. Price vs player reception
SELECT
    CASE
        WHEN price = 0 THEN 'Free'
        WHEN price <= 500 THEN '₹1 - ₹500'
        WHEN price <= 1000 THEN '₹501 - ₹1000'
        WHEN price <= 2000 THEN '₹1001 - ₹2000'
        ELSE 'Above ₹2000'
    END AS price_segment,

    COUNT(*) AS game_count,

    ROUND(AVG(positive_percent), 2) AS avg_positive_percent,

    ROUND(AVG(review_count), 0) AS avg_review_count

FROM fact_game_metrics

WHERE snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND price IS NOT NULL

GROUP BY
    CASE
        WHEN price = 0 THEN 'Free'
        WHEN price <= 500 THEN '₹1 - ₹500'
        WHEN price <= 1000 THEN '₹501 - ₹1000'
        WHEN price <= 2000 THEN '₹1001 - ₹2000'
        ELSE 'Above ₹2000'
    END

ORDER BY
    avg_review_count DESC;
