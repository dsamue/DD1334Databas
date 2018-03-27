
--1
SELECT last_name, first_name FROM authors WHERE author_id = (SELECT author_id FROM books WHERE title = 'The Shining');

--2
SELECT title FROM books WHERE author_id = (SELECT author_id FROM authors WHERE first_name = 'Paulette' AND last_name = 'Bourgeois');

--3
SELECT last_name, first_name FROM customers WHERE customer_id IN 
	(SELECT customer_id FROM shipments WHERE isbn IN 
		(SELECT isbn FROM editions WHERE book_id IN 
			(SELECT book_id FROM books WHERE subject_id = 
				(SELECT subject_ID FROM subjects WHERE subject = 'Horror')
			)
		)
	);

--4
SELECT title FROM books WHERE book_id IN 
	(SELECT book_id FROM editions WHERE isbn IN
		(SELECT isbn FROM stock WHERE stock >= ALL 
			(SELECT stock FROM stock)
		)
	);


--5
SELECT SUM(stock.retail_price) 
FROM books, stock, subjects, editions 
WHERE books.subject_id = subjects.subject_id AND subjects.subject = 'Science Fiction' AND editions.book_id = books.book_id AND editions.isbn = stock.isbn;


--6
SELECT title
FROM books 
WHERE book_id IN
(SELECT book_id 
 FROM
 	(SELECT DISTINCT COUNT(customer_id), book_id 
 	 FROM shipments, editions 
 	 WHERE editions.isbn = shipments.isbn 
 	 GROUP BY book_id) 
 AS test 
 WHERE count = 2);


--7
SELECT name, sum FROM publishers,

		(SELECT publisher_id, sum FROM (
			SELECT publisher_id, SUM(sums) FROM editions 
				NATURAL JOIN
			((SELECT isbn, cost*stock as sums FROM stock)
				UNION
			(SELECT shipments.isbn, SUM(stock.cost) as sums FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn)) as allCosts
		GROUP BY publisher_id) 
        AS test
		WHERE sum >= ALL 

			(SELECT SUM(sums) FROM editions 
					NATURAL JOIN
				((SELECT isbn, cost*stock as sums FROM stock)
					UNION
				(SELECT shipments.isbn, SUM(stock.cost) as sums FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn)) as allCosts
			GROUP BY publisher_id)) 
			AS monster

WHERE publishers.publisher_id = monster.publisher_id;



--8
SELECT 
(SELECT SUM(retail_price - cost) FROM shipments, stock WHERE stock.isbn = shipments.isbn)
-
(SELECT SUM(cost*stock) FROM stock) 
as earned;


 
--9 
SELECT last_name, first_name FROM customers WHERE customer_id IN 
(SELECT customer_id FROM 
(SELECT customer_id, COUNT(DISTINCT subject_id) FROM shipments, editions, books WHERE shipments.isbn = editions.isbn AND editions.book_id = books.book_id GROUP BY customer_id) 
AS numSubjects 
WHERE count >= 3);




--10
SELECT subject FROM subjects WHERE subject_id NOT IN 
(SELECT subject_id FROM shipments, editions, books WHERE shipments.isbn = editions.isbn AND editions.book_id = books.book_id);

