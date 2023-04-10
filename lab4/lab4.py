from enum import Enum
import cx_Oracle
import argparse
import json

def select(query_dict):
    query_type = query_dict['type']
    query_columns = query_dict['columns']
    query_tables = query_dict['tables']
    query_join = query_dict.get('join', '')
    query_filter = query_dict.get('filter', '')

    # SELECT
    sql = f'{query_type} {", ".join(query_columns)} FROM {", ".join(query_tables)} '
    if query_join:
        sql += f'{query_join["type"].upper()} JOIN {query_join["table"]} ON {query_join["condition"]}'
    if query_filter:
        sql += condition(query_filter)
    return sql

def condition(query_filter):
    if query_filter["type"] == "base":
        return f' WHERE {query_filter["condition"]}'
    elif query_filter["type"] == "in":
        return f' WHERE {query_filter["variable"]} {query_filter["modifier"].upper()} ( {", ".join(query_filter["condition"])} )'
    elif query_filter["type"] == "exist":
        return f' WHERE {query_filter["modifier"].upper()} ( {select(query_filter["condition"])} )'
    else:
        raise ValueError("Invalid condition type.")


def dml(query_dict):
    query_type = query_dict['type']
    query_table = query_dict['table']

    # INSERT
    if query_type.upper() == "INSERT":
        query_columns = query_dict['columns']
        query_values = query_dict['values']
        sql = f"INSERT INTO {query_table} ({','.join(query_columns)})"
        if query_values['type'] == 'base':
            sql += " VALUES ("

            for item in query_values['values']:
                if type(item) is str:
                    sql += "'" + item + "'"
                elif type(item) is int:
                    sql += str(item)
                else:
                    raise ValueError("Invalid value passed to insert clause.")
                sql += ", "
            sql = sql[:-2]
            sql += ')'

            # for line in query_values['values']:
            #     sql += '('
            #     sql += ', '.join(["'" + str(n) + "'" for n in line])
            #     sql += ')'
            #     sql += ','
            # sql = sql[:-1]
        elif query_values['type'] == 'compound':
            sql += f" {select(query_values['values'])}"

    # UPDATE
    elif query_type == "UPDATE":
        query_values : dict = query_dict.get("values")
        query_filter = query_dict.get("filter")
        sql = f"UPDATE {query_table} SET "

        for k, v in query_values.items():
            if type(v) is str:
                sql += f"{k} = '{v}'"
            elif type(v) is int:
                sql += f"{k} = {str(v)}"
            else:
                raise ValueError("Invalid value passed to update clause.")
            sql += ", "
        sql = sql[:-2]

        if query_filter:
            sql += condition(query_filter)

    # DELETE
    elif query_type.upper() == "DELETE":
        query_filter = query_dict.get('filter', '')
        sql = f"DELETE FROM {query_table}"
        if query_filter:
            sql += condition(query_filter)
    
    # Non-existing type
    else:
        raise ValueError("Invalid query type.")

    return sql


def ddl(query_dict):
    query_type = query_dict.get("type")
    query_table = query_dict.get("table")

    # CREATE TABLE
    if query_type == "CREATE_TABLE":
        query_columns = query_dict.get("columns")
        column_definitions = ", ".join([f"{col['name']} {col['type']}" for col in query_columns])
        sql = f"CREATE TABLE {query_table} ({column_definitions})"
        query_id = None
        for col in query_columns:
            if col['name'] in 'id':
                query_id = col['name']
                break
        if query_id is None:
            raise TypeError("Column with id not found")
        sql_2 = """
CREATE OR REPLACE TRIGGER autoincrement_id_{}
BEFORE INSERT ON {}
FOR EACH ROW
DECLARE
    max_id NUMBER;
BEGIN
    SELECT MAX({}) INTO max_id FROM {};
    :NEW.{} := NVL(max_id, 0) + 1;
END;""".format(query_table, query_table, query_id, query_table, query_id)
        return [sql, sql_2]

    # DROP TABLE
    elif query_type == "DROP_TABLE":
        sql = f"DROP TABLE {query_table}"
    return sql


def exec(sql, connection_string):
    # Connect to the database and execute the SQL query
    if type(sql) is not list:
        sql = [sql]
    with cx_Oracle.connect(connection_string) as conn:
        cursor = conn.cursor()
        for query in sql:
            print(query)
            cursor.execute(query)
        print("Operation done")

        for row in cursor:
            print(row)
        # Return the cursor to the calling code
        return cursor


def execute(query_str: str):
    query_dict = json.loads(query_str)
    if query_dict['type'] in ['SELECT']:
        sql = select(query_dict)
    elif query_dict['type'] in ['INSERT', 'UPDATE', 'DELETE']:
        sql = dml(query_dict)
    elif query_dict['type'] in ['CREATE_TABLE', 'DROP_TABLE']:
        sql = ddl(query_dict)
    else:
        raise TypeError('Undefined type of operation')
    return sql


def main():
    connection_string = "imaksus/trailking201@172.28.0.2:1521/LAB1_PDB"
    parser = argparse.ArgumentParser()
    parser.add_argument('--file', type=str)
    args = parser.parse_args()
    with open(args.file) as f:
        query_str = f.read()
        print(query_str)
        sql = execute(query_str)
    # print(sql)
    cursor = exec(sql, connection_string)


