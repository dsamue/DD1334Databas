--Q1: KLAR
SELECT *
FROM Countries

	NATURAL LEFT OUTER JOIN

(SELECT country, SUM(count) AS medals
FROM 
(
	(SELECT country, COUNT(country) FROM Sports, Nationality WHERE gold = nationality.contestant_id GROUP BY country)
		UNION
	(SELECT country, COUNT(country) FROM Sports, Nationality WHERE silver = nationality.contestant_id GROUP BY country)
		UNION
	(SELECT country, COUNT(country) FROM Sports, Nationality WHERE bronze = nationality.contestant_id GROUP BY country)
) 
AS Medals
GROUP BY country) AS Q1;


--Q2: KLAR
SELECT time, sport
FROM Competitions
WHERE time LIKE ('2020-08-14%') AND location_id IN 
(SELECT location_id FROM Locations WHERE arena = 'Friends Arena');


--Q3: KLAR
SELECT country                                                             
FROM Nationality
WHERE contestant_id IN 
(SELECT contestant_id FROM Practice WHERE sport = 'Slalom' AND gender = 'F');


--Q4: KLAR
SELECT arena, location, time
FROM Competitions, Locations
WHERE sport = 'Bobsleigh' AND round = 'Final' and Competitions.location_id = Locations.location_id;

--Q5: KLAR
SELECT name 
FROM athletes 
WHERE athlete_id IN 
(SELECT athlete_id FROM TeamMembers WHERE position = 'Goal Keeper' AND team_id IN 
	(SELECT team_id FROM Nationality WHERE country = 'Russia' AND team_id IN 
		(SELECT team_id FROM Sports WHERE sport = 'Ice Hockey' AND gender = 'M' )
	)
);


