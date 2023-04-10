{"type": "SELECT", 
        "columns": ["id", "name"], 
        "tables": ["students"], 
        "filter": {"type": "exist", "modifier": "exists", "condition": 
            {"type": "SELECT",
            "columns": ["*"], 
            "tables": ["groups"], 
            "filter": {"type": "base", "condition": "groups.id = students.group_id"}
            }
        }
        }
