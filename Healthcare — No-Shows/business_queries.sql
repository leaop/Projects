-- 1. Overall KPIs
SELECT *
FROM dbo.vw_NoShowOverview;


-- 2. No-show by neighbourhood
SELECT *
FROM dbo.vw_NoShowByNeighbourhood
ORDER BY NoShows DESC;


-- 3. Highest no-show rates by neighbourhood
SELECT *
FROM dbo.vw_NoShowByNeighbourhood
WHERE Appointments >= 100
ORDER BY NoShowRate DESC;


-- 4. No-show by income group
SELECT
    IncomeGroup,
    SUM(Appointments) AS Appointments,
    SUM(NoShows) AS NoShows,
    CAST(
        SUM(NoShows) * 100.0 / SUM(Appointments)
        AS DECIMAL(5,2)
    ) AS NoShowRate
FROM dbo.vw_NoShowByNeighbourhood
WHERE IncomeGroup IS NOT NULL
GROUP BY IncomeGroup
ORDER BY NoShowRate DESC;


-- 5. No-show by waiting group
SELECT *
FROM dbo.vw_NoShowByWaitingGroup
ORDER BY
    CASE WaitingGroup
        WHEN 'Same day' THEN 1
        WHEN '1-2 days' THEN 2
        WHEN '3-7 days' THEN 3
        WHEN '8-14 days' THEN 4
        WHEN '15-30 days' THEN 5
        WHEN '31-60 days' THEN 6
        WHEN '61+ days' THEN 7
    END;


-- 6. SMS comparison
SELECT *
FROM dbo.vw_NoShowBySMS;


-- 7. SMS comparison controlled by waiting group
SELECT
    WaitingGroup,
    SMSReceived,
    COUNT(*) AS Appointments,
    SUM(CAST(NoShowFlag AS INT)) AS NoShows,
    CAST(
        SUM(CAST(NoShowFlag AS INT)) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS NoShowRate
FROM dbo.FactAppointment
GROUP BY
    WaitingGroup,
    SMSReceived
ORDER BY
    CASE WaitingGroup
        WHEN 'Same day' THEN 1
        WHEN '1-2 days' THEN 2
        WHEN '3-7 days' THEN 3
        WHEN '8-14 days' THEN 4
        WHEN '15-30 days' THEN 5
        WHEN '31-60 days' THEN 6
        WHEN '61+ days' THEN 7
    END,
    SMSReceived;


-- 8. Average waiting time
SELECT
    CAST(
        AVG(CAST(WaitingDays AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageWaitingDays
FROM dbo.FactAppointment;


-- 9. Recoverable capacity scenarios
WITH NoShowBase AS (
    SELECT
        SUM(CAST(NoShowFlag AS INT)) AS TotalNoShows
    FROM dbo.FactAppointment
)

SELECT
    TotalNoShows,
    CAST(TotalNoShows * 0.10 AS INT) AS RecoverableSlots_10pct,
    CAST(TotalNoShows * 0.20 AS INT) AS RecoverableSlots_20pct,
    CAST(TotalNoShows * 0.30 AS INT) AS RecoverableSlots_30pct
FROM NoShowBase;


-- 10. Communication priority
SELECT *
FROM dbo.vw_CommunicationPriority
WHERE
    SMSReceived = 0
    AND NoShowRate > 20.19
ORDER BY
    NoShows DESC,
    NoShowRate DESC;