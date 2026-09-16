SELECT COUNT(*) AS TotalFactRows
FROM dbo.FactAppointment;

-- Appointment uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT AppointmentID) AS DistinctAppointments
FROM dbo.FactAppointment;

-- Orphan PatientKey
SELECT COUNT(*) AS MissingPatients
FROM dbo.FactAppointment f
LEFT JOIN dbo.DimPatient p
    ON f.PatientKey = p.PatientKey
WHERE p.PatientKey IS NULL;

-- Orphan NeighbourhoodKey
SELECT COUNT(*) AS MissingNeighbourhoods
FROM dbo.FactAppointment f
LEFT JOIN dbo.DimNeighbourhood n
    ON f.NeighbourhoodKey = n.NeighbourhoodKey
WHERE n.NeighbourhoodKey IS NULL;

-- Orphan ScheduledDateKey
SELECT COUNT(*) AS MissingScheduledDates
FROM dbo.FactAppointment f
LEFT JOIN dbo.DimDate d
    ON f.ScheduledDateKey = d.DateKey
WHERE d.DateKey IS NULL;

-- Orphan AppointmentDateKey
SELECT COUNT(*) AS MissingAppointmentDates
FROM dbo.FactAppointment f
LEFT JOIN dbo.DimDate d
    ON f.AppointmentDateKey = d.DateKey
WHERE d.DateKey IS NULL;

-- Main business metrics
SELECT
    COUNT(*) AS Appointments,
    SUM(CAST(NoShowFlag AS INT)) AS NoShows,
    CAST(
        SUM(CAST(NoShowFlag AS INT)) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS NoShowRate
FROM dbo.FactAppointment;