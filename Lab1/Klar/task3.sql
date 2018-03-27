--Task 3
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
	BEFORE INSERT ON shipments
	FOR EACH ROW
		EXECUTE PROCEDURE decstock();



--Kolla stock
SELECT * FROM stock;

--Beställ bok som är slut:
INSERT INTO shipments
VALUES(2000, 860, '0394900014', '2012-12-07');

--Beställ bok som finns
INSERT INTO shipments
VALUES(2001, 860, '044100590X', '2012-12-07');

--Kolla läget igen
SELECT * FROM stock;


--Återställ DB och rensa trigger:
DELETE FROM shipments WHERE shipment_id > 1999;
UPDATE stock SET stock = 89 WHERE isbn = '044100590X';                                                                                                                  
DROP FUNCTION decstock() CASCADE;
