CREATE DATABASE MoviesApp

CREATE TABLE Directors(
 Id INT PRIMARY KEY IDENTITY,
 Name NVARCHAR(50) NOT NULL,
 Surname NVARCHAR(50) NOT NULL
)
CREATE TABLE Languages(
 Id INT PRIMARY KEY IDENTITY,
 Name NVARCHAR(50) NOT NULL,
)

CREATE TABLE Movies(
 Id INT PRIMARY KEY IDENTITY,
 Name NVARCHAR(50) NOT NULL,
 Description NVARCHAR(200),
 CoverPhoto NVARCHAR(50),
 DirectorID INT FOREIGN KEY REFERENCES Directors(Id),
 LanguageID INT FOREIGN KEY REFERENCES Languages(Id)
)



CREATE TABLE Actors(
 Id INT PRIMARY KEY IDENTITY,
 Name NVARCHAR(50) NOT NULL,
 Surname NVARCHAR(50) NOT NULL
)

CREATE TABLE Genres(
 Id INT PRIMARY KEY IDENTITY,
 Name NVARCHAR(50) NOT NULL,
)

CREATE TABLE MoviesActors(
Id INT PRIMARY KEY IDENTITY,
MovieID INT FOREIGN KEY REFERENCES Movies(Id),
ActorID INT FOREIGN KEY REFERENCES Actors(Id)
)

CREATE TABLE MoviesGenres(
Id INT PRIMARY KEY IDENTITY,
MovieID INT FOREIGN KEY REFERENCES Movies(Id),
GenreID INT FOREIGN KEY REFERENCES Genres(Id)
)


INSERT INTO Actors 
VALUES ('Robert', 'Downey Jr.'),
       ('Chris', 'Hemsworth'),
       ('Jennifer', 'Lawrence'),
       ('Emma', 'Stone');


INSERT INTO Languages
VALUES ('Spanish'),
       ('French'),
       ('German'),
       ('Japanese');

INSERT INTO Genres
VALUES ('Horror'),
       ('Thriller'),
       ('Sci-Fi'),
       ('Fantasy');

INSERT INTO Directors
VALUES ('Steven', 'Spielberg'),
       ('Christopher', 'Nolan'),
       ('Quentin', 'Tarantino');

INSERT INTO Movies
VALUES ('Inception', 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a CEO.', 'URL4', 2, 2),
       ('Jurassic Park', 'During a preview tour, a theme park suffers a major power breakdown that allows its cloned dinosaur exhibits to run amok.', 'URL5', 1, 3),
       ('Pulp Fiction', 'The lives of two mob hitmen, a boxer, a gangster and his wife, and a pair of diner bandits intertwine in four tales of violence and redemption.', 'URL6', 3, 1);



SELECT * FROM Movies
SELECT * FROM Actors
SELECT * FROM Genres
SELECT * FROM Directors
SELECT * FROM MOVIESACTORS
SELECT * FROM MoviesGenres



INSERT INTO MoviesGenres
VALUES (2, 2),
       (2, 3),
       (3, 1),
       (4, 2);

INSERT INTO MoviesActors
VALUES (2, 2),
       (2, 4),
       (3, 1),
       (3, 3),
       (4, 1),
       (4, 4);



CREATE OR ALTER PROCEDURE GetDirectorMovies @directorId INT
AS
BEGIN
    SELECT 
        Movies.name AS 'MovieName',
        Languages.name AS Language
    FROM 
        Movies
    JOIN 
        Languages ON Movies.languageID = Languages.id
    WHERE 
        Movies.directorId = @directorId;
END;

EXEC GetDirectorMovies 2

CREATE OR ALTER FUNCTION GetMoviesCountByLanguage (@languageId INT)
RETURNS INT
AS
BEGIN
    DECLARE @movieCount INT;

    SELECT @movieCount = COUNT(*)
    FROM Movies
    WHERE languageId = @languageId;

    RETURN @movieCount;
END;

SELECT dbo.GetMoviesCountByLanguage(1);

CREATE OR ALTER PROCEDURE GetGenreMovies
    @genreId INT
AS
BEGIN
    SELECT m.Id, m.Name AS MovieName, d.Name AS DirectorName
    FROM Movies m
    JOIN MoviesGenres mg ON m.Id = mg.MovieID
    JOIN Directors d ON m.DirectorID = d.Id
    WHERE mg.GenreID = @genreId;
END;


CREATE OR ALTER FUNCTION HasActorParticipatedInMoreThanThreeMovies (@actorId INT)
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT;

    IF (SELECT COUNT(*) FROM MoviesActors WHERE ActorID = @actorId) > 3
    BEGIN
        SET @result = 1;
    END
    ELSE
    BEGIN
        SET @result = 0; 
    END

    RETURN @result;
END;


CREATE TRIGGER trg_AfterInsertMovie
ON Movies
AFTER INSERT
AS
BEGIN
    SELECT m.Id, m.Name AS MovieName, d.Name AS DirectorName, l.Name AS Language
    FROM Movies m
    JOIN Directors d ON m.DirectorID = d.Id
    JOIN Languages l ON m.LanguageID = l.Id;
END;




