CREATE OR REPLACE PROCEDURE compare_schemas (
  dev_schema_name IN VARCHAR2,
  prod_schema_name IN VARCHAR2
)
IS
  dev_table VARCHAR2(50);
  prod_table VARCHAR2(50);
  v_col1 NUMBER;
  v_diff BOOLEAN := FALSE;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Tables in ' || dev_schema_name || ' but not in ' || prod_schema_name || ':');
  
  FOR r IN (
    SELECT table_name FROM all_tables WHERE owner = dev_schema_name
    MINUS
    SELECT table_name FROM all_tables WHERE owner = prod_schema_name
  )
  LOOP
    DBMS_OUTPUT.PUT_LINE(r.table_name);
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE('Tables with different structures:');
  
  FOR r IN (
    SELECT table_name FROM all_tables WHERE owner = dev_schema_name
    INTERSECT
    SELECT table_name FROM all_tables WHERE owner = prod_schema_name
  )
  LOOP
    dev_table := dev_schema_name || '.' || r.table_name;
    prod_table := prod_schema_name || '.' || r.table_name;
    
    FOR col1 IN (SELECT column_name FROM all_tab_columns WHERE owner = dev_schema_name AND table_name = r.table_name ORDER BY column_id)
    LOOP
      v_diff := TRUE;
      
      FOR col2 IN (SELECT column_name FROM all_tab_columns WHERE owner = prod_schema_name AND table_name = r.table_name ORDER BY column_id)
      LOOP
        IF col1.column_name <> col2.column_name THEN
          v_diff := FALSE;
          EXIT;
        END IF;
      END LOOP;
      
      IF v_diff = FALSE THEN
        DBMS_OUTPUT.PUT_LINE(prod_table);
      END IF;
    END LOOP;
  END LOOP;
END;
/


exec compare_schemas('DEV_SCHEMA', 'PROD_SCHEMA');
SELECT table_name FROM all_tables WHERE owner = 'DEV_SCHEMA';
SELECT table_name FROM all_tables WHERE owner = 'PROD_SCHEMA';

SET SERVEROUT ON;
