CREATE OR REPLACE FUNCTION Task6(
  salary NUMBER,
  precentage NUMBER
) RETURN NUMBER
IS
    bonus NUMBER;
BEGIN
    IF salary < 0 OR precentage < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Data must be above zero');
    END IF;
    
    IF TRUNC(precentage) <> precentage THEN
        RAISE_APPLICATION_ERROR(-20002, 'presentage must be int');
    END IF;
    
    bonus := (1+precentage/100)*12*salary;
    
    RETURN bonus;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, SQLERRM);
END Task6;
/


DECLARE
    result_ NUMBER := 0;
BEGIN
    result_ := Task6(-500, 3.5);
    DBMS_OUTPUT.PUT_LINE(result_);
END;
/