SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION task4(
    id_ NUMBER
) RETURN VARCHAR2
IS
    query_ VARCHAR2(100);
    val NUMBER;
BEGIN
    SELECT val INTO val FROM MYTABLE WHERE id = id_;
    query_ := 'INSERT INTO MYTABLE VALUES (' || id_ || ', ' || val || ');';
    RETURN query_;
END;
/
-- accept id_enter VARCHAR2(100) prompt 'Enter id: '
-- accept val_enter VARCHAR2(100) prompt 'Enter val: '

DECLARE
    outp VARCHAR2(100);
BEGIN
    outp := task4(36144);
    DBMS_OUTPUT.PUT_LINE(outp);
END;
/