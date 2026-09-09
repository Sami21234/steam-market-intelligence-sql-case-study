/*
Steam Market Intelligence
SQL Case Study - Rating Analysis

Business Questions:
    1. What is the overall average positive review percentage?
    2. How many games fall into different rating categories?
    3. Which games have the strongest player reception?
    4. Which games have poor player reception?
    5. Does having more reviews relate to positive reception?

Analysis uses the latest available snapshot for each game.
*/

-- 1. Overall average positive review percentage
SELECT 
	ROUND(AVG(positive_percent), 2) AS avg_positive_percent
FROM fact_game_metrics
WHERE snapshot_date = (
	SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND positive_percent IS NOT NULL;

-- 2. Distribution of games by rating category
SELECT 
	CASE
		WHEN positive_percent >= 90 THEN "Excellent"
		WHEN positive_percent >= 80 THEN "Very Positive"
        WHEN positive_percent >= 70 THEN "Positive"
        WHEN positive_percent >= 60 THEN "Mixed"
        ELSE "Mostly Negative"
	END AS "rating_category",
    COUNT(*) AS game_count
FROM fact_game_metrics
WHERE snapshot_date = (
	SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND positive_percent IS NOT NULL

GROUP BY
	CASE
		WHEN positive_percent >= 90 THEN "Excellent"
		WHEN positive_percent >= 80 THEN "Very Positive"
        WHEN positive_percent >= 70 THEN "Positive"
        WHEN positive_percent >= 60 THEN "Mixed"
        ELSE "Mostly Negative"
	END
ORDER BY game_count DESC;

-- 3. Top 20 games by positive review percentage
SELECT
	g.game_id,
    g.game_name,
    f.review_count,
    f.positive_percent,
    f.price
FROM dim_games AS g
JOIN fact_game_metrics AS f
	ON g.game_id = f.game_id
WHERE f.snapshot_date = (
	SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND f.positive_percent IS NOT NULL
ORDER BY positive_percent DESC LIMIT 20

-- 4. Games with poor player reception
SELECT
    g.game_name,
    f.positive_percent,
    f.review_count,
    f.price,
    f.discount_percent
FROM dim_games AS g
JOIN fact_game_metrics AS m
    ON g.game_id = f.game_id

WHERE f.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND f.positive_percent IS NOT NULL
AND f.positive_percent < 60
AND f.review_count IS NOT NULL

ORDER BY
    f.positive_percent ASC, f.review_count DESC LIMIT 20;

-- 5. Highly reviewed games with strong reception
SELECT 
    g.game_name,
    f.positive_percent,
    f.review_count,
    f.price,
    f.discount_percent
FROM dim_games AS g
JOIN fact_game_metrics AS f
    ON g.game_id = f.game_id

WHERE f.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND f.review_count >= 50000
AND f.positive_percent >= 90

ORDER BY f.review_count DESC;

-- 6. Highly reviewed games with weak reception
SELECT 
    g.game_name,
    f.positive_percent,
    f.review_count,
    f.price,
    f.discount_percent
FROM dim_games AS g
JOIN fact_game_metrics AS f
    ON g.game_id = f.game_id

WHERE f.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND f.review_count >= 50000
AND f.positive_percent < 70

ORDER BY f.review_count DESC;
