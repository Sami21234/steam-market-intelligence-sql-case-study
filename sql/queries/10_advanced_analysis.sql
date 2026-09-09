/*
Steam Market Intelligence
SQL Case Study - Advanced Analysis

Advanced SQL Techniques:
    - CTEs
    - Window Functions
    - Ranking
    - Percentage calculations
    - First vs Latest snapshot comparison
    - Conditional aggregation
    - Multi-table analytical joins

Business Questions:
    1. What are the top games within each genre?
    2. Which games have the highest review counts relative to their genre?
    3. Which games gained the most reviews between snapshots?
    4. Which games improved or declined in player reception?
    5. What percentage of games are discounted?
    6. Which publishers have the strongest portfolio?
    7. Which games are both popular and highly rated?
*/

-- 1. Top 5 most reviewed games within each genre
WITH ranked_games AS (
	SELECT
		ge.genre_name,
        g.game_name,
        f.review_count,
        f.positive_percent,
		ROW_NUMBER() OVER(PARTITION BY ge.genre_name 
						  ORDER BY f.review_count DESC) AS genre_rank
	FROM dim_genres AS ge
	JOIN bridge_game_genres AS gg
		ON ge.genre_id = gg.genre_id
	JOIN dim_games AS g
		ON g.game_id = gg.game_id
	JOIN fact_game_metrics AS f
		ON f.game_id = g.game_id
	WHERE snapshot_date = (
		SELECT MAX(snapshot_date)
        FROM fact_game_metrics
    )
    AND f.review_count IS NOT NULL
)
SELECT
	genre_name,
    game_name,
    review_count,
    positive_percent,
    genre_rank
FROM ranked_games
WHERE genre_rank <= 5
ORDER BY genre_name, genre_rank;

-- 2. Games ranked by review count within their genre
WITH ranked_games AS (
	SELECT
		ge.genre_name,
        g.game_name,
        f.review_count,
        f.positive_percent,
		RANK() OVER(PARTITION BY ge.genre_name 
						  ORDER BY f.review_count DESC) AS genre_rank
	FROM dim_genres AS ge
	JOIN bridge_game_genres AS gg
		ON ge.genre_id = gg.genre_id
	JOIN dim_games AS g
		ON g.game_id = gg.game_id
	JOIN fact_game_metrics AS f
		ON f.game_id = g.game_id
	WHERE snapshot_date = (
		SELECT MAX(snapshot_date)
        FROM fact_game_metrics
    )
    AND f.review_count IS NOT NULL
)
SELECT
	genre_name,
    game_name,
    review_count,
    positive_percent,
    genre_rank
FROM ranked_games
ORDER BY genre_name, genre_rank;

-- 3. Review growth between first and latest snapshots
WITH snapshot_data AS (

    SELECT
        game_id,

        FIRST_VALUE(review_count) OVER (
            PARTITION BY game_id
            ORDER BY snapshot_date
        ) AS first_review_count,

        LAST_VALUE(review_count) OVER (
            PARTITION BY game_id
            ORDER BY snapshot_date
            ROWS BETWEEN UNBOUNDED PRECEDING
                 AND UNBOUNDED FOLLOWING
        ) AS latest_review_count,

        COUNT(*) OVER (
            PARTITION BY game_id
        ) AS snapshot_count

    FROM fact_game_metrics

    WHERE review_count IS NOT NULL
)

SELECT DISTINCT
    g.game_name,

    first_review_count,

    latest_review_count,

    latest_review_count - first_review_count
        AS review_growth,

    snapshot_count

FROM snapshot_data AS s

JOIN dim_games AS g
    ON s.game_id = g.game_id

WHERE snapshot_count >= 2

ORDER BY review_growth DESC

LIMIT 20;

-- 4. Player reception change between first and latest
WITH snapshot_data AS (

    SELECT
        game_id,

        FIRST_VALUE(positive_percent) OVER (
            PARTITION BY game_id
            ORDER BY snapshot_date
        ) AS first_positive_percent,

        LAST_VALUE(positive_percent) OVER (
            PARTITION BY game_id
            ORDER BY snapshot_date
            ROWS BETWEEN UNBOUNDED PRECEDING
                 AND UNBOUNDED FOLLOWING
        ) AS latest_positive_percent,

        COUNT(*) OVER (
            PARTITION BY game_id
        ) AS snapshot_count

    FROM fact_game_metrics

    WHERE positive_percent IS NOT NULL
)

