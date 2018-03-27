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
SELECT SUM(retail_price * numsold) FROM stock WHERE isbn IN
	(SELECT shipments.isbn, COUNT(shipments.isbn)*retail_price AS total FROM shipments, stock WHERE shipments.isbn IN 
		(SELECT isbn FROM editions WHERE book_id IN 
			(SELECT book_id FROM books WHERE subject_id = 
				(SELECT subject_ID FROM subjects WHERE subject = 'Science Fiction')
			)
		)
	GROUP BY shipments.isbn)
	;


Backlog:
Denna ger åtminstonde 4 potentiella isbn som är sålda 1 gång var;
(SELECT isbn, COUNT(isbn) AS numSold FROM shipments WHERE isbn IN       
	(SELECT isbn FROM editions WHERE book_id IN                                     
		(SELECT book_id FROM books WHERE subject_id =                                   
			(SELECT subject_ID FROM subjects WHERE subject = 'Science Fiction')             
			)                                                                               
		)                                                                               
	GROUP BY isbn);