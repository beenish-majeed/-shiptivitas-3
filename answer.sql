-- ============================================================
-- SHIPTIVITAS MODULE 3
-- Analytics - Analyse the latest feature releases
--
-- Kanban Board release date: 2018-06-02
--
-- Key finding:
-- Average daily active users increased from 3.63 before the
-- Kanban Board release to 11.79 after the release.
-- This is approximately a 3.25x increase (+225%).
--
-- Note: this shows correlation, not proof that the Kanban Board
-- alone caused the increase.
-- ============================================================


-- ============================================================
-- QUERY 1
-- DAILY ACTIVE USERS BEFORE AND AFTER KANBAN BOARD
--
-- Use this result to create the daily DAU time-series graph.
-- ============================================================

SELECT
    date(login_timestamp, 'unixepoch') AS day,
    COUNT(DISTINCT user_id) AS daily_active_users,
    CASE
        WHEN date(login_timestamp, 'unixepoch') < '2018-06-02'
            THEN 'Before Kanban Board'
        ELSE 'After Kanban Board'
    END AS period
FROM login_history
GROUP BY day
ORDER BY day;


-- ============================================================
-- QUERY 2
-- AVERAGE DAILY ACTIVE USERS BEFORE VS AFTER
-- ============================================================

SELECT
    period,
    ROUND(AVG(daily_active_users), 2) AS average_daily_active_users
FROM (
    SELECT
        date(login_timestamp, 'unixepoch') AS day,
        COUNT(DISTINCT user_id) AS daily_active_users,
        CASE
            WHEN date(login_timestamp, 'unixepoch') < '2018-06-02'
                THEN 'Before Kanban Board'
            ELSE 'After Kanban Board'
        END AS period
    FROM login_history
    GROUP BY day
)
GROUP BY period
ORDER BY period;


-- ============================================================
-- QUERY 3
-- STATUS CHANGES BY CARD
--
-- Initial card creation is excluded because oldStatus is NULL.
-- ============================================================

SELECT
    c.id AS card_id,
    c.name AS card_name,
    COUNT(*) AS status_changes
FROM card_change_history h
JOIN card c
    ON c.id = h.cardID
WHERE h.oldStatus IS NOT NULL
  AND h.oldStatus <> h.newStatus
GROUP BY c.id, c.name
ORDER BY status_changes DESC;


-- ============================================================
-- DATA-BACKED INSIGHTS
--
-- 1. Hypothesis:
--    The Kanban Board increased user engagement by making work
--    progress easier to visualize and manage.
--
--    Expected Impact:
--    Higher and more consistent daily active usage.
--
--    What the feature is:
--    A visual board that organizes cards by workflow status,
--    allowing users to see and update work progress.
--
--
-- 2. Hypothesis:
--    Making workflow changes easier and more visible can encourage
--    users to interact with cards more frequently.
--
--    Expected Impact:
--    More repeat sessions and higher DAU through regular workflow
--    management.
--
--    What the feature is:
--    Cards can move between workflow statuses, providing a simple
--    visual representation of progress.
--
--
-- 3. Hypothesis:
--    Cards with frequent status changes represent highly active
--    workflows and can be used to identify behaviours worth
--    encouraging across the product.
--
--    Expected Impact:
--    Increase engagement by making successful workflow patterns
--    easier for users to discover and repeat.
--
--    What the feature is:
--    The product records card status transitions in
--    card_change_history, allowing teams to analyse workflow
--    activity.
--
--
-- KEY DATA POINTS
--
-- Before Kanban Board average DAU: 3.63
-- After Kanban Board average DAU: 11.79
-- Approximate increase: 225%
-- Approximate multiplier: 3.25x
--
-- Highest observed status-change card:
-- Kutch-Mueller (card 187): 5 status changes
--
-- Other highly active cards:
-- Osinski Inc: 4
-- O'Kon Group: 4
-- Boehm, West and Oberbrunner: 4
-- O'Keefe Inc: 4
--
-- Caution:
-- The increase in DAU coincides with the Kanban Board release but
-- does not establish causation. Other product or user-growth
-- factors may also have contributed.
-- ============================================================