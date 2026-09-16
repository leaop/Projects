SELECT COUNT(*) AS StagingRows
FROM dbo.stg_Appointments;

SELECT COUNT(*) AS RowsAfterJoins
FROM dbo.stg_Appointments AS s

INNER JOIN dbo.DimPatient AS p
    ON s.PatientId = p.PatientId

INNER JOIN dbo.DimNeighbourhood AS n
    ON s.Neighbourhood = n.NeighbourhoodName

INNER JOIN dbo.DimDate AS sd
    ON CAST(s.ScheduledDay AS DATE) = sd.[Date]

INNER JOIN dbo.DimDate AS ad
    ON CAST(s.AppointmentDay AS DATE) = ad.[Date];

    INSERT INTO dbo.FactAppointment (
    AppointmentID,
    PatientKey,
    NeighbourhoodKey,
    ScheduledDateKey,
    AppointmentDateKey,
    Age,
    AgeGroup,
    SMSReceived,
    WaitingDays,
    WaitingGroup,
    ObservedVisitType,
    NoShowFlag,
    AppointmentCount
)

SELECT
    s.AppointmentID,
    p.PatientKey,
    n.NeighbourhoodKey,
    sd.DateKey,
    ad.DateKey,
    s.Age,

    CASE
        WHEN s.Age < 18 THEN '0-17'
        WHEN s.Age BETWEEN 18 AND 29 THEN '18-29'
        WHEN s.Age BETWEEN 30 AND 44 THEN '30-44'
        WHEN s.Age BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60+'
    END AS AgeGroup,

    s.SMS_received,
    s.WaitingDays,
    s.WaitingGroup,
    s.ObservedVisitType,
    s.NoShowFlag,
    1 AS AppointmentCount

FROM dbo.stg_Appointments AS s

INNER JOIN dbo.DimPatient AS p
    ON s.PatientId = p.PatientId

INNER JOIN dbo.DimNeighbourhood AS n
    ON s.Neighbourhood = n.NeighbourhoodName

INNER JOIN dbo.DimDate AS sd
    ON CAST(s.ScheduledDay AS DATE) = sd.[Date]

INNER JOIN dbo.DimDate AS ad
    ON CAST(s.AppointmentDay AS DATE) = ad.[Date];


SELECT COUNT(*) AS TotalFactRows
FROM dbo.FactAppointment;

SELECT TOP 20 *
FROM dbo.FactAppointment
ORDER BY AppointmentID;

SELECT COUNT(*) AS TotalFactRows
FROM dbo.FactAppointment;

SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT AppointmentID) AS DistinctAppointments
FROM dbo.FactAppointment;

SELECT COUNT(*) AS MissingPatients
FROM dbo.FactAppointment f
LEFT JOIN dbo.DimPatient p
    ON f.PatientKey = p.PatientKey
WHERE p.PatientKey IS NULL;

SELECT COUNT(*) AS MissingNeighbourhoods
FROM dbo.FactAppointment f
LEFT JOIN dbo.DimNeighbourhood n
    ON f.NeighbourhoodKey = n.NeighbourhoodKey
WHERE n.NeighbourhoodKey IS NULL;

SELECT COUNT(*) AS MissingScheduledDates
FROM dbo.FactAppointment f
LEFT JOIN dbo.DimDate d
    ON f.ScheduledDateKey = d.DateKey
WHERE d.DateKey IS NULL;

SELECT COUNT(*) AS MissingAppointmentDates
FROM dbo.FactAppointment f
LEFT JOIN dbo.DimDate d
    ON f.AppointmentDateKey = d.DateKey
WHERE d.DateKey IS NULL;

SELECT
    COUNT(*) AS Appointments,
    SUM(CAST(NoShowFlag AS INT)) AS NoShows,
    CAST(
        SUM(CAST(NoShowFlag AS INT)) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS NoShowRate
FROM dbo.FactAppointment;