-- INSERT
CREATE OR REPLACE PROCEDURE InsertTable(
  id_ in int,
  val_ in int
) AS
BEGIN
  INSERT INTO MYTABLE(id, val)
  VALUES (id_, val_);
END InsertTable;
EXEC InsertTable(30051, 2);

-- UPDATE
CREATE OR REPLACE PROCEDURE UpdateTable(
  id_ in int,
  val_ in int
) AS
BEGIN
  UPDATE MYTABLE
  SET val = val_
  WHERE id = id_;
END UpdateTable;
EXEC UpdateTable(30051, 2);

-- DELETE
CREATE OR REPLACE PROCEDURE DeleteTable(
  id_ in int
) AS
BEGIN
  DELETE FROM MYTABLE
  WHERE id = id_;
END DeleteTable;
EXEC DeleteTable(30051);