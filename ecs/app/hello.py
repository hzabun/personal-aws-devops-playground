from flask import Flask
import os
import requests

app = Flask(__name__)

def get_task_id():
    metadata_uri = os.environ.get("ECS_CONTAINER_METADATA_URI_V4")
    if not metadata_uri:
        return "Metadata URI not found"
    
    try:
        response = requests.get(f"{metadata_uri}/task")
        response.raise_for_status()
        metadata = response.json()
        return metadata.get("TaskARN", "Task ARN not found").split("/")[-1]  # Extract Task ID from ARN
    except Exception as e:
        return f"Error fetching task metadata: {str(e)}"

# Show basic HTML message at root level
@app.route("/")
def hello_world():
    task_id = get_task_id()
    return f"<p>Hello, World from my containerized Flask app!</p><p>Task ID: {task_id}</p>"