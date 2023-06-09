-- Tables for logging
DROP TABLE students_log;
DROP TABLE groups_log;
DROP TABLE courses_log;

CREATE TABLE students_log
(
    log_pk NUMBER(10) GENERATED BY DEFAULT AS IDENTITY,
    operation VARCHAR2(6) NOT NULL,
    operation_time TIMESTAMP NOT NULL,
    id NUMBER(10) NOT NULL,
    name VARCHAR2(50) NOT NULL,
    group_id NUMBER(10),
    enter_date TIMESTAMP NOT NULL
);

CREATE TABLE groups_log
(
    log_pk NUMBER(10) GENERATED BY DEFAULT AS IDENTITY,
    operation VARCHAR2(6) NOT NULL,
    operation_time TIMESTAMP NOT NULL,
    id NUMBER(10) NOT NULL,
    name VARCHAR2(50) NOT NULL,
    students_count NUMBER(10) NOT NULL
);

CREATE TABLE courses_log
(
    log_pk NUMBER(10) GENERATED BY DEFAULT AS IDENTITY,
    operation VARCHAR2(6) NOT NULL,
    operation_time TIMESTAMP NOT NULL,
    id NUMBER(10) NOT NULL,
    name VARCHAR2(50) NOT NULL,
    professor VARCHAR2(50)
);


-- Triggers for logging
CREATE OR REPLACE TRIGGER logging_students
AFTER INSERT OR UPDATE OR DELETE ON students
FOR EACH ROW
DECLARE
   operation VARCHAR2(10);
   old_id NUMBER(10);
BEGIN
   IF INSERTING THEN
      operation := 'INSERT';
   ELSIF UPDATING THEN
      operation := 'UPDATE';
   ELSE
      operation := 'DELETE';
   END IF;
   
   IF INSERTING THEN
      INSERT INTO students_log (operation, operation_time, id, name, group_id, enter_date)
      VALUES (operation, CURRENT_TIMESTAMP, :NEW.id, :NEW.name, :NEW.group_id, :NEW.enter_date);
   ELSE
      INSERT INTO students_log (operation, operation_time, id, name, group_id, enter_date)
      VALUES (operation, CURRENT_TIMESTAMP, :OLD.id, :OLD.name, :OLD.group_id, :OLD.enter_date);
   END IF;
END;
/


CREATE OR REPLACE TRIGGER logging_groups
AFTER INSERT OR UPDATE OR DELETE ON groups
FOR EACH ROW
DECLARE
   operation VARCHAR2(10);
   old_id NUMBER(10);
BEGIN
   IF INSERTING THEN
      operation := 'INSERT';
   ELSIF UPDATING THEN
      operation := 'UPDATE';
   ELSE
      operation := 'DELETE';
   END IF;
   
   IF INSERTING THEN
      INSERT INTO groups_log (operation, operation_time, id, name, students_count)
      VALUES (operation, CURRENT_TIMESTAMP, :NEW.id, :NEW.name, :NEW.students_count);
   ELSE
      INSERT INTO groups_log (operation, operation_time, id, name, students_count)
      VALUES (operation, CURRENT_TIMESTAMP, :OLD.id, :OLD.name, :OLD.students_count);
   END IF;
END;
/


CREATE OR REPLACE TRIGGER logging_courses
AFTER INSERT OR UPDATE OR DELETE ON courses
FOR EACH ROW
DECLARE
   operation VARCHAR2(10);
   old_id NUMBER(10);
BEGIN
   IF INSERTING THEN
      operation := 'INSERT';
   ELSIF UPDATING THEN
      operation := 'UPDATE';
   ELSE
      operation := 'DELETE';
   END IF;
   
   IF INSERTING THEN
      INSERT INTO courses_log (operation, operation_time, id, name, professor)
      VALUES (operation, CURRENT_TIMESTAMP, :NEW.id, :NEW.name, :NEW.professor);
   ELSE
      INSERT INTO courses_log (operation, operation_time, id, name, professor)
      VALUES (operation, CURRENT_TIMESTAMP, :OLD.id, :OLD.name, :OLD.professor);
   END IF;
END;
/