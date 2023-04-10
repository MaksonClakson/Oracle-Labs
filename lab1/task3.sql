SET SERVEROUTPUT ON;
DECLARE
  odd_count INTEGER := 0;
  even_count INTEGER := 0;
BEGIN
  SELECT count(*) INTO odd_count FROM (SELECT rownum rn FROM MYTABLE) WHERE MOD(rn,2) <> 0;
  select count(*) into even_count from MYTABLE;
  even_count := even_count - odd_count;
  IF odd_count > even_count THEN DBMS_OUTPUT.put_line('TRUE');
  ELSE DBMS_OUTPUT.put_line('FALSE');
  END IF;
END;
