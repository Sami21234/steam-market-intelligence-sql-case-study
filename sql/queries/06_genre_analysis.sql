/*
Steam Market Intelligence
SQL Case Study - Genre Analysis

Business Questions:
    1. Which genres have the most games?
    2. Which genres have the highest average player reception?
    3. Which genres have the most reviews?
    4. Which genres have the highest average price?
    5. Which genres have the highest average discount?
    6. Which genres combine popularity with strong reception?

Analysis uses the latest available snapshot.
*/

-- 1. Number of games by genre
SELECT 
	ge.genre_name,
	COUNT(DISTINCT gg.game_id) AS "game_count"
FROM bridge_game_genres AS gg
JOIN dim_genres AS ge
	ON gg.genre_id = ge.genre_id
GROUP BY ge.genre_name
ORDER BY game_count DESC;

-- 2. Genre popularity and player reception
SELECT
    ge.genre_name,

    COUNT(DISTINCT g.game_id) AS game_count,

    ROUND(AVG(m.review_count), 0)
        AS avg_review_count,

    ROUND(AVG(m.positive_percent), 2)
        AS avg_positive_percent

FROM dim_genres AS ge

JOIN bridge_game_genres AS gg
    ON ge.genre_id = gg.genre_id

JOIN dim_games AS g
    ON gg.game_id = g.game_id

JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)

GROUP BY ge.genre_name

ORDER BY avg_review_count DESC;

-- 3. Genres with highest player reception
SELECT
    ge.genre_name,
    COUNT(DISTINCT g.game_id) AS game_count,
    ROUND(AVG(m.positive_percent), 2)
        AS avg_positive_percent
FROM dim_genres AS ge
JOIN bridge_game_genres AS gg
    ON ge.genre_id = gg.genre_id
JOIN dim_games AS g
    ON gg.game_id = g.game_id
JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id
WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND m.positive_percent IS NOT NULL
GROUP BY ge.genre_name
HAVING COUNT(DISTINCT g.game_id) >= 5
ORDER BY avg_positive_percent DESC
LIMIT 20;

-- 4. Genres with highest average price
SELECT 
	ge.genre_name,
    COUNT(DISTINCT g.game_id) AS "game_count",
    ROUND(AVG(f.price), 2) AS "avg_price"
FROM dim_genres AS ge
JOIN bridge_game_genres AS gg
	ON ge.genre_id = gg.genre_id
JOIN dim_games AS g
	ON g.game_id = gg.game_id
JOIN fact_game_metrics AS f
	ON g.game_id = f.game_id
WHERE f.snapshot_date = (
	SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND f.price IS NOT NULL
GROUP BY ge.genre_name
HAVING COUNT(DISTINCT g.game_id) >= 5
ORDER BY avg_price DESC LIMIT 20;

-- 5. Genres with highest average discount
SELECT 
	ge.genre_name,
    COUNT(DISTINCT g.game_id) AS "game_count",
    ROUND(AVG(f.discount_percent), 2) AS "avg_discount_percent"
FROM dim_genres AS ge
JOIN bridge_game_genres AS gg
	ON ge.genre_id = gg.genre_id
JOIN dim_games AS g
	ON g.game_id = gg.game_id
JOIN fact_game_metrics AS f
	ON g.game_id = f.game_id
WHERE f.snapshot_date = (
	SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND f.price IS NOT NULL
GROUP BY ge.genre_name
HAVING COUNT(DISTINCT g.game_id) >= 5
ORDER BY avg_discount_percent DESC LIMIT 20;

-- 6. Most reviewed games within each genre
SELECT
    ge.genre_name,
    g.game_name,
    m.review_count,
    m.positive_percent,
    m.price
FROM dim_genres AS ge
JOIN bridge_game_genres AS gg
    ON ge.genre_id = gg.genre_id
JOIN dim_games AS g
    ON gg.game_id = g.game_id
JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id
WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)
AND m.review_count IS NOT NULL
ORDER BY
    ge.genre_name,
    m.review_count DESC;

-- 7. Popular genres with strong player reception
SELECT
    ge.genre_name,

    COUNT(DISTINCT g.game_id) AS game_count,

    ROUND(AVG(m.review_count), 0)
        AS avg_review_count,

    ROUND(AVG(m.positive_percent), 2)
        AS avg_positive_percent

FROM dim_genres AS ge

JOIN bridge_game_genres AS gg
    ON ge.genre_id = gg.genre_id

JOIN dim_games AS g
    ON gg.game_id = g.game_id

JOIN fact_game_metrics AS m
    ON g.game_id = m.game_id

WHERE m.snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM fact_game_metrics
)

AND m.review_count IS NOT NULL
AND m.positive_percent IS NOT NULL

GROUP BY ge.genre_name

HAVING COUNT(DISTINCT g.game_id) >= 10
   AND AVG(m.review_count) >= 100

ORDER BY
    avg_positive_percent DESC,
    avg_review_count DESC;