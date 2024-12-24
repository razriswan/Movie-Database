
create database Movie;
use movie;

create table Movies(
MovieID int auto_increment  primary key,  
Title varchar(20),
ReleaseYear int,
DirectorID int,
GenreID int,
Rating float,
foreign key(DirectorID) references Directors(DirectorID),
foreign key(GenreID) references Genres(GenreID)
);

insert into Movies(MovieID,Title ,ReleaseYear ,DirectorID ,GenreID ,Rating)values
(123,"king lier",2008,1,542,"8.4"),
(141,"Boomer",2018,3,481,"6.4"),
(135,"Spiderman",2019,1,954,"7.1"),
(142,"Solomen's life ",2011,2,471,"7.7"),
(184,"Bad boy",2022,1,954,"6.9");

create table Actors(
ActorID int auto_increment  primary key, 
ActorName varchar(20),
BirthYear int
);

insert into Actors(ActorID,ActorName,BirthYear) values
(21,"Smith",1980),
(22,"william",1985),
(23,"john",1979),
(24,"jack",1992),
(25,"srk",1980);

create table Directors(
DirectorID int auto_increment  primary key, 
DirectorName varchar(20)
);

insert into Directors(DirectorID,DirectorName) values
(1,"Steven"),
(2,"Martin"),
(3,"Nolan");

create table Reviews(
ReviewID int auto_increment  primary key, 
MovieID int,
ReviewerName varchar(20),
Comment text,
Rating float,
foreign key(MovieID)references Movies(MovieID)
);

insert into Reviews(ReviewID,MovieID,ReviewerName ,Comment ,Rating)values
(001,123,"Billy","Amazing movie with a great storyline!","7.8"),
(002,141,"David","Good performances, but the pacing was slow.","6.9"),
(003,135,"Angel","An absolute masterpiece! A must-watch","8.9"),
(004,142,"Joy","Not my type of movie, but well-made.","7.2"),
(005,184,"Beckam","Interesting plot but a bit predictable.","7.0");

create table Genres(
GenreID int auto_increment  primary key, 
GenreName varchar(20)
);

insert into Genres(GenreID,GenreName)values
(481,"Thriller"),
(542,"Comedy"),
(471,'Drama'),
(954,"Action");

create table MovieActors(
MovieID int, 
ActorID int,
foreign key(MovieID)references Movies(MovieID),
foreign key(ActorID)references Actors(ActorID)
);

insert into MovieActors(MovieID,ActorID)values
(123,24),
(141,21),
(141,25),
(135,22),
(142,23),
(184,24),
(184,22);

select * from Movies; 
select * from Actors;
select * from Directors;
select * from Reviews;
select * from Genres;
select * from MovieActors;


#Find movies of "Action" genre along with their directors and main cast.

select m.Title, g.GenreName , d.DirectorName, group_concat(a.ActorName)
from Movies m
inner join Genres g on m.GenreID=g.GenreID
inner join Directors d ON m.DirectorID = d.DirectorID
inner join MovieActors ma ON m.MovieID = ma.MovieID
inner JOIN Actors a ON ma.ActorID = a.ActorID
where g.GenreName="Action"
GROUP BY m.MovieID;

#Find the main actors who acted in "Boomer" movie

select a.ActorName
from Actors a
join MovieActors ma on a.ActorID=ma.ActorID
join Movies m on ma.MovieID=m.MovieID
where m.Title="Boomer";

#Find the top 5 highest-rated movies and their average ratings.

select Title,Rating 
from Movies
where rating >= (SELECT AVG(Rating) FROM Movies)
order by Rating desc limit 5;

#Subqueries

#Finding movies with a rating above 7.5

select m.Title,m.ReleaseYear
from Movies m
where m.MovieID in(
	select MovieID
    from Reviews
    where rating>7.5
);

#Find the average rating for a specific director:

SELECT d.DirectorName, AVG(m.Rating) AS avg_rating
FROM Movies m
join Directors d on m.DirectorID = d.DirectorID
where DirectorName="Martin";

#Stored Procedure to Count Movies by Genre

DELIMITER $$

create procedure GetMovieCountByGenre(IN GenreName varchar(255))
begin
	select g.GenreName, count(m.MovieID) AS MovieCount
    from Movies m
    join Genres g on m.GenreID=g.GenreID
    where g.GenreName=GenreName
	group by g.GenreID;
    
end $$

DELIMITER ;
call GetMovieCountByGenre('Action');

#Stored Procedure to find Movies by the actor name

DELIMITER $$

CREATE PROCEDURE GetMoviesByActorName(IN ActorName VARCHAR(255))
BEGIN
    SELECT m.Title
    FROM Movies m
    JOIN MovieActor ma ON m.MovieID = ma.MovieID
    JOIN Actors a ON ma.ActorID = a.ActorID
    WHERE a.ActorName LIKE CONCAT('%', ActorName, '%');
END $$

DELIMITER ;
call GetMoviesByActorName('Smith');

#Index function

CREATE INDEX idx_genre_name ON Genres(GenreName);
show index from Genres;

#Create view method

CREATE VIEW MovieRatings AS
SELECT 
    m.MovieID, 
    m.Title, 
    AVG(r.Rating) AS AvgRating
FROM 
    Movies m
LEFT JOIN Reviews r ON m.MovieID = r.MovieID
GROUP BY 
    m.MovieID, m.Title;

SELECT * FROM MovieRatings;

#String function

SELECT UPPER(title)
FROM Movies;

SELECT title
FROM Movies
WHERE title LIKE 'K%';

SELECT CONCAT(d.DirectorName, ' directed ', m.Title) AS DirectorMovie
FROM Movies m
JOIN Directors d ON m.DirectorID = d.DirectorID;




#Top 2 Directors with the Most Movies

SELECT 
    DirectorName, 
    MovieCount
FROM (
    SELECT 
        d.DirectorName, 
        COUNT(m.MovieID) AS MovieCount
    FROM 
        Directors d
    LEFT JOIN Movies m ON d.DirectorID = m.DirectorID
    GROUP BY 
        d.DirectorID
) AS DirectorStats
ORDER BY 
    MovieCount DESC
LIMIT 2;

#Total Reviews and Average Rating by Genre

SELECT 
    g.GenreName, 
    COUNT(r.ReviewID) AS TotalReviews, 
    AVG(r.Rating) AS AverageRating
FROM 
    Genres g
LEFT JOIN Movies m ON g.GenreID = m.GenreID
LEFT JOIN Reviews r ON m.MovieID = r.MovieID
GROUP BY 
    g.GenreID;


#Finding the Highest Rated Movie in Each Genre 

SELECT 
    g.GenreName, 
    m.Title AS MovieTitle, 
    m.Rating as highest_rating
FROM 
    Movies m
JOIN 
    Genres g ON m.GenreID = g.GenreID
WHERE 
    m.Rating = (
        SELECT 
            MAX(m1.Rating)
        FROM 
            Movies m1
        WHERE 
            m1.GenreID = m.GenreID
    );
