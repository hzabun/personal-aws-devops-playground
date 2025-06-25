import os
import requests

from flask import Flask

app = Flask(__name__)

def get_instance_id():
    # Try querying the EC2 metadata endpoint
    try:
        # IMDSv2 token required for Amazon Linux 2/EKS AL2023
        token = requests.put(
            "http://169.254.169.254/latest/api/token",
            headers={"X-aws-ec2-metadata-token-ttl-seconds": "60"},
            timeout=1
        ).text
        instance_id = requests.get(
            "http://169.254.169.254/latest/meta-data/instance-id",
            headers={"X-aws-ec2-metadata-token": token},
            timeout=1
        ).text
        return instance_id
    except Exception as e:
        return f"Could not get instance ID: {e}"

@app.route("/")
def hello():
    pod_name = os.environ.get("POD_NAME", "unknown")
    pod_ip = os.environ.get("POD_IP", "unknown")
    node_name = os.environ.get("NODE_NAME", "unknown")
    node_ip = os.environ.get("NODE_IP", "unknown")
    instance_id = get_instance_id()
    return (
        f"<p>Hello from pod: {pod_name}</p>"
        f"<p>Pod IP: {pod_ip}</p>"
        f"<p>Node name: {node_name}</p>"
        f"<p>Node IP: {node_ip}</p>"
        f"<p>EC2 instance ID: {instance_id}</p>"
    )