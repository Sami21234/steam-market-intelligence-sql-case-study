/*
Steam Market Intelligence
SQL - Data Quality Checks
*/

-- 1. Total games
SELECT
    COUNT(*) AS total_games
FROM dim_games;

-- 2. Total metric records
SELECT
    COUNT(*) AS total_metric_records
FROM fact_game_metrics;

-- 3. Latest snapshot
SELECT
    MAX(snapshot_date) AS latest_snapshot
FROM fact_game_metrics;

-- 4. Duplicate game + snapshot records
SELECT
    game_id,
    snapshot_date,
    COUNT(*) AS duplicate_count
FROM fact_game_metrics
GROUP BY
    game_id,
    snapshot_date
HAVING COUNT(*) > 1;

-- 5. Games with missing price
SELECT
    COUNT(*) AS missing_price_records
FROM fact_game_metrics
WHERE price IS NULL;

-- 6. Games with missing review count
SELECT
    COUNT(*) AS missing_review_records
FROM fact_game_metrics
WHERE review_count IS NULL;

-- 7. Invalid positive review percentages
SELECT
    COUNT(*) AS invalid_positive_percent
FROM fact_game_metrics
WHERE positive_percent IS NOT NULL
AND (
    positive_percent < 0
    OR positive_percent > 100
);

-- 8. Invalid discount percentages
SELECT
    COUNT(*) AS invalid_discount_percent
FROM fact_game_metrics
WHERE discount_percent IS NOT NULL
AND (
    discount_percent < 0
    OR discount_percent > 100
);

-- 9. Games with multiple historical snapshots
SELECT
    COUNT(*) AS games_with_multiple_snapshots
FROM (
    SELECT
        game_id
    FROM fact_game_metrics
    GROUP BY game_id
    HAVING COUNT(DISTINCT snapshot_date) > 1
) AS historical_games;

-- 10. Snapshot coverage
SELECT
    snapshot_date,
    COUNT(*) AS records,
    COUNT(DISTINCT game_id) AS unique_games
FROM fact_game_metrics
GROUP BY snapshot_date
ORDER BY snapshot_date;