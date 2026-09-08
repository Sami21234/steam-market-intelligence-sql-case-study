
/*
Steam Market Intelligence
SQL Case Study - Market Overview

Purpose:
    Establish a high-level overview of the Steam dataset.

Business Questions:
    1. How many unique games are available?
    2. How many historical metric records exist?
    3. How many snapshot dates were collected?
    4. What is the latest snapshot date?
    5. What is the average game price?
    6. What is the average positive review percentage?

*/

-- 1. Total number of unique games
SELECT 
    COUNT(*) AS total_unique_games
FROM (
    SELECT DISTINCT * 
    FROM dim_games
) AS unique_games;

-- 2. Total number of historical metric records
SELECT 
    COUNT(*) AS total_metric_records
FROM fact_game_metrics;

-- 3. Snapshot coverage
SELECT
    COUNT(DISTINCT snapshot_date) AS total_snapshot_dates,
    MIN(snapshot_date) AS first_snapshot,
    MAX(snapshot_date) AS latest_snapshot
FROM fact_game_metrics;

-- 4. Overall pricing and review statistics
SELECT 
    COUNT(*) AS total_metric_records,
    ROUND(AVG(price), 2) AS average_price,
    ROUND(AVG(positive_percent), 2) AS average_positive_percent,
    ROUND(AVG(review_count), 2) AS average_review_count
FROM fact_game_metrics;

-- 5. Free-to_play games
SELECT 
    COUNT(DISTINCT game_id) AS free_to_play_games
FROM fact_game_metrics
WHERE price = 0;