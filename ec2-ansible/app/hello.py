from flask import Flask

app = Flask(__name__)


# Print basic HTML message at root level
@app.route("/")
def hello_world():
    return "<p>Hello, World from my containerized Flask app!</p>"
