SELECT COUNT(*) AS CurrentPatients
FROM dbo.DimPatient;

INSERT INTO dbo.DimPatient (
    PatientId,
    Gender
)
SELECT DISTINCT
    PatientId,
    Gender
FROM dbo.stg_Appointments
WHERE PatientId IS NOT NULL;

SELECT COUNT(*) AS TotalPatients
FROM dbo.DimPatient;

SELECT TOP 20 *
FROM dbo.DimPatient
ORDER BY PatientKey;

SELECT COUNT(*) AS PatientIdsEndingDotZero
FROM dbo.DimPatient
WHERE PatientId LIKE '%.0';

UPDATE dbo.stg_Appointments
SET PatientId = LEFT(PatientId, LEN(PatientId) - 2)
WHERE PatientId LIKE '%.0';

UPDATE dbo.DimPatient
SET PatientId = LEFT(PatientId, LEN(PatientId) - 2)
WHERE PatientId LIKE '%.0';

SELECT TOP 20 *
FROM dbo.DimPatient
ORDER BY PatientKey;

SELECT
    COUNT(*) AS DimensionRows,
    COUNT(DISTINCT PatientId) AS DistinctPatientIds
FROM dbo.DimPatient;

INSERT INTO dbo.DimNeighbourhood (
    NeighbourhoodName,
    NeighbourhoodCode,
    IncomeMean,
    IncomeMedian,
    ResponsiblePersons,
    Residents,
    IncomeGroup
)
SELECT DISTINCT
    Neighbourhood,
    NULL AS NeighbourhoodCode,
    IncomeMean,
    IncomeMedian,
    ResponsiblePersons,
    Residents,
    IncomeGroup
FROM dbo.stg_Appointments
WHERE Neighbourhood IS NOT NULL;

SELECT COUNT(*) AS TotalNeighbourhoods
FROM dbo.DimNeighbourhood;

SELECT TOP 20 *
FROM dbo.DimNeighbourhood
ORDER BY NeighbourhoodKey;

SELECT
    COUNT(*) AS DimensionRows,
    COUNT(DISTINCT NeighbourhoodName) AS DistinctNeighbourhoods
FROM dbo.DimNeighbourhood;

SELECT
    NeighbourhoodName,
    COUNT(*) AS Qty
FROM dbo.DimNeighbourhood
GROUP BY NeighbourhoodName
HAVING COUNT(*) > 1;

SELECT
    MIN(CAST(ScheduledDay AS DATE)) AS MinScheduledDate,
    MAX(CAST(AppointmentDay AS DATE)) AS MaxAppointmentDate
FROM dbo.stg_Appointments;

DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT
    @StartDate = MIN(CAST(ScheduledDay AS DATE)),
    @EndDate = MAX(CAST(AppointmentDay AS DATE))
FROM dbo.stg_Appointments;

WITH DateSeries AS (
    SELECT @StartDate AS [Date]

    UNION ALL

    SELECT DATEADD(DAY, 1, [Date])
    FROM DateSeries
    WHERE [Date] < @EndDate
)

INSERT INTO dbo.DimDate (
    DateKey,
    [Date],
    [Year],
    [Quarter],
    MonthNumber,
    MonthName,
    [Day],
    WeekdayNumber,
    WeekdayName,
    IsWeekend
)
SELECT
    CONVERT(INT, CONVERT(CHAR(8), [Date], 112)) AS DateKey,
    [Date],
    YEAR([Date]) AS [Year],
    DATEPART(QUARTER, [Date]) AS [Quarter],
    MONTH([Date]) AS MonthNumber,
    DATENAME(MONTH, [Date]) AS MonthName,
    DAY([Date]) AS [Day],
    DATEPART(WEEKDAY, [Date]) AS WeekdayNumber,
    DATENAME(WEEKDAY, [Date]) AS WeekdayName,
    CASE
        WHEN DATENAME(WEEKDAY, [Date]) IN ('Saturday', 'Sunday')
        THEN 1
        ELSE 0
    END AS IsWeekend
FROM DateSeries
OPTION (MAXRECURSION 0);

SELECT
    COUNT(*) AS TotalDates,
    MIN([Date]) AS MinDate,
    MAX([Date]) AS MaxDate
FROM dbo.DimDate;

SELECT TOP 20 *
FROM dbo.DimDate
ORDER BY [Date];