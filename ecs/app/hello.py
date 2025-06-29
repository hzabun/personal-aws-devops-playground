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

def get_container_info():
    metadata_uri = os.environ.get("ECS_CONTAINER_METADATA_URI_V4")
    if not metadata_uri:
        return "Metadata URI not found"
    try:
        response = requests.get(f"{metadata_uri}/task")
        response.raise_for_status()
        metadata = response.json()
        containers = metadata.get("Containers", [])
        if not containers:
            return "No container info found"
        # Show info for the first container (usually the current one)
        container = containers[0]
        name = container.get("Name", "N/A")
        docker_id = container.get("DockerId", "N/A")
        image = container.get("Image", "N/A")
        return f"Name: {name}, Docker ID: {docker_id}, Image: {image}"
    except Exception as e:
        return f"Error fetching container info: {str(e)}"

# Show basic HTML message at root level
@app.route("/")
def hello_world():
    task_id = get_task_id()
    container_info = get_container_info()
    return (
        f"<p>Hello, World from my containerized Flask app!</p>"
        f"<p>Task ID: {task_id}</p>"
        f"<p>Container Info: {container_info}</p>"
    )