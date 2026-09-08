
/*
Steam Market Intelligence
SQL Case Study - Top Game Performance

Business Questions:
    1. Which games have the highest number of reviews?
    2. Which games have the highest positive review percentage?
    3. Which games combine popularity and positive reception?

Important:
    Analysis uses the latest available snapshot for each game.

*/

-- 1. Top 20 games by review count
SELECT 
	g.game_id,
    g.game_name,
    f.price,
    f.discount_percent,
    f.snapshot_date,
    f.review_count
FROM dim_games AS g
JOIN fact_game_metrics AS f
	ON g.game_id = f.game_id
WHERE f.snapshot_date = (
	SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
ORDER BY f.review_count DESC
LIMIT 20;

-- 2. Top 20 games by positive review percentage
SELECT 
	g.game_id,
    g.game_name,
    f.price,
    f.positive_percent,
    f.discount_percent,
    f.snapshot_date,
    f.review_count
FROM dim_games AS g
JOIN fact_game_metrics AS f
	ON g.game_id = f.game_id
WHERE f.snapshot_date = (
	SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND f.positive_percent IS NOT NULL 
ORDER BY f.positive_percent DESC
LIMIT 20;

-- 3. Popular AND highly-rated games
-- Minimum 10,000 reviews and at least 80% positive reviews
SELECT 
	g.game_id,
    g.game_name,
    f.review_count,
    f.positive_percent,
    f.price,
    f.discount_percent
FROM dim_games AS g
JOIN fact_game_metrics AS f
	ON g.game_id = f.game_id
WHERE f.snapshot_date = (
	SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND f.review_count >= 10000
AND f.positive_percent >= 80
ORDER BY f.review_count DESC, f.positive_percent DESC

-- 4. Highly reviewed games with lower sentiment
-- More than 10,000 reviews but below 70% positive
SELECT
    g.game_id,
    g.game_name,
    m.review_count,
    m.positive_percent,
    m.price,
    m.discount_percent
FROM dim_games AS g
JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id
WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND m.review_count >= 10000
AND m.positive_percent < 70
ORDER BY m.review_count DESC;