CREATE OR REPLACE TRIGGER cascade_delete_groups
BEFORE DELETE ON groups
FOR EACH ROW
BEGIN
   IF DELETING THEN
      DELETE FROM students WHERE group_id = :OLD.id;
   END IF;
END;
/

-- Test Functionality
BEGIN
    DELETE FROM groups WHERE id = 3;
END;
/