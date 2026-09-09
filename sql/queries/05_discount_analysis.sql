/*
Steam Market Intelligence
SQL Case Study - Discount Analysis

Business Questions:
    1. How many games are discounted?
    2. What is the average discount percentage?
    3. What are the different discount segments?
    4. Which games have the highest discounts?
    5. Which discounted games have the most reviews?
    6. What is the relationship between discount and reviews?
    7. How does player reception vary by discount range?

Analysis uses the latest available snapshot.
*/

-- 1. Overall discount statistics
SELECT
    COUNT(*) AS discounted_games,
    ROUND(AVG(discount_percent), 2) AS average_discount,
    MIN(discount_percent) AS minimum_discount,
    MAX(discount_percent) AS maximum_discount
FROM fact_game_metrics
WHERE snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND discount_percent IS NOT NULL
AND discount_percent > 0;

-- 2. Discounted vs Non-discounted games
SELECT
	CASE 
		WHEN discount_percent IS NULL OR discount_percent = 0
			THEN "Not Discounted"
		WHEN discount_percent > 0 
			THEN "Discounted"
	END AS "discount_status",
    COUNT(*) AS "game_count"
FROM fact_game_metrics  
WHERE snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
GROUP BY
    CASE
        WHEN discount_percent IS NULL OR discount_percent = 0
            THEN 'Not Discounted'
        WHEN discount_percent > 0
            THEN 'Discounted'
    END
ORDER BY game_count DESC;

-- 3. Games by discount segment
SELECT
    CASE
        WHEN discount_percent IS NULL OR discount_percent = 0
            THEN 'No Discount'
        WHEN discount_percent > 0 AND discount_percent <= 25
            THEN '1% - 25%'
        WHEN discount_percent > 25 AND discount_percent <= 50
            THEN '26% - 50%'
        WHEN discount_percent > 50 AND discount_percent <= 75
            THEN '51% - 75%'
        WHEN discount_percent > 75
            THEN 'Above 75%'
    END AS discount_segment,
    COUNT(*) AS game_count
FROM fact_game_metrics
WHERE snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
GROUP BY
    CASE
        WHEN discount_percent IS NULL OR discount_percent = 0
            THEN 'No Discount'
        WHEN discount_percent > 0 AND discount_percent <= 25
            THEN '1% - 25%'
        WHEN discount_percent > 25 AND discount_percent <= 50
            THEN '26% - 50%'
        WHEN discount_percent > 50 AND discount_percent <= 75
            THEN '51% - 75%'
        WHEN discount_percent > 75
            THEN 'Above 75%'
    END
ORDER BY game_count DESC;

-- 4. Top 20 games with highest discounts
SELECT
    g.game_name,
    m.price,
    m.discount_percent,
    m.review_count,
    m.positive_percent
FROM dim_games AS g
JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id
WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND m.discount_percent IS NOT NULL
AND m.discount_percent > 0
ORDER BY m.discount_percent DESC LIMIT 20;

-- 5. Most reviewed discounted games
SELECT
    g.game_name,
    m.discount_percent,
    m.price,
    m.review_count,
    m.positive_percent
FROM dim_games AS g
JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id
WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND m.discount_percent > 0
AND m.review_count IS NOT NULL
ORDER BY m.review_count DESC LIMIT 20;

-- 6. Discount vs player reception
SELECT
    CASE
        WHEN discount_percent IS NULL OR discount_percent = 0
            THEN 'No Discount'
        WHEN discount_percent <= 25
            THEN '1% - 25%'
        WHEN discount_percent <= 50
            THEN '26% - 50%'
        WHEN discount_percent <= 75
            THEN '51% - 75%'
        ELSE 'Above 75%'
    END AS discount_segment,

    COUNT(*) AS game_count,

    ROUND(AVG(positive_percent), 2)
        AS avg_positive_percent,

    ROUND(AVG(review_count), 0)
        AS avg_review_count

FROM fact_game_metrics

WHERE snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)

GROUP BY
    CASE
        WHEN discount_percent IS NULL OR discount_percent = 0
            THEN 'No Discount'
        WHEN discount_percent <= 25
            THEN '1% - 25%'
        WHEN discount_percent <= 50
            THEN '26% - 50%'
        WHEN discount_percent <= 75
            THEN '51% - 75%'
        ELSE 'Above 75%'
    END

ORDER BY avg_review_count DESC;

-- 7. Highly discounted games with strong player reception
SELECT
    g.game_name,
    m.discount_percent,
    m.price,
    m.review_count,
    m.positive_percent
FROM dim_games AS g
JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id
WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND m.discount_percent >= 50
AND m.positive_percent >= 80
AND m.review_count IS NOT NULL
ORDER BY
    m.review_count DESC LIMIT 20;