-- Dev Schema

CREATE USER dev_schema IDENTIFIED BY dev_schema_password;

GRANT CONNECT, RESOURCE TO dev_schema;

ALTER USER dev_schema DEFAULT TABLESPACE users;

CREATE TABLE dev_schema.firs_table (
  id NUMBER,
  name VARCHAR2(50),
  age NUMBER
);

CREATE TABLE dev_schema.students
(
    id NUMBER(10) NOT NULL,
    name VARCHAR2(50) NOT NULL,
    group_id NUMBER(10) NOT NULL
);

CREATE OR REPLACE TRIGGER dev_schema.students_trigger
BEFORE INSERT ON students
FOR EACH ROW
BEGIN
  -- Check if the group_id is valid
  IF :NEW.group_id NOT IN (1, 2, 3) THEN
    RAISE_APPLICATION_ERROR(-20001, 'Invalid group ID');
  END IF;
  
  -- Generate a new ID if not provided
  IF :NEW.id IS NULL THEN
    SELECT MAX(id) + 1 INTO :NEW.id FROM students;
  END IF;
END;
/



-- Prod Schema

CREATE USER prod_schema IDENTIFIED BY prod_schema_password;

GRANT CONNECT, RESOURCE TO prod_schema;

ALTER USER prod_schema DEFAULT TABLESPACE users;

CREATE TABLE prod_schema.first_table (
  id NUMBER,
  name VARCHAR2(50),
  age NUMBER
);

ALTER USER IMAKSUS IDENTIFIED BY trailking201;
CREATE TABLE prod_schema.students
(
    id NUMBER(10) NOT NULL,
    name VARCHAR2(50) NOT NULL
);

CREATE OR REPLACE TRIGGER prod_schema.students_trigger
BEFORE INSERT ON students
FOR EACH ROW
BEGIN
  -- Check if the group_id is valid
  IF :NEW.group_id NOT IN (1, 2, 3) THEN
    RAISE_APPLICATION_ERROR(-20001, 'Invalid group ID');
  END IF;
  
  -- Generate a new ID if not provided
  IF :NEW.id IS NULL THEN
    SELECT MAX(id) + 1 INTO :NEW.id FROM students;
  END IF;
END;
/

INSERT INTO students (name,group_id) VALUES ('Nikolaj222', 3);

-- Check existing schemas

SELECT username
FROM sys.all_users;
