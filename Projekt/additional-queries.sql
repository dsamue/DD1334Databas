-- Q6:
SELECT name, COUNT(official_id)
FROM Officials
NATURAL JOIN Competitions
WHERE round='Final'
GROUP BY 1;

-- Q7:
SELECT arena 
FROM locations 
NATURAL JOIN competitions 
WHERE sport = 'Bobsleigh'; 

-- Q8:
SELECT name, sport
FROM athletes JOIN practice ON contestant_id = athlete_id
WHERE athletes.gender = 'F';

-- Q9:
SELECT name 
FROM officials NATURAL JOIN qualifications 
WHERE sport = 'Slalom';