SELECT DISTINCT
    g.game_name,

    ROUND(first_positive_percent, 2)
        AS first_positive_percent,

    ROUND(latest_positive_percent, 2)
        AS latest_positive_percent,

    ROUND(
        latest_positive_percent
        - first_positive_percent,
        2
    ) AS reception_change,

    snapshot_count

FROM snapshot_data AS s

JOIN dim_games AS g
    ON s.game_id = g.game_id

WHERE snapshot_count >= 2

ORDER BY reception_change DESC LIMIT 20;

-- 5. Percentage of games that are discounted
WITH pricing AS (

    SELECT
        COUNT(*) AS total_games,

        SUM(
            CASE
                WHEN discount_percent > 0
                THEN 1
                ELSE 0
            END
        ) AS discounted_games

    FROM fact_game_metrics

    WHERE snapshot_date = (
        SELECT MAX(snapshot_date)
        FROM fact_game_metrics
    )
)

SELECT
    total_games,
    discounted_games,

    ROUND(
        discounted_games * 100.0 / total_games,
        2
    ) AS discounted_percentage

FROM pricing;

-- 6. Publisher portfolio performance
WITH publisher_metrics AS (

    SELECT
        p.publisher_name,

        COUNT(DISTINCT g.game_id)
            AS game_count,

        SUM(m.review_count)
            AS total_reviews,

        AVG(m.positive_percent)
            AS avg_positive_percent,

        AVG(m.review_count)
            AS avg_review_count

    FROM dim_publishers AS p

    JOIN bridge_game_publisher AS gp
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

    GROUP BY p.publisher_name

    HAVING COUNT(DISTINCT g.game_id) >= 3
)

SELECT
    publisher_name,
    game_count,
    total_reviews,

    ROUND(avg_review_count, 0)
        AS avg_review_count,

    ROUND(avg_positive_percent, 2)
        AS avg_positive_percent,

    RANK() OVER (
        ORDER BY total_reviews DESC
    ) AS popularity_rank

FROM publisher_metrics

ORDER BY popularity_rank LIMIT 20;

-- 7. Popular + highly rated games
WITH game_metrics AS (
    SELECT
        g.game_name,
        m.review_count,
        m.positive_percent,
        m.price,
        m.discount_percent,

        PERCENT_RANK() OVER(
            ORDER BY m.review_count
        ) AS review_percentile,

        PERCENT_RANK() OVER (
            ORDER BY m.positive_percent
        ) AS r

    FROM dim_games as g
    JOIN fact_game_metrics AS m
        ON g.game_id = m.game_id

    WHERE m.snapshot_date = (
        SELECT MAX(snapshot_date)
        FROM fact_game_metrics
    )

    AND m.review_count IS NOT NULL
    AND m.positive_percent IS NOT NULL
)

SELECT
    game_name,
    review_count,
    positive_percent,
    price,
    discount_percent,

    ROUND(review_percentile * 100, 2)
        AS review_percentile,

    ROUND(rating_percentile * 100, 2)
        AS rating_percentile

FROM game_metrics

WHERE review_percentile >= 0.75
  AND rating_percentile >= 0.75

ORDER BY
    review_count DESC LIMIT 20;

-- 8. Games with high popularity but weak reception
WITH game_metrics AS (

    SELECT
        g.game_name,
        m.review_count,
        m.positive_percent,

        PERCENT_RANK() OVER (
            ORDER BY m.review_count
        ) AS review_percentile,

        PERCENT_RANK() OVER (
            ORDER BY m.positive_percent
        ) AS rating_percentile

    FROM dim_games AS g

    JOIN fact_game_metrics AS m
        ON g.game_id = m.game_id

    WHERE m.snapshot_date = (
        SELECT MAX(snapshot_date)
        FROM fact_game_metrics
    )

    AND m.review_count IS NOT NULL
    AND m.positive_percent IS NOT NULL
)

SELECT
    game_name,
    review_count,
    positive_percent,

    ROUND(review_percentile * 100, 2)
        AS review_percentile,

    ROUND(rating_percentile * 100, 2)
        AS rating_percentile

FROM game_metrics

WHERE review_percentile >= 0.75
  AND rating_percentile <= 0.25

ORDER BY review_count DESC LIMIT 20;