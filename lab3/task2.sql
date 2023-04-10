CREATE OR REPLACE PROCEDURE all_compare_schemas (
  dev_schema_name IN VARCHAR2,
  prod_schema_name IN VARCHAR2
)
IS
BEGIN
  FOR r IN (
    SELECT object_name, object_type FROM all_objects WHERE owner = dev_schema_name
    MINUS
    SELECT object_name, object_type FROM all_objects WHERE owner = prod_schema_name
  )
  LOOP
    DBMS_OUTPUT.PUT_LINE(r.object_name || ' (' || r.object_type || ')');
  END LOOP;
END;
/

EXEC all_compare_schemas('DEV_SCHEMA', 'PROD_SCHEMA');
SET SERVEROUT ON;
