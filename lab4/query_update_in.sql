{"type": "UPDATE", 
        "columns": ["name", "group_id"], 
        "table": "students",
        "values": {"name": "Nikolaj", "group_id": 3},
        "filter": {"type": "in", "modifier": "in", "variable": "students.name", "condition": ["Vasya", "Petya"]}
        }
