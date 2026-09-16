SELECT DB_NAME() AS CurrentDatabase;
CREATE TABLE DimPatient (
    PatientKey INT IDENTITY(1,1) PRIMARY KEY,
    PatientId BIGINT NOT NULL,
    Gender CHAR(1) NULL
);
SELECT *
FROM DimPatient;

CREATE TABLE DimNeighbourhood (
    NeighbourhoodKey INT IDENTITY(1,1) PRIMARY KEY,
    NeighbourhoodName VARCHAR(100) NOT NULL,
    NeighbourhoodCode VARCHAR(20) NULL,
    IncomeMean DECIMAL(12,2) NULL,
    IncomeMedian DECIMAL(12,2) NULL,
    ResponsiblePersons INT NULL,
    Residents INT NULL,
    IncomeGroup VARCHAR(30) NULL
);

SELECT *
FROM DimNeighbourhood;

CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    [Date] DATE NOT NULL,
    [Year] SMALLINT NOT NULL,
    [Quarter] TINYINT NOT NULL,
    MonthNumber TINYINT NOT NULL,
    MonthName VARCHAR(20) NOT NULL,
    [Day] TINYINT NOT NULL,
    WeekdayNumber TINYINT NOT NULL,
    WeekdayName VARCHAR(20) NOT NULL,
    IsWeekend BIT NOT NULL
);

SELECT *
FROM DimDate;

CREATE TABLE FactAppointment (
    AppointmentID BIGINT PRIMARY KEY,

    PatientKey INT NOT NULL,
    NeighbourhoodKey INT NOT NULL,
    ScheduledDateKey INT NOT NULL,
    AppointmentDateKey INT NOT NULL,

    Age INT NULL,
    AgeGroup VARCHAR(20) NULL,
    SMSReceived BIT NULL,
    WaitingDays INT NULL,
    WaitingGroup VARCHAR(20) NULL,
    ObservedVisitType VARCHAR(30) NULL,
    NoShowFlag BIT NOT NULL,
    AppointmentCount INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_FactAppointment_DimPatient
        FOREIGN KEY (PatientKey)
        REFERENCES DimPatient(PatientKey),

    CONSTRAINT FK_FactAppointment_DimNeighbourhood
        FOREIGN KEY (NeighbourhoodKey)
        REFERENCES DimNeighbourhood(NeighbourhoodKey),

    CONSTRAINT FK_FactAppointment_ScheduledDate
        FOREIGN KEY (ScheduledDateKey)
        REFERENCES DimDate(DateKey),

    CONSTRAINT FK_FactAppointment_AppointmentDate
        FOREIGN KEY (AppointmentDateKey)
        REFERENCES DimDate(DateKey)
);

SELECT *
FROM FactAppointment;

ALTER TABLE DimPatient
ALTER COLUMN PatientId VARCHAR(30) NOT NULL;