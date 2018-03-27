1.
CREATE VIEW task1 AS SELECT isbn, title FROM books, editions WHERE books.book_id = editions.book_id;
SELECT * FROM task1;
DROP VIEW task1;

Nice to have isbns for all editions for example. 

2. 
INSERT INTO editions VALUES ('5555', 12345, 1, 59, '2012-12-02');

ERROR:  insert or update on table "editions" violates foreign key constraint "editions_book_id_fkey"
DETAIL:  Key (book_id)=(12345) is not present in table "books".

Alltså boken vi försöker sätta in finns inte i books och därför failar queryn eftersom det är en foreign key. 


3.
INSERT INTO editions VALUES ('5555');

ERROR:  new row for relation "editions" violates check constraint "integrity"
DETAIL:  Failing row contains (5555, null, null, null, null).

Alla får vara null enligt information-schemat, 

Denna ger lite info men typ inget nytt. 
SELECT * FROM INFORMATION_SCHEMA.table_constraints WHERE table_schema='public' AND constraint_name = 'integrity';

Ok, finns alltså någon form av check men jag är osäker på vad...

4.
INSERT INTO books VALUES (12345, 'How I Insert');
INSERT INTO editions VALUES ('5555', 12345, 1, 59, '2012-12-02');

output:
INSERT 0 1
INSERT 0 1SLE

SELECT * FROM books, editions WHERE editions.book_id = books.book_id AND title = 'How I Insert';

Output:
 book_id |    title     | author_id | subject_id | isbn | book_id | edition | publisher_id | publication_date 
---------+--------------+-----------+------------+------+---------+---------+--------------+------------------
   12345 | How I Insert |           |            | 5555 |   12345 |       1 |           59 | 2012-12-02

För att både author_id och subject_id tillåts vara null. 

5. 