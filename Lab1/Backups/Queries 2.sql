1.
SELECT last_name, first_name FROM authors WHERE author_id = (SELECT author_id FROM books WHERE title = 'The Shining');

2.
SELECT title FROM books WHERE author_id = (SELECT author_id FROM authors WHERE first_name = 'Paulette' AND last_name = 'Bourgeois');

3.
SELECT last_name, first_name FROM customers WHERE customer_id IN 
	(SELECT customer_id FROM shipments WHERE isbn IN 
		(SELECT isbn FROM editions WHERE book_id IN 
			(SELECT book_id FROM books WHERE subject_id = 
				(SELECT subject_ID FROM subjects WHERE subject = 'Horror')
			)
		)
	);

4.
SELECT title FROM books WHERE book_id IN 
	(SELECT book_id FROM editions WHERE isbn IN
		(SELECT isbn FROM stock WHERE stock >= ALL 
			(SELECT stock FROM stock)
		)
	);


5.
SELECT SUM(numsold * stock.retail_price) FROM stock,
	(SELECT isbn, COUNT(isbn) AS numSold FROM shipments WHERE isbn IN       
		(SELECT isbn FROM editions WHERE book_id IN                                     
			(SELECT book_id FROM books WHERE subject_id =                                   
				(SELECT subject_ID FROM subjects WHERE subject = 'Science Fiction')             
			)                                                                               
		)                                                                               
	GROUP BY isbn) AS test
WHERE test.isbn = stock.isbn;


6. 
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


7.
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




Historik:
Här är alla isbn från allt i stock och sålt (stämmer bra)
(SELECT isbn FROM shipments) UNION ALL (SELECT isbn FROM stock)


Här försöker jag få in priser och publisher:

Denna funkar för att få med priserna
SELECT cost, isbn
FROM stock
NATURAL JOIN ((SELECT isbn FROM shipments) UNION ALL (SELECT isbn FROM stock)) AS TEST;


Här är även publisers med 
(SELECT isbn, publisher_id, cost FROM editions 
	NATURAL JOIN
(SELECT cost, isbn FROM stock) as costs
	NATURAL JOIN 	
((SELECT isbn FROM shipments) UNION ALL (SELECT isbn FROM stock)) as isbns);


Gruppera på publiser och summera priserna
SELECT publisher_id, SUM(cost) FROM ((SELECT isbn, publisher_id, cost FROM editions 
	NATURAL JOIN
(SELECT cost, isbn FROM stock) as costs
	NATURAL JOIN 	
((SELECT isbn FROM shipments) UNION ALL (SELECT isbn FROM stock)) as isbns)) AS all GROUP BY publisher_id;



Ok, nyttförsök eftersom priserna i stock måste multipliceras med antal i lager:

Allt i stock:
SELECT cost*stock as stockCost, isbn FROM stock;

Allt i shipped:
SELECT shipments.isbn, SUM(stock.cost) FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn;

Lägg ihop(union):
(SELECT isbn, cost*stock as sum FROM stock)
	UNION
(SELECT shipments.isbn, SUM(stock.cost) as sum FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn);


Lägg till publisher, summera:
SELECT publisher_id, SUM(sums) FROM editions 
	NATURAL JOIN
	((SELECT isbn, cost*stock as sums FROM stock)
		UNION
	(SELECT shipments.isbn, SUM(stock.cost) as sums FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn)) as allCosts
GROUP BY publisher_id;


Ta fram max och namn på publisher:
SELECT name FROM publishers WHERE publisher_id IN (

	SELECT MAX(sum) FROM (
		SELECT publisher_id, SUM(sums) FROM editions 
			NATURAL JOIN
			((SELECT isbn, cost*stock as sums FROM stock)
				UNION
			(SELECT shipments.isbn, SUM(stock.cost) as sums FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn)) as allCosts
		GROUP BY publisher_id
		) AS final
	)
;

Ok, kan inte få fram både max-värdet OCH publiser_ID iom att jag då måste gruppera och då blir det max per grupp... 


SELECT publisher_id FROM  


( SELECT publisher_id, SUM(sums) FROM editions 
	NATURAL JOIN
	((SELECT isbn, cost*stock as sums FROM stock)
		UNION
	(SELECT shipments.isbn, SUM(stock.cost) as sums FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn)) as allCosts
GROUP BY publisher_id ) as test1
WHERE sum >= ALL 

(	SELECT MAX(sum) FROM (
		SELECT publisher_id, SUM(sums) FROM editions 
			NATURAL JOIN
			((SELECT isbn, cost*stock as sums FROM stock)
				UNION
			(SELECT shipments.isbn, SUM(stock.cost) as sums FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn)) as allCosts
		GROUP BY publisher_id)
);



Ok, DENNA får faktiskt fram publisher-id och summa! BEhöver alltså bara få in publisher name:
SELECT publisher_id, sum FROM (
		SELECT publisher_id, SUM(sums) FROM editions 
			NATURAL JOIN
			((SELECT isbn, cost*stock as sums FROM stock)
				UNION
			(SELECT shipments.isbn, SUM(stock.cost) as sums FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn)) as allCosts
		GROUP BY publisher_id
		) 
        AS test
		WHERE sum >= ALL (SELECT SUM(sums) FROM editions 
			NATURAL JOIN
			((SELECT isbn, cost*stock as sums FROM stock)
				UNION
			(SELECT shipments.isbn, SUM(stock.cost) as sums FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn)) as allCosts
		GROUP BY publisher_id); 

----------------------------------------------



SELECT name, sum FROM publishers,

(SELECT publisher_id, sum FROM (
		SELECT publisher_id, SUM(sums) FROM editions 
			NATURAL JOIN
			((SELECT isbn, cost*stock as sums FROM stock)
				UNION
			(SELECT shipments.isbn, SUM(stock.cost) as sums FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn)) as allCosts
		GROUP BY publisher_id
		) 
        AS test
		WHERE sum >= ALL (SELECT SUM(sums) FROM editions 
			NATURAL JOIN
			((SELECT isbn, cost*stock as sums FROM stock)
				UNION
			(SELECT shipments.isbn, SUM(stock.cost) as sums FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn)) as allCosts
		GROUP BY publisher_id)) as monster

WHERE publishers.publisher_id = monster.publisher_id;



test:

SELECT publisher_id, sum FROM (
		SELECT publisher_id, SUM(sums) FROM editions 
			NATURAL JOIN
			((SELECT isbn, cost*stock as sums FROM stock)
				UNION
			(SELECT shipments.isbn, SUM(stock.cost) as sums FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn)) as allCosts
		GROUP BY publisher_id
		) 
        AS test
		WHERE sum >= ALL (SELECT SUM(sums) FROM editions 
			NATURAL JOIN
			((SELECT isbn, cost*stock as sums FROM stock)
				UNION
			(SELECT shipments.isbn, SUM(stock.cost) as sums FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn)) as allCosts
		GROUP BY publisher_id); 


SELECT publisher_id, SUM(sums) FROM editions 
			NATURAL JOIN
			((SELECT isbn, cost*stock as sums FROM stock)
				UNION
			(SELECT shipments.isbn, SUM(stock.cost) as sums FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn)) as allCosts
		GROUP BY publisher_id
		) 
        AS test
		WHERE sum >= ALL (SELECT SUM(sums) FROM editions 
			NATURAL JOIN
			((SELECT isbn, cost*stock as sums FROM stock)
				UNION
			(SELECT shipments.isbn, SUM(stock.cost) as sums FROM shipments, stock WHERE shipments.isbn = stock.isbn GROUP BY shipments.isbn)) as allCosts
		GROUP BY publisher_id;



8.







