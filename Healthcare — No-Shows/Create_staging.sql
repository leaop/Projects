SELECT DB_NAME() AS CurrentDatabase;
CREATE TABLE stg_Appointments (
    PatientId BIGINT NULL,
    AppointmentID BIGINT NULL,
    Gender CHAR(1) NULL,
    ScheduledDay DATETIME2 NULL,
    AppointmentDay DATE NULL,
    Age INT NULL,
    Neighbourhood VARCHAR(100) NULL,
    Scholarship BIT NULL,
    Hypertension BIT NULL,
    Diabetes BIT NULL,
    Alcoholism BIT NULL,
    Handicap INT NULL,
    SMS_received BIT NULL,
    NoShowFlag BIT NULL,
    WaitingDays INT NULL,
    WaitingGroup VARCHAR(20) NULL,
    ObservedVisitType VARCHAR(30) NULL,
    IncomeMean DECIMAL(12,2) NULL,
    IncomeMedian DECIMAL(12,2) NULL,
    ResponsiblePersons INT NULL,
    Residents INT NULL,
    IncomeGroup VARCHAR(30) NULL
);

SELECT *
FROM stg_Appointments;

ALTER TABLE stg_Appointments
ALTER COLUMN PatientId VARCHAR(30) NULL;

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME = 'PatientId';

SELECT COUNT(*) AS RowsBeforeLoad
FROM stg_Appointments;

SELECT COUNT(*) AS RowsAfterLoad
FROM stg_Appointments;

SELECT COUNT(*) AS CurrentRows
FROM dbo.stg_Appointments;

SELECT COUNT(*) AS TotalRows
FROM dbo.stg_Appointments;