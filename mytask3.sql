Create database DepartmentWorkers

CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL
);

CREATE TABLE Positions (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Limit INT NOT NULL
);

CREATE TABLE Workers (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Surname NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(50) NOT NULL,
    Salary DECIMAL(18, 2) NOT NULL,
    BirthDate DATE NOT NULL,
    DepartmentId INT,
    PositionId INT,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id),
    FOREIGN KEY (PositionId) REFERENCES Positions(Id)
);

CREATE FUNCTION GetDepartmentAverageSalary (@DepartmentId INT)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @AvgSalary DECIMAL(18, 2)
    SELECT @AvgSalary = AVG(Salary) FROM Workers WHERE DepartmentId = @DepartmentId
    RETURN @AvgSalary
END

CREATE TRIGGER CheckWorkerAge
ON Workers
After INSERT
AS
BEGIN
    DECLARE @BirthDate DATE
    SELECT @BirthDate = BirthDate FROM inserted

    IF DATEDIFF(YEAR, @BirthDate, GETDATE()) < 18
    BEGIN
        RAISERROR ('Worker age must be greater than 18', 16, 1)
    END
    ELSE
    BEGIN
        INSERT INTO Workers (Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId)
        SELECT Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId
        FROM inserted
    END
END

CREATE TRIGGER CheckPositionLimit
ON Workers
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @PositionId INT
    SELECT @PositionId = PositionId FROM inserted

    IF (SELECT COUNT(*) FROM Workers WHERE PositionId = @PositionId) >= (SELECT Limit FROM Positions WHERE Id = @PositionId)
    BEGIN
        RAISERROR ('Position limit reached', 16, 1)
    END
    ELSE
    BEGIN
        INSERT INTO Workers (Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId)
        SELECT Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId
        FROM inserted
    END
END
