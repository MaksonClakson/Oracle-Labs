CREATE TABLE students
(
    id NUMBER(10) NOT NULL,
    name VARCHAR2(50) NOT NULL,
    group_id NUMBER(10) NOT NULL
);

CREATE TABLE groups
(
    id NUMBER(10) NOT NULL,
    name VARCHAR2(50) NOT NULL,
    students_count NUMBER(10) NOT NULL
);