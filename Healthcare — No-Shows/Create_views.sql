CREATE OR ALTER VIEW dbo.vw_NoShowOverview
AS

SELECT
    COUNT(*) AS TotalAppointments,

    SUM(
        CAST(NoShowFlag AS INT)
    ) AS TotalNoShows,

    CAST(
        SUM(CAST(NoShowFlag AS INT)) * 100.0
        / COUNT(*)
        AS DECIMAL(5,2)
    ) AS NoShowRate,

    CAST(
        AVG(CAST(WaitingDays AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageWaitingDays

FROM dbo.FactAppointment;

SELECT *
FROM dbo.vw_NoShowOverview;

CREATE OR ALTER VIEW dbo.vw_NoShowByNeighbourhood
AS

SELECT
    n.NeighbourhoodKey,
    n.NeighbourhoodName,
    n.IncomeMedian,
    n.IncomeGroup,

    COUNT(*) AS Appointments,

    SUM(
        CAST(f.NoShowFlag AS INT)
    ) AS NoShows,

    CAST(
        SUM(CAST(f.NoShowFlag AS INT)) * 100.0
        / COUNT(*)
        AS DECIMAL(5,2)
    ) AS NoShowRate

FROM dbo.FactAppointment AS f

INNER JOIN dbo.DimNeighbourhood AS n
    ON f.NeighbourhoodKey = n.NeighbourhoodKey

GROUP BY
    n.NeighbourhoodKey,
    n.NeighbourhoodName,
    n.IncomeMedian,
    n.IncomeGroup;
    
SELECT *
FROM dbo.vw_NoShowByNeighbourhood
ORDER BY NoShows DESC;

CREATE OR ALTER VIEW dbo.vw_NoShowByWaitingGroup
AS

SELECT
    WaitingGroup,

    COUNT(*) AS Appointments,

    SUM(
        CAST(NoShowFlag AS INT)
    ) AS NoShows,

    CAST(
        SUM(CAST(NoShowFlag AS INT)) * 100.0
        / COUNT(*)
        AS DECIMAL(5,2)
    ) AS NoShowRate,

    CAST(
        AVG(CAST(WaitingDays AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageWaitingDays

FROM dbo.FactAppointment

GROUP BY
    WaitingGroup;

SELECT *
FROM dbo.vw_NoShowByWaitingGroup;

CREATE OR ALTER VIEW dbo.vw_NoShowBySMS
AS

SELECT
    SMSReceived,

    CASE
        WHEN SMSReceived = 1 THEN 'SMS received'
        ELSE 'No SMS'
    END AS SMSStatus,

    COUNT(*) AS Appointments,

    SUM(
        CAST(NoShowFlag AS INT)
    ) AS NoShows,

    CAST(
        SUM(CAST(NoShowFlag AS INT)) * 100.0
        / COUNT(*)
        AS DECIMAL(5,2)
    ) AS NoShowRate,

    CAST(
        AVG(CAST(WaitingDays AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageWaitingDays

FROM dbo.FactAppointment

GROUP BY
    SMSReceived;

CREATE OR ALTER VIEW dbo.vw_CommunicationPriority
AS

SELECT
    f.WaitingGroup,
    f.ObservedVisitType,
    n.IncomeGroup,
    f.SMSReceived,

    COUNT(*) AS Appointments,

    SUM(
        CAST(f.NoShowFlag AS INT)
    ) AS NoShows,

    CAST(
        SUM(CAST(f.NoShowFlag AS INT)) * 100.0
        / COUNT(*)
        AS DECIMAL(5,2)
    ) AS NoShowRate

FROM dbo.FactAppointment AS f

INNER JOIN dbo.DimNeighbourhood AS n
    ON f.NeighbourhoodKey = n.NeighbourhoodKey

GROUP BY
    f.WaitingGroup,
    f.ObservedVisitType,
    n.IncomeGroup,
    f.SMSReceived;

SELECT *
FROM dbo.vw_CommunicationPriority
WHERE
    SMSReceived = 0
    AND NoShowRate > 20.19
ORDER BY
    NoShows DESC,
    NoShowRate DESC;