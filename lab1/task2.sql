SET SERVEROUTPUT ON;

/* Fill with numbers */
BEGIN
	FOR i IN 0..10000 LOOP
		INSERT INTO MYTABLE(val)
		VALUES (FLOOR(DBMS_RANDOM.value(low => -100, high => 100)));
	END LOOP;
END;

/* Clear the table */
TRUNCATE TABLE MYTABLE;
