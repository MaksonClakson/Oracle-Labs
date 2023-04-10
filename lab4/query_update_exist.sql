{"type": "UPDATE", 
        "table": "students",
        "values": {"name": "Nikolaj", "group_id": 3},
        "filter": {"type": "exist", "modifier": "exists", "condition": 
            {"type": "SELECT",
            "columns": ["*"], 
            "tables": ["groups"], 
            "filter": {"type": "base", "condition": "groups.id = students.group_id"}
            }
        }
        }
