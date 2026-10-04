-- ============================================================
-- SHIPTIVITAS ANALYTICS
-- Feature: Kanban Board
-- Release date: 2018-06-02
--
-- This file contains the SQL solution for:
-- 1. Daily active users before and after the feature release
-- 2. Average daily active users by period
-- 3. Daily status changes by card
-- ============================================================


-- ============================================================
-- QUERY 1
-- Daily active users before and after Kanban Board release
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
-- Average daily active users before vs after release
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
-- Daily number of status changes by card
-- ============================================================

SELECT
    date(h.timestamp, 'unixepoch') AS day,
    c.id AS card_id,
    c.name AS card_name,
    COUNT(*) AS status_changes
FROM card_change_history h
JOIN card c
    ON c.id = h.cardID
WHERE h.oldStatus IS NOT NULL
  AND h.oldStatus <> h.newStatus
GROUP BY
    day,
    c.id,
    c.name
ORDER BY
    day,
    status_changes DESC;


-- ============================================================
-- QUERY 4
-- Total status changes by card
-- Useful for identifying cards/workflows with the most activity.
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
GROUP BY
    c.id,
    c.name
ORDER BY
    status_changes DESC;


-- ============================================================
-- KEY FINDINGS
--
-- Average DAU before Kanban Board: 3.63
-- Average DAU after Kanban Board: 11.79
--
-- This represents approximately:
--   3.25x higher average DAU
--   approximately 225% increase
--
-- The card with the highest number of recorded status changes
-- was Kutch-Mueller (card 187), with 5 changes.
--
-- Note:
-- The increase in DAU happened after the Kanban Board release,
-- but this analysis alone does not prove that the feature caused
-- the increase. Other factors may have contributed.
-- ============================================================


-- ============================================================
-- ACTIONABLE IDEA 1
--
-- Hypothesis:
-- Making workflow progress visually clear encourages users
-- to return more frequently.
--
-- Expected Impact:
-- Higher repeat usage and higher daily active users.
--
-- What the feature is:
-- Improve the Kanban Board with clearer visual progress,
-- lane counts, and an obvious "what needs attention" view.
-- ============================================================


-- ============================================================
-- ACTIONABLE IDEA 2
--
-- Hypothesis:
-- Users are more likely to return when they can quickly see
-- cards that require action or have recently changed status.
--
-- Expected Impact:
-- More repeat sessions and increased daily active users.
--
-- What the feature is:
-- Add a "Needs Attention" view showing cards that recently
-- changed status or are waiting for the user's next action.
-- ============================================================


-- ============================================================
-- ACTIONABLE IDEA 3
--
-- Hypothesis:
-- Cards with frequent status changes represent highly active
-- workflows and can be used to identify opportunities for
-- engagement features.
--
-- Expected Impact:
-- Encourage users to interact with active cards more often,
-- increasing recurring usage and DAU.
--
-- What the feature is:
-- Add recent activity/history to each card, showing status
-- changes and the latest activity so users can immediately
-- understand what has changed.
-- ============================================================