if __name__ == "__main__":
    try:
        main()
    except cx_Oracle.InterfaceError:
        pass
    # # import cx_Oracle

    # dsn_tns = cx_Oracle.makedsn('172.28.0.2', '1521', service_name='LAB1_PDB') # if needed, place an 'r' before any parameter in order to address special characters such as '\'.
    # conn = cx_Oracle.connect(user='imaksus', password='trailking201', dsn=dsn_tns) # if needed, place an 'r' before any parameter in order to address special characters such as '\'. For example, if your user name contains '\', you'll need to place 'r' before the user name: user=r'User Name'

    # c = conn.cursor()
    # c.execute('select * from imaksus.students') # use triple quotes if you want to spread your query across multiple lines
    # for row in c:
    #     print (row[0], '-', row[1]) # this only shows the first two columns. To add an additional column you'll need to add , '-', row[2], etc.
    # #conn.close()


    # # Выбирает студентов с id > 10
    # query_select = """
    #     {"type": "SELECT", 
    #     "columns": ["students.id", "students.name", "groups.name"], 
    #     "tables": ["students"], 
    #     "join": {"type":"inner", "table": "groups","condition": "groups.id = students.group_id"}, 
    #     "filter": {"type": "base", "condition": "id > 10"}
    #     }
    # """
    # # Выбирает студентов с именем Vasya либо Petya
    # query_existance_where = """
    #     {"type": "SELECT", 
    #     "columns": ["students.id", "students.name", "groups.name"], 
    #     "tables": ["students"], 
    #     "join": {"type":"inner", "table": "groups","condition": "groups.id = students.group_id"}, 
    #     "filter": {"type": "in", "modifier": "in", "variable": "students.name", "condition": ["Vasya", "Petya"]}
    #     }
    # """
    # # Выбирает студентов у которых определена группа
    # query_compound_where = """
    #     {"type": "SELECT", 
    #     "columns": ["id", "name"], 
    #     "tables": ["students"], 
    #     "filter": {"type": "exist", "modifier": "exists", "condition": 
    #         {"type": "SELECT",
    #         "columns": ["*"], 
    #         "tables": ["groups"], 
    #         "filter": {"type": "base", "condition": "groups.id = students.group_id"}
    #         }
    #     }
    #     }
    # """
    # # Вставляет студентов (base)
    # # ** множество значение 
    # # (INSERT INTO students (name, group_id) VALUES ('John', 1), ('Jane', 2), ('Mark', 1);)
    # # невозможно реализовать в oracle походу (вылетает ошибка ORA-00933: SQL command not properly ended)
    # query_insert_base = """
    #     {"type": "INSERT", 
    #     "columns": ["name", "group_id"], 
    #     "table": "students",
    #     "values": {"type":"base", "values": ["Nikolaj", 3]}
    #     }
    # """
    # # Update (base)
    # query_update_base = """
    #     {"type": "UPDATE", 
    #     "columns": ["name", "group_id"], 
    #     "table": "students",
    #     "values": {"name": "Nikolaj", "group_id": 3},
    #     "filter": {"type": "base", "condition": "id > 10"}
    #     }
    # """
    # # Update (in)
    # query_update_in = """
    #     {"type": "UPDATE", 
    #     "columns": ["name", "group_id"], 
    #     "table": "students",
    #     "values": {"name": "Nikolaj", "group_id": 3},
    #     "filter": {"type": "in", "modifier": "in", "variable": "students.name", "condition": ["Vasya", "Petya"]}
    #     }
    # """
    # # Update (exist)
    # query_update_exist = """
    #     {"type": "UPDATE", 
    #     "table": "students",
    #     "values": {"name": "Nikolaj", "group_id": 3},
    #     "filter": {"type": "exist", "modifier": "exists", "condition": 
    #         {"type": "SELECT",
    #         "columns": ["*"], 
    #         "tables": ["groups"], 
    #         "filter": {"type": "base", "condition": "groups.id = students.group_id"}
    #         }
    #     }
    #     }
    # """
    # # Delete
    # query_delete = """
    #     {"type": "DELETE", 
    #     "table": "students",
    #     "values": {"name": "Nikolaj", "group_id": 3},
    #     "filter": {"type": "exist", "modifier": "exists", "condition": 
    #         {"type": "SELECT",
    #         "columns": ["*"], 
    #         "tables": ["groups"], 
    #         "filter": {"type": "base", "condition": "groups.id = students.group_id"}
    #         }
    #     }
    #     }
    # """
    # # Create table
    # query_create_table = """
    # {"type": "CREATE_TABLE",
    # "table": "students",
    # "columns": [
    #     {"name": "id", "type": "NUMBER"},
    #     {"name": "name", "type": "VARCHAR2(50)"},
    #     {"name": "group_id", "type": "NUMBER"}
    #     ]
    # }
    # """
    # # Drop table
    # query_drop_table = """
    # {"type": "DROP_TABLE",
    # "table": "students",
    # "filter": {"type": "base", "condition": "id > 10"}}
    # """