DROP TABLE IF EXISTS "locations" CASCADE;
DROP TABLE IF EXISTS "competitors" CASCADE;
DROP TABLE IF EXISTS "competitions" CASCADE;
DROP TABLE IF EXISTS "sportlocations" CASCADE;
DROP TABLE IF EXISTS "qualifications" CASCADE;
DROP TABLE IF EXISTS "nationality" CASCADE;
DROP TABLE IF EXISTS "practice" CASCADE;
DROP TABLE IF EXISTS "teammembers" CASCADE;
DROP TABLE IF EXISTS "teams" CASCADE;
DROP TABLE IF EXISTS "athletes" CASCADE;
DROP TABLE IF EXISTS "countries" CASCADE;
DROP TABLE IF EXISTS "sports" CASCADE;
DROP TABLE IF EXISTS "officials" CASCADE;
DROP FUNCTION IF EXISTS checkcheck() CASCADE;
DROP FUNCTION IF EXISTS checkoff() CASCADE;
DROP FUNCTION IF EXISTS checkTime() CASCADE;
DROP FUNCTION IF EXISTS checkOffTime() CASCADE;
DROP FUNCTION IF EXISTS checkConTime() CASCADE;

CREATE TABLE "locations" (
	"location_id" integer NOT NULL,
	"arena" text,
	"location" text,
	Constraint "location_pkey" Primary Key ("location_id")
);

CREATE TABLE "sports" (
	"sport" text NOT NULL,
	"gender" text NOT NULL,
	"teamplay" boolean,
	"gold" integer,
	"silver" integer,
	"bronze" integer,
    Constraint "sports_pkey" Primary Key ("sport","gender")
);

CREATE TABLE "officials" (
	"official_id" integer NOT NULL,
	"name" text NOT NULL,
	"gender" text NOT NULL,
	Constraint "official_id_pkey" Primary Key ("official_id")
);

CREATE TABLE "countries" (
	"country" text NOT NULL,
	Constraint "countries_pkey" Primary Key ("country")
);


CREATE TABLE "athletes" (
	"athlete_id" integer NOT NULL,
	"name" text NOT NULL,
	"gender" text NOT NULL,
	Constraint "athlete_id_pkey" Primary Key ("athlete_id")
);


CREATE TABLE "teams" (
	"team_id" integer NOT NULL,
	Constraint "team_id_pkey" Primary Key ("team_id")
);


CREATE TABLE "teammembers" (
	"team_id" integer NOT NULL references teams(team_id),
	"athlete_id" integer NOT NULL references athletes(athlete_id),
	"position" text,
	Constraint "teammembers_pkey" Primary Key ("athlete_id","team_id")
);


CREATE TABLE "practice" (
	"sport" text NOT NULL,
	"gender" text NOT NULL,
	"contestant_id" integer NOT NULL,			--Can be either an athlete or a team
	Foreign Key ("sport","gender") references sports("sport","gender")
);


CREATE TABLE "nationality" (
	"country" text NOT NULL references countries(country),
	"contestant_id" integer NOT NULL
);


CREATE TABLE "qualifications" (
	"official_id" integer NOT NULL references officials(official_id),
	"gender" text NOT NULL,
    "sport" text NOT NULL,
    Foreign Key ("sport","gender") references sports("sport","gender")
);


CREATE TABLE "sportlocations" (
	"location_id" integer NOT NULL references locations(location_id),
	"sport" text
);


CREATE TABLE "competitions" (
	"competition_id" integer NOT NULL,
	"location_id" integer references locations(location_id),
	"official" integer references officials(official_id),
	"time" text,
	"duration" text,
	"sport" text,
	"gender" text,
	"group" text,
	"round" text,
	Constraint "competition_fkey" Foreign Key ("sport","gender") references sports("sport","gender"),
	Constraint "competition_id_pkey" Primary Key ("competition_id")
);


CREATE TABLE "competitors" (
	"competition_id" integer NOT NULL references competitions(competition_id),
	"contestant_id" integer NOT NULL			--Can be either an athlete or a team
);





COPY "locations" FROM stdin;
5001	Hammarbybacken	Main track
5002	Friends Arena	Main hall
5003	Globen	Main hall
5004	Globen	Annexet
5005	Hovet	Main hall
5006	Ostermalms IP	Main track
\.

COPY "sports" FROM stdin;
Slalom	F	False	2004	2003	2008
Bobsleigh	F	False	2003	2008	2004
Bobsleigh	M	False	2020	2010	2009
Ice Hockey	M	True	3001	3002	3003
\.

COPY "countries" FROM stdin;
Sweden
Russia
France
Argentina
Palau
Norway
\.

COPY "officials" FROM stdin;
4001	Charlotte Markgren	F
4002	Harald Lif	M
4003	Svea Andersson	F
4004	Mats Carlsson	M
4005	Ingrid Manhem	F
\.

