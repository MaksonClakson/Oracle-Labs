-- Students
CREATE OR REPLACE TRIGGER check_id_students
BEFORE INSERT ON students
FOR EACH ROW
DECLARE
   count_ NUMBER;
   max_id NUMBER;
BEGIN
   SELECT COUNT(*) INTO count_ FROM students WHERE id = :NEW.id;
   IF count_ > 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Id already exists');
   END IF;
   
   SELECT MAX(id) INTO max_id FROM students;
   :NEW.id := NVL(max_id, 0) + 1;
END;
/

-- Groups
CREATE OR REPLACE TRIGGER check_id_groups
BEFORE INSERT ON groups
FOR EACH ROW
DECLARE
   count_ NUMBER;
   max_id NUMBER;
BEGIN
   SELECT COUNT(*) INTO count_ FROM groups WHERE id = :NEW.id;
   IF count_ > 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Id already exists');
   END IF;
   
   SELECT MAX(id) INTO max_id FROM groups;
   :NEW.id := NVL(max_id, 0) + 1;
   
   SELECT COUNT(*) INTO count_ FROM groups WHERE name = :NEW.name;
   IF count_ > 0 THEN
      RAISE_APPLICATION_ERROR(-20002, 'Name already exists');
   END IF;
END;
/

-- Test Functionality
BEGIN
    INSERT INTO students (name, group_id) VALUES ('Vasya', 1);
    -- INSERT INTO students(id, name, group_id) VALUES (1, 'Petya', 1);
END;
/

BEGIN
    INSERT INTO groups (name, students_count) VALUES ('phisics', 0);
    -- INSERT INTO students(id, name, group_id) VALUES (1, 'Petya', 1);
END;
/
