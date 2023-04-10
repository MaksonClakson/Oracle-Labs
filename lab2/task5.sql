CREATE OR REPLACE TRIGGER update_students_count
AFTER INSERT OR UPDATE OR DELETE ON students
FOR EACH ROW
BEGIN
   UPDATE groups
   SET students_count = (SELECT COUNT(*) FROM students WHERE group_id = :NEW.group_id)
   WHERE id = :NEW.group_id;
   UPDATE groups
   SET students_count = (SELECT COUNT(*) FROM students WHERE group_id = :OLD.group_id)
   WHERE id = :OLD.group_id;
END;
/

CREATE OR REPLACE TRIGGER group_size_iterator
AFTER INSERT OR DELETE ON students
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE groups
        SET groups.students_count = groups.students_count + 1
        WHERE id = :NEW.group_id;
    ELSE
        UPDATE groups
        SET groups.students_count = groups.students_count - 1
        WHERE id = :OLD.group_id;
    END IF;
END;
/

-- Test Functionality
BEGIN
    INSERT INTO students (name, group_id) VALUES ('Popupo', 1);
END;
/