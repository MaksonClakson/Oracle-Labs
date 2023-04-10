CREATE OR REPLACE PROCEDURE compare_schemas_advanced (
  dev_schema_name IN VARCHAR2,
  prod_schema_name IN VARCHAR2
)
IS
  dev_table VARCHAR2(50);
  prod_table VARCHAR2(50);
  v_sql VARCHAR2(4000);
BEGIN
  DBMS_OUTPUT.PUT_LINE('Objects in ' || prod_schema_name || ' but not in ' || dev_schema_name || ':');
  
  FOR r IN (
    SELECT object_name, object_type FROM all_objects WHERE owner = dev_schema_name
    MINUS
    SELECT object_name, object_type FROM all_objects WHERE owner = prod_schema_name
  )
  LOOP
    v_sql := 'DROP ' || r.object_type || ' ' || prod_schema_name || '.' || r.object_name || ';';
    DBMS_OUTPUT.PUT_LINE(v_sql);
  END LOOP;
    
  DBMS_OUTPUT.PUT_LINE('Objects with different structures');
  FOR r IN (
    SELECT object_name, object_type FROM all_objects WHERE owner = prod_schema_name
    INTERSECT
    SELECT object_name, object_type FROM all_objects WHERE owner = dev_schema_name
  )
  LOOP
    v_sql := REPLACE(dbms_metadata.get_ddl(r.object_type, r.object_name, prod_schema_name), prod_schema_name, dev_schema_name);
    IF v_sql <> dbms_metadata.get_ddl(r.object_type, r.object_name, dev_schema_name) THEN
        DBMS_OUTPUT.PUT_LINE(r.object_name || ' (' || r.object_type || ')');
        DBMS_OUTPUT.PUT_LINE(v_sql);
    END IF;
  END LOOP;
END;
/

-- Grant neccessary privilegies
GRANT SELECT_CATALOG_ROLE to IMAKSUS with delegate option;

INSERT INTO imaksus.students (id, name, group_id)
VALUES (1, 'John', 1);

GRANT SELECT_CATALOG_ROLE to PROCEDURE compare_schemas_advanced;


exec compare_schemas_advanced('PROD_SCHEMA', 'DEV_SCHEMA');

SELECT table_name FROM all_tables WHERE owner = 'DEV_SCHEMA';
SELECT table_name FROM all_tables WHERE owner = 'PROD_SCHEMA';

SET SERVEROUT ON;