COPY "athletes" FROM stdin;
2001	Hanh Haase	M
2002	Vern Woelfel	M
2003	Shayla Chesnut	F
2004	Ranee Kirkley	F
2005	Dan Barra	M
2006	Mack Digiovanni	M
2007	Thurman Harkness	M
2008	Odette Casarez	F
2009	David Steck	M
2010	Reno Sinegal	M
2011	Laurine Mckissick	F
2012	Antionette Lechler	F
2013	Sueann Wang	F
2014	Eddie Kilduff	M
2015	Genoveva Maynes	F
2016	Amanda Tallon	F
2017	Eddie Shanks	M
2018	Ruthe Hartsock	F
2019	Lorraine Gully	F
2020	Ming Forand	M
\.

COPY "teams" FROM stdin;
3001
3002
3003
3004
3005
3006
3007
3008
3009
3010
\.

COPY "teammembers" FROM stdin;
3001	2001	Goal Keeper
3002	2014	Goal Keeper
\.

COPY "practice" FROM stdin;
Bobsleigh	F	2003
Bobsleigh	F	2004
Bobsleigh	F	2008
Bobsleigh	M	2009
Bobsleigh	M	2010
Bobsleigh	M	2020
Slalom	F	2016
Slalom	F	2018
Slalom	F	2019
Slalom	F	2012
Slalom	F	2013
Slalom	F	2011
Ice Hockey	M	3001
Ice Hockey	M	3002
\.

COPY "nationality" FROM stdin;
Russia	2001
Palau	2002
Palau	2003
Palau	2004
Argentina	2005
France	2006
Russia	2007
France	2008
Sweden	2009
Argentina	2010
Russia	2011
Palau	2012
Argentina	2013
Russia	2014
Russia	2015
France	2016
France	2017
Argentina	2018
Palau	2019
Sweden	2020
Russia	3001
Sweden	3002
Argentina	3003
France	3004
\.

COPY "qualifications" FROM stdin;
4001	F	Slalom
4003	F	Bobsleigh
4004	M	Bobsleigh
4005	M	Ice Hockey
4004	M	Ice Hockey
\.

COPY "sportlocations" FROM stdin;
5001	Slalom
5002	Figure Skating
5003	Short Track Speed Skating
5004	Curling
5002	Ice Hockey
5006	Bobsleigh
\.

COPY "competitions" FROM stdin;
1001	5001	4001	2020-08-12 08:45:00	2020-08-12 09:15:00	Slalom	F	A	1
1002	5001	4002	2020-08-12 09:30:00	2020-08-12 10:00:00	Slalom	F	B	1
1003	5006	4004	2020-08-13 10:00:00	2020-08-13 10:45:00	Bobsleigh	M	Null	Final
1004	5006	4003	2020-08-13 11:00:00	2020-08-13 11:45:00	Bobsleigh	F	Null	Final
1005	5002	4005	2020-08-14 12:00:00	2020-08-14 13:30:00	Ice Hockey	M	A	1
\.


COPY "competitors" FROM stdin;
1001	2016
1001	2018
1001	2019
1002	2012
1002	2013
1002	2011
1003	2009
1003	2010
1003	2020
1004	2003
1004	2004
1004	2008
1005	3001
1005	3002
\.

CREATE FUNCTION checkcheck() RETURNS trigger AS $checkExisting$
  BEGIN
  IF NEW.contestant_id IN (SELECT contestant_id FROM nationality) THEN RAISE EXCEPTION 'Finns redan i ett Team';
  ELSE RETURN NEW;
  END IF;
  END;
$checkExisting$ LANGUAGE plpgsql;

CREATE TRIGGER checkExisting
  BEFORE INSERT ON nationality
  FOR EACH ROW
    EXECUTE PROCEDURE checkcheck(NEW);

CREATE FUNCTION checkOff() RETURNS trigger AS $checkOfficial$
  BEGIN
  IF NEW.sport IN (SELECT sport FROM Qualifications WHERE NEW.official = official_id) THEN RETURN NEW;
  ELSE RAISE EXCEPTION 'Official not qualified';
  END IF;
  END;
$checkOfficial$ LANGUAGE plpgsql;

CREATE TRIGGER checkOfficial
  BEFORE INSERT ON Competitions
  FOR EACH ROW
    EXECUTE PROCEDURE checkOff(NEW);

CREATE FUNCTION checkTime() RETURNS trigger AS $checkTimeSlot$
  BEGIN
  IF NEW.location_id IN (SELECT location_id FROM Competitions WHERE NEW.duration < time) OR NEW.location_id IN (SELECT location_id FROM Competitions WHERE NEW.time > duration) OR NEW.location_id NOT IN (SELECT location_id FROM Competitions) THEN RETURN NEW;
  ELSE RAISE EXCEPTION 'Time slot already taken';
  END IF;
  END;
$checkTimeSlot$ LANGUAGE plpgsql;

CREATE TRIGGER checkTimeSlot
	BEFORE INSERT ON Competitions
  FOR EACH ROW
    EXECUTE PROCEDURE checkTime(NEW);

