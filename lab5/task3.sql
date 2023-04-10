
-- restore_database_package
CREATE OR REPLACE PACKAGE restore_database_package IS

    PROCEDURE restore_students(p_time IN TIMESTAMP);
    PROCEDURE restore_groups(p_time IN TIMESTAMP);
    PROCEDURE restore_courses(p_time IN TIMESTAMP);
	PROCEDURE restore_database(p_time IN TIMESTAMP);
    PROCEDURE restore_database(time_mili IN INTEGER);
    
END restore_database_package;
/


-- restore_database_package BODY
CREATE OR REPLACE PACKAGE BODY restore_database_package IS

    PROCEDURE restore_students(p_time IN TIMESTAMP)
    IS
    BEGIN
       DBMS_OUTPUT.put_line('Restoring database by: ' || p_time);
       FOR log_row IN (SELECT * FROM students_log WHERE operation_time > p_time ORDER BY operation_time ASC)
       LOOP
          IF log_row.operation = 'INSERT' THEN
             DELETE FROM students WHERE id = log_row.id;
          ELSIF log_row.operation = 'UPDATE' THEN
             UPDATE students SET name = log_row.name, group_id = log_row.group_id WHERE id = log_row.id;
          ELSE
             INSERT INTO students (id, name, group_id) VALUES (log_row.id, log_row.name, log_row.group_id);
          END IF;
       END LOOP;
       DELETE FROM students_log WHERE operation_time > p_time;
    END restore_students;


    PROCEDURE restore_groups(p_time IN TIMESTAMP)
    IS
    BEGIN
       FOR log_row IN (SELECT * FROM groups_log WHERE operation_time > p_time ORDER BY operation_time ASC)
       LOOP
          IF log_row.operation = 'INSERT' THEN
             DELETE FROM groups WHERE id = log_row.id;
          ELSIF log_row.operation = 'UPDATE' THEN
             UPDATE groups SET name = log_row.name, students_count = log_row.students_count WHERE id = log_row.id;
          ELSE
             INSERT INTO groups (id, name, students_count) VALUES (log_row.id, log_row.name, log_row.students_count);
          END IF;
       END LOOP;
       DELETE FROM groups_log WHERE operation_time > p_time;
    END restore_groups;


    PROCEDURE restore_courses(p_time IN TIMESTAMP)
    IS
    BEGIN
       FOR log_row IN (SELECT * FROM courses_log WHERE operation_time > p_time ORDER BY operation_time ASC)
       LOOP
          IF log_row.operation = 'INSERT' THEN
             DELETE FROM courses WHERE id = log_row.id;
          ELSIF log_row.operation = 'UPDATE' THEN
             UPDATE courses SET name = log_row.name, professor = log_row.professor WHERE id = log_row.id;
          ELSE
             INSERT INTO courses (id, name, professor) VALUES (log_row.id, log_row.name, log_row.professor);
          END IF;
       END LOOP;
       DELETE FROM courses_log WHERE operation_time > p_time;
    END restore_courses;
    
    
	PROCEDURE restore_database(p_time IN TIMESTAMP)
    IS
    BEGIN
        restore_database_package.restore_students(p_time);
        restore_database_package.restore_groups(p_time);
        restore_database_package.restore_courses(p_time);
    END restore_database;
	
    
    PROCEDURE restore_database(time_mili IN INTEGER)
    AS
        v_time TIMESTAMP := CURRENT_TIMESTAMP - NUMTODSINTERVAL(time_mili / 1000, 'SECOND');
    BEGIN
        restore_database_package.restore_students(CURRENT_TIMESTAMP - NUMTODSINTERVAL(time_mili / 1000, 'SECOND'));
        restore_database_package.restore_groups(CURRENT_TIMESTAMP - NUMTODSINTERVAL(time_mili / 1000, 'SECOND'));
        restore_database_package.restore_courses(CURRENT_TIMESTAMP - NUMTODSINTERVAL(time_mili / 1000, 'SECOND'));
    END restore_database;
	
END restore_database_package;
/


-- Test Functionality

EXECUTE restore_database_package.restore_database(TO_TIMESTAMP('31.03.23 23:05:00.000000000', 'dd.mm.yy hh24:mi:ss.ff'));
EXECUTE restore_database_package.restore_database(60000);

SET SERVEROUTPUT ON;