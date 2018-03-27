task 3. 

CREATE FUNCTION decstock() RETURNS trigger AS $pname$
	BEGIN
		IF (SELECT stock FROM stock WHERE stock.isbn = NEW.isbn) = 0
		THEN RAISE EXCEPTION 'Sorry, out of books';
		ELSE UPDATE stock SET stock = stock-1 WHERE stock.isbn = NEW.isbn;
		END IF;
		RETURN NEW;
	END;
$pname$ LANGUAGE plpgsql;

CREATE TRIGGER testname
	AFTER INSERT ON shipments
	FOR EACH ROW
		EXECUTE PROCEDURE decstock();



Historik
Denna rensar triggern:
DROP FUNCTION decstock() CASCADE;

Ok, Denna skaoar alltså en fungerande trigger!
CREATE FUNCTION decstock() RETURNS trigger AS $pname$
	BEGIN
		IF NEW.isbn = '0394900014'
		THEN RAISE EXCEPTION 'testmessage to show';
		END IF;
		RETURN NEW;
	END;

$pname$ LANGUAGE plpgsql;

CREATE TRIGGER testname
	AFTER INSERT ON shipments
	FOR EACH ROW
		EXECUTE PROCEDURE decstock();



Får den att kolla om stock är 0:
DROP FUNCTION decstock() CASCADE;

CREATE FUNCTION decstock() RETURNS trigger AS $pname$
	BEGIN
		IF (SELECT stock FROM stock WHERE stock.isbn = NEW.isbn) = 0
		THEN RAISE EXCEPTION 'Sorry, out of books';
		END IF;
		RETURN NEW;
	END;

$pname$ LANGUAGE plpgsql;

CREATE TRIGGER testname
	AFTER INSERT ON shipments
	FOR EACH ROW
		EXECUTE PROCEDURE decstock();


Försöker minska stock:
DROP FUNCTION decstock() CASCADE;

CREATE FUNCTION decstock() RETURNS trigger AS $pname$
	BEGIN
		IF (SELECT stock FROM stock WHERE stock.isbn = NEW.isbn) = 0
		THEN RAISE EXCEPTION 'Sorry, out of books';
		ELSE UPDATE stock SET stock = stock-1 WHERE stock.isbn = NEW.isbn;
		END IF;
		RETURN NEW;
	END;
$pname$ LANGUAGE plpgsql;

CREATE TRIGGER testname
	AFTER INSERT ON shipments
	FOR EACH ROW
		EXECUTE PROCEDURE decstock();



Output:
CREATE FUNCTION
CREATE TRIGGER

David=# SELECT * FROM stock
    isbn    | cost  | retail_price | stock 
------------+-------+--------------+-------
 0385121679 | 29.00 |        36.95 |    65
 039480001X | 30.00 |        32.95 |    31
 0394900014 | 23.00 |        23.95 |     0
 044100590X | 36.00 |        45.95 |    89
 0441172717 | 17.00 |        21.95 |    77
 0451160916 | 24.00 |        28.95 |    22
 0451198492 | 36.00 |        46.95 |     0
 0451457994 | 17.00 |        22.95 |     0
 0590445065 | 23.00 |        23.95 |    10
 0679803335 | 20.00 |        24.95 |    18
 0694003611 | 25.00 |        28.95 |    50
 0760720002 | 18.00 |        23.95 |    28
 0823015505 | 26.00 |        28.95 |    16
 0929605942 | 19.00 |        21.95 |    25
 1885418035 | 23.00 |        24.95 |    77
 0394800753 | 16.00 |        16.95 |     4
(16 rows)

David=# INSERT INTO shipments
David-# VALUES(2000, 860, '0394900014', '2012-12-07');
ERROR:  Sorry, out of books
CONTEXT:  PL/pgSQL function decstock() line 4 at RAISE
David=# INSERT INTO shipments
David-# VALUES(2001, 860, '044100590X', '2012-12-07');
INSERT 0 1
David=# SELECT * FROM stock                                                                                                                  ;
    isbn    | cost  | retail_price | stock 
------------+-------+--------------+-------
 0385121679 | 29.00 |        36.95 |    65
 039480001X | 30.00 |        32.95 |    31
 0394900014 | 23.00 |        23.95 |     0
 0441172717 | 17.00 |        21.95 |    77
 0451160916 | 24.00 |        28.95 |    22
 0451198492 | 36.00 |        46.95 |     0
 0451457994 | 17.00 |        22.95 |     0
 0590445065 | 23.00 |        23.95 |    10
 0679803335 | 20.00 |        24.95 |    18
 0694003611 | 25.00 |        28.95 |    50
 0760720002 | 18.00 |        23.95 |    28
 0823015505 | 26.00 |        28.95 |    16
 0929605942 | 19.00 |        21.95 |    25
 1885418035 | 23.00 |        24.95 |    77
 0394800753 | 16.00 |        16.95 |     4
 044100590X | 36.00 |        45.95 |    88
(16 rows)

