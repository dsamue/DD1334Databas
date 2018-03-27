--1.
CREATE VIEW task1 AS SELECT isbn, title FROM books, editions WHERE books.book_id = editions.book_id;
SELECT * FROM task1;
DROP VIEW task1;

--Nice to have isbns for all editions for example. 

--2. 
INSERT INTO editions VALUES ('5555', 12345, 1, 59, '2012-12-02');

--Alltså boken vi försöker sätta in finns inte i books och därför failar queryn eftersom det är en foreign key. 


--3.
INSERT INTO editions VALUES ('5555'); 

--Denna ger lite info men typ inget nytt. 
--SELECT * FROM INFORMATION_SCHEMA.table_constraints WHERE table_schema='public' AND constraint_name = 'integrity';
--Ok, finns alltså någon form av check men jag är osäker på vad. Alla får vara null enligt information-schemat.

--4.
INSERT INTO books VALUES (12345, 'How I Insert');
INSERT INTO editions VALUES ('5555', 12345, 1, 59, '2012-12-02');

SELECT * FROM books, editions WHERE editions.book_id = books.book_id AND title = 'How I Insert';


--För att både author_id och subject_id tillåts vara null. 

--5. 
SELECT subject_id FROM Subjects WHERE subject = 'Mystery';

UPDATE books SET subject_id = 10 WHERE book_id = 12345;

SELECT subject FROM subjects WHERE subject_id IN (SELECT subject_id FROM books WHERE book_id = 12345);


--6.
DELETE FROM books WHERE book_id=12345 AND title='How I Insert';

--iom att att book_id är en foreign key från editions så får vi inte ta bort den från books.


--7.
DELETE FROM editions WHERE isbn = '5555' AND book_id = 12345 AND edition = 1 AND publisher_id = 59 AND publication_date = '2012-12-02';

DELETE FROM books WHERE book_id=12345 AND title='How I Insert';

--Koll från upg. 4:
SELECT * FROM books, editions WHERE editions.book_id = books.book_id AND title = 'How I Insert';


--8.
INSERT INTO books(book_id, title, subject_id ) VALUES (12345, 'How I Insert', 3443);

--Subject_id finns inte i subjects och det är en foreign key.


--9.

--Ta bort ev. constraint:
--ALTER TABLE books DROP CONSTRAINT hasSubject
--Ok, Båda dessa verkar funka separat vet ej hur jag ska kombinera checken och foreign key.. 
ALTER TABLE books ADD CONSTRAINT hasSubject
	CHECK (subject_id IS NOT NULL)
	FOREIGN KEY (subject_id) REFERENCES subjects(subject_id);

