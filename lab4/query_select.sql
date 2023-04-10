{"type": "SELECT", 
        "columns": ["students.id", "students.name", "groups.name"], 
        "tables": ["students"], 
        "join": {"type":"inner", "table": "groups","condition": "groups.id = students.group_id"}, 
        "filter": {"type": "base", "condition": "students.id > 10"}
        }
        